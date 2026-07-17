-- Identificar el lote de facturas
DECLARE @Pendientes TABLE (id Nvarchar(50));
INSERT INTO @Pendientes SELECT TOP 100 NumFactura FROM (
    SELECT NumFactura, 0 AS priority, FechaFactura
    FROM KLK_FACTURAHDR
    WHERE EnviadoASAP = 0 AND LogErrorIntegrador IS NULL
    UNION ALL
    SELECT NumFactura, 1 AS priority, FechaFactura
    FROM KLK_FACTURAHDR
    WHERE EnviadoASAP = 0 AND LogErrorIntegrador IS NOT NULL
) AS sub ORDER BY priority ASC, FechaFactura ASC;

-- RESULTSET [0]: Cabeceras
SELECT 
    F.NumFactura as external_ref,
    --(SELECT TOP 1 T.ObjType FROM KLK_FACTURALINE L WITH (NOLOCK)
    -- INNER JOIN KLK_TIPO_DOCUMENTO_AUDITORIA T WITH (NOLOCK) ON L.CodigoAlmacen = T.CodigoAlmacen
    -- WHERE L.NumFactura = F.NumFactura) AS picking_type_id,
    F.CodCliente AS partner_vat, C.NomCliente AS partner_name, C.Correo AS partner_email,
    C.Telefono AS partner_phone, C.Direccion AS partner_adress,
    upper(C.Agente) As agente_retencion, C.Tasa as porcentaje_retencion, F.FechaFactura AS [fecha_factura],f.Hora as hora_factura, 
	F.TasaUSD as currency_rate,
    NumTicketFiscal as nro_ctrl_fiscal, NCorteZ as nro_ctrl_fiscal_z,
    F.FacturaACredito as factura_credito, C.DiasCredito as dias_credito
FROM KLK_FACTURAHDR F WITH (NOLOCK)
INNER JOIN KLK_CLIENTE C WITH (NOLOCK) ON F.CodCliente = C.CodCliente
WHERE F.NumFactura IN (SELECT id FROM @Pendientes);

-- RESULTSET [1]: Líneas
SELECT NumFactura, CodArticulo AS product_id, Cantidad AS qty,
    -- TotalDespDescuentosUsd/Cantidad  AS price_unit  -- query en usd
    TotalDespDescuentos/Cantidad  AS price_unit,  -- query en bs
    CodigoAlmacen AS warehouse_code
FROM KLK_FACTURALINE WITH (NOLOCK)
WHERE NumFactura IN (SELECT id FROM @Pendientes);

-- RESULTSET [2]: Pagos
SELECT CL.NFactura AS NumFactura, PC.CodigoCuenta AS journal_id, PC.DescripcionCuenta AS journal_name, 
    -- CL.MontoUsd AS amount -- query en usd
    CL.Monto AS amount,  -- query en bs
    CL.FormadePago, CL.NTransaccion as nro_referencia, CL.TarjetaCredito as nro_lote,
    CASE WHEN CL.FormadePago = 'Pago Nota de crédito' THEN 1 ELSE 0 END AS es_nota_credito
FROM KLK_COBROLINE CL WITH (NOLOCK)
JOIN KLK_SAP_PLANDECUENTA PC ON CL.CuentaSAP = PC.CodigoCuenta
WHERE CL.NFactura IN (SELECT id FROM @Pendientes);


-- Identificar el lote de notas de credito
DECLARE @PendientesNota TABLE (id Nvarchar(50));
INSERT INTO @PendientesNota SELECT TOP 100 NumNota FROM (
    SELECT NumNota, 0 AS priority, FechaNota
    FROM KLK_NCREDITOHDR
    WHERE EnviadoASAP = 0 AND LogErrorIntegrador IS NULL
    UNION ALL
    SELECT NumNota, 1 AS priority, FechaNota
    FROM KLK_NCREDITOHDR
    WHERE EnviadoASAP = 0 AND LogErrorIntegrador IS NOT NULL
) AS sub ORDER BY priority ASC, FechaNota ASC;

-- RESULTSET [0]: Cabeceras
SELECT 
    F.NumNota AS external_ref, F.facturaafectada as external_ref_factura,
    --(SELECT TOP 1 T.ObjType FROM KLK_NCREDITOLINE L WITH (NOLOCK)
    -- INNER JOIN KLK_TIPO_DOCUMENTO_AUDITORIA T WITH (NOLOCK) ON L.CodigoAlmacen = T.CodigoAlmacen
    -- WHERE L.NumNota = F.NumNota) AS picking_type_id,
    F.CodCliente AS partner_vat, C.NomCliente AS partner_name, C.Correo AS partner_email,
    C.Telefono AS partner_phone, C.Direccion AS partner_adress,
    upper(C.Agente) As agente_retencion, C.Tasa as porcentaje_retencion, F.FechaFactura AS [fecha_factura],f.Hora as hora_factura, 
    F.TasaUSD as currency_rate,
    NumTicketFiscal as nro_ctrl_fiscal, NCorteZ as nro_ctrl_fiscal_z
FROM KLK_NCREDITOHDR F WITH (NOLOCK)
INNER JOIN KLK_CLIENTE C WITH (NOLOCK) ON F.CodCliente = C.CodCliente
WHERE F.NumNota IN (SELECT id FROM @PendientesNota);

-- RESULTSET [1]: Líneas
SELECT NumNota, CodArticulo AS product_id, Cantidad AS qty,
    -- TotalDespDescuentosUsd/Cantidad  AS price_unit  -- query en usd
    TotalDespDescuentos/Cantidad  AS price_unit,  -- query en bs
    CodigoAlmacen AS warehouse_code
FROM KLK_NCREDITOLINE WITH (NOLOCK)
WHERE NumNota IN (SELECT id FROM @PendientesNota);

SELECT RCL.NroRecibo AS Recibo_id, CL.NFactura AS NumFactura, PC.CodigoCuenta AS journal_id, PC.DescripcionCuenta AS journal_name, 
     --CL.MontoUsd AS amount, -- query en usd
    CL.Monto AS amount,  -- query en bs
    CL.FormadePago, CL.NTransaccion as nro_referencia, CL.TarjetaCredito as nro_lote,
    CASE WHEN CL.FormadePago = 'Pago Nota de crédito' THEN 1 ELSE 0 END AS es_nota_credito,
    C.DiasCredito
FROM KLK_RECIBOCOBROLINE RCL WITH (NOLOCK)
join KLK_COBROLINE CL on RCL.NroCobro = CL.NroCobro and CL.Monto = RCL.TotalAbonado
JOIN KLK_SAP_PLANDECUENTA PC ON CL.CuentaSAP = PC.CodigoCuenta
JOIN KLK_FACTURAHDR F ON CL.NFactura = F.NumFactura
JOIN KLK_CLIENTE C ON F.CodCliente = C.CodCliente
WHERE RCL.EnviadoASAP = 0;
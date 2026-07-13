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
    F.NumFactura AS id,
    (SELECT TOP 1 T.ObjType FROM KLK_FACTURALINE L WITH (NOLOCK)
     INNER JOIN KLK_TIPO_DOCUMENTO_AUDITORIA T WITH (NOLOCK) ON L.CodigoAlmacen = T.CodigoAlmacen
     WHERE L.NumFactura = F.NumFactura) AS picking_type_id,
    F.CodCliente AS partner_vat, C.NomCliente AS partner_name, C.Correo AS partner_email,
    C.Telefono AS partner_phone, C.Direccion AS partner_street,
    C.Agente, C.Tasa,
    F.NumFactura AS external_ref, F.FechaFactura AS date, 
    F.TasaUSD as nx_rate, F.TasaUSD as currency_rate,
    NumTicketFiscal as nx_nro_ctrl, NCorteZ as nx_fiscal_printer_invoice_number_z,
    F.FacturaACredito, C.DiasCredito
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
SELECT CL.NFactura AS NumFactura, PC.IdFPagoSAP AS journal_id, PC.IdFPagoSAP AS journal_code, 
    -- CL.MontoUsd AS amount -- query en usd
    CL.Monto AS amount,  -- query en bs
    CL.FormadePago, CL.NTransaccion, CL.TarjetaCredito,
    CASE WHEN CL.FormadePago = 'Pago Nota de crédito' THEN 1 ELSE 0 END AS es_nota_credito
FROM KLK_COBROLINE CL WITH (NOLOCK)
JOIN KLK_SAP_PLANDECUENTA PC ON CL.CuentaSAP = PC.CodigoCuenta
WHERE CL.NFactura IN (SELECT id FROM @Pendientes);

-- Identificar el lote de facturas
-- CORRECCIÓN: Agregar IDSucursal a la tabla temporal
DECLARE @Pendientes TABLE (IDSucursal Nvarchar(50), NumFactura Nvarchar(50));

INSERT INTO @Pendientes (IDSucursal, NumFactura)
SELECT TOP 100 IDSucursal, NumFactura FROM (
    SELECT IDSucursal, NumFactura, 0 AS priority, FechaFactura
    FROM KLK_FACTURAHDR
    WHERE EnviadoASAP = 0 AND LogErrorIntegrador IS NULL
    UNION ALL
    SELECT IDSucursal, NumFactura, 1 AS priority, FechaFactura
    FROM KLK_FACTURAHDR
    WHERE EnviadoASAP = 0 AND LogErrorIntegrador IS NOT NULL
) AS sub 
ORDER BY priority ASC, FechaFactura ASC;

-- RESULTSET [0]: Cabeceras
SELECT 
    F.IDSucursal + '-' + F.NumFactura AS id,    
    (
     SELECT TOP 1 T.ObjType 
     FROM KLK_FACTURALINE L WITH (NOLOCK)
     INNER JOIN KLK_TIPO_DOCUMENTO_AUDITORIA T WITH (NOLOCK) ON L.CodigoAlmacen = T.CodigoAlmacen
     -- CORRECCIÓN: Agregar IDSucursal al cruce de la subconsulta
     WHERE L.NumFactura = F.NumFactura AND L.IDSucursal = F.IDSucursal
    ) AS picking_type_id,
    F.CodCliente AS partner_vat, C.NomCliente AS partner_name, C.Correo AS partner_email,
    C.Telefono AS partner_phone, C.Direccion AS partner_street,
    C.Agente, C.Tasa,
    F.Error as serial_impresora,
    F.IDSucursal + '-' + F.NumFactura AS external_ref, F.FechaFactura AS date, 
    F.TasaUSD as nx_rate, F.TasaUSD as currency_rate,
    F.NumTicketFiscal as nro_ctrl,
    F.Error as nx_nro_ctrl, NCorteZ as nx_fiscal_printer_invoice_number_z,
    F.FacturaACredito, 
    IIF(F.FacturaACredito = 1, C.DiasCredito, 0) as DiasCredito
FROM KLK_FACTURAHDR F WITH (NOLOCK)
INNER JOIN KLK_CLIENTE C WITH (NOLOCK) ON F.CodCliente = C.CodCliente
-- CORRECCIÓN: Hacer JOIN con la tabla temporal usando ambas columnas
INNER JOIN @Pendientes P ON F.IDSucursal = P.IDSucursal AND F.NumFactura = P.NumFactura;


-- RESULTSET [1]: Líneas
SELECT 
    L.IDSucursal + '-' + L.NumFactura as NumFactura, 
    L.CodArticulo AS product_id, 
    L.Cantidad AS qty,
    -- TotalDespDescuentosUsd/Cantidad  AS price_unit  -- query en usd
    L.TotalDespDescuentos/L.Cantidad  AS price_unit,  -- query en bs
    L.CodigoAlmacen AS warehouse_code
FROM KLK_FACTURALINE L WITH (NOLOCK)
-- CORRECCIÓN: Hacer JOIN con la tabla temporal usando ambas columnas
INNER JOIN @Pendientes P ON L.IDSucursal = P.IDSucursal AND L.NumFactura = P.NumFactura;


-- RESULTSET [2]: Pagos
SELECT 
    CL.IDSucursal + '-' + CL.NFactura AS NumFactura, 
    PC.CodigoCuenta as CodCuenta,
    D.JournalId AS journal_id, 
    D.JournalId AS journal_code, 
    -- CL.MontoUsd AS amount -- query en usd
    CL.Monto AS amount,  -- query en bs
    CL.FormadePago, CL.NTransaccion, CL.TarjetaCredito,
    CASE WHEN CL.FormadePago = 'Pago Nota de crédito' THEN 1 ELSE 0 END AS es_nota_credito
FROM KLK_COBROLINE CL WITH (NOLOCK)
JOIN KLK_SAP_PLANDECUENTA PC ON CL.CuentaSAP = PC.CodigoCuenta
LEFT JOIN KLK_SAP_DIARIO D ON PC.CodigoCuenta = D.CodigoCuenta
-- CORRECCIÓN: Hacer JOIN con la tabla temporal usando ambas columnas
INNER JOIN @Pendientes P ON CL.IDSucursal = P.IDSucursal AND CL.NFactura = P.NumFactura;
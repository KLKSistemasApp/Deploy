-- Identificar el lote de facturas
DECLARE @Pendientes TABLE (id Nvarchar(50));
INSERT INTO @Pendientes SELECT TOP 100 NumFactura FROM KLK_FACTURAHDR WHERE EnviadoASAP = 0 ORDER BY FechaFactura ASC;

-- RESULTSET [0]: Cabeceras
SELECT 
    F.NumFactura AS id,
    (SELECT TOP 1 T.ObjType FROM KLK_FACTURALINE L WITH (NOLOCK)
     INNER JOIN KLK_TIPO_DOCUMENTO_AUDITORIA T WITH (NOLOCK) ON L.CodigoAlmacen = T.CodigoAlmacen
     WHERE L.NumFactura = F.NumFactura) AS picking_type_id,
    F.CodCliente AS partner_vat, C.NomCliente AS partner_name, C.Correo AS partner_email,
    C.Telefono AS partner_phone, C.Direccion AS partner_street,
    F.NumFactura AS external_ref, F.FechaFactura AS date, 
    F.TasaUSD as nx_rate, F.TasaUSD as currency_rate,
    NumTicketFiscal as nx_nro_ctrl, NCorteZ as nx_fiscal_printer_invoice_number_z
FROM KLK_FACTURAHDR F WITH (NOLOCK)
INNER JOIN KLK_CLIENTE C WITH (NOLOCK) ON F.CodCliente = C.CodCliente
WHERE F.NumFactura IN (SELECT id FROM @Pendientes);

-- RESULTSET [1]: Líneas
SELECT NumFactura, CodArticulo AS product_id, Cantidad AS qty,
    -- TotalDespDescuentosUsd/Cantidad  AS price_unit  -- query en usd
    TotalDespDescuentos/Cantidad  AS price_unit  -- query en bs
FROM KLK_FACTURALINE WITH (NOLOCK)
WHERE NumFactura IN (SELECT id FROM @Pendientes);

-- RESULTSET [2]: Pagos
SELECT CL.NFactura AS NumFactura, PC.IdFPagoSAP AS journal_id, PC.IdFPagoSAP AS journal_code, 
    -- CL.MontoUsd AS amount -- query en usd
    CL.Monto AS amount  -- query en bs
FROM KLK_COBROLINE CL WITH (NOLOCK)
JOIN KLK_SAP_PLANDECUENTA PC ON CL.CuentaSAP = PC.CodigoCuenta
WHERE CL.NFactura IN (SELECT id FROM @Pendientes);

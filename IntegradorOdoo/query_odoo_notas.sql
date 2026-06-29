-- Identificar el lote de notas de credito
DECLARE @Pendientes TABLE (id Nvarchar(50));
INSERT INTO @Pendientes SELECT TOP 100 NumNota FROM KLK_NCREDITOHDR WHERE EnviadoASAP = 0 ORDER BY FechaNota ASC;

-- RESULTSET [0]: Cabeceras
SELECT 
    F.NumNota AS id, F.facturaafectada,
    (SELECT TOP 1 T.ObjType FROM KLK_NCREDITOLINE L WITH (NOLOCK)
     INNER JOIN KLK_TIPO_DOCUMENTO_AUDITORIA T WITH (NOLOCK) ON L.CodigoAlmacen = T.CodigoAlmacen
     WHERE L.NumNota = F.NumNota) AS picking_type_id,
    F.CodCliente AS partner_vat, C.NomCliente AS partner_name, C.Correo AS partner_email,
    C.Telefono AS partner_phone, C.Direccion AS partner_street,
    C.Agente, C.Tasa,
    F.NumNota AS external_ref, F.FechaFactura AS date, 
    F.TasaUSD as nx_rate, F.TasaUSD as currency_rate,
    NumTicketFiscal as nx_nro_ctrl, NCorteZ as nx_fiscal_printer_invoice_number_z
FROM KLK_NCREDITOHDR F WITH (NOLOCK)
INNER JOIN KLK_CLIENTE C WITH (NOLOCK) ON F.CodCliente = C.CodCliente
WHERE F.NumNota IN (SELECT id FROM @Pendientes);

-- RESULTSET [1]: Líneas
SELECT NumNota, CodArticulo AS product_id, Cantidad AS qty,
    -- TotalDespDescuentosUsd/Cantidad  AS price_unit  -- query en usd
    TotalDespDescuentos/Cantidad  AS price_unit  -- query en bs
FROM KLK_NCREDITOLINE WITH (NOLOCK)
WHERE NumNota IN (SELECT id FROM @Pendientes);
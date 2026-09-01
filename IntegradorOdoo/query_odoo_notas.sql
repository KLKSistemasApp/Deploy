-- Identificar el lote de notas de credito
-- CORRECCIÓN: Agregar IDSucursal a la tabla temporal
DECLARE @Pendientes TABLE (IDSucursal Nvarchar(50), NumNota Nvarchar(50));

INSERT INTO @Pendientes (IDSucursal, NumNota)
SELECT TOP 100 IDSucursal, NumNota FROM (
    SELECT IDSucursal, NumNota, 0 AS priority, FechaNota
    FROM KLK_NCREDITOHDR
    WHERE EnviadoASAP = 0 AND LogErrorIntegrador IS NULL
    UNION ALL
    SELECT IDSucursal, NumNota, 1 AS priority, FechaNota
    FROM KLK_NCREDITOHDR
    WHERE EnviadoASAP = 0 AND LogErrorIntegrador IS NOT NULL
) AS sub 
ORDER BY priority ASC, FechaNota ASC;

-- RESULTSET [0]: Cabeceras
SELECT 
    -- CORRECCIÓN: Se concatena la sucursal para evitar IDs duplicados en el destino
    F.IDSucursal + '-' + F.NumNota AS id, 
    F.IDSucursal + '-' + F.facturaafectada AS facturaafectada,
    (
     SELECT TOP 1 T.ObjType 
     FROM KLK_NCREDITOLINE L WITH (NOLOCK)
     INNER JOIN KLK_TIPO_DOCUMENTO_AUDITORIA T WITH (NOLOCK) ON L.CodigoAlmacen = T.CodigoAlmacen
     -- CORRECCIÓN: Agregar IDSucursal al cruce de la subconsulta
     WHERE L.NumNota = F.NumNota AND L.IDSucursal = F.IDSucursal
    ) AS picking_type_id,
    F.CodCliente AS partner_vat, C.NomCliente AS partner_name, C.Correo AS partner_email,
    C.Telefono AS partner_phone, C.Direccion AS partner_street,
    C.Agente, C.Tasa, C.DiasCredito,
    F.Error as serial_impresora,
    F.IDSucursal + '-' + F.NumNota AS external_ref, F.FechaFactura AS date, 
    F.TasaUSD as nx_rate, F.TasaUSD as currency_rate,
    F.NumTicketFiscal as nro_ctrl,
    F.Error as nx_nro_ctrl,NCorteZ as nx_fiscal_printer_invoice_number_z
FROM KLK_NCREDITOHDR F WITH (NOLOCK)
INNER JOIN KLK_CLIENTE C WITH (NOLOCK) ON F.CodCliente = C.CodCliente
-- CORRECCIÓN: Usar INNER JOIN con la tabla temporal (llave compuesta)
INNER JOIN @Pendientes P ON F.IDSucursal = P.IDSucursal AND F.NumNota = P.NumNota;


-- RESULTSET [1]: Líneas
SELECT 
    -- CORRECCIÓN: Concatenar la sucursal al igual que en facturas
    L.IDSucursal + '-' + L.NumNota as NumNota, 
    L.CodArticulo AS product_id, 
    L.Cantidad AS qty,
    -- L.TotalDespDescuentosUsd/L.Cantidad  AS price_unit  -- query en usd
    L.TotalDespDescuentos/L.Cantidad  AS price_unit,  -- query en bs
    L.CodigoAlmacen AS warehouse_code
FROM KLK_NCREDITOLINE L WITH (NOLOCK)
-- CORRECCIÓN: Usar INNER JOIN con la tabla temporal (llave compuesta)
INNER JOIN @Pendientes P ON L.IDSucursal = P.IDSucursal AND L.NumNota = P.NumNota;
SELECT TOP 1
    p.TasaDolar,
    p.CodListaPrecio,
    pa.CodigoAlmacen,
    p.PuertoLibreImpuesto,
    CASE
        WHEN p.PuertoLibreImpuesto = 1 THEN (
            SELECT TOP 1 CodigoImpuesto
            FROM KLK_SAP_IMPUESTOS
            WHERE PorcImpuesto = 0
        )
        ELSE '0'
    END AS impuesto
FROM
    KLK_PARAMETRIZACION p
INNER JOIN
    KLK_PARAMETRIZACION_ALMACENES pa ON pa.AlmacenPrincipal = 1
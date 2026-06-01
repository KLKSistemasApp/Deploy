MERGE KLK_SAP_BARRAS AS DESTINO
    USING (
    SELECT CodArticulo, CodBarra, Id_UndMd FROM (
        VALUES {VALUES_CHUNK}
    ) AS T (CodArticulo, CodBarra, Id_UndMd)
    WHERE T.CodArticulo IS NOT NULL -- Aquí está el filtro legal
) AS ORIGEN
    ON DESTINO.CodArticulo = ORIGEN.CodArticulo
       AND DESTINO.CodBarra = ORIGEN.CodBarra
       AND DESTINO.Id_UndMd = ORIGEN.Id_UndMd
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (CodArticulo, CodBarra, Id_UndMd)
        VALUES (ORIGEN.CodArticulo, ORIGEN.CodBarra, ORIGEN.Id_UndMd)

    WHEN NOT MATCHED BY SOURCE AND DESTINO.CodArticulo = @CodArticulo THEN
        DELETE
    ;
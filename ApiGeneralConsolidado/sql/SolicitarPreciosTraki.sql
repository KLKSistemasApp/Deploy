SELECT   '01' AS PriceList,
    c_Codigo AS ItemCode,
   CAST(ISNULL(n_precio1, 0) AS decimal(19, 6))  AS Price
FROM VAD20.DBO.MA_PRODUCTOS
WHERE c_Codigo IN (SELECT value FROM OPENJSON(@CodArticulo))

UNION ALL

SELECT 
    '02' AS PriceList,
    c_Codigo AS ItemCode,
    CAST(ISNULL(n_Precio2, 0) AS decimal(19, 6)) AS Price
FROM VAD20.DBO.MA_PRODUCTOS
WHERE c_Codigo IN (SELECT value FROM OPENJSON(@CodArticulo))

UNION ALL

SELECT 
    '03' AS PriceList,
    c_Codigo AS ItemCode,
    CAST(ISNULL(n_Precio3, 0) AS decimal(19, 6)) AS Price
FROM VAD20.DBO.MA_PRODUCTOS
WHERE c_Codigo IN (SELECT value FROM OPENJSON(@CodArticulo))
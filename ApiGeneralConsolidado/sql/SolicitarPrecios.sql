SELECT 
  OITM.ItemCode,
  ITM1.Price,
  ITM1.PriceList
FROM OITM
INNER JOIN ITM1 ON OITM.ItemCode = ITM1.ItemCode
INNER JOIN OPLN ON ITM1.PriceList = OPLN.ListNum
WHERE ITM1.PriceList IN (SELECT value FROM OPENJSON(@CodListaPrecio))
  AND OITM.ItemCode IN (SELECT value FROM OPENJSON(@CodArticulo))
ORDER BY ITM1.PriceList, OITM.ItemCode;

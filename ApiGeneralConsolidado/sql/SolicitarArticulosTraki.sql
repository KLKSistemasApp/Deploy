SELECT DISTINCT
    ART.c_Codigo AS ItemCode,
    ART.c_Descri AS ItemName,
    ART.c_Grupo AS ItmsGrpCod,
    1 AS PriceList, -- Hardcoded: Lista de precios por defecto
    ART.c_Codigo AS CodBarra, -- Usamos el código como código de barra por defecto
    cast (ISNULL(ART.n_Precio1, 0) as decimal(19, 6)) AS Price, -- Tomamos Precio1 como el principal
   'A6' AS TaxCodeAR, -- Hardcoded
    n_Impuesto1 AS PorcImpueto,
    0 AS U_Tipo_umv, -- Hardcoded
    '0001' AS CodigoAlmacenDefault, -- Hardcoded
    'Y' AS invntItem, -- ¡CAMBIADO A 'Y'! Así coincide con tu mapeo JS e["invntItem"] == "Y"
    ISNULL(GR.C_DESCRIPCIO, 'N/A') AS ItmsGrpNam,
    CAST(0 AS decimal(19, 6)) AS onhand, 
    1 AS U_POS_TIPO_DIST, -- Hardcoded
    'Y' AS VATLiable, -- Hardcoded (Sujeto a impuesto)
    'N' AS ManSerNum, -- Hardcoded: Serial NO
    'Y' AS SellItem, -- ¡CAMBIADO A 'Y'! Para que e["SellItem"] == "Y" sea True
    'Y' AS PrchseItem, -- ¡CAMBIADO A 'Y'! Para que e["PrchseItem"] == "Y" sea True
    'N' AS frozenFor, -- Hardcoded (No inactivo)
    'N' AS frozenFor, -- Hardcoded (No inactivo)
    'NO' AS Pesable, -- Hardcoded
    'UND' AS SalUnitMsr, -- Hardcoded
    cast (1 as decimal(19, 6)) AS NumInSale, -- Hardcoded: Factor 1
    'N/A' AS Categoria,
    'N/A' AS NomCategoria,
    'N/A' AS Tipo,
    'N/A' AS NomTipo,
    'N/A' AS Composicion,
    'N/A' AS NomComposicion,
    'N/A' AS FormGeom,
    'N/A' AS NomFormGeom,
    'N/A' AS Textura,
    'N/A' AS NomTextura,
    'N/A' AS DescAdicional,
    'N/A' AS Color,
    'N/A' AS NomColor,
    'N/A' AS Medida,
    'N/A' AS UNMED,
    'N/A' AS CBM,
    'UND' AS BuyUnitMsr, -- Hardcoded
    cast (1 as decimal(19, 6)) AS NumInBuy, -- Hardcoded
    'UND' AS UgpCode, -- Hardcoded
    0 AS FirmCode,
    ISNULL(ART.c_Marca, 'N/A') AS FirmName, -- Colocamos la marca de VAD aquí
    ART.c_CodMoneda AS Currency,
    ART.c_CodMoneda AS PrimCurr,
    'N' AS U_PRECIOFIJO,
    ISNULL(ART.c_Subgrupo, 'N/A') AS SubGrupo,
    ISNULL(SGR.c_DESCRIPCIO, 'N/A') AS NomSubGrupo,
    ISNULL(ART.c_Departamento, 'N/A') AS Departamento,
    ISNULL(DR.C_DESCRIPCIO, 'N/A') AS NomDepartamento,
     cast (ISNULL(ART.n_CostoAct, 0) as decimal(19, 6)) AS LastPurPrc, -- Costo actual como último precio de compra
    ART.c_CodMoneda AS LastPurCur
FROM VAD20.DBO.MA_PRODUCTOS ART
LEFT JOIN VAD10.DBO.MA_GRUPOS GR 
    ON GR.c_CODIGO = ART.C_GRUPO 
LEFT JOIN VAD10.DBO.MA_DEPARTAMENTOS DR 
    ON dr.c_CODIGO = ART.c_Departamento 
LEFT JOIN VAD10.DBO.MA_SUBGRUPOS SGR 
    ON SGR.c_CODIGO = ART.c_Subgrupo
    where ART.c_Codigo in (SELECT value FROM OPENJSON(@CodArticulo))
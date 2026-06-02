select distinct OITM.ItemCode,oitm.ItemName,oitm.ItmsGrpCod, itm1.PriceList,
        ISNULL(oitm.CodeBars,OITM.ItemCode) as CodBarra, ISNULL(itm1.Price,0) Price, IIF(oitm.TaxCodeAR Is Null or LEN(oitm.TaxCodeAR)=0,'IVA',oitm.TaxCodeAR) TaxCodeAR, 
        ISNULL(OSTA.Rate,16) PorcImpueto,ISNULL(U_tipo_umv,0) U_Tipo_umv, 
        '01' CodigoAlmacenDefault, OITM.invntItem, oitb.ItmsGrpNam, oitm.onhand,
	    isnull(U_POS_TIPO_DIST,1) U_POS_TIPO_DIST,oitm.VATLiable,ManSerNum,
	    OITM.SellItem,OITM.PrchseItem,OITM.frozenFor,
	    (IIF(U_Pesable Is Null or LEN(U_Pesable)=0,'NO',U_Pesable)) Pesable,
	    ISNULL(OITM.SalUnitMsr,'UND') SalUnitMsr,
	    ISNULL(OITM.NumInSale,1) NumInSale,
	    (IIF(U_CAT Is Null or LEN(U_CAT)=0,'N/A',U_CAT)) Categoria,
		(IIF(U_CAT Is Null or LEN(U_CAT)=0,'N/A',(CAT.Name))) NomCategoria,
	    (IIF(U_NIV_I Is Null or LEN(U_NIV_I)=0,'N/A',U_NIV_I)) Tipo,
	    (IIF(U_NIV_I Is Null or LEN(U_NIV_I)=0,'N/A',(TIP.Name ))) NomTipo,
	    (IIF(U_NIV_II Is Null or LEN(U_NIV_II)=0,'N/A',U_NIV_II)) Composicion,
		(IIF(U_NIV_II Is Null or LEN(U_NIV_II)=0,'N/A',(COMP.Name ))) NomComposicion,
	    (IIF(U_NIV_III Is Null or LEN(U_NIV_III)=0,'N/A',U_NIV_III)) FormGeom,
	    (IIF(U_NIV_III Is Null or LEN(U_NIV_III)=0,'N/A',(FORMG.Name ))) NomFormGeom,
	    (IIF(U_NIV_IV Is Null or LEN(U_NIV_IV)=0,'N/A',U_NIV_IV)) Textura,
	    (IIF(U_NIV_IV Is Null or LEN(U_NIV_IV)=0,'N/A',(TEX.Name))) NomTextura,
	    (IIF(U_NIV_V Is Null or LEN(U_NIV_V)=0,'N/A',U_NIV_V)) DescAdicional,
	    (IIF(U_NIV_VI Is Null or LEN(U_NIV_VI)=0,'N/A',U_NIV_VI)) Color,
	    (IIF(U_NIV_VI Is Null or LEN(U_NIV_VI)=0,'N/A',(COL.Name )))NomColor,
	    (IIF(U_MED Is Null or LEN(U_MED)=0,'N/A',U_MED)) Medida,
	    (IIF(U_UNMED Is Null or LEN(U_UNMED)=0,'N/A',U_UNMED)) UNMED,
	    (IIF(U_CBM Is Null or LEN(U_CBM)=0,'N/A',U_CBM)) CBM,
		ISNULL(OITM.BuyUnitMsr,'UND') BuyUnitMsr,
	    ISNULL(OITM.NumInBuy,1) NumInBuy,
	    OUGP.UgpCode,
		OITM.FirmCode FirmCode,
		OMRC.FirmName FirmName,
	    ITM1.Currency,
	    OPLN.PrimCurr,
        ISNULL(OITM.U_PRECIOFIJO,'N') as U_PRECIOFIJO,
	    'N/A' SubGrupo,
	    'N/A' NomSubGrupo,
	    'N/A' Departamento,
		'N/A' NomDepartamento,
        ISNULL(OITM.LastPurPrc,0.00) LastPurPrc,
        ISNULL(OITM.LastPurCur,'USD') LastPurCur 
        from OITM  
        inner join ITM1  
        on oitm.itemcode = itm1.itemcode  
        Inner Join Oitw 
        On Oitw.ItemCode = Oitm.ItemCode 
        Inner Join Owhs 
        on Owhs.WhsCode = Oitw.WhsCode 
        Inner Join OITB 
        on OITB.ItmsGrpCod = OITM.ItmsGrpCod   
	    inner join OUGP
	    on OITM.UgpEntry=OUGP.UgpEntry  
	    inner join OPLN
	    on ITM1.PriceList=OPLN.ListNum
        Left join OSTA
        on OITM.TaxCodeAR=OSTA.Code
	    LEFT join OMRC
	    on OITM.FirmCode=OMRC.FirmCode
	    left join [dbo].[@CATEGORIA] as CAT
	    on OITM.U_CAT=CAT.Code
	    left join [dbo].[@NIVI] as TIP
	    on OITM.U_NIV_I=TIP.Code
	    left join [dbo].[@NIVII] as COMP
	    on OITM.U_NIV_II=COMP.Code
	    left join [dbo].[@NIVIII] as FORMG
	    on OITM.U_NIV_III=FORMG.Code
	    left join [dbo].[@NIVIV] as TEX
	    on OITM.U_NIV_IV=TEX.Code
	    left join [dbo].[@NIVVI] as COL
	    on OITM.U_NIV_VI=COL.Code
        where itm1.pricelist = @CodListaPrecioPrincipal and oitm.itemcode in (SELECT value FROM OPENJSON(@CodArticulo))
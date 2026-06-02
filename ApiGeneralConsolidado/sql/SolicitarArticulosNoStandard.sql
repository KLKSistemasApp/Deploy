select distinct OITM.ItemCode,oitm.ItemName,oitm.ItmsGrpCod, itm1.PriceList,
        ISNULL(oitm.CodeBars,0) as CodBarra, ISNULL(itm1.Price,0) Price, isnull(oitm.TaxCodeAR,'') TaxCodeAR, 
        ISNULL(OSTA.Rate,16) PorcImpueto,ISNULL(U_tipo_umv,0) U_Tipo_umv, 
        '01' CodigoAlmacenDefault, OITM.invntItem, oitb.ItmsGrpNam, oitm.onhand,
	    isnull(U_POS_TIPO_DIST,1) U_POS_TIPO_DIST,oitm.VATLiable,ManSerNum,
	    OITM.SellItem,OITM.PrchseItem,OITM.frozenFor,
	    (IIF(U_Pesable Is Null or LEN(U_Pesable)=0,'NO',U_Pesable)) Pesable,
	    ISNULL(OITM.SalUnitMsr,'UND') SalUnitMsr,
	    ISNULL(OITM.NumInSale,1) NumInSale,
	    (IIF(U_YMG_CAT Is Null or LEN(U_YMG_CAT)=0,'N/A',U_YMG_CAT)) NomCategoria,
	    (IIF(U_NIV_I Is Null or LEN(U_NIV_I)=0,'N/A',U_NIV_I)) Tipo,
	    (IIF(U_NIV_I Is Null or LEN(U_NIV_I)=0,'N/A',(TIP.Name ))) NomTipo,
	    (IIF(U_YMG_SEG2 Is Null or LEN(U_YMG_SEG2)=0,'N/A',U_YMG_SEG2)) Composicion,
		(IIF(U_YMG_SEG2 Is Null or LEN(U_YMG_SEG2)=0,'N/A',U_YMG_SEG2)) NomComposicion,
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
	    (IIF(U_Pesable Is Null or LEN(U_Pesable)=0,ISNULL(OITM.BuyUnitMsr,'PZA'),OITM.BuyUnitMsr)) BuyUnitMsr,
	    (IIF(U_Pesable Is Null or LEN(U_Pesable)=0,ISNULL(OITM.NumInBuy,1),OITM.NumInBuy)) NumInBuy,
	    OUGP.UgpCode,
		(IIF(U_YMG_MARCA Is Null or LEN(U_YMG_MARCA)=0,'N/A',U_YMG_MARCA)) FirmCode,
		(IIF(U_YMG_MARCA Is Null or LEN(U_YMG_MARCA)=0,'N/A',U_YMG_MARCA)) FirmName,
	    ITM1.Currency,
	    OPLN.PrimCurr,
        ISNULL(OITM.U_PRECIOFIJO,'N') as U_PRECIOFIJO,
	    (IIF(U_YMG_SUBDEP Is Null or LEN(U_YMG_SUBDEP)=0,'N/A',U_YMG_SUBDEP)) SubGrupo,
	    (IIF(U_YMG_SUBDEP Is Null or LEN(U_YMG_SUBDEP)=0,'N/A',U_YMG_SUBDEP)) NomSubGrupo,
	    (IIF(U_YMG_SEG1 Is Null or LEN(U_YMG_SEG1)=0,'N/A',U_YMG_SEG1)) Departamento,
		(IIF(U_YMG_SEG1 Is Null or LEN(U_YMG_SEG1)=0,'N/A',U_YMG_SEG1)) NomDepartamento,
        ISNULL(COSTOS.Price,0.00) LastPurPrc,
        ISNULL(COSTOS.Currency,'USD') LastPurCur 
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
        left join ITM1 AS COSTOS 
        on oitm.itemcode = COSTOS.itemcode  and COSTOS.PriceList='5' 
        where itm1.pricelist = @CodListaPrecioPrincipal and oitm.itemcode in (SELECT value FROM OPENJSON(@CodArticulo))
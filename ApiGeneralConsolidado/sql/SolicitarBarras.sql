Select B.BcdCode, B.ItemCode,U.UomCode,iif(B.BcdEntry=D.BcdEntDft,'Y','N') as DftBcdCode
From OBCD B
Left Join OUOM U on B.UomEntry=U.UomEntry
Left Join ITM12 D on B.ItemCode=D.ItemCode and B.UomEntry=D.UomEntry and UomType='S'
Inner Join OITM A on  B.ItemCode=A.ItemCode
where B.ItemCode in (SELECT value FROM OPENJSON(@CodArticulo))
Group by B.BcdCode, B.ItemCode,U.UomCode,B.BcdEntry,D.BcdEntDft,U.UomEntry
Order by B.ItemCode,B.BcdCode,U.UomEntry

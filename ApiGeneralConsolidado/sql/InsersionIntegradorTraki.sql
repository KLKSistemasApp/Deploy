INSERT INTO StageTRK.dbo.MA_TRANSACCION (F_fecha, c_Localidad, Cod_Principal, c_Concepto, cantidad, Subtotal, impuesto1, impuesto, documento_origen, linea_origen)
          SELECT F_fecha, c_Localidad, Cod_Principal, c_Concepto, cantidad, Subtotal, impuesto1, impuesto, documento_origen, linea_origen
          FROM OPENJSON(@json)
          WITH (
            F_fecha datetime '$.F_fecha',
            c_Localidad nvarchar(50) '$.c_Localidad',
            Cod_Principal nvarchar(50) '$.Cod_Principal',
            c_Concepto nvarchar(10) '$.c_Concepto',
            cantidad decimal(18,3) '$.cantidad',
            Subtotal decimal(18,4) '$.Subtotal',
            impuesto1 nvarchar(20) '$.impuesto1',
            impuesto decimal(18,4) '$.impuesto',
            documento_origen nvarchar(50) '$.documento_origen',
            linea_origen int '$.linea_origen'
          )
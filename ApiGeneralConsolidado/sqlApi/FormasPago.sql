select fp.[CodFPago]
      ,fp.[Descripcion]
      ,fp.[TipoFPago]
      ,fp.[CuentaSAP]
      ,fp.[PorcRetISLR]
      ,fp.[PorcDebBanc]
      ,fp.[Activo]
      ,fps.CuentaContable as [CodCtaSAP]
      ,fp.[TarjetaCredito]
      ,fps.CuentaSAp as [IdFPagoSAP]
      ,fp.[CodigoBanco]
      ,fp.[CodigoTarjeta]
      ,fp.[CodigoCuentaBancaria]
      ,fp.[CodigoCajaERP]
      ,fp.[FormaPagoERP]
      ,fp.[Moneda]
      ,fp.[IntegradoSAPR3]
      ,fp.[FechaModificacion]
	  from KLK_FORMAPAGO fp
join KLK_FORMAPAGO_SUCURSAL fps on fp.CodFPago = fps.CodFPago and fps.CodSucursal = @IdSucursal
 where fps.FechaModificacion > @FechaModificacion
and fps.Asignada = 1;

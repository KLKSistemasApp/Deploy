select fp.* from KLK_FORMAPAGO fp
join KLK_FORMAPAGO_SUCURSAL fps on fp.CodFPago = fps.CodFPago and fps.CodSucursal = @IdSucursal
 where fp.FechaModificacion > @FechaModificacion
and fps.Asignada = 1;
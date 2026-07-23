DECLARE @PromocionAProcesar TABLE (
	Codigo nvarchar(30) PRIMARY KEY 
	,CodGrupoPromo nvarchar(30)
	,CodTipoPromo nvarchar(30)
);
insert into @PromocionAProcesar 
	select
	Codigo
	,CodGrupoPromo
	,CodTipoPromo
from KLK_PROMOCIONHDR
where FechaModificacion > @FechaModificacion;

SELECT distinct
	prhdr.[Codigo]
      ,prhdr.[Descripcion]
      ,prhdr.[MensajePromo]
	,IIF(prs.Disponible = 1, prhdr.Estatus, 1 ) as Estatus
      ,prhdr.[FechaInicio]
      ,prhdr.[FechaFin]
      ,prhdr.[HoraInicio]
      ,prhdr.[HoraFin]
      ,prhdr.[Lunes]
      ,prhdr.[Martes]
      ,prhdr.[Miercoles]
      ,prhdr.[Jueves]
      ,prhdr.[Viernes]
      ,prhdr.[Sabado]
      ,prhdr.[Domingo]
      ,prhdr.[CodTipoPromo]
      ,prhdr.[PorGrupo]
      ,prhdr.[PorArticuloSeleccionado]
      ,prhdr.[EntrePrecios]
      ,prhdr.[PrecioMin]
      ,prhdr.[PrecioMax]
      ,prhdr.[CantidadVenta1]
      ,prhdr.[CantidadPagar1]
      ,prhdr.[PorcDescuento1]
      ,prhdr.[PrecioPagar1]
      ,prhdr.[FechaCreacion]
      ,prhdr.[FechaModificacion]
      ,prhdr.[Usuario]
      ,prhdr.[PorExistencia]
      ,prhdr.[PorExistenciaStockTotal]
      ,prhdr.[ListasPrecios]
      ,prhdr.[CodGrupoPromo]
      ,prhdr.[SoloaListasPrecio]
      ,prhdr.[TipoCondAplicar]
      ,prhdr.[SoloClientesFidelizados]
      ,prhdr.[CantidadListaPrecio]
      ,prhdr.[CodigoListaPrecio]
      ,prhdr.[SoloFidelizacionListadas]
      ,prhdr.[ListaCodFidelizacion]
      ,prhdr.[ListaTipoCliente]
      ,prhdr.[ListaFormasDePago]
      ,prhdr.[PorCumpleano]
      ,prhdr.[PeriodoValidesCumpleano]
      ,prhdr.[IntervaloDiasAntesCumpleano]
      ,prhdr.[IntervaloDiasDespuesCumpleano]
FROM 
	[KLK_CONSOLIDADO].[dbo].[KLK_PROMOCIONHDR] prhdr
	join KLK_PROMOCION_SUCURSAL prs on prhdr.[Codigo] = prs.Codigo 
where
prhdr.Codigo in (select codigo from @PromocionAProcesar)
and prs.CodSucursal = @CodSucursal;

select * from KLK_PROMOCIONLINE where Codigo in (select codigo from @PromocionAProcesar);
select * from KLK_PROMOCIONGRUPOHDR  where CodGrupoPromo in (select CodGrupoPromo from @PromocionAProcesar) or FechaModificacion > @FechaModificacion;
select * from KLK_PROMOCIONGRUPOLINE where CodGrupoPromo in (select CodGrupoPromo from @PromocionAProcesar) or  CodGrupoPromo in (select CodGrupoPromo from KLK_PROMOCIONGRUPOHDR where FechaModificacion > @FechaModificacion);
select * from KLK_PROMOCIONTIPO where Codigo in (select CodTipoPromo from @PromocionAProcesar);
IF EXISTS (SELECT 1 FROM @PromocionAProcesar)
BEGIN
    SELECT * FROM KLK_PROMOCION_PARAMETRIZACION;
END
ELSE
BEGIN
    SELECT TOP 0 * FROM KLK_PROMOCION_PARAMETRIZACION;
END

select * from KLK_SAP_LISTAPRECIO where FechaModificacion > @FechaModificacion;
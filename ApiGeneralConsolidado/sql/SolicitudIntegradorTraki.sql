DECLARE @Faturas TABLE (id Nvarchar(50));
INSERT INTO @Faturas SELECT TOP 100 NumFactura FROM KLK_FACTURAHDR WHERE EnviadoASAP = 0 ORDER BY FechaFactura ASC;
DECLARE @notas TABLE (id Nvarchar(50));
INSERT INTO @notas SELECT TOP 100 NumNota FROM KLK_NCREDITOHDR WHERE EnviadoASAP = 0 ORDER BY FechaNota ASC;

select 
	FechaFactura as F_fecha
	,Sucursal as c_Localidad
	,CodArticulo as Cod_Principal
	,'VEN'  as c_Concepto
	,Cantidad as cantidad
	/*,PrecioUSD*/
	,TotalLineaDespDescUsd as Subtotal
	,CodImpuesto as impuesto1
	,PorcImpuesto as impuesto
	,NumFactura as documento_origen
	,NumLineas as linea_origen
from KLK_FACTURALINE where NumFactura in (select id from @Faturas)


select 
	FechaNota as F_fecha
	,Sucursal as c_Localidad
	,CodArticulo as Cod_Principal
	,'DEV' as c_Concepto
	,Cantidad as cantidad
	/*,PrecioUSD*/
	,TotalLineaDespDescUsd as Subtotal
	,CodImpuesto as impuesto1
	,PorcImpuesto as impuesto
	,NumNota as documento_origen
	,NumLineas as linea_origen
from KLK_NCREDITOLINE where NumNota in (select id from @notas)


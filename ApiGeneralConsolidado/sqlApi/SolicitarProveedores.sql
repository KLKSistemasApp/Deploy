DECLARE @ProveedoresAProcesar TABLE (
	id_proveedor nvarchar(30) PRIMARY KEY 
);
insert into @ProveedoresAProcesar 
	select
	id_proveedor
from KLK_PROVEEDOR
where FechaModificacion > @FechaModificacion;

select * from KLK_PROVEEDOR where id_proveedor in (select id_proveedor from @ProveedoresAProcesar)
select * from KLK_TIPO_PROVEEDOR where FechaModificacion > @FechaModificacion;
select * from KLK_PROVEEDOR_RETENCIONES where id_proveedor in (select id_proveedor from @ProveedoresAProcesar)
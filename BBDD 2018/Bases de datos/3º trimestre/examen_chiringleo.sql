use ChiringLeo
go

--ejercicio 1

--cuando el precio de una tapa, media o racion esta a null le pongo como importe cero porque hay campos que estan a null
--tanto en el precio del establecimiento como en el precio del plato

/*
PG
inicio
	declarar una tabla donde poner los id de los pedidos y su importe

	actualizar importe añadiendo el costo de los complementos

	actualizar importe añadiendo el costo de los platos

	actualizar importe añadiendo el costo de los vinos

	actualizar tabla pedidos con el importe calculado
fin
*/

GO
/**
cabecera: FnCalcularImporteComplementos()
comentario: metodo que calcula el importe total a pagar de los pedidos que incluyan algun complemento
precondiciones: nada
entrada: nada
salida: una tabla
postcondiciones: asociado al nombre devuelve una tabla con el id cada pedido que deba pagar por algun complemento, junto al total a pagar
*/
CREATE FUNCTION FnCalcularImporteComplementos()
RETURNS TABLE as
return(
	select P.ID, sum(C.Importe*PC.Cantidad) as ImporteTotal from CLPedidos as P
	inner join CLPedidosComplementos as PC on P.ID=PC.IDPedido
	inner join CLComplementos as C on PC.IDComplemento=C.ID
	group by P.ID
)
GO


/**
cabecera: FnCalcularImportePlatos()
comentario: metodo que calcula el importe total a pagar por los platos ordenados en los pedidos
precondiciones: nada
entrada: nada
salida: una tabla
postcondiciones: asociado al nombre devuelve una tabla con el id de cada pedido junto al total que debe pagar pos los platos consumidos. Si el establecimiento no dispone del precio del plato se considera que es gratuito.
*/

CREATE FUNCTION FnCalcularImportePlatos()
RETURNS table as
return(
	select Total.ID, SUM(Total.TotalTapa+Total.TotalMedia+Total.TotalRacion) as TotalImporte from
	(
		select SubTotal.ID, SUM(SubTotal.CantidadTapas*case when SubTotal.PrecioTapa is null then 0 else SubTotal.PrecioTapa end) as TotalTapa,
			SUM(SubTotal.CantidadMedias*case when SubTotal.PrecioMedia is null then 0 else SubTotal.PrecioMedia end) as TotalMedia,
			SUM(SubTotal.CantidadRaciones*case when SubTotal.PrecioRacion is null then 0 else SubTotal.PrecioRacion end) as TotalRacion
		 from
		(	
			select Cantidades.ID, Cantidades.IDEstablecimiento, Cantidades.IDPlato, Cantidades.CantidadTapas, Precios.PrecioTapa,
				Cantidades.CantidadMedias, Precios.PrecioMedia, Cantidades.CantidadRaciones, Precios.PrecioRacion
			from
			(
				--cantidad de platos pedidos en cada orden
				select P.ID, P.IDEstablecimiento, PP.IDPlato, PP.CantidadTapas, PP.CantidadMedias, PP.CantidadRaciones from CLPedidos as P
				inner join CLPedidosPlatos as PP on P.ID=PP.IDPedido
			) as Cantidades
			full join (
				--precio de cada plato por establecimiento
				select P.ID, CP.IDEstablecimiento, CP.IDPlato,
				CP.PVPTapa as PrecioTapa,
				CP.PVPMedia as PrecioMedia,
				CP.PVPRacion as PrecioRacion
				from CLPedidos as P
				inner join CLEstablecimientos as E on P.IDEstablecimiento=E.ID
				inner join CLCartaPlatos as CP on E.ID=CP.IDEstablecimiento
			) as Precios on Cantidades.ID=Precios.ID and Cantidades.IDEstablecimiento=Precios.IDEstablecimiento and Cantidades.IDPlato=Precios.IDPlato
			where Cantidades.ID is not null and Cantidades.IDEstablecimiento is not null and Cantidades.IDPlato is not null
		) as SubTotal
		group by SubTotal.ID
	) as Total
	group by Total.ID
--order by Total.ID
)
GO


/**
cabecera: FnCalcularImportePlatos()
comentario: metodo que calcula el importe total a pagar por los platos ordenados en los pedidos
precondiciones: nada
entrada: nada
salida: una tabla
postcondiciones: asociado al nombre devuelve una tabla con el id de cada pedido junto al total que debe pagar pos los vinos consumidos. Si el establecimiento no dispone del precio del vino se considera que es gratuito.
*/

CREATE FUNCTION FnCalcularImporteVinos()
RETURNS table as
return(
	
		select Total.ID, SUM(Total.Cantidad*case when Total.PVP is null then 0 else Total.PVP end) as TotalVino
		 from
		(	
			select Cantidades.ID, Cantidades.IDEstablecimiento, Cantidades.IDVino, Cantidades.Cantidad, Precios.PVP
			from
			(
				--cantidad de vinos pedidos en cada orden
				select P.ID, P.IDEstablecimiento, PV.IDVino, PV.Cantidad from CLPedidos as P
				inner join CLPedidosVinos as PV on P.ID=PV.IDPedido
			) as Cantidades
			full join (
				--precio de cada vino por establecimiento
				select P.ID, CV.IDEstablecimiento, CV.IDVino, CV.PVP
				from CLPedidos as P
				inner join CLEstablecimientos as E on P.IDEstablecimiento=E.ID
				inner join CLCartaVinos as CV on E.ID=CV.IDEstablecimiento
			) as Precios on Cantidades.ID=Precios.ID and Cantidades.IDEstablecimiento=Precios.IDEstablecimiento and Cantidades.IDVino=Precios.IDVino
			where Cantidades.ID is not null and Cantidades.IDEstablecimiento is not null and Cantidades.IDVino is not null
		) as Total
		group by Total.ID
)
GO


/**
cabecera: AsignarImportes()
comentario: procedimiento para actualizar el valor del campo Importe de la tabla CLPedidos
precondiciones: nada
entrada: nada
salida: nada
postcondiciones: Inserta en la tabla CLPedidos el importe de cada pedido
*/
CREATE PROCEDURE AsignarImportes AS
BEGIN

--begin transaction
	declare @contador bigint
	declare @totalRegistros bigint
	declare @importe smallmoney

	DECLARE @tablaActualizacion table (IDPedido bigint, Importe smallmoney)
	DECLARE @tablaPreciosComplementos table (IDPedido bigint, Importe smallmoney)
	DECLARE @tablaPreciosPlatos table (IDPedido bigint, Importe smallmoney)
	DECLARE @tablaPreciosVinos table (IDPedido bigint, Importe smallmoney)

	insert into @tablaPreciosComplementos
	select ID, ImporteTotal from dbo.FnCalcularImporteComplementos ()

	insert into @tablaPreciosPlatos
	select ID, TotalImporte from dbo.FnCalcularImportePlatos ()

	insert into @tablaPreciosVinos
	select ID, TotalVino from dbo.FnCalcularImporteVinos ()

	insert into @tablaActualizacion
	select Final.ID, SUM(Final.Complementos+Final.Platos+final.Vinos) as Importe from
	(
		select Pe.ID,
			case when C.Importe is null then 0 else C.Importe end AS Complementos, 
			case when P.Importe is null then 0 else P.Importe end AS Platos,
			case when V.Importe is null then 0 else V.Importe end AS Vinos
			from @tablaPreciosComplementos as C
		full join @tablaPreciosPlatos as P on C.IDPedido=P.IDPedido
		full join @tablaPreciosVinos as V on C.IDPedido=V.IDPedido
		right join CLPedidos as Pe on C.IDPedido=Pe.ID and P.IDPedido=Pe.ID and V.IDPedido=Pe.ID
	) as Final
	group by Final.ID

	select @contador = 1, @totalRegistros = count(*) from CLPedidos
	
	while(@contador<=@totalRegistros)
	begin
		select @importe = Importe from @tablaActualizacion where IDPedido = @contador

		update CLPedidos
		set Importe = @importe
		where CLPedidos.ID = @contador

		set @contador +=1
	end
	
	--rollback
	--commit
END
GO

--select * from CLPedidos

--begin transaction

--exec dbo.AsignarImportes

--rollback
--commit




--EJERCICIO 2

SELECT * FROM CLEstablecimientos
select * from CLPedidos

GO
/**
cabecera: FnRankingChiringuitos(@inico smalldatetime, @fin smalldatetime)
comentario: funcion que devuelve una serie de datos de cada chiringuito en un rango de fechas
precondiciones: nada
entrada: dos fechas
salida: una tabla
postcondiciones: asociado al nombre devuelve una tabla con datos de cada chiringuito
*/

CREATE FUNCTION FnRankingChiringuitos(@inico smalldatetime, @fin smalldatetime)
returns  table as
return(


	--select ID, Denominacion, Ciudad from CLEstablecimientos

	--select IDEstablecimiento, count(*) as TotalPedidos from CLPedidos group by IDEstablecimiento

	--select P.IDEstablecimiento, sum(PP.CantidadMedias+PP.CantidadRaciones+PP.CantidadTapas) TotalPlatos from CLPedidosPlatos PP
	--inner join CLPedidos as P on PP.IDPedido=P.ID
	--group by P.IDEstablecimiento

	--select IDEstablecimiento, sum(Importe) as Facturado from CLPedidos
	--group by IDEstablecimiento

	--select P.IDEstablecimiento, sum(PV.Cantidad) as TotalVinos from CLPedidosVinos as PV
	--inner join CLPedidos as P on PV.IDPedido=P.ID
	--group by P.IDEstablecimiento

	--select IDEstablecimiento, count(distinct IDCliente) as TotalClientes from CLPedidos
	--group by IDEstablecimiento


	select Datos.ID, Datos.Denominacion, Datos.Ciudad, Pedidos.TotalPedidos, Platos.TotalPlatos, Facturacion.Facturado, vinos.TotalVinos, clientes.TotalClientes 
	
	from (
		select ID, Denominacion, Ciudad from CLEstablecimientos
	) as Datos
	left join (
		select IDEstablecimiento, count(*) as TotalPedidos from CLPedidos
		--where Fecha between @inico and @fin
		group by IDEstablecimiento
	) as Pedidos on Datos.ID=Pedidos.IDEstablecimiento
	left join (
		select P.IDEstablecimiento, sum(PP.CantidadMedias+PP.CantidadRaciones+PP.CantidadTapas) TotalPlatos from CLPedidosPlatos PP
		inner join CLPedidos as P on PP.IDPedido=P.ID
		--where Fecha between @inico and @fin
		group by P.IDEstablecimiento
	) as Platos on Datos.ID=Platos.IDEstablecimiento
	left join (
		select IDEstablecimiento, sum(Importe) as Facturado from CLPedidos
		--where Fecha between @inico and @fin
		group by IDEstablecimiento
	) as Facturacion on Datos.ID=Facturacion.IDEstablecimiento
	left join (
		select P.IDEstablecimiento, sum(PV.Cantidad) as TotalVinos from CLPedidosVinos as PV
		inner join CLPedidos as P on PV.IDPedido=P.ID
		--where Fecha between @inico and @fin
		group by P.IDEstablecimiento
	) as Vinos on Datos.ID=Vinos.IDEstablecimiento
	left join (
		select IDEstablecimiento, count(distinct IDCliente) as TotalClientes from CLPedidos
		--where Fecha between @inico and @fin
		group by IDEstablecimiento
	) as clientes on Datos.ID=clientes.IDEstablecimiento
	
	--where Fecha between @inico and @fin
)
go

--POR FALTA DE TIEMPO NO IMPLEMENTO LA FECHA ni el ejercicio 3
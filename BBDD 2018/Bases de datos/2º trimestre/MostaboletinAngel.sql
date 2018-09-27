use TMPrueba
GO

select * from TMBases
select * from TMTiposMostachon
select * from TMMostachones
select * from TMMostachonesToppings
select * from TMToppings
select * from TMPedidos
select * from TMComplementos
select * from TMPedidosComplementos
select * from TMEstablecimientos
select * from TMRepartidores
select * from TMClientes

--1. Toppings utilizados en todos los pedidos pedidos del año 2016, contando cuantas veces se han utilizado
select T.Topping, count(MT.IDTopping) as Cantidad from TMToppings as T
inner join TMMostachonesToppings AS MT on T.ID=MT.IDTopping
inner join TMMostachones as M on MT.IDMostachon=M.ID
inner join TMPedidos as P on M.IDPedido=P.ID
where YEAR(P.Enviado) = 2016
group by T.Topping


--2. Complementos vendidos en los pedidos cuyo tipo de harina era 'Arroz' o 'Integral' y la cantidad vendida
select C.Complemento, count(PC.IDComplemento) as Cantidad from TMTiposMostachon as TM
inner join TMMostachones as M on TM.Harina=M.Harina
inner join TMPedidos as P on M.IDPedido=P.ID
inner join TMPedidosComplementos as PC on P.ID=PC.IDPedido
inner join TMComplementos as C on PC.IDComplemento=C.ID
where TM.Harina in ('Arroz','Integral')
group by C.Complemento


--3. Recaudacion del establecimiento 'La Fresca' durante agosto de 2017
select sum(P.Importe) as Recaudado from TMEstablecimientos as E
inner join TMPedidos as P on E.ID=P.IDEstablecimiento
where E.Denominacion = 'La Fresca'
and P.Enviado between DATEFROMPARTS(2017,8,1) and DATEFROMPARTS(2017,8,31)


--4. Mes de mayor recaudacion de cada establecimiento durante el año 2015, cuanto han recaudado ese mes y
--que porcentaje de la recaudacion anual es la recaudacion de ese mes, mostrando el nombre de cada establecimiento,
--ordenado de mayor a menor porcentaje de ganancia de ese mes respecto a las ganancias anuales, mostrando el nombre del mes

--todo lo recaudado cada mes de 2015
select IDEstablecimiento, MONTH(Enviado) as Mes, SUM(Importe) as Recaudado from TMPedidos
where YEAR(Enviado) = 2015
group by IDEstablecimiento, MONTH(Enviado)

--recaudaciones 2015
select Recaudaciones.IDEstablecimiento,  MAX(Recaudaciones.Recaudado) as Recaudado, SUM(Recaudaciones.Recaudado) as TotalRecaudado from(
	select IDEstablecimiento, MONTH(Enviado) as Mes, SUM(Importe) as Recaudado from TMPedidos
	where YEAR(Enviado) = 2015
	group by IDEstablecimiento, MONTH(Enviado)
) as Recaudaciones
group by Recaudaciones.IDEstablecimiento

--resuelto
select E.Denominacion, R2.Mes, R1.Recaudado, R1.TotalRecaudado, (R1.Recaudado*100)/R1.TotalRecaudado as [% de recaudacion anual] from(
	select Recaudaciones.IDEstablecimiento,  MAX(Recaudaciones.Recaudado) as Recaudado, SUM(Recaudaciones.Recaudado) as TotalRecaudado from(
		select IDEstablecimiento, SUM(Importe) as Recaudado from TMPedidos
		where YEAR(Enviado) = 2015
		group by IDEstablecimiento, MONTH(Enviado)
	) as Recaudaciones
	group by Recaudaciones.IDEstablecimiento
) as R1
inner join(
	select IDEstablecimiento, DATENAME(MONTH, Enviado) as Mes, SUM(Importe) as Recaudado from TMPedidos
	where YEAR(Enviado) = 2015
	group by IDEstablecimiento, DATENAME(MONTH, Enviado)
) as R2 on R1.Recaudado=R2.Recaudado
inner join TMEstablecimientos as E on R1.IDEstablecimiento=E.ID
order by [% de recaudacion anual] desc


--5. Cuantos mostachones de cada variacion ha pedido el cliente Borja Monero (tipo de base, harina y numero de toppings)
select M.ID, M.TipoBase, M.Harina, T.Topping from TMPedidos as P
inner join TMMostachones as M on P.ID=M.IDPedido
inner join TMMostachonesToppings as MT on P.ID=MT.IDMostachon
inner join TMToppings as T on MT.IDTopping=T.ID
inner join TMClientes as C on P.IDCliente=C.ID
where C.Nombre = 'Borja' and C.Apellidos = 'Monero'


--resuelto
select M.ID, M.TipoBase, M.Harina, count(T.Topping) as [Numero de toppings] from TMPedidos as P
inner join TMMostachones as M on P.ID=M.IDPedido
inner join TMMostachonesToppings as MT on P.ID=MT.IDMostachon
inner join TMToppings as T on MT.IDTopping=T.ID
inner join TMClientes as C on P.IDCliente=C.ID
where C.Nombre = 'Borja' and C.Apellidos = 'Monero'
group by M.ID, M.TipoBase, M.Harina
order by M.TipoBase, M.Harina

--
select PedidosCliente.TipoBase, PedidosCliente.Harina, PedidosCliente.[Numero de toppings], count(PedidosCliente.ID) as [Veces pedido] from(
	select M.ID, M.TipoBase, M.Harina, count(T.Topping) as [Numero de toppings] from TMPedidos as P
	inner join TMMostachones as M on P.ID=M.IDPedido
	inner join TMMostachonesToppings as MT on P.ID=MT.IDMostachon
	inner join TMToppings as T on MT.IDTopping=T.ID
	inner join TMClientes as C on P.IDCliente=C.ID
	where C.Nombre = 'Borja' and C.Apellidos = 'Monero'
	group by M.ID, M.TipoBase, M.Harina
) as PedidosCliente
group by PedidosCliente.TipoBase, PedidosCliente.Harina, PedidosCliente.[Numero de toppings]


--6. Repartidores que han cobrado mas de 1000 euros a clientes
select Repartos.Nombre, Repartos.Apellidos, Repartos.Cobrado from(
	select R.Nombre, R.Apellidos, sum(P.Importe) as Cobrado from TMRepartidores as R
	inner join TMPedidos as P on R.ID=P.IDRepartidor
	group by R.Nombre, R.Apellidos
)as Repartos
where Repartos.Cobrado>1000


--7. Cuantas veces ha repartido cada repartidor a cada cliente. Especifica nombres y apellidos
select R.Nombre, R.Apellidos, count(P.ID) as Pedidos, c.Nombre, C.Apellidos from TMRepartidores as R
inner join TMPedidos as P on R.ID=P.IDRepartidor
inner join TMClientes as C on P.IDCliente=C.ID
group by R.Nombre, R.Apellidos, c.Nombre, C.Apellidos


--8. Que repartidores no han hecho nunca un reparto (nombre, apellidos y telefono de contacto)
select Nombre, Apellidos, Telefono from TMRepartidores
except
select Repartidor.Nombre, Repartidor.Apellidos, Repartidor.Telefono from(
	select distinct R.Telefono, R.Nombre, R.Apellidos from TMRepartidores as R
	inner join TMPedidos as P on R.ID=P.IDRepartidor
) as Repartidor

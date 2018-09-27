use TMPrueba
go

--ejercicio 1
select E.Denominacion, E.Ciudad, DATENAME(MONTH, P.Enviado) as Mes, YEAR(P.Enviado) as Anio,
	sum(P.Importe)/count(P.ID) as [Precio medio], MAX(P.Importe) as [Precio mas caro]
from TMPedidos as P
inner join TMEstablecimientos as E on P.IDEstablecimiento=E.ID
group by YEAR(P.Enviado), DATENAME(MONTH, P.Enviado),month(P.Enviado), E.Denominacion, E.Ciudad
order by Anio, month(P.Enviado)


--ejercicio 2

select C.Nombre, C.Apellidos, C.Ciudad, PedidosClientes.Harina, PedidosClientes.TipoBase,
	PedidosClientes.Topping, MasVecesPedido.[Mostachon mas pedido] as [Veces pedido]
from(
	select P.IDCliente, M.Harina, M.TipoBase, T.Topping, count(M.ID) as [Veces pedido] from TMMostachones as M
	inner join TMMostachonesToppings as MT on M.ID=MT.IDMostachon
	inner join TMToppings as T on MT.IDTopping=T.ID
	inner join TMPedidos as P on M.IDPedido=P.ID
	group by P.IDCliente, M.Harina, M.TipoBase, T.Topping
) as PedidosClientes
inner join(
	select MayorPedido.IDCliente, MAX(MayorPedido.[Veces pedido]) as [Mostachon mas pedido] from(
		select P.IDCliente, count(M.ID) as [Veces pedido] from TMMostachones as M
		inner join TMMostachonesToppings as MT on M.ID=MT.IDMostachon
		inner join TMToppings as T on MT.IDTopping=T.ID
		inner join TMPedidos as P on M.IDPedido=P.ID
		group by P.IDCliente, M.Harina, M.TipoBase, T.Topping
	) as MayorPedido
	group by MayorPedido.IDCliente
) as MasVecesPedido
	on PedidosClientes.IDCliente=MasVecesPedido.IDCliente and PedidosClientes.[Veces pedido]=MasVecesPedido.[Mostachon mas pedido]
inner join TMClientes as C on PedidosClientes.IDCliente=C.ID
group by C.Nombre, C.Apellidos, C.Ciudad, PedidosClientes.Harina, PedidosClientes.TipoBase,
	PedidosClientes.Topping, MasVecesPedido.[Mostachon mas pedido]


--ejercicio 3

select E.Denominacion, E.Ciudad, VentasAnioActual.Pedidos as [Pedidos este anio], VentasAnioAnterior.Pedidos as [Pedidos anio anterior],
	((VentasAnioActual.Pedidos*100)/VentasAnioAnterior.Pedidos)-100 as [% incremento/decremento] from TMEstablecimientos as E
inner join(
	select P.IDEstablecimiento, count(M.ID) as Pedidos from TMPedidos as P
	inner join TMMostachones as M on P.ID=M.IDPedido
	where YEAR(Enviado)=YEAR(CURRENT_TIMESTAMP)
	group by P.IDEstablecimiento
) as VentasAnioActual on E.ID=VentasAnioActual.IDEstablecimiento
inner join(
	select P.IDEstablecimiento, count(M.ID) as Pedidos from TMPedidos as P
	inner join TMMostachones as M on P.ID=M.IDPedido
	where YEAR(Enviado)=YEAR(CURRENT_TIMESTAMP)-1
	group by P.IDEstablecimiento
) as VentasAnioAnterior on E.ID=VentasAnioAnterior.IDEstablecimiento
group by E.Denominacion, E.Ciudad, VentasAnioActual.Pedidos, VentasAnioAnterior.Pedidos


--ejercicio 4

--insercion de datos
select * from TMToppings where Topping='Wasabi'

INSERT INTO TMToppings
(ID, Topping)
(SELECT MAX(id)+1, 'Wasabi' from TMToppings)


select * from TMBases where Base='Bambú'

insert into TMBases
(Base)
VALUES
('Bambú')


-- actualizar toppings
begin transaction

update TMMostachonesToppings
SET IDTopping = (select ID from TMToppings where Topping = 'Wasabi')
where IDMostachon in (
	select M.ID from TMToppings as T
	inner join TMMostachonesToppings as MT on T.ID=MT.IDTopping
	inner join TMMostachones as M on MT.IDMostachon=M.ID
	inner join TMPedidos as P on M.IDPedido=P.ID
	inner join TMEstablecimientos as E on P.IDEstablecimiento=E.ID
	where E.Ciudad = 'Tokyo'
	and T.Topping = 'Sirope'
)
and IDTopping = (select id from TMToppings where Topping = 'Sirope')

rollback

commit transaction


-- actualizar bases
begin transaction

UPDATE TMMostachones
set TipoBase = 'Bambú'
where ID in (
	select M.ID from TMMostachones as M
	inner join TMPedidos as P on M.IDPedido=P.ID
	inner join TMEstablecimientos as E on P.IDEstablecimiento=E.ID
	where E.Ciudad = 'Tokyo'
	and M.TipoBase = 'Tradicional'
)


rollback

commit transaction


--ejercicio 5

--insertar el pedido
begin transaction

insert into TMPedidos
(ID, Recibido, Enviado, IDCliente, IDEstablecimiento, IDRepartidor, Importe)
(select (select MAX(ID)+1 from TMPedidos), CURRENT_TIMESTAMP, null, C.ID, E.ID, null, (2.00*2)+(0.6*3)+CO.Importe from TMPedidos as P
inner join TMClientes as C on P.IDCliente=C.ID
inner join TMEstablecimientos as E on P.IDEstablecimiento=E.ID
inner join TMPedidosComplementos as PC on P.ID=PC.IDPedido
inner join TMComplementos as CO on PC.IDComplemento=CO.ID
where C.Nombre = 'Olga'
	and C.Apellidos = 'Llinero'
	and E.Denominacion = 'Sol Naciente'
	and CO.Complemento = 'café'
group by C.ID, E.ID, CO.Importe)


rollback

commit transaction

--insertar complemento

begin transaction

insert into TMPedidosComplementos
(IDPedido, IDComplemento, Cantidad)
(select(select max(id) from TMPedidos), (select id from TMComplementos where Complemento = 'café'), 1)


rollback

commit transaction


--insertar mostachon 1

begin transaction

insert into TMMostachones
(ID, IDPedido, TipoBase, Harina)
(select MAX(M.ID)+1, (select max(id) from TMPedidos), 'Reciclado', 'Maíz' from TMMostachones as M
)


rollback

commit transaction


--insertar topping de mostachon 1

	--insertamos mermelada como topping porque no esta en la base de datos
INSERT INTO TMToppings
(ID, Topping)
(SELECT MAX(id)+1, 'Mermelada' from TMToppings)


begin transaction

insert into TMMostachonesToppings
(IDMostachon, IDTopping)
(select (select max(id) from TMMostachones),(select ID from TMToppings where Topping = 'Mermelada'))


rollback

commit transaction


----------------------------
--insertar mostachon 2

begin transaction

insert into TMMostachones
(ID, IDPedido, TipoBase, Harina)
(select MAX(M.ID)+1, (select max(id) from TMPedidos), 'Cartulina', 'Espelta' from TMMostachones as M
)


rollback

commit transaction


--insertar toppings de mostachon 2
select * from TMToppings
select * from TMMostachonesToppings order by IDMostachon desc

begin transaction

insert into TMMostachonesToppings
(IDMostachon, IDTopping)
(select (select max(id) from TMMostachones),(select ID from TMToppings where Topping = 'Nata'))

insert into TMMostachonesToppings
(IDMostachon, IDTopping)
(select (select max(id) from TMMostachones),(select ID from TMToppings where Topping = 'Almendra picada'))


rollback

commit transaction


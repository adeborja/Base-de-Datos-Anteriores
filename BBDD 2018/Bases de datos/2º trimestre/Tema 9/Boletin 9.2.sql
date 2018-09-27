use Northwind
go

--1. Número de clientes de cada país.
select * from Orders

select CustomerID, ShipCountry from Orders

select Clientes.ShipCountry, count(Cantidad.ShipCountry) as numero from Orders as Clientes
inner join(
	select ShipCountry from Orders
) as Cantidad on Clientes.ShipCountry=Cantidad.ShipCountry
group by Clientes.ShipCountry

--resuelto
select ShipCountry, count(ShipCountry) as clientes from Orders group by ShipCountry


--2. Número de clientes diferentes que compran cada producto. Incluye el nombre
--del producto
select * from [Order Details]
select * from Orders

--que productos a comprado cada cliente
select distinct OD.ProductID, O.CustomerID from Orders as O
inner join [Order Details] as OD on O.OrderID=OD.OrderID order by O.CustomerID, OD.ProductID

----resuelto
select P.ProductName, count(Compras.ProductID) as [Clientes unicos] from Products as P
inner join(
	select distinct OD.ProductID, O.CustomerID from Orders as O
	inner join [Order Details] as OD on O.OrderID=OD.OrderID
) as Compras on P.ProductID=Compras.ProductID
group by P.ProductName

------------comprobacion
select SUM(T.[Clientes unicos]) from(
select P.ProductName, count(Compras.ProductID) as [Clientes unicos] from Products as P
inner join(
	select distinct OD.ProductID, O.CustomerID from Orders as O
	inner join [Order Details] as OD on O.OrderID=OD.OrderID
) as Compras on P.ProductID=Compras.ProductID
group by P.ProductName
) as T

--3. Número de países diferentes en los que se vende cada producto. Incluye el
--nombre del producto
select * from Products
select * from [Order Details]
select * from Orders

--productos que se han vendido en cada pais
select distinct OD.ProductID, O.ShipCountry from [Order Details] as OD
inner join Orders as O on OD.OrderID=O.OrderID

--informacion del producto
select P.ProductName, P.ProductID from Products as P order by p.ProductID

--resuelto
select P.ProductName, count(VentasPais.ShipCountry) as [Paises unicos] from Products as P 
inner join(
	select distinct OD.ProductID, O.ShipCountry from [Order Details] as OD
	inner join Orders as O on OD.OrderID=O.OrderID
) as VentasPais on P.ProductID=VentasPais.ProductID
group by P.ProductName


--4. Empleados (nombre y apellido) que han vendido alguna vez
--“Gudbrandsdalsost”, “Lakkalikööri”, “Tourtière” o “Boston Crab Meat”.
select * from Employees
select * from Orders
select * from [Order Details]
select * from Products

select distinct E.EmployeeID, E.FirstName, E.LastName from Employees as E
inner join Orders as O on E.EmployeeID=O.EmployeeID
inner join [Order Details] as OD on O.OrderID=OD.OrderID
inner join Products as P on OD.ProductID=P.ProductID
where P.ProductName in ('Boston Crab Meat')


--5. Empleados que no han vendido nunca “Northwoods Cranberry Sauce” o
--“Carnarvon Tigers”.

select EmployeeID, FirstName, LastName from Employees
except
select distinct E.EmployeeID, E.FirstName, E.LastName from Employees as E
inner join Orders as O on E.EmployeeID=O.EmployeeID
inner join [Order Details] as OD on O.OrderID=OD.OrderID
inner join Products as P on OD.ProductID=P.ProductID
where P.ProductName in ('Northwoods Cranberry Sauce','Carnarvon Tigers')



--6. Número de unidades de cada categoría de producto que ha vendido cada
--empleado. Incluye el nombre y apellidos del empleado y el nombre de la
--categoría.
select * from Employees
select * from Orders
select * from [Order Details]
select * from Products
select * from Categories

--ventas de cada producto de cada empleado
select E.EmployeeID, E.FirstName, E.LastName, OD.ProductID, SUM(OD.Quantity) as Ventas from Employees as E
inner join Orders as O on E.EmployeeID=O.EmployeeID
inner join [Order Details] as OD on O.OrderID=OD.OrderID
group by E.EmployeeID, E.FirstName, E.LastName, OD.ProductID

--

select E.EmployeeID, E.FirstName, E.LastName, C.CategoryName, SUM(OD.Quantity) as Ventas from Employees as E
inner join Orders as O on E.EmployeeID=O.EmployeeID
inner join [Order Details] as OD on O.OrderID=OD.OrderID
inner join Products as P on OD.ProductID=P.ProductID
inner join Categories as C on P.CategoryID=C.CategoryID
group by E.EmployeeID, E.FirstName, E.LastName, C.CategoryName
order by C.CategoryName, E.EmployeeID


--7. Total de ventas (US$) de cada categoría en el año 97. Incluye el nombre de la
--categoría.
select * from [Order Details]
select * from Products
select * from Categories

select C.CategoryName, (OD.Quantity*OD.UnitPrice*(1-OD.Discount)) as [Ganancia en ventas $] from [Order Details] as OD
inner join Products as P on OD.ProductID=P.ProductID
inner join Categories as C on P.CategoryID=C.CategoryID
group by C.CategoryName, OD.Quantity, OD.UnitPrice, OD.Discount
order by C.CategoryName

---total ganancias de cada venta
select ProductID, Quantity*UnitPrice*(1-Discount) as Venta$ from [Order Details]


----resuelto
select C.CategoryName, SUM(VentasProductos.Venta$) as [Total de ventas en $] from Categories as C
inner join Products as P on C.CategoryID=P.CategoryID
inner join(
	select ProductID, Quantity*UnitPrice*(1-Discount) as Venta$ from [Order Details]
) as VentasProductos on P.ProductID=VentasProductos.ProductID
group by C.CategoryName


--8. Productos que han comprado más de un cliente del mismo país, indicando el
--nombre del producto, el país y el número de clientes distintos de ese país que
--lo han comprado.

--productos comprados por cada cliente
select distinct O.CustomerID, O.ShipCountry, OD.ProductID from Orders as O
inner join [Order Details] as OD on O.OrderID=Od.OrderID

--resuelto
select P.ProductName, Clientes.ShipCountry, count(Clientes.ShipCountry) as [Numero de clientes] from(
	select distinct O.CustomerID, O.ShipCountry, OD.ProductID from Orders as O
	inner join [Order Details] as OD on O.OrderID=Od.OrderID
) as Clientes
inner join Products as P on Clientes.ProductID=P.ProductID
group by P.ProductName, Clientes.ShipCountry
having count(Clientes.ShipCountry) >1


--9. Total de ventas (US$) en cada país cada año.

select distinct O.ShipCountry, SUM(OD.Quantity*OD.UnitPrice*(1-OD.Discount)) as Ventas, YEAR(O.OrderDate) as Anio from Orders as O
inner join [Order Details] as OD on O.OrderID=Od.OrderID
group by O.ShipCountry, YEAR(O.OrderDate)
order by O.ShipCountry, Anio


--10. Producto superventas de cada año, indicando año, nombre del producto,
--categoría y cifra total de ventas.

select OD.ProductID, SUM(OD.Quantity*OD.UnitPrice*(1-OD.Discount)) as Venta$, YEAR(O.OrderDate) as Anio from Orders as O
inner join [Order Details] as OD on O.OrderID=Od.OrderID
group by OD.ProductID, YEAR(O.OrderDate)

----Ganancias del producto mas vendido cada año
select distinct TotalVentas.Anio, MAX(TotalVentas.Venta$) as Ganancia from(
	select OD.ProductID, SUM(OD.Quantity*OD.UnitPrice*(1-OD.Discount)) as Venta$, YEAR(O.OrderDate) as Anio from Orders as O
	inner join [Order Details] as OD on O.OrderID=Od.OrderID
	group by OD.ProductID, YEAR(O.OrderDate)
) as TotalVentas
group by TotalVentas.Anio

-- ventas de cada producto cada año
select P.ProductName, SUM(OD.Quantity*OD.UnitPrice*(1-OD.Discount)) as Ventas, YEAR(O.OrderDate) as Anio from Products as P
inner join [Order Details] as OD on P.ProductID=OD.ProductID
inner join Orders as O on OD.OrderID=O.OrderID
group by P.ProductName, YEAR(O.OrderDate)
order by P.ProductName, Anio

----
select VentasProducto.ProductName, MaximaVenta.Ganancia, MaximaVenta.Anio from(
	select distinct TotalVentas.Anio, MAX(TotalVentas.Venta$) as Ganancia from(
		select OD.ProductID, SUM(OD.Quantity*OD.UnitPrice*(1-OD.Discount)) as Venta$, YEAR(O.OrderDate) as Anio from Orders as O
		inner join [Order Details] as OD on O.OrderID=Od.OrderID
		group by OD.ProductID, YEAR(O.OrderDate)
	) as TotalVentas
	group by TotalVentas.Anio
) as MaximaVenta
inner join(
	select P.ProductName, SUM(OD.Quantity*OD.UnitPrice*(1-OD.Discount)) as Ventas, YEAR(O.OrderDate) as Anio from Products as P
	inner join [Order Details] as OD on P.ProductID=OD.ProductID
	inner join Orders as O on OD.OrderID=O.OrderID
	group by P.ProductName, YEAR(O.OrderDate)
) as VentasProducto on MaximaVenta.Anio=VentasProducto.Anio and MaximaVenta.Ganancia=VentasProducto.Ventas
order by MaximaVenta.Anio
--------------------------------------
select VentasProducto.ProductName, MaximaVenta.Ganancia, MaximaVenta.Anio from(
	select distinct TotalVentas.Anio, MAX(TotalVentas.Venta$) as Ganancia from(
		select OD.ProductID, SUM(OD.Quantity*OD.UnitPrice*(1-OD.Discount)) as Venta$, YEAR(O.OrderDate) as Anio from Orders as O
		inner join [Order Details] as OD on O.OrderID=Od.OrderID
		group by OD.ProductID, YEAR(O.OrderDate)
	) as TotalVentas
	group by TotalVentas.Anio
) as MaximaVenta
inner join(
	select P.ProductName, SUM(OD.Quantity*OD.UnitPrice*(1-OD.Discount)) as Ventas, YEAR(O.OrderDate) as Anio from Products as P
	inner join [Order Details] as OD on P.ProductID=OD.ProductID
	inner join Orders as O on OD.OrderID=O.OrderID
	group by P.ProductName, YEAR(O.OrderDate)
) as VentasProducto on MaximaVenta.Anio=VentasProducto.Anio and MaximaVenta.Ganancia=VentasProducto.Ventas
order by MaximaVenta.Anio




--11. Cifra de ventas de cada producto en el año 97 y su aumento o disminución
--respecto al año anterior en US $ y en %.

--ventas año 97
select OD.ProductID, sum(OD.UnitPrice*OD.Quantity*(1-OD.Discount)) as Ganancias from [Order Details] as OD
inner join Orders as O on OD.OrderID=O.OrderID
where YEAR(O.OrderDate) = 1997
group by OD.ProductID

----
select P.ProductName, Ventas97.Ganancias as [Ganancias 1997], Ventas97.Ganancias-Ventas96.Ganancias as [Incremento desde 1996],
((Ventas97.Ganancias-Ventas96.Ganancias)*100)/Ventas96.Ganancias as [% de incremento]  from(
	select OD.ProductID, sum(OD.UnitPrice*OD.Quantity*(1-OD.Discount)) as Ganancias from [Order Details] as OD
	inner join Orders as O on OD.OrderID=O.OrderID
	where YEAR(O.OrderDate) = 1997
	group by OD.ProductID
) as Ventas97
inner join(
	select OD.ProductID, sum(OD.UnitPrice*OD.Quantity*(1-OD.Discount)) as Ganancias from [Order Details] as OD
	inner join Orders as O on OD.OrderID=O.OrderID
	where YEAR(O.OrderDate) = 1996
	group by OD.ProductID
) as Ventas96 on Ventas97.ProductID=Ventas96.ProductID
inner join Products as P on Ventas97.ProductID=P.ProductID
order by P.ProductName

--12. Mejor cliente (el que más nos compra) de cada país.

--lo que ha comprado cada cliente de cada pais
select O.CustomerID, SUM(OD.UnitPrice*OD.Quantity*(1-OD.Discount)) as [Total $], O.ShipCountry from [Order Details] as OD
inner join Orders as O on OD.OrderID=O.OrderID
group by O.CustomerID, O.ShipCountry

--mierda
select O.CustomerID, MAX(TotalCompras.[Total $]), O.ShipCountry from(
	select O.CustomerID, SUM(OD.UnitPrice*OD.Quantity*(1-OD.Discount)) as [Total $], O.ShipCountry from [Order Details] as OD
	inner join Orders as O on OD.OrderID=O.OrderID
	group by O.CustomerID, O.ShipCountry
)as TotalCompras
inner join Orders as O on TotalCompras.CustomerID=O.CustomerID and TotalCompras.ShipCountry=O.ShipCountry
group by O.CustomerID, O.ShipCountry

--mas vendido en cada pais
select MAX(MasVendido.[Total $]) as Maximo, MasVendido.ShipCountry from(
select O.CustomerID, SUM(OD.UnitPrice*OD.Quantity*(1-OD.Discount)) as [Total $], O.ShipCountry from [Order Details] as OD
inner join Orders as O on OD.OrderID=O.OrderID
group by O.CustomerID, O.ShipCountry
) as MasVendido
group by MasVendido.ShipCountry

--resuelto
select TotalVentas.CustomerID, MasVendido.Maximo, MasVendido.ShipCountry from(
	select O.CustomerID, SUM(OD.UnitPrice*OD.Quantity*(1-OD.Discount)) as [Total $], O.ShipCountry from [Order Details] as OD
	inner join Orders as O on OD.OrderID=O.OrderID
	group by O.CustomerID, O.ShipCountry
) as TotalVentas
inner join(
	select MAX(MasVentas.[Total $]) as Maximo, MasVentas.ShipCountry from(
		select O.CustomerID, SUM(OD.UnitPrice*OD.Quantity*(1-OD.Discount)) as [Total $], O.ShipCountry from [Order Details] as OD
		inner join Orders as O on OD.OrderID=O.OrderID
		group by O.CustomerID, O.ShipCountry
	) as MasVentas
	group by MasVentas.ShipCountry
) as MasVendido on TotalVentas.[Total $]=MasVendido.Maximo and TotalVentas.ShipCountry=MasVendido.ShipCountry
order by MasVendido.ShipCountry



--13. Número de productos diferentes que nos compra cada cliente. Incluye el
--nombre y apellidos del cliente y su dirección completa.
select * from Customers

select C.ContactName, C.[Address], C.City, C.Region, C.PostalCode, C.Country, count(distinct OD.ProductID) as Productos from [Order Details] as OD
inner join Orders as O on OD.OrderID=O.OrderID
inner join Customers as C on O.CustomerID=C.CustomerID
group by C.ContactName, C.[Address], C.City, C.Region, C.PostalCode, C.Country


--14. Clientes que nos compran más de cinco productos diferentes.

select C.ContactName,  count(distinct OD.ProductID) as Productos from [Order Details] as OD
inner join Orders as O on OD.OrderID=O.OrderID
inner join Customers as C on O.CustomerID=C.CustomerID
group by C.ContactName, C.[Address], C.City, C.Region, C.PostalCode, C.Country
having count(distinct OD.ProductID)>5

--15. Vendedores (nombre y apellidos) que han vendido una mayor cantidad que la
--media en US $ en el año 97.

--media del año 97
select SUM(OD.Quantity*OD.UnitPrice*(1-OD.Discount))/count(O.ShipCountry) as Media from [Order Details] as OD
inner join Orders as O on Od.OrderID=O.OrderID
where O.ShipCountry = 'USA' and YEAR(O.OrderDate) = 1997
group by O.ShipCountry

--media de empleados
select O.EmployeeID, SUM(OD.Quantity*OD.UnitPrice*(1-OD.Discount))/count(O.ShipCountry) from [Order Details] as OD
inner join Orders as O on OD.OrderID=O.OrderID
where O.ShipCountry = 'USA' and YEAR(O.OrderDate) = 1997
group by O.EmployeeID

--resuelto
go
with Ventas1997 (Medias, Anio) as(
	select SUM(OD.Quantity*OD.UnitPrice*(1-OD.Discount))/count(O.ShipCountry), YEAR(O.OrderDate) from [Order Details] as OD
	inner join Orders as O on Od.OrderID=O.OrderID
	where O.ShipCountry = 'USA' and YEAR(O.OrderDate) = 1997
	group by O.ShipCountry, YEAR(O.OrderDate)
),
VentasEmpleados (Nombre, Apellido, Ventas, Anio) as(
	select E.FirstName, E.LastName, SUM(OD.Quantity*OD.UnitPrice*(1-OD.Discount))/count(O.ShipCountry), YEAR(O.OrderDate) from [Order Details] as OD
	inner join Orders as O on OD.OrderID=O.OrderID
	inner join Employees as E on O.EmployeeID=E.EmployeeID
	where O.ShipCountry = 'USA' and YEAR(O.OrderDate) = 1997
	group by E.FirstName, E.LastName, YEAR(O.OrderDate)
)
select VE.Nombre, VE.Apellido from Ventas1997 as V
inner join VentasEmpleados as VE on V.Anio=VE.Anio
where VE.Ventas>V.Medias

go

--16. Empleados que hayan aumentado su cifra de ventas más de un 10% entre dos
--años consecutivos, indicando el año en que se produjo el aumento.

--total ventas cada año
select O.EmployeeID, SUM(OD.Quantity*OD.UnitPrice*(1-OD.Discount)) as Ventas, YEAR(O.OrderDate) as Anio from [Order Details] as OD
inner join Orders as O on OD.OrderID=O.OrderID --where YEAR(O.OrderDate) = 1997 or YEAR(O.OrderDate) = 1998
group by O.EmployeeID, YEAR(O.OrderDate)
order by O.EmployeeID, Anio

--
with Ventas1996 (ID, Vendido) as(
	select O.EmployeeID, SUM(OD.Quantity*OD.UnitPrice*(1-OD.Discount)) as Ventas from [Order Details] as OD
	inner join Orders as O on OD.OrderID=O.OrderID
	where YEAR(O.OrderDate) = 1996
	group by O.EmployeeID
),
Ventas1997 (ID, Vendido) as(
	select O.EmployeeID, SUM(OD.Quantity*OD.UnitPrice*(1-OD.Discount)) as Ventas from [Order Details] as OD
	inner join Orders as O on OD.OrderID=O.OrderID
	where YEAR(O.OrderDate) = 1997
	group by O.EmployeeID
),
Ventas1998 (ID, Vendido) as(
	select O.EmployeeID, SUM(OD.Quantity*OD.UnitPrice*(1-OD.Discount)) as Ventas from [Order Details] as OD
	inner join Orders as O on OD.OrderID=O.OrderID
	where YEAR(O.OrderDate) = 1998
	group by O.EmployeeID
)
select Ventas1998.ID from Ventas1996
inner join Ventas1997 on Ventas1996.ID=Ventas1997.ID
inner join Ventas1998 on Ventas1997.ID=Ventas1998.ID
where Ventas1997.Vendido>Ventas1996.Vendido*1.1 and Ventas1998.Vendido>Ventas1997.Vendido*1.1


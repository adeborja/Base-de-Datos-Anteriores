USE Northwind
GO

--1. Nombre de los proveedores y número de productos que nos vende cada uno
--select * from Suppliers
--select * from Products
--select * from [Order Details]
--select * from Orders

select S.CompanyName , COUNT(DISTINCT OD.ProductID) AS [Numero de productos], YEAR(O.OrderDate) as Anio from Suppliers as S
inner join Products as P on S.SupplierID=P.SupplierID
inner join [Order Details] as OD on P.ProductID=OD.ProductID
inner join Orders as O on OD.OrderID=O.OrderID
GROUP BY S.CompanyName, YEAR(O.OrderDate)
ORDER BY S.CompanyName, Anio

--2. Nombre completo y telefono de los vendedores que trabajen en New York, Seattle, Vermont, Columbia, Los Angeles, Redmond o Atlanta.
--select * from Employees
--select * from EmployeeTerritories
--select * from Territories

select TB.LastName, TB.FirstName, TB.HomePhone from(
	select DISTINCT E.EmployeeID, E.LastName, E.FirstName, E.HomePhone from Employees as E
	inner join EmployeeTerritories as ET on E.EmployeeID=ET.EmployeeID
	inner join Territories as T on ET.TerritoryID=T.TerritoryID
	where T.TerritoryDescription in ('New York','Seattle','Vermont','Columbia','Los Angeles','Redmond','Atlanta')
) as TB

--3. Número de productos de cada categoría y nombre de la categoría.
--select * from Products
--select * from Categories

select COUNT(P.ProductID) as Cantidad, C.CategoryName from Products as P
inner join Categories as C on P.CategoryID=C.CategoryID
group by C.CategoryName


--4. Nombre de la compañía de todos los clientes que hayan comprado queso de cabrales o tofu.
--select * from Customers
--select * from Orders
--select * from [Order Details]
--select * from Products

select C.CompanyName from Customers as C
inner join Orders as O on C.CustomerID=O.CustomerID
inner join [Order Details] as OD on O.OrderID=OD.OrderID
inner join Products as P on OD.ProductID=P.ProductID
where P.ProductName in ('queso de cabrales','tofu')


--5. Empleados (ID, nombre, apellidos y teléfono) que han vendido algo a Bon app' o Meter Franken.
--select * from Employees
--select * from Orders
--select * from Customers

select distinct E.EmployeeID, E.FirstName, E.LastName, E.HomePhone from Employees as E
inner join Orders as O on E.EmployeeID=O.EmployeeID
inner join Customers as C on O.CustomerID=C.CustomerID
where C.CompanyName in ('bon app''','meter franken') --revisar empleados, porque salen todos, realizarlo con subconsulta

select O.EmployeeID from Orders as O
inner join Customers as C on O.CustomerID=C.CustomerID
where C.CompanyName in ('bon app''','meter franken')
group by O.EmployeeID --la anterior es correcta

--6. Empleados (ID, nombre, apellidos, mes y día de su cumpleaños) que no han vendido nunca nada a ningún cliente de Francia. *
--select * from Employees
--select * from Orders

--los que han vendido a francia
select distinct EmployeeID from Orders
where ShipCountry = 'france'

--con select except select
select EmployeeID, FirstName, LastName, MONTH(BirthDate) as [Mes nacimiento], DAY(BirthDate) as [Dia nacimiento] from Employees
except
select distinct E.EmployeeID, E.FirstName, E.LastName, MONTH(E.BirthDate) as [Mes nacimiento], DAY(E.BirthDate) as [Dia nacimiento] from Orders as O
inner join Employees as E on O.EmployeeID=E.EmployeeID
where O.ShipCountry = 'ireland'

--con with
with DatosEmpleados (ID, Nombre, Apellido, Mes, Dia) as
(select EmployeeID, FirstName, LastName, MONTH(BirthDate), DAY(BirthDate) from Employees)
, EmpleadosExcluidos(ID) as
(select distinct EmployeeID from Orders where ShipCountry = 'ireland')
select DE.ID, DE.Nombre, DE.Apellido, DE.Mes, DE.Dia from DatosEmpleados as DE
inner join EmpleadosExcluidos as EE on DE.ID=EE.ID
where DE.ID not in (EE.ID)

with DatosEmpleados (ID, Nombre, Apellido, Mes, Dia) as
(select EmployeeID, FirstName, LastName, MONTH(BirthDate), DAY(BirthDate) from Employees)
, EmpleadosExcluidos(ID, Nombre, Apellido, Mes, Dia) as
(select distinct E.EmployeeID, E.FirstName, E.LastName, MONTH(E.BirthDate), DAY(E.BirthDate) from Orders as O
inner join Employees as E on O.EmployeeID=E.EmployeeID
where O.ShipCountry = 'ireland')
select ID, Nombre, Apellido, Mes, Dia from DatosEmpleados
except
select ID, Nombre, Apellido, Mes, Dia from EmpleadosExcluidos
--NO SE PUEDE, TIENE QUE UTILIZAR SUBCONSULTAS EN LOS SELECT DE LOS WITH

--7. Total de ventas en US$ de productos de cada categoría (nombre de la categoría).
--select * from Categories
--select * from Products
--select * from [Order Details]

select C.CategoryName, SUM(OD.Ganancia) as [Total $] from Categories AS C
inner join Products as P on C.CategoryID=P.CategoryID
inner join(
	select ProductID, UnitPrice*Quantity*(1-Discount) as Ganancia from [Order Details]
) as OD on P.ProductID=OD.ProductID
group by C.CategoryName


--8. Total de ventas en US$ de cada empleado cada año (nombre, apellidos, dirección).
--select * from Employees
--select * from Orders
--select * from [Order Details]

select E.FirstName, E.LastName, E.[Address], YEAR(O.OrderDate) as Anio, SUM(OD.Ganancia) as [Total $] from Employees as E
inner join Orders as O on E.EmployeeID=O.EmployeeID
inner join(
	select OrderID, UnitPrice*Quantity*(1-Discount) as Ganancia from [Order Details]
) as OD on O.OrderID=OD.OrderID
group by E.FirstName, E.LastName, E.[Address], YEAR(O.OrderDate)
order by E.FirstName, E.LastName, E.[Address], Anio

--9. Ventas de cada producto en el año 97. Nombre del producto y unidades.
--select * from Products
--select * from [Order Details]
--select * from Orders

select P.ProductName, SUM(OD.Quantity) as [Unidades vendidas], SUM(OD.UnitPrice*OD.Quantity*(1-OD.Discount)) as Ganancias from Products as P
inner join [Order Details] as OD on OD.ProductID=P.ProductID
inner join Orders as O on OD.OrderID=O.OrderID
where YEAR(O.OrderDate) = 1997
group by P.ProductName
order by P.ProductName


--10. Cuál es el producto del que hemos vendido más unidades en cada país. *
select * from Products
select * from [Order Details]
select * from Orders

select P.ProductName, SUM(OD.Quantity) as Cantidad, O.ShipCountry from Products as P
inner join [Order Details] as OD on P.ProductID=OD.ProductID
inner join Orders as O on OD.OrderID=O.OrderID
--where O.ShipCountry = 'USA'
group by P.ProductName, O.ShipCountry
order by P.ProductName, Cantidad desc


select distinct T.ShipCountry, T.ProductName, MAX(T.Cantidad) as MaximoVentas from(
	select P.ProductName, SUM(OD.Quantity) as Cantidad, O.ShipCountry from Products as P
	inner join [Order Details] as OD on P.ProductID=OD.ProductID
	inner join Orders as O on OD.OrderID=O.OrderID
	group by P.ProductName, O.ShipCountry
) as T
group by T.ProductName, T.ShipCountry
order by T.ProductName, MaximoVentas desc

----------------------------------------

select Y.ShipCountry, T.ProductName, MAX(T.Cantidad) as MaximoVentas from(
	select P.ProductName, SUM(OD.Quantity) as Cantidad, O.ShipCountry from Products as P
	inner join [Order Details] as OD on P.ProductID=OD.ProductID
	inner join Orders as O on OD.OrderID=O.OrderID
	group by P.ProductName, O.ShipCountry
) as T
inner join (
	select distinct ShipCountry from Orders
) as Y on T.ShipCountry=Y.ShipCountry
group by T.ProductName, Y.ShipCountry
order by T.ProductName, MaximoVentas desc, Y.ShipCountry

---------------------------------------

select P.ProductName, SUM(OD.Quantity) as Cantidad, O.ShipCountry from Products as P
inner join [Order Details] as OD on P.ProductID=OD.ProductID
inner join Orders as O on OD.OrderID=O.OrderID
group by P.ProductName, O.ShipCountry

select TT.ShipCountry, MAX(Cantidad) from(
	select O.ShipCountry, SUM(OD.Quantity) as Cantidad, OD.ProductID from Orders as O
	inner join [Order Details] as OD on O.OrderID=OD.OrderID
	group by O.ShipCountry, OD.ProductID
) as TT
group by TT.ShipCountry

--=====
select T1.ProductName, T2.ShipCountry, T2.Ventas from(
	select P.ProductName, SUM(OD.Quantity) as Cantidad, O.ShipCountry from Products as P
	inner join [Order Details] as OD on P.ProductID=OD.ProductID
	inner join Orders as O on OD.OrderID=O.OrderID
	group by P.ProductName, O.ShipCountry
) as T1
inner join (
	select TT.ShipCountry, MAX(Cantidad) as Ventas from(
		select O.ShipCountry, SUM(OD.Quantity) as Cantidad, OD.ProductID from Orders as O
		inner join [Order Details] as OD on O.OrderID=OD.OrderID
		group by O.ShipCountry, OD.ProductID
	) as TT
	group by TT.ShipCountry
) as T2 on T1.Cantidad=T2.Ventas and T1.ShipCountry=T2.ShipCountry
order by T1.ShipCountry, T2.Ventas



--11. Empleados (nombre y apellidos) que trabajan a las órdenes de Andrew Fuller.
select * from Employees

select EmployeeID from Employees
where FirstName='Andrew' and LastName='Fuller'

select FirstName, LastName from Employees
where ReportsTo in (
	select EmployeeID from Employees
	where FirstName='Andrew' and LastName='Fuller'
)


--12. Número de subordinados que tiene cada empleado, incluyendo los que no tienen ninguno. Nombre, apellidos, ID.
select * from Employees

select EmployeeID, ReportsTo from Employees

--With JefeEmpleados (ID, jefe) as
--(select EmployeeID, ReportsTo from Employees)
--, DatosEmpleados (ID, nombre, apellido) as 
--(select EmployeeID, FirstName, LastName from Employees)


select E.EmployeeID, E.FirstName, E.LastName, count(E2.ReportsTo) as Subordinados from Employees as E
inner join(
	select EmployeeID, ReportsTo from Employees
) as E2 on E.EmployeeID=E.EmployeeID
where E.EmployeeID=E2.ReportsTo
group by E.EmployeeID, E.FirstName, E.LastName

--------------------

select E.EmployeeID, E.FirstName, E.LastName, EmpleadosConSubordinados.Subordinados from(
	select E.EmployeeID, E.FirstName, E.LastName, count(E2.ReportsTo) as Subordinados from Employees as E
	inner join(
		select EmployeeID, ReportsTo from Employees
	) as E2 on E.EmployeeID=E.EmployeeID
	where E.EmployeeID=E2.ReportsTo
	group by E.EmployeeID, E.FirstName, E.LastName
) as EmpleadosConSubordinados
right join Employees as E on EmpleadosConSubordinados.EmployeeID=E.EmployeeID

-------------------

select E.EmployeeID, E.FirstName, E.LastName, case 
												when EmpleadosConSubordinados.Subordinados is null then 0
												else EmpleadosConSubordinados.Subordinados
												end
as Subordinados from(
	select E.EmployeeID, E.FirstName, E.LastName, count(E2.ReportsTo) as Subordinados from Employees as E
	inner join(
		select EmployeeID, ReportsTo from Employees
	) as E2 on E.EmployeeID=E.EmployeeID
	where E.EmployeeID=E2.ReportsTo
	group by E.EmployeeID, E.FirstName, E.LastName
) as EmpleadosConSubordinados
right join Employees as E on EmpleadosConSubordinados.EmployeeID=E.EmployeeID

-----

select Todos.EmployeeID, Todos.FirstName, Todos.LastName, count(E.ReportsTo) as subordinados from Employees as E
right join Employees as Todos on E.ReportsTo=Todos.EmployeeID
group by Todos.EmployeeID, Todos.FirstName, Todos.LastName
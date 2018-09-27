use Northwind
go

--1. Nombre del pa�s y n�mero de clientes de cada pa�s, ordenados alfab�ticamente por el nombre del pa�s.
--select * from Customers

select Country, count(CustomerID) as [Customers amount] from Customers group by Country order by Country

--2. ID de producto y n�mero de unidades vendidas de cada producto.
--select * from Products

--select ProductID, UnitsOnOrder from Products

--select * from [Order Details]

select ProductID, sum(Quantity) as Cantidad from [Order Details] group by ProductID order by ProductID

--3. ID del cliente y n�mero de pedidos que nos ha hecho.
--select * from Orders

select CustomerID, count(orderid) as [Pedidos] from Orders group by CustomerID

--4. ID del cliente, a�o y n�mero de pedidos que nos ha hecho cada a�o.

select CustomerID, year(OrderDate) as [Anio], count(OrderID) as [Pedidos] from Orders
	group by CustomerID, year(OrderDate) order by CustomerID

--5. ID del producto, precio unitario y total facturado de ese producto, ordenado por cantidad facturada de mayor a menor.
--Si hay varios precios unitarios para el mismo producto tomaremos el mayor.
--select * from [Order Details]

select ProductID, MAX(UnitPrice) as Precio, MAX(UnitPrice)*SUM(Quantity) as TotalFacturado from [Order Details]
	group by ProductID order by TotalFacturado

--6. ID del proveedor e importe total del stock acumulado de productos correspondientes a ese proveedor.
--select * from Products

select SupplierID, SUM(UnitsInStock*UnitPrice) as [Importe total del stock] from Products group by SupplierID

--7. N�mero de pedidos registrados mes a mes de cada a�o.
--select * from Orders

select count(OrderID) as Pedidos, month(OrderDate) as Mes, year(OrderDate) as Anio from Orders
	group by year(OrderDate), month(OrderDate) order by year(OrderDate), month(OrderDate)

select count(OrderID) as Pedidos, datename(month,OrderDate) as Mes, year(OrderDate) as Anio from Orders
	group by year(OrderDate), datename(month,OrderDate), month(OrderDate) order by year(OrderDate), DATEPART(month,orderdate)

--8. A�o y tiempo medio transcurrido entre la fecha de cada pedido (OrderDate) y la fecha en la que lo hemos
--enviado (ShipDate), en d�as para cada a�o.
--select * from Orders

select year(OrderDate) as Anio, SUM(DATEDIFF(day,OrderDate,ShippedDate))/count(orderid) as [Media dias transcurridos] from Orders
	group by year(OrderDate) order by Anio

select year(OrderDate) as Anio, AVG(DATEDIFF(day,OrderDate,ShippedDate)) as [Media dias transcurridos] from Orders
	group by year(OrderDate) order by Anio

--9. ID del distribuidor y n�mero de pedidos enviados a trav�s de ese distribuidor.
--select * from Orders

select ShipVia, count(OrderID) as Pedidos from Orders group by ShipVia

--10. ID de cada proveedor y n�mero de productos distintos que nos suministra.
select * from Products

select distinct count(ProductID) as Productos, SupplierID from Products group by SupplierID

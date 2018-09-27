use Northwind
go


 --1. Inserta un nuevo cliente.
select * from Customers

insert into Customers
(CustomerID, CompanyName, ContactName, ContactTitle, [Address], City, Region, PostalCode, Country, Phone, Fax)
VALUES
('MOSTA','Mostachones Utrera', 'Aitor Tilla', 'Owner', 'Calle pastelosa S/N', 'Utrera', null, '41234', 'Spain', null, null)

 --2. Véndele (hoy) tres unidades de "Pavlova”, diez de "Inlagd Sill” y 25 de "Filo Mix”. El distribuidor será Speedy Express
 --		y el vendedor Laura Callahan.
 select * from Orders
 select * from [Order Details]
 select * from Products order by ProductName
 select * from Suppliers order by CompanyName
 select * from Shippers

 begin transaction

 rollback

 commit

 insert into Orders
 (OrderID, CustomerID, EmployeeID, OrderDate, RequiredDate, ShippedDate, ShipVia, Freight, ShipName, ShipAddress, ShipCity, ShipRegion, ShipPostalCode, ShipCountry)
 (select (select MAX(OrderID)+1, 'MOSTA', (select EmployeeID from Employees where FirstName='Laura' and LastName='Callahan'),
 CURRENT_TIMESTAMP, null, null, (select ShipperID from Shippers where CompanyName='Speedy Express'), null
 ,(select CompanyName from Customers where CustomerID='MOSTA')
 ,(select [Address] from Customers where CustomerID='MOSTA')
 ,(select City from Customers where CustomerID='MOSTA')
 ,(select Region from Customers where CustomerID='MOSTA')
 ,(select PostalCode from Customers where CustomerID='MOSTA')
 ,(select Country from Customers where CustomerID='MOSTA')
  from Orders))

  ----probar con cross join

 insert into Orders
 (OrderID, CustomerID, EmployeeID, OrderDate, RequiredDate, ShippedDate, ShipVia, Freight, ShipName, ShipAddress, ShipCity, ShipRegion, ShipPostalCode, ShipCountry)
 (select MAX(O.OrderID)+1, C.CustomerID, (select EmployeeID from Employees where FirstName='Laura' and LastName='Callahan'),
 CURRENT_TIMESTAMP, null, null, (select ShipperID from Shippers where CompanyName='Speedy Express'), null
 , C.CompanyName, C.[Address], C.City, C.Region, C.PostalCode, C.Country
 from Orders as O
 cross join Customers as C
 where C.CustomerID = 'MOSTA'
 group by C.CustomerID, C.CompanyName, C.[Address], C.City, C.Region, C.PostalCode, C.Country)

------------------- parte 1

insert into Orders
 (CustomerID, EmployeeID, OrderDate, RequiredDate, ShippedDate, ShipVia, Freight, ShipName, ShipAddress, ShipCity, ShipRegion, ShipPostalCode, ShipCountry)
 (select C.CustomerID, E.EmployeeID,
 CURRENT_TIMESTAMP, null, null, S.ShipperID, null
 , C.CompanyName, C.[Address], C.City, C.Region, C.PostalCode, C.Country
 from Orders as O
 cross join Customers as C
 cross join Employees as E
 cross join Shippers as S
 where C.CustomerID = 'MOSTA'
 and E.FirstName='Laura' and E.LastName='Callahan'
 and S.CompanyName='Speedy Express'
 group by C.CustomerID, C.CompanyName, C.[Address], C.City, C.Region, C.PostalCode, C.Country, E.EmployeeID, S.ShipperID)

 ---------parte 2
 select * from [Order Details]


 begin transaction

 rollback

 commit


 insert into [Order Details]
 (OrderID, ProductID, UnitPrice, Quantity, Discount)
 (select MAX(O.OrderID), P.ProductID, P.UnitPrice, 3, 0.0
 from Orders as O
 cross join Products as P
 where O.CustomerID = 'MOSTA'
 and P.ProductName = 'Pavlova'
 group by P.ProductID, P.UnitPrice)


 insert into [Order Details]
 (OrderID, ProductID, UnitPrice, Quantity, Discount)
 (select MAX(O.OrderID), P.ProductID, P.UnitPrice, 10, 0.0
 from Orders as O
 cross join Products as P
 where O.CustomerID = 'MOSTA'
 and P.ProductName = 'Inlagd Sill'
 group by P.ProductID, P.UnitPrice)


 insert into [Order Details]
 (OrderID, ProductID, UnitPrice, Quantity, Discount)
 (select MAX(O.OrderID), P.ProductID, P.UnitPrice, 25, 0.0
 from Orders as O
 cross join Products as P
 where O.CustomerID = 'MOSTA'
 and P.ProductName = 'Filo Mix'
 group by P.ProductID, P.UnitPrice)


 --3. Ante la bajada de ventas producida por la crisis, hemos de adaptar nuestros precios según las siguientes reglas:
 --		Los productos de la categoría de bebidas (Beverages) que cuesten más de $10 reducen su precio en un dólar.
 --		Los productos de la categoría Lácteos que cuesten más de $5 reducen su precio en un 10%.
 --		Los productos de los que se hayan vendido menos de 200 unidades en el último año, reducen su precio en un 5%
 
 select * from Categories
 select * from Products where CategoryID = 1

 begin transaction

 rollback

 commit

 update Products
 set UnitPrice = UnitPrice-1
 where ProductID in (select P.ProductID from Categories as C
						inner join Products as P on C.CategoryID=P.CategoryID
						where C.CategoryName = 'Beverages'
						 and P.UnitPrice>10.0)


 
 --4. Inserta un nuevo vendedor llamado Michael Trump. Asígnale los territorios de Louisville, Phoenix, Santa Cruz y Atlanta.
 
 select * from Employees
 select * from EmployeeTerritories
 select * from Territories

 begin transaction

 rollback

 commit


 insert into Employees
 (LastName, FirstName)
 values
 ('Trump','Michael')

 insert into EmployeeTerritories
 (EmployeeID, TerritoryID)
 (select MAX(E.EmployeeID), ET.TerritoryID from EmployeeTerritories as ET
 cross join Employees as E
 where ET.TerritoryID in(
	select TerritoryID from Territories where TerritoryDescription in ('Louisville', 'Phoenix', 'Santa Cruz', 'Atlanta')
	)
 group by ET.TerritoryID
 )


 
 --5. Haz que las ventas del año 97 de Robert King que haya hecho a clientes de los estados de California y Texas se le asignen
 --		al nuevo empleado.

 select * from Orders where EmployeeID in (7,10) order by CustomerID

 select * from Customers where Region is not null and Country='usa'


 begin transaction

 rollback

 commit

 update Orders
 set EmployeeID = (select EmployeeID from Employees where FirstName = 'Michael' and LastName = 'Trump')
 where EmployeeID in (select EmployeeID from Employees where FirstName = 'Robert' and LastName = 'King')
 and YEAR(OrderDate) = 1997
 and CustomerID in (
	select CustomerID from Customers where Region in ('CA','TX') --,'WA'
 )

 
 --6. Inserta un nuevo producto con los siguientes datos:
 --       ProductID: 90
 --       ProductName: Nesquick Power Max
 --       SupplierID: 12
 --       CategoryID: 3
 --       QuantityPerUnit: 10 x 300g
 --       UnitPrice: 2,40
 --       UnitsInStock: 38
 --       UnitsOnOrder: 0
 --       ReorderLevel: 0
 --       Discontinued: 0

 select * from Products

 begin transaction

 rollback

 commit

 
 insert into Products
 (ProductName, SupplierID, CategoryID, QuantityPerUnit, UnitPrice, UnitsInStock, UnitsOnOrder, ReorderLevel, Discontinued)
 values
 ('Nesquick Power Max',12,3,'10 x 300g',2.40,38,0,0,0)
 
 
 --7. Inserta un nuevo producto con los siguientes datos:
 --       ProductID: 91
 --       ProductName: Mecca Cola
 --       SupplierID: 1
 --       CategoryID: 1
 --       QuantityPerUnit: 6 x 75 cl
 --       UnitPrice: 7,35
 --       UnitsInStock: 14
 --       UnitsOnOrder: 0
 --       ReorderLevel: 0
 --       Discontinued: 0

 insert into Products
 (ProductName, SupplierID, CategoryID, QuantityPerUnit, UnitPrice, UnitsInStock, UnitsOnOrder, ReorderLevel, Discontinued)
 values
 ('Mecca Cola',1,1,'6 x 75 cl',7.35,14,0,0,0)
 
 
 --8. Todos los que han comprado "Outback Lager" han comprado cinco años después la misma cantidad de
 --		Mecca Cola al mismo vendedor
 select O.* from Orders as O 
 inner join [Order Details] as OD on O.OrderID=Od.OrderID
 inner join Products as P on OD.ProductID=P.ProductID 
 where P.ProductName = 'Outback Lager'

 begin transaction

 rollback

 commit

 GO
 declare @tabla as table(
 id int not null)

 insert into @tabla
 select O.OrderID from Orders as O 
 inner join [Order Details] as OD on O.OrderID=Od.OrderID
 inner join Products as P on OD.ProductID=P.ProductID 
 where P.ProductName = 'Outback Lager'
 

 --select * from @tabla
 --select * from orders
 --select * from products
 --select * from [order details]

 insert into Orders
 select CustomerID,EmployeeID,DATEADD(YEAR,5,OrderDate), DATEADD(YEAR,5,RequiredDate), DATEADD(YEAR,5,ShippedDate), --ISNULL(DATEADD(YEAR,5,ShippedDate),DATEADD(YEAR,5,ShippedDate))
 ShipVia, null, ShipName, ShipAddress, ShipCity, ShipRegion, ShipPostalCode, ShipCountry
  from Orders
 where OrderID in (select id from @tabla) --por terminar, introducir nuevo producto y datos en order details

 --delete from Orders where YEAR(OrderDate) between 1999 and 2015

 insert into [Order Details]
 select @tabla.id, (select ProductID from Products where ProductName='Mecca Cola'), P.UnitPrice, OD.Quantity, 0 from [Order Details] as OD
 inner join @tabla on OD.OrderID=@tabla.id
 inner join Products as P on OD.ProductID=P.ProductID
 where OD.OrderID in (select id from @tabla)
 and OD.ProductID = (select ProductID from Products where ProductName='Outback Lager')

 --9. El pasado 20 de enero, Margaret Peacock consiguió vender una caja de Nesquick Power Max a todos los clientes
 --		que le habían comprado algo anteriormente. Los datos de envío (dirección, transportista, etc) son los mismos de
 --		alguna de sus ventas anteriores a ese cliente).




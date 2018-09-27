use AdventureWorks2012
go

--Consultas sencillas

--1.Nombre del producto, código y precio, ordenado de mayor a menor precio
--select * from Production.Product

select Name, ProductID, ListPrice from Production.Product order by ListPrice

--2.Número de direcciones de cada Estado/Provincia
--select * from Person.Address

select count(AddressID) as [Numero de direcciones], StateProvinceID from person.[Address] group by StateProvinceID

--3.Nombre del producto, código, número, tamaño y peso de los productos que estaban a la venta durante todo el mes de septiembre
--de 2002. No queremos que aparezcan aquellos cuyo peso sea superior a 2000.
Select * from Production.Product

select name, ProductID, ProductNumber, Size, [Weight] from Production.Product
	where DATEFROMPARTS(2002,9,22) between SellStartDate and SellEndDate 
	or (SellStartDate <= DATEFROMPARTS(2002,9,22) and SellEndDate is null)
	and Weight>2000

--4.Margen de beneficio de cada producto (Precio de venta menos el coste), y porcentaje que supone respecto del precio de venta. 
select * from Production.Product

select name, StandardCost, ListPrice, ListPrice-StandardCost as [Margen de beneficio], ((ListPrice*100)/StandardCost)-100 as [%] from Production.Product
	where StandardCost>0


--Consultas de dificultad media
--5.Número de productos de cada categoría
--select * from Production.Product
--select * from Production.ProductSubcategory
--select * from Production.ProductCategory

select ProductSubcategoryID, count(ProductID) as Cantidad from Production.Product group by ProductSubcategoryID


--6.Igual a la anterior, pero considerando las categorías generales (categorías de categorías).

select PC.ProductCategoryID, count(P.ProductID) as Cantidad from Production.Product as P
inner join Production.ProductSubcategory as PS on PS.ProductSubcategoryID=P.ProductSubcategoryID
inner join Production.ProductCategory as PC on PC.ProductCategoryID=PS.ProductCategoryID
	group by PC.ProductCategoryID



--7.Número de unidades vendidas de cada producto cada año.
--select * from Production.Product
--select * from Purchasing.ProductVendor
--select * from Purchasing.PurchaseOrderDetail

select P.Name, SUM(POD.OrderQty) as Cantidad, YEAR(POD.DueDate) as Anio from Production.Product as P
inner join Purchasing.PurchaseOrderDetail as POD on POD.ProductID=P.ProductID
	group by P.Name,YEAR(POD.DueDate)
	order by P.Name, Anio ASC

--8.Nombre completo, compañía y total facturado a cada cliente
--select * from Purchasing.PurchaseOrderDetail
--select * from Purchasing.PurchaseOrderHeader
--select * from Purchasing.Vendor

--select  from Purchasing.PurchaseOrderDetail as POD
--inner join Purchasing.Vendor as V on V.BusinessEntityID=POD.id


P.person>S.customer>S.store>P.businessentity>Pur.vendor
select * from Person.Person
select * from Sales.Customer
select * from Sales.Store
select * from Person.BusinessEntity
select * from Purchasing.Vendor

--lo dejamos hasta que leo se decida si usamos el nombre de la tienda

--9.Número de producto, nombre y precio de todos aquellos en cuya descripción aparezcan las palabras "race”, "competition” o "performance” 
select * from Production.Product
select * from Production.ProductModel
select * from Production.ProductModelProductDescriptionCulture
select * from Production.ProductDescription

select PR.ProductNumber, PR.Name, PR.ListPrice, PD.[Description] from Production.Product as PR
inner join Production.ProductModel as PM on PM.ProductModelID=PR.ProductModelID
inner join Production.ProductModelProductDescriptionCulture as PMPDC on PMPDC.ProductModelID=PM.ProductModelID
inner join Production.ProductDescription as PD on PD.ProductDescriptionID=PMPDC.ProductDescriptionID
where PD.[Description] like '%race%' or PD.[Description] like '%competition%' or PD.[Description] like '%performance%'


--Consultas avanzadas
--10.Facturación total en cada país; vamos a elegir ser la tienda que vende a los clientes en lugar de la empresa que vende a las tiendas

select * from Sales.SalesOrderHeader --totaldue	--1							--1
select * from sales.Customer					--2
select * from Person.Person
select * from Person.BusinessEntityContact
select * from Sales.Store						--3
select * from Person.BusinessEntity				--4
select * from Person.BusinessEntityAddress		--5
select * from Person.[Address]					--6							--2
select * from Person.StateProvince				--7 --countryregioncode		--3
select * from Person.CountryRegion				--8							--4

select CR.Name, SUM(SOH.TotalDue) as [Total facturado] from Sales.SalesOrderHeader as SOH
inner join Person.[Address] as A on SOH.BillToAddressID=A.AddressID
inner join Person.StateProvince as SP on A.StateProvinceID=SP.StateProvinceID
inner join Person.CountryRegion as CR on SP.CountryRegionCode=CR.CountryRegionCode
group by CR.Name

--11.Facturación total en cada Estado

select SP.Name, SUM(SOH.TotalDue) as [Total facturado] from Sales.SalesOrderHeader as SOH
inner join Person.[Address] as A on SOH.BillToAddressID=A.AddressID
inner join Person.StateProvince as SP on A.StateProvinceID=SP.StateProvinceID
group by SP.Name


--12.Margen medio de beneficios y total facturado en cada país


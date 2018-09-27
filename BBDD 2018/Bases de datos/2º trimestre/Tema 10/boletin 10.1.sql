use AdventureWorks2012
go


--1. Nombre y dirección completas de todos los clientes que tengan alguna sede en Canada.
--select * from Sales.Customer
--select * from Person.Person
--select * from Person.Address
--select * from Person.StateProvince

--stateprovinte -> address -> businessenttyaddress -> businessentity -> person

--select * from Person.AddressType
--select * from Person.BusinessEntityAddress

go
CREATE VIEW AW_ClientesCanada
AS
select P.FirstName, P.MiddleName, P.LastName, A.AddressLine1, A.AddressLine2, A.PostalCode, A.City, SP.Name from Person.StateProvince as SP
inner join Person.[Address] as A on SP.StateProvinceID=A.StateProvinceID
inner join Person.BusinessEntityAddress as BEA on A.AddressID=BEA.AddressID
inner join Person.BusinessEntity as BE on BEA.BusinessEntityID=BE.BusinessEntityID
inner join Person.Person as P on BE.BusinessEntityID=P.BusinessEntityID
where SP.CountryRegionCode = 'CA'
go

select * from AW_ClientesCanada


--2. Nombre de cada categoría y producto más caro y más barato de la misma, incluyendo los precios.
--select * from Production.ProductCategory
--select * from Production.ProductSubcategory
--select * from Production.Product

go
CREATE VIEW AW_CategoriaMinimoMaximo
AS
select PC.Name, MIN(P.ListPrice) as Minimo, MAX(P.ListPrice) as Maximo from Production.Product as P
inner join Production.ProductSubcategory as PSC on P.ProductSubcategoryID=PSC.ProductSubcategoryID
inner join Production.ProductCategory as PC on PSC.ProductCategoryID=PC.ProductCategoryID
group by PC.Name
go

select * from AW_CategoriaMinimoMaximo


--3. Total de Ventas en cada país en dinero (Ya hecha en el boletín 9.3).
--select * from Sales.SalesOrderDetail
--select * from Sales.SalesOrderHeader
--select * from Sales.SalesTerritory

go
create view AW_TotalVentasPais
as
select ST.Name, SUM(SOH.TotalDue) as Ventas from Sales.SalesOrderHeader as SOH
inner join Sales.SalesTerritory as ST on SOH.TerritoryID=ST.TerritoryID
group by ST.Name
go

select * from AW_TotalVentasPais


--4. Número de clientes que tenemos en cada país. Contaremos cada dirección como si fuera un cliente distinto.
--select * from Person.Address
--select * from Person.StateProvince
--select * from Person.CountryRegion

go
create view AW_ClientesPorPais
AS
select CR.Name, count(A.AddressID) as clientes from Person.[Address] as A
inner join Person.StateProvince as SP on A.StateProvinceID=SP.StateProvinceID
inner join Person.CountryRegion as CR on SP.CountryRegionCode=CR.CountryRegionCode
group by CR.Name
go

select * from AW_ClientesPorPais


--5. Repite la consulta anterior pero contando cada cliente una sola vez. Si el cliente tiene varias direcciones,
--sólo consideraremos aquella en la que nos haya comprado la última vez.
select * from sales.Customer
select * from Sales.SalesOrderHeader
select * from Person.[Address]

go
create view AW_ClientesUnicosPorPais
as
select t2.Name, count(T2.[Ultima direccion]) as clientes from(
	select T.CustomerID, MIN(T.AddressLine1) as [Ultima direccion], T.Name from(
		select C.CustomerID, A.AddressLine1, CR.Name from Sales.Customer as C
		inner join Sales.SalesOrderHeader as SOH on C.CustomerID=SOH.CustomerID
		inner join Person.[Address] as A on SOH.BillToAddressID=A.AddressID
		inner join Person.StateProvince as SP on A.StateProvinceID=SP.StateProvinceID
		inner join Person.CountryRegion as CR on SP.CountryRegionCode=CR.CountryRegionCode
		--order by SOH.ShipDate
	) as T
	group by T.CustomerID, T.Name
) as T2
group by T2.Name
go

select * from AW_ClientesUnicosPorPais
select * from AW_ClientesPorPais

--6.Repite la consulta anterior pero en este caso si el cliente tiene varias direcciones, sólo
--consideraremos aquella en la que nos haya comprado más.
go
create view AW_ClientesPorPaisDireccionConMasCompras
as
select T3.Name, count(T3.CustomerID) as clientes from(
	select T2.CustomerID, T2.AddressLine1, MAX(T2.veces) as [mas veces], T2.Name from(
		select T.CustomerID, T.AddressLine1, count(T.AddressLine1) as veces,  T.Name from(
			select C.CustomerID, A.AddressLine1, CR.Name from Sales.Customer as C
			inner join Sales.SalesOrderHeader as SOH on C.CustomerID=SOH.CustomerID
			inner join Person.[Address] as A on SOH.BillToAddressID=A.AddressID
			inner join Person.StateProvince as SP on A.StateProvinceID=SP.StateProvinceID
			inner join Person.CountryRegion as CR on SP.CountryRegionCode=CR.CountryRegionCode
			--order by SOH.ShipDate
		) as T
		group by T.CustomerID, T.AddressLine1, T.Name
	) as T2
	group by T2.CustomerID, T2.AddressLine1, T2.Name
) as T3
group by T3.Name
go

select * from AW_ClientesPorPaisDireccionConMasCompras


--7. Los tres países en los que más hemos vendido, incluyendo la cifra total de ventas y la fecha de la última venta.
select * from Sales.SalesOrderHeader
select * from Person.[Address]
select * from Person.StateProvince
select * from Person.CountryRegion


select CR.Name, SUM(SOH.TotalDue) as [Total facturado] from Sales.SalesOrderHeader as SOH
inner join Person.[Address] as A on SOH.ShipToAddressID=A.AddressID
inner join Person.StateProvince as SP on A.StateProvinceID=SP.StateProvinceID
inner join Person.CountryRegion as CR on SP.CountryRegionCode=CR.CountryRegionCode
group by CR.Name

--select ShipToAddressID, count(ShipDate) as veces from Sales.SalesOrderHeader
select ShipToAddressID, MAX(ShipDate) as [compra mas reciente] from Sales.SalesOrderHeader
--where ShipToAddressID = 15675
group by ShipToAddressID
--having count(*)>1

----------------------------------------------
go
select TOP 3 PaisesMasVentas.[Total facturado], PaisesMasVentas.Name, UltimaVenta.[compra mas reciente] from(
	select CR.Name, SUM(SOH.TotalDue) as [Total facturado] from Sales.SalesOrderHeader as SOH
	inner join Person.[Address] as A on SOH.ShipToAddressID=A.AddressID
	inner join Person.StateProvince as SP on A.StateProvinceID=SP.StateProvinceID
	inner join Person.CountryRegion as CR on SP.CountryRegionCode=CR.CountryRegionCode
	group by CR.Name
) as PaisesMasVentas
inner join(
	select CR.Name, MAX(SOH.ShipDate) as [compra mas reciente] from Sales.SalesOrderHeader as SOH
	inner join Person.[Address] as A on SOH.ShipToAddressID=A.AddressID
	inner join Person.StateProvince as SP on A.StateProvinceID=SP.StateProvinceID
	inner join Person.CountryRegion as CR on SP.CountryRegionCode=CR.CountryRegionCode
	group by CR.Name
) as UltimaVenta on PaisesMasVentas.Name=UltimaVenta.Name
order by PaisesMasVentas.[Total facturado] desc


--8. Sobre la consulta tres de ventas por país, calcula el valor medio y repite la consulta tres pero incluyendo
--solamente los países cuyas ventas estén por encima de la media.
go
alter view AW_MediaGananciasTotal
as
select SUM(SOH.TotalDue)/count(CR.Name) as [Media facturado] from Sales.SalesOrderHeader as SOH
inner join Person.[Address] as A on SOH.ShipToAddressID=A.AddressID
inner join Person.StateProvince as SP on A.StateProvinceID=SP.StateProvinceID
inner join Person.CountryRegion as CR on SP.CountryRegionCode=CR.CountryRegionCode
go
select [Media facturado] from AW_MediaGananciasTotal
------

select * from(
	select CR.Name, SUM(SOH.TotalDue)/count(SOH.DueDate) as [Media facturado] from Sales.SalesOrderHeader as SOH
	inner join Person.[Address] as A on SOH.ShipToAddressID=A.AddressID
	inner join Person.StateProvince as SP on A.StateProvinceID=SP.StateProvinceID
	inner join Person.CountryRegion as CR on SP.CountryRegionCode=CR.CountryRegionCode
	group by CR.Name
) as MediaVentas
where MediaVentas.[Media facturado]>(select [Media facturado] from AW_MediaGananciasTotal)


--9. Nombre de la categoría y número de clientes diferentes que han comprado productos de cada una.
select * from Sales.SalesOrderDetail
select * from Production.ProductCategory

select PC.Name, count(distinct SOH.CustomerID) as Clientes from Production.Product as P
inner join Production.ProductSubcategory as PSC on P.ProductSubcategoryID=PSC.ProductSubcategoryID
inner join Production.ProductCategory as PC on PSC.ProductCategoryID=PC.ProductCategoryID
inner join Sales.SalesOrderDetail as SOD on P.ProductID=SOD.ProductID
inner join Sales.SalesOrderHeader as SOH on SOD.SalesOrderID=SOH.SalesOrderID
group by PC.Name


--10. Clientes que nunca han comprado ninguna bicicleta (discriminarlas por categorías)
go
select Pe.FirstName, Pe.MiddleName, Pe.LastName from Production.Product as P
inner join Production.ProductSubcategory as PSC on P.ProductSubcategoryID=PSC.ProductSubcategoryID
inner join Production.ProductCategory as PC on PSC.ProductCategoryID=PC.ProductCategoryID
inner join Sales.SalesOrderDetail as SOD on P.ProductID=SOD.ProductID
inner join Sales.SalesOrderHeader as SOH on SOD.SalesOrderID=SOH.SalesOrderID
inner join Sales.Customer as C on SOH.CustomerID=C.CustomerID
inner join Person.Person as Pe on C.PersonID=Pe.BusinessEntityID
where PC.Name not in ('Bikes')
group by Pe.FirstName, Pe.MiddleName, Pe.LastName
go

--11. A la consulta anterior, añádele el total de compras (en dinero) efectuadas por cada cliente.
go
select Pe.FirstName, Pe.MiddleName, Pe.LastName, SUM(SOH.TotalDue) as [Total en compras] from Production.Product as P
inner join Production.ProductSubcategory as PSC on P.ProductSubcategoryID=PSC.ProductSubcategoryID
inner join Production.ProductCategory as PC on PSC.ProductCategoryID=PC.ProductCategoryID
inner join Sales.SalesOrderDetail as SOD on P.ProductID=SOD.ProductID
inner join Sales.SalesOrderHeader as SOH on SOD.SalesOrderID=SOH.SalesOrderID
inner join Sales.Customer as C on SOH.CustomerID=C.CustomerID
inner join Person.Person as Pe on C.PersonID=Pe.BusinessEntityID
where PC.Name not in ('Bikes')
group by Pe.FirstName, Pe.MiddleName, Pe.LastName
go


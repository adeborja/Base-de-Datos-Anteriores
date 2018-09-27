use AdventureWorks2012
go

--1. Nombre, numero de producto, precio y color de los productos de color rojo o amarillo cuyo precio esté comprendido entre 50 y 500

select name, ProductNumber, ListPrice, Color from Production.Product where Color in ('yellow','red') and ListPrice between 50.0 and 500.0

--2. Nombre, número de producto, precio de coste,  precio de venta, margen de beneficios total y margen de beneficios en % del precio
--de venta de los productos de categorías inferiores a 16
--select * from production.product

select name, ProductNumber, StandardCost, ListPrice, ListPrice-StandardCost as [Margen de beneficio total],
((ListPrice-StandardCost)*100)/StandardCost as [% de beneficio] from Production.Product where ProductSubcategoryID<16

--3. Empleados cuyo nombre o apellidos contenga la letra "r". Los empleados son los que tienen el valor "EM" en la columna PersonType
--de la tabla Person
--select * from Person.Person

select * from Person.Person where (FirstName like '%r%' or MiddleName like '%r%' or LastName like '%r%') and PersonType = 'EM'

--4. LoginID, nationalIDNumber, edad y puesto de trabajo (jobTitle) de los empleados (tabla Employees) de sexo femenino que
--tengan más de cinco años de antigüedad
--select * from HumanResources.Employee

select LoginID, NationalIDNumber, year(CURRENT_TIMESTAMP)-year(BirthDate) as [Age], JobTitle from HumanResources.Employee
	where Gender='F' and year(current_timestamp)-year(HireDate) > 5

select LoginID, NationalIDNumber, DATEDIFF(MONTH,BirthDate,CURRENT_TIMESTAMP)/12 as [Age], JobTitle from HumanResources.Employee
	where Gender='F' and year(current_timestamp)-year(HireDate) > 5

--5. Ciudades correspondientes a los estados 11, 14, 35 o 70, sin repetir. Usar la tabla Person.Address
--select * from Person.[Address]

select distinct StateProvinceID, city from Person.[Address] where StateProvinceID in (11, 14, 35, 70)
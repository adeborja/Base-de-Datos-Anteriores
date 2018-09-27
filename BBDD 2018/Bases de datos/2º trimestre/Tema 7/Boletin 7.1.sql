USE Northwind

--1.   Nombre de la compañía y dirección completa (dirección, cuidad, país) de todos los 
--clientes que no sean de los Estados Unidos.  
select CompanyName, [Address], City, Country from Customers where Country <> 'usa'


--2.   La consulta anterior ordenada por país y ciudad.
select CompanyName, [Address], City, Country from Customers where Country <> 'usa' order by Country, City


--3.   Nombre, Apellidos, Ciudad y Edad de todos los empleados, ordenados por antigüedad en 
--la empresa.
select FirstName, LastName, City, year(CURRENT_TIMESTAMP)-year(BirthDate) as Edad from Employees order by HireDate


--4.   Nombre y precio de cada producto, ordenado de mayor a menor precio. 
select ProductName, UnitPrice from Products order by UnitPrice desc


--5.   Nombre de la compañía y dirección completa de cada proveedor de algún país de 
--América del Norte. 
select CompanyName, Address, City, Country from Suppliers where Country in ('Canada', 'USA', 'Mexico')


--6.   Nombre del producto, número de unidades en stock y valor total del stock, de los 
--productos que no sean de la categoría 4. 
select ProductName, UnitsInStock, UnitsInStock*UnitPrice as [Valor de stock] from Products where CategoryID <> 4


--7.   Clientes (Nombre de la Compañía, dirección completa, persona de contacto) que no 
--residan en un país de América del Norte y que la persona de contacto no sea el 
--propietario de la compañía 
select * from Employees
select * from Customers order by ContactName


--8.   ID del cliente y número de pedidos realizados por cada cliente, ordenado de mayor a 
--menor número de pedidos. 


--9.   Número de pedidos enviados a cada ciudad, incluyendo el nombre de la ciudad. 
select * from Orders

--10. Número de productos de cada categoría. 
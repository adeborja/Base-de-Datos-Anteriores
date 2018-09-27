USE Northwind

--1.   Nombre de la compa��a y direcci�n completa (direcci�n, cuidad, pa�s) de todos los 
--clientes que no sean de los Estados Unidos.  
select CompanyName, [Address], City, Country from Customers where Country <> 'usa'


--2.   La consulta anterior ordenada por pa�s y ciudad.
select CompanyName, [Address], City, Country from Customers where Country <> 'usa' order by Country, City


--3.   Nombre, Apellidos, Ciudad y Edad de todos los empleados, ordenados por antig�edad en 
--la empresa.
select FirstName, LastName, City, year(CURRENT_TIMESTAMP)-year(BirthDate) as Edad from Employees order by HireDate


--4.   Nombre y precio de cada producto, ordenado de mayor a menor precio. 
select ProductName, UnitPrice from Products order by UnitPrice desc


--5.   Nombre de la compa��a y direcci�n completa de cada proveedor de alg�n pa�s de 
--Am�rica del Norte. 
select CompanyName, Address, City, Country from Suppliers where Country in ('Canada', 'USA', 'Mexico')


--6.   Nombre del producto, n�mero de unidades en stock y valor total del stock, de los 
--productos que no sean de la categor�a 4. 
select ProductName, UnitsInStock, UnitsInStock*UnitPrice as [Valor de stock] from Products where CategoryID <> 4


--7.   Clientes (Nombre de la Compa��a, direcci�n completa, persona de contacto) que no 
--residan en un pa�s de Am�rica del Norte y que la persona de contacto no sea el 
--propietario de la compa��a 
select * from Employees
select * from Customers order by ContactName


--8.   ID del cliente y n�mero de pedidos realizados por cada cliente, ordenado de mayor a 
--menor n�mero de pedidos. 


--9.   N�mero de pedidos enviados a cada ciudad, incluyendo el nombre de la ciudad. 
select * from Orders

--10. N�mero de productos de cada categor�a. 
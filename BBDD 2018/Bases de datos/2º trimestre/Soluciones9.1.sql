--Boletín 9.1
-- Ejercicio 10
USE Northwind
GO
-- Consulta 10 usando with para las subconsultas
-- Producto más vendido de cada país

With VentasProductoPorPais (Producto, NumeroProductos,Pais) AS 
	(select p.ProductName, sum(od.Quantity),o.ShipCountry
			from Products as p
			inner join [Order Details] as od
			on p.ProductID = od.ProductID
			inner join Orders as o
			on o.OrderID = od.OrderID
			group by p.ProductName,o.ShipCountry)
,
VentasPorPais (NumeroProductos,Pais) AS (
	Select max(VePa.NumeroProductos),ShipCountry from 
	(Select p.ProductName, sum(od.Quantity) as [NumeroProductos],o.ShipCountry
				from Products as p
				inner join [Order Details] as od
				on p.ProductID = od.ProductID
				inner join Orders as o
				on o.OrderID = od.OrderID
				group by p.ProductName,o.ShipCountry) AS VePa
		Group By ShipCountry)
-- And finally
SELECT Producto, VPP.Pais,VPPP.NumeroProductos
	FROM VentasProductoPorPais AS VPPP INNER JOIN VentasPorPais AS VPP
	ON VPPP.NumeroProductos = VPP.NumeroProductos
		AND VPPP.Pais = VPP.Pais

-- That's all, folks!
-- Boletin 11. En la base de datos NorthWind. Para comprobar si una tabla existe puedes utilizar la función OBJECT_ID
use Northwind
go

-- 1. Deseamos incluir un producto en la tabla Products llamado "Cruzcampo lata” pero no estamos seguros si se ha insertado o no.
--		El precio son 4,40, el proveedor es el 16, la categoría 1 y la cantidad por unidad es "Pack 6 latas” "Discontinued” 
--		toma el valor 0 y el resto de columnas se dejarán a NULL. Escribe un script que compruebe si existe un producto con ese nombre. 
--		En caso afirmativo, actualizará el precio y en caso negativo insertarlo. 

/*	
	Interfaz del procedimiento comprobarProducto
	Signatura: create procedure comprobarProducto
	Comentario: Este procedimiento comprobará la existencia de un producto en la tabla "Products".
				Si existe, se le cambiará el precio a 4.40, mientras que si no existe, lo creará con los 
				siguientes parámetros: 16, 1, 'Pack 6 latas', 4.40, 8,7,5,0
	Entrada: Producto, tipo nvarchar(40)
	Salida: Nada
	E/S: Nada
	Postcondiciones: El producto introducido de la tabla products quedará modificado/creado.
*/

create procedure comprobarProducto
	@Producto nvarchar(40)
as
begin
	if exists (select * from Products where ProductName like @Producto)
	begin
		print 'Este producto existe. Se procederá a cambiarle el precio, te guste o no MUAJAJAJAJAJA, soy malvado.'	
		update Products
		set UnitPrice = 4.40
		where ProductName = @Producto
	end
	else
	begin
		print 'Este producto no existe. Se procederá a crearlo, te guste o no MUAJAJAJAJAJA, soy malvado.'	
		insert into Products
		values(@Producto, 16, 1, 'Pack 6 latas', 4.40, 8,7,5,0)
	end
end

select * from Products

declare @producto nvarchar(40)='Cerveza maX eXtreme taXte with a lot of X'
execute comprobarProducto @producto

--delete from Products where ProductName = @producto

-- Explicación de procedimientos almacenados de manera práctica.

-- 2. Comprueba si existe una tabla llamada ProductSales. Esta tabla ha de tener de cada producto el ID, el Nombre, el Precio unitario,
--		el número total de unidades vendidas y el total de dinero facturado con ese producto. Si no existe, créala

/*	
	Interfaz del procedimiento comprobarProductsSales
	Signatura: create procedure comprobarProductsSales
	Comentario: Este procedimiento comprobará la existencia de la tabla "ProductsSales".
				En el caso de no existir, se creará con un ID, Nombre, Precio unitario,
				número total de unidades vendidas y total de dinero facturado con cada producto.
	Entrada: Nada
	Salida: Nada
	E/S: Nada
	Postcondiciones: Si la tabla no existe, será creada.
*/
go

create procedure comprobarProductsSales
as
begin
if object_id (N'ProductSales') is null
	begin
		print 'La tabla no existe. Se procederá a crearla.'
		create table ProductSales(
			ID char(5) not null 
				constraint PK_ID Primary key,
			Nombre varchar (25) not null, 
			PrecioUnitario money not null, 
			UnidadesVendidas int, 
			DineroFacturado money)
	end
	else 
	begin
		print 'La tabla ya existe.'
	end
end

execute comprobarProductsSales

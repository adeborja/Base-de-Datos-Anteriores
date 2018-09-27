-- Boletin 11. En la base de datos NorthWind. Para comprobar si una tabla existe puedes utilizar la funci�n OBJECT_ID
use Northwind
go

-- 1. Deseamos incluir un producto en la tabla Products llamado "Cruzcampo lata� pero no estamos seguros si se ha insertado o no.
--		El precio son 4,40, el proveedor es el 16, la categor�a 1 y la cantidad por unidad es "Pack 6 latas� "Discontinued� 
--		toma el valor 0 y el resto de columnas se dejar�n a NULL. Escribe un script que compruebe si existe un producto con ese nombre. 
--		En caso afirmativo, actualizar� el precio y en caso negativo insertarlo. 

/*	
	Interfaz del procedimiento comprobarProducto
	Signatura: create procedure comprobarProducto
	Comentario: Este procedimiento comprobar� la existencia de un producto en la tabla "Products".
				Si existe, se le cambiar� el precio a 4.40, mientras que si no existe, lo crear� con los 
				siguientes par�metros: 16, 1, 'Pack 6 latas', 4.40, 8,7,5,0
	Entrada: Producto, tipo nvarchar(40)
	Salida: Nada
	E/S: Nada
	Postcondiciones: El producto introducido de la tabla products quedar� modificado/creado.
*/

create procedure comprobarProducto
	@Producto nvarchar(40)
as
begin
	if exists (select * from Products where ProductName like @Producto)
	begin
		print 'Este producto existe. Se proceder� a cambiarle el precio, te guste o no MUAJAJAJAJAJA, soy malvado.'	
		update Products
		set UnitPrice = 4.40
		where ProductName = @Producto
	end
	else
	begin
		print 'Este producto no existe. Se proceder� a crearlo, te guste o no MUAJAJAJAJAJA, soy malvado.'	
		insert into Products
		values(@Producto, 16, 1, 'Pack 6 latas', 4.40, 8,7,5,0)
	end
end

select * from Products

declare @producto nvarchar(40)='Cerveza maX eXtreme taXte with a lot of X'
execute comprobarProducto @producto

--delete from Products where ProductName = @producto

-- Explicaci�n de procedimientos almacenados de manera pr�ctica.

-- 2. Comprueba si existe una tabla llamada ProductSales. Esta tabla ha de tener de cada producto el ID, el Nombre, el Precio unitario,
--		el n�mero total de unidades vendidas y el total de dinero facturado con ese producto. Si no existe, cr�ala

/*	
	Interfaz del procedimiento comprobarProductsSales
	Signatura: create procedure comprobarProductsSales
	Comentario: Este procedimiento comprobar� la existencia de la tabla "ProductsSales".
				En el caso de no existir, se crear� con un ID, Nombre, Precio unitario,
				n�mero total de unidades vendidas y total de dinero facturado con cada producto.
	Entrada: Nada
	Salida: Nada
	E/S: Nada
	Postcondiciones: Si la tabla no existe, ser� creada.
*/
go

create procedure comprobarProductsSales
as
begin
if object_id (N'ProductSales') is null
	begin
		print 'La tabla no existe. Se proceder� a crearla.'
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

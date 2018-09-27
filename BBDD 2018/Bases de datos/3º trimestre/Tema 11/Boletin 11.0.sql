use LeoTurf
go

--1.Crea una función inline llamada FnCarrerasCaballo que reciba un rango de fechas (inicio y fin) y nos devuelva el número de
--carreras disputadas por cada caballo entre esas dos fechas. Las columnas serán ID (del caballo), nombre, sexo, fecha de
--nacimiento y número de carreras disputadas.
select * from LTCarreras
select * from LTCaballosCarreras

select C.ID, C.Nombre, C.Sexo, C.FechaNacimiento, count(CC.IDCaballo) as Carreras from LTCaballos as C
inner join LTCaballosCarreras as CC on C.ID=CC.IDCaballo
inner join LTCarreras as Ca on CC.IDCarrera=Ca.ID
where Ca.Fecha between DATEFROMPARTS(2000,1,1) and DATEFROMPARTS(2026,1,1)
group by C.ID, C.Nombre, C.Sexo, C.FechaNacimiento

GO
/**
cabecera: FnCarrerasCaballo (@dateInicio date, @dateFinal date)
precondiciones: nada
entradas: dos datos tipo date
salidas: una tabla
postcondiciones: asociado al nombre devuelve la tabla con ID (del caballo), nombre, sexo, fecha de nacimiento y número de carreras disputadas
*/
CREATE FUNCTION FnCarrerasCaballo (@dateInicio date, @dateFinal date)
RETURNS TABLE AS
RETURN(
	select C.ID, C.Nombre, C.Sexo, C.FechaNacimiento, count(CC.IDCaballo) as Carreras from LTCaballos as C
	inner join LTCaballosCarreras as CC on C.ID=CC.IDCaballo
	inner join LTCarreras as Ca on CC.IDCarrera=Ca.ID
	where Ca.Fecha between @dateInicio and @dateFinal
	group by C.ID, C.Nombre, C.Sexo, C.FechaNacimiento
)
GO

declare @fecha1 date
declare @fecha2 date

set @fecha1 = DATEFROMPARTS(2018,1,1)
set @fecha2 = DATEFROMPARTS(2018,4,1)

select * from FnCarrerasCaballo(@fecha1, @fecha2)

--2.Crea una función escalar llamada FnTotalApostadoCC que reciba como parámetros el ID de un caballo y el ID de una carrera y
--nos devuelva el dinero que se ha apostado a ese caballo en esa carrera.
select * from LTApuestas

select sum(Importe) as TotalApostado from LTApuestas
where IDCaballo=1 and IDCarrera=1

GO
/**
cabecera: FnTotalApostadoCC (@idCaballo smallint, @idcarrera smallint)
precondiciones: nada
entradas: dos enteros
salidas: un real
postcondiciones: asociado al nombre devuelve el dinero que se ha apostado a ese caballo en esa carrera
*/
CREATE FUNCTION FnTotalApostadoCC (@idCaballo smallint, @idcarrera smallint)
returns smallmoney as
begin
declare @apostado smallmoney

select @apostado = sum(Importe) from LTApuestas
where IDCaballo=1 and IDCarrera=1

return @apostado
end

GO

declare @idcaballo smallint
declare @idcarrera smallint

select @idcaballo=1, @idcarrera=1

select dbo.FnTotalApostadoCC(@idcaballo, @idcarrera)

--3.Crea una función escalar llamada FnPremioConseguido que reciba como parámetros el ID de una apuesta y nos devuelva el dinero
--que ha ganado dicha apuesta. Si todavía no se conocen las posiciones de los caballos, devolverá un NULL

select * from LTApuestas
select * from LTCaballosCarreras



GO
/**

*/
CREATE FUNCTION FnPremioConseguido (@id int)
RETURNS smallmoney as
begin

declare @importeApuesta smallmoney --null
declare @idcarrera smallint
declare @idcaballo smallint

select @idcarrera = IDCarrera, @idcaballo = IDCaballo from LTApuestas where ID=@id --**

if (select Posicion from LTCaballosCarreras where IDCarrera=@idcarrera and IDCaballo=@idcaballo) is not null
begin
	if (select Posicion from LTCaballosCarreras where IDCarrera=@idcarrera and IDCaballo=@idcaballo) = 1
	begin
		set @importeApuesta = (select Importe from LTApuestas where ID=@id) * (select Premio1 from LTCaballosCarreras where IDCarrera=@idcarrera and Posicion=1) --**
	end
	else
	begin
		if (select Posicion from LTCaballosCarreras where IDCarrera=@idcarrera and IDCaballo=@idcaballo) = 2
		begin
			set @importeApuesta = (select Importe from LTApuestas where ID=@id) * (select Premio2 from LTCaballosCarreras where IDCarrera=@idcarrera and Posicion=2) --**
		end
		--else
		--begin
		--	set @importeApuesta = null
		--end
	end
end

--case (select Posicion from LTCaballosCarreras where IDCarrera=@idcarrera and IDCaballo=@idcaballo)
--when 1 then print '1'
--end

return @importeApuesta
--print @importeApuesta

end
GO

declare @id smallint
set @id=4

select dbo.FnPremioConseguido (@id)

--4.El procedimiento para calcular los premios en las apuestas de una carrera (los valores que deben figurar en la columna Premio1
--y Premio2) es el siguiente:
--a.Se calcula el total de dinero apostado en esa carrera
--b.El valor de la columna Premio1 para cada caballo se calcula dividiendo el total de dinero apostado entre lo apostado a ese
--caballo y se multiplica el resultado por 0.6
--c.El valor de la columna Premio2 para cada caballo se calcula dividiendo el total de dinero apostado entre lo apostado a ese
--caballo y se multiplica el resultado por 0.2
--d.Si a algún caballo no ha apostado nadie tanto el Premio1 como el Premio2 se ponen a 100.
--Crea una función que devuelva una tabla con tres columnas: ID de la apuesta, Premio1 y Premio2. -id del caballo
--Debes usar la función del Ejercicio 2. Si lo estimas oportuno puedes crear otras funciones para realizar parte de los cálculos.




--5.Crea una función FnPalmares que reciba un ID de caballo y un rango de fechas y nos devuelva el palmarés de ese caballo en ese
--intervalo de tiempo.
--El palmarés es el número de victorias, segundos puestos, etc. Se devolverá una tabla con dos columnas: Posición y NumVeces, que
--indicarán, respectivamente, cada una de las posiciones y las veces que el caballo ha obtenido ese resultado. Queremos que aparezcan
--8 filas con las posiciones de la 1 a la 8. Si el caballo nunca ha finalizado en alguna de esas posiciones, aparecerá el valor 0 en
--la columna NumVeces.
select * from LTCaballosCarreras

declare @Posicion1 smallint
declare @Posicion2 smallint
declare @Posicion3 smallint
declare @Posicion4 smallint
declare @Posicion5 smallint
declare @Posicion6 smallint
declare @Posicion7 smallint
declare @Posicion8 smallint

select @Posicion1=0,@Posicion2=0,@Posicion3=0,@Posicion4=0,@Posicion5=0,@Posicion6=0,@Posicion7=0,@Posicion8=0



--6.Crea una función FnCarrerasHipodromo que nos devuelva las carreras celebradas en un hipódromo en un rango de fechas.
--La función recibirá como parámetros el nombre del hipódromo y la fecha de inicio y fin del intervalo y nos devolverá una
--tabla con las siguientes columnas: Fecha de la carrera, número de orden, numero de apuestas realizadas, número de caballos
--inscritos, número de caballos que la finalizaron y nombre del ganador.



--7.Crea una función FnObtenerSaldo a la que pasemos el ID de un jugador y una fecha y nos devuelva su saldo en esa fecha. Si se omite la fecha, se devolverá el saldo actual



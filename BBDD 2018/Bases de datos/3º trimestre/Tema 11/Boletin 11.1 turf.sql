use LeoTurf
go

--1.Crea una función a la que pasemos un intervalo de tiempo y nos devuelva una tabla con el Happy day (el día que más ha ganado)
--y el black day (el día que más ha perdido) de cada jugador. Si hay más de un día en que haya ganado o perdido el máximo,
--tomaremos el más reciente. Columnas: ID del jugador, nombre, apellidos, fecha del happy day, cantidad ganada, fecha del black
--day, cantidad perdida.

--tener en cuenta que puede haber mas de una apuesta al dia
--el beneficio es el total ganado menos el total apostado
--si un socio no ha realizado apuestas, dejamos los campos a null

select * from LTJugadores
select * from LTApuestas where IDJugador=100
select * from LTApuntes where IDJugador=100
select * from LTApuntes where Concepto not like 'Apuesta%' and Concepto not like 'Premio por la apuesta%'
select * from LTApuntes where Concepto not like 'Ingreso inicial'

--total ganado cada dia por jugador
select IDJugador ,Fecha, sum(importe) as ganancia from LTApuntes where Concepto not like 'Ingreso inicial'
	group by IDJugador, Fecha
	order by IDJugador, Fecha


declare @numero int
set @numero = 45

select * from LTApuntes where Concepto like 'Premio por la apuesta '+cast(@numero as varchar)

select top 1 * from LTApuntes where IDJugador=22 order by Importe desc, Fecha desc
select top 1 * from LTApuntes where IDJugador=22 order by Importe, Fecha desc --bien, 22

select top 1 * from LTApuntes where Importe>0 group by IDJugador, Orden, Fecha, Importe, Saldo, Concepto


--
declare @tablaGanancias table(id int, fecha date, dinero smallmoney)

insert into @tablaGanancias
select IDJugador ,Fecha, sum(importe) as ganancia from LTApuntes where Concepto not like 'Ingreso inicial'
	group by IDJugador, Fecha

select * from @tablaGanancias where id=6

select top 1 * from @tablaGanancias where id=6 order by dinero desc, fecha desc --mayor ganancia
select top 1 * from @tablaGanancias where id=6 order by dinero, fecha desc --mayor perdida

go
/*

*/
CREATE FUNCTION FnOhHappyDayOhBlackDay (@inicio smalldatetime, @final smalldatetime)
RETURNS TABLE AS
RETURN(
	declare @tablaFinal table(ID int, nombre varchar, apellidos varchar, FechaHappyDay date, ImporteHappyDay smallmoney, FechaBlackDay date, ImporteBlackDay smallmoney)
	--declare @happy table(ID int, FechaHappyDay date, ImporteHappyDay smallmoney)
	--declare @black table(ID int, FechaBlackDay date, ImporteBlackDay smallmoney)
	declare @tablaid table(id int identity(1,1),idJugador int)
	declare @contador int
	declare @numeroJugadores int
	declare @tablaGanancias table(id int, fecha date, dinero smallmoney)

	set @contador = 1
	set @numeroJugadores = (select count(id) from LTJugadores)

	insert into @tablaid
	select ID from LTJugadores

	insert into @tablaFinal
	(ID)
	(select idJugador from @tablaid)


	insert into @tablaGanancias
	select IDJugador ,Fecha, sum(importe) as ganancia from LTApuntes where Concepto not like 'Ingreso inicial'
		group by IDJugador, Fecha

	WHILE @contador <= @numeroJugadores
	BEGIN
		UPDATE @tablaFinal
		SET FechaHappyDay = (select top 1 FechaHappyDay from @tablaGanancias where id=(select idJugador from @tablaid where id=@contador) order by dinero desc, fecha desc)
		WHERE ID=(select idJugador from @tablaid where id=@contador)
		
		UPDATE @tablaFinal
		SET ImporteHappyDay = (select top 1 ImporteHappyDay from @tablaGanancias where id=(select idJugador from @tablaid where id=@contador) order by dinero desc, fecha desc)
		WHERE ID=(select idJugador from @tablaid where id=@contador)

		UPDATE @tablaFinal
		SET FechaBlackDay = (select top 1 FechaBlackDay from @tablaGanancias where id=(select idJugador from @tablaid where id=@contador) order by dinero desc, fecha desc)
		WHERE ID=(select idJugador from @tablaid where id=@contador)

		UPDATE @tablaFinal
		SET ImporteBlackDay = (select top 1 ImporteBlackDay from @tablaGanancias where id=(select idJugador from @tablaid where id=@contador) order by dinero desc, fecha desc)
		WHERE ID=(select idJugador from @tablaid where id=@contador)
		


	END
	
	select * from @tablaFinal
)

go

--2.Se ha creado un coeficiente para valorar los caballos. Su valor se calcula sumando el número de carreras ganadas multiplicado
--por cinco más el número de carreras en las que ha quedado segundo multiplicado por tres. El resultado se divide entre el número
--de carreras disputadas multiplicado por 0,2. Al resultado de todo eso de lo multiplica por un coeficiente de edad que se calcula
--según la tabla siguiente:

--Edad						Valor
--Seis o menos años			100
--Siete						90
--Ocho o nueve				75
--Diez						65
--Más de diez				40


select IDCaballo, count(Posicion) as victorias from LTCaballosCarreras
where Posicion=1 group by IDCaballo

select IDCaballo, count(Posicion) as subvictorias from LTCaballosCarreras
where Posicion=2 group by IDCaballo

select IDCaballo, count(*) as carreras from LTCaballosCarreras
where Posicion is not null group by IDCaballo

select CAR.IDCaballo, VIC.victorias, SEG.subvictorias, CAR.carreras from(
	select IDCaballo, count(*) as carreras from LTCaballosCarreras
	where Posicion is not null group by IDCaballo) as CAR
	full join (
		select IDCaballo, count(Posicion) as victorias from LTCaballosCarreras
		where Posicion=1 group by IDCaballo
	) as VIC on CAR.IDCaballo=VIC.IDCaballo
	full join (
		select IDCaballo, count(Posicion) as subvictorias from LTCaballosCarreras
		where Posicion=2 group by IDCaballo
	) as SEG on CAR.IDCaballo=SEG.IDCaballo


GO
/**
cabecera: FnCoeficientesCaballos
*/
CREATE FUNCTION FnCoeficientesCaballos ()
RETURNS @Devolver table(IDCaballo smallint, Puntuacion decimal(8,3)) AS
BEGIN
	DECLARE @resultados table(IDCaballo smallint, Edad smallint, victorias smallint, segundos smallint, carreras smallint)

	insert into @resultados
	(IDCaballo, Edad, victorias, segundos, carreras)
	select CAR.IDCaballo, DATEDIFF(day,C.FechaNacimiento, CURRENT_TIMESTAMP)/365.25, VIC.victorias, SEG.subvictorias, CAR.carreras from(
		select IDCaballo, count(*) as carreras from LTCaballosCarreras
		where Posicion is not null group by IDCaballo) as CAR
		full join (
			select IDCaballo, count(Posicion) as victorias from LTCaballosCarreras
			where Posicion=1 group by IDCaballo
		) as VIC on CAR.IDCaballo=VIC.IDCaballo
		full join (
			select IDCaballo, count(Posicion) as subvictorias from LTCaballosCarreras
			where Posicion=2 group by IDCaballo
		) as SEG on CAR.IDCaballo=SEG.IDCaballo
		inner join LTCaballos as C on CAR.IDCaballo=C.ID

	UPDATE @resultados
	set victorias = 0 where victorias is null

	UPDATE @resultados
	set segundos = 0 where segundos is null

	--select * from @resultados

	insert into @Devolver
	(IDCaballo, Puntuacion)
	select IDCaballo, (((victorias*5)+(segundos*3))/(carreras*0.2)) * 
		(CASE 
		when Edad<7 then 100
		when Edad=7 then 90
		when Edad between 8 and 9 then 75
		when Edad=10 then 65
		when Edad>10 then 40
		END
	) from @resultados

	RETURN --(SELECT C.ID, C.Nombre, C.Sexo, @Devolver.Puntuacion FROM LTCaballos AS C
		--inner join @Devolver on C.ID=@Devolver.IDCaballo)
END

GO

select * from FnCoeficientesCaballos ()



--3.Queremos saber la cantidad de dinero en apuestas que mueve cada hipódromo. Haz una función a la que se le pase un rango de fechas
--y nos devuelva el dinero movido en apuestas en cada hipódromo entre esas fechas. También queremos saber cuál fue la apuesta más alta
--de ese periodo. Considerar solo las apuestas, no los premios. Columnas: Nombre del hipódromo, cantidad gestionada, fecha de la apuesta
--más alta, importe de la apuesta más alta y otra columna que tomará los valores G,C o P según si esa apuesta acertó el primero (Ganador),
--el segundo (Colocado) o no obtuvo premio (Pierde).
select * from LTApuestas
select * from LTCarreras
select * from LTCaballosCarreras

--importe total apostado
select sum(A.Importe) as cantidad from LTApuestas as A
inner join LTCarreras as C on A.IDCarrera=C.ID
where C.Fecha between DATEFROMPARTS(2018,3,1) and DATEFROMPARTS(2018,5,5)

--apuesta mas alta
select top 1 A.importe, C.Fecha from LTApuestas as A
inner join LTCarreras as C on A.IDCarrera=C.ID
where C.Fecha between DATEFROMPARTS(2018,3,1) and DATEFROMPARTS(2018,5,5)
group by A.Importe, C.Fecha
order by A.Importe desc

--columna valores
declare @letra varchar(1)
set @letra = 'b'

select top 1 A.importe, C.Fecha, A.ID ,
	case @letra
		when 'A' then 'Bien'
		else 'Mal'
		end
from LTApuestas as A
inner join LTCarreras as C on A.IDCarrera=C.ID
--inner join LTCaballosCarreras
where C.Fecha between DATEFROMPARTS(2018,2,1) and DATEFROMPARTS(2018,3,5)
group by A.Importe, C.Fecha, A.ID
order by A.Importe desc

--final
select TotalApostado.cantidad, ApuestaMasAlta.Importe, ApuestaMasAlta.Fecha from (
	select sum(A.Importe) as cantidad from LTApuestas as A
	inner join LTCarreras as C on A.IDCarrera=C.ID
	--where C.Fecha between DATEFROMPARTS(2018,3,1) and DATEFROMPARTS(2018,5,5)
) as TotalApostado
full join(
	select top 1 A.importe, C.Fecha from LTApuestas as A
	inner join LTCarreras as C on A.IDCarrera=C.ID
	--where C.Fecha between DATEFROMPARTS(2018,3,1) and DATEFROMPARTS(2018,5,5)
	group by A.Importe, C.Fecha
	order by A.Importe desc
)as ApuestaMasAlta

/**
cabecera: 
comentario: funcion para conocer la posicion en que ha terminado un caballo de una apuesta en una carrera
precondiciones: nada
entrada: un entero
salida: un entero
postcondiciones: asociado al nombre devuelve 
*/
GO
CREATE FUNCTION FnResultadoCaballoApuesta(@IDApuesta int)
RETURNS smallint AS
BEGIN
	declare @resultado tinyint
	declare @IDCaballo smallint
	declare @IDCarrera smallint

	select @IDCaballo=IDCaballo, @IDCarrera=IDCarrera from LTApuestas
	where ID=@IDApuesta

	select @resultado = CC.Posicion from LTApuestas as A
	inner join LTCarreras as C on A.IDCarrera=C.ID
	inner join LTCaballosCarreras as CC on C.ID=CC.IDCarrera
	where CC.IDCaballo=@IDCaballo and CC.IDCarrera=@IDCarrera

	return @resultado
END
GO

select dbo.FnResultadoCaballoApuesta(60)

GO
/**

*/
--tienen que ser todos los hipodromos, no solo uno


--4.Haz una función DescalificaCaballo que reciba como parámetros el ID de un Caballo y en ID de una carrera y descalifique a ese caballo
--en esa carrera. Eso puede dar lugar, si el caballo quedó primero o segundo, a que haya que alterar los premios obtenidos.

--a.Si el caballo descalificado fue primero: Crear apuntes para descontar los premios obtenidos por los que apostaron por él, anular
--también los apuntes de los que apostaron por el segundo, que ahora pasa a ser primero y generar los apuntes correspondientes al nuevo
--premio. Crear los apuntes correspondientes al segundo premio para los que apostaron por el tercero, que ahora pasa a ser segundo.

--b.Si el caballo descalificado fue segundo: Anular las ganancias de los que apostaron por él. Crear los apuntes correspondientes al
--segundo premio para los que apostaron por el tercero, que ahora pasa a ser segundo.

--La función nos devolverá los apuntes que haya que insertar en la tabla Apuntes. No se borra ningún apunte. Los que ya no sirvan se crea
--uno con el importe opuesto.

select * from LTCaballosCarreras
select * from LTCarreras
select * from LTApuestas
select * from LTJugadores
select * from LTApuntes WHERE IDJugador=1

/*
Obtener posicion del caballo en esa carrera

SI EL CABALLO TERMINO 1 O 2
	Cancelar las ganancias obtenidas en esa carrera si el caballo descalificado fue 1º o 2º

	modificar las ganancias en caso de que fuese primero
		ahora el segundo es el primero
		añadir premios a tabla a devolver

	--modificar las ganancias en caso de que fuese primero o segundo
		ahora el tercero es el segundo
		añadir premios a tabla a devolver
FIN SI

devolver tabla
*/

GO
/**
cabecera:
*/
CREATE FUNCTION FnDescalificarCaballo(@IDCarrera smallint, @IDCaballo smallint)
RETURNS @tabla TABLE(Posicion smallint, Premio smallmoney) AS
BEGIN
	DECLARE @posicionCaballo tinyint
	DECLARE @apuntes table(IDJugador int, importe smallmoney)
	DECLARE @fechaCarrera date

	SET @fechaCarrera = (select Fecha from LTCarreras where ID=@IDCarrera)
	SELECT @posicionCaballo=Posicion FROM LTCaballosCarreras WHERE IDCaballo=@IDCaballo AND IDCarrera=@IDCarrera

	IF(@posicionCaballo=1)
	BEGIN
		INSERT INTO @apuntes
		SELECT A.IDJugador, A.Importe, AP.ID FROM LTApuntes AS A
			INNER JOIN LTApuestas AS AP ON A.IDJugador=AP.IDJugador
			INNER JOIN LTCaballosCarreras AS CC ON AP.IDCaballo=CC.IDCaballo AND AP.IDCarrera=CC.IDCarrera
			INNER JOIN LTCarreras AS C ON CC.IDCarrera=C.ID
			WHERE CC.IDCaballo=1 AND CC.IDCarrera=1 AND A.Fecha = (SELECT FECHA FROM LTCarreras WHERE ID=1) AND A.Importe>0
			--WHERE CC.IDCaballo=@IDCaballo AND CC.IDCarrera=@IDCarrera AND A.Fecha = @fechaCarrera AND A.Importe>0
	END

END

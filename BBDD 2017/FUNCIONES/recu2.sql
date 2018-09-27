USE LeoFest
GO

--Ejercicio 1
--Haz una función a la que se pase el nombre de una banda y un rango de fechas y nos devuelva una tabla indicando cuantas
--veces ha interpretado cada tema en ese rango de fechas. Las columnas serán ID del tema, título, nombre del autor, nombre
--del estilo y número de veces que se ha interpretado.

select * from LFBandas
select * from LFTemasBandasEdiciones --interpretaciones
select * from LFTemas --id, titulo
select * from LFMusicos --nombreAutor
select * from LFEstilos --nombreEstilo
select * from LFEdiciones --intervalo

select IDTema, count(*) from LFTemasBandasEdiciones group by IDTema

select T.ID, T.Titulo, M.Nombre, M.Apellidos, E.Estilo, COUNT(TBE.IDTema) AS Interpretaciones from LFTemas as T
INNER JOIN LFMusicos AS M ON M.ID=T.IDAutor
INNER JOIN LFEstilos AS E ON E.ID=T.IDEstilo
INNER JOIN LFTemasBandasEdiciones AS TBE ON TBE.IDTema=T.ID
INNER JOIN LFBandas AS B ON B.ID=TBE.IDBanda
INNER JOIN LFEdiciones AS ED ON ED.IDFestival=TBE.IDFestival AND ED.Ordinal=TBE.Ordinal
WHERE B.NombreBanda = 'Ejecucion hipotecaria'
AND ED.FechaHoraInicio>SMALLDATETIMEFROMPARTS(2001,1,1,0,0) AND ED.FechaHoraFin<SMALLDATETIMEFROMPARTS(2002,1,1,0,0)
GROUP BY T.ID, T.Titulo, M.Nombre, M.Apellidos, E.Estilo


GO
/**
interfaz de fn_temasBandasIntervalo
cabecera: fn_temasBandasIntervalo (@nombre varchar(50), @inicio smalldatetime, @fin smalldatetime)
precondiciones: nada
entrada: una cadena
salida: una tabla
postcondiciones: devuelve el id, titulo y estilo de la cancion, nombre y apellidos del autor y veces que se ha interpretado en el intervalo
*/
CREATE FUNCTION fn_temasBandasIntervalo (@nombre varchar(50), @inicio smalldatetime, @fin smalldatetime)
RETURNS TABLE AS
RETURN(
	select T.ID, T.Titulo, M.Nombre, M.Apellidos, E.Estilo, COUNT(TBE.IDTema) AS Interpretaciones from LFTemas as T
	INNER JOIN LFMusicos AS M ON M.ID=T.IDAutor
	INNER JOIN LFEstilos AS E ON E.ID=T.IDEstilo
	INNER JOIN LFTemasBandasEdiciones AS TBE ON TBE.IDTema=T.ID
	INNER JOIN LFBandas AS B ON B.ID=TBE.IDBanda
	INNER JOIN LFEdiciones AS ED ON ED.IDFestival=TBE.IDFestival AND ED.Ordinal=TBE.Ordinal
	WHERE B.NombreBanda = @nombre
	AND ED.FechaHoraInicio>@inicio AND ED.FechaHoraFin<@fin
	GROUP BY T.ID, T.Titulo, M.Nombre, M.Apellidos, E.Estilo
)
GO

DECLARE @INI SMALLDATETIME
DECLARE @FI SMALLDATETIME
DECLARE @BANDA VARCHAR(50)
SET @INI=SMALLDATETIMEFROMPARTS(2001,1,1,0,0)
SET @FI=SMALLDATETIMEFROMPARTS(2007,1,1,0,0)
SET @BANDA='Ejecucion hipotecaria' --Ejecucion hipotecaria

SELECT * FROM dbo.fn_temasBandasIntervalo (@BANDA, @INI, @FI)




--Ejercicio 2
--Diseña una función que nos devuelva los datos de los músicos que han formado parte de una banda a lo largo de su historia.
--Las columnas serán Id, nombre artístico, años de antigüedad, meses y días. La antigüedad se calculará mediante la diferencia
--entre el momento en que el músico entró a formar parte de la banda y cuando la abandonó. Si todavía sigue en la misma, se
--considerará la antiguedad hasta la fecha actual. 
--Si un músico ha formado parte de la banda, la ha abndonado y luego ha vuelto se sumará la duración de todos los periodos en 
--los que haya formado parte de la misma. El parámetro de entrada será el nombre de la banda.

select * from LFBandas
select * from LFMusicosBandas
select * from LFMusicos

select M.ID, M.NombreArtistico, SUM(DATEDIFF(DAY,MB.FechaIncorporacion, MB.FechaAbandono)) AS Dias from LFMusicosBandas as MB
INNER JOIN LFBandas AS B ON B.ID=MB.IDBanda
INNER JOIN LFMusicos AS M ON M.ID=MB.IDMusico
WHERE B.ID=1
GROUP BY M.ID, M.NombreArtistico

--
SELECT X.ID, X.NombreArtistico, X.Anios, X.Meses-(X.Anios*12) AS Meses, X.Dias-(X.Meses*30) AS Dias FROM(
	SELECT M.ID, M.NombreArtistico, MB.Dias, MB.Dias/30 AS Meses, MB.Dias/365 AS Anios FROM LFBandas AS B
	INNER JOIN(
		SELECT MB.IDMusico, MB.IDBanda, SUM(DATEDIFF(DAY, MB.FechaIncorporacion, MB.FechaFin)) AS Dias FROM (
			SELECT IDBanda, IDMusico, FechaIncorporacion, (CASE 
				WHEN FechaAbandono IS NULL THEN CURRENT_TIMESTAMP
				ELSE FechaAbandono END) AS FechaFin
			FROM LFMusicosBandas
		) as MB
		WHERE MB.IDBanda=5
		GROUP BY MB.IDBanda, MB.IDMusico
	) as MB on B.ID=MB.IDBanda
	INNER JOIN LFMusicos AS M on M.ID=MB.IDMusico
	GROUP BY M.ID, M.NombreArtistico, MB.Dias
) AS X


----MODO B (DATEDIFF)

SELECT X.ID, X.NombreArtistico,
CASE WHEN X.Dias<0 AND X.Meses<0 THEN X.Anios-2 WHEN X.Dias<0 THEN X.Anios-1 WHEN X.Meses<0 THEN X.Anios-1 WHEN X.Dias>=0 AND X.Meses>=0 THEN X.Anios END AS Anios,
CASE WHEN X.Meses<0 THEN X.Meses+12 WHEN X.Meses>=0 THEN X.Meses END AS Meses,
CASE WHEN X.Dias<0 THEN X.Dias+365 WHEN X.Dias>=0 THEN X.Dias END AS Dias FROM(
	SELECT M.ID, M.NombreArtistico, MB.Dias-(MB.Anios*365) AS Dias, MB.Meses-(MB.Anios*12) AS Meses, MB.Dias/365 AS Anios FROM LFBandas AS B
	INNER JOIN(
		SELECT MB.IDMusico, MB.IDBanda, SUM(DATEDIFF(DAY, MB.FechaIncorporacion, MB.FechaFin)) AS Dias,
		SUM(DATEDIFF(MONTH, MB.FechaIncorporacion, MB.FechaFin)) AS Meses, SUM(DATEDIFF(YEAR, MB.FechaIncorporacion, MB.FechaFin)) AS Anios
		FROM (
			SELECT IDBanda, IDMusico, FechaIncorporacion, ISNULL (FechaAbandono, CURRENT_TIMESTAMP) AS FechaFin
			FROM LFMusicosBandas
			WHERE IDBanda=12
		) as MB
		GROUP BY MB.IDBanda, MB.IDMusico
	) as MB on B.ID=MB.IDBanda
	INNER JOIN LFMusicos AS M on M.ID=MB.IDMusico
	GROUP BY M.ID, M.NombreArtistico, MB.Dias, Mb.Meses,MB.Anios
) AS X


GO
/**
interfaz de fn_historicoMiembrosBanda
cabecera: fn_historicoMiembrosBanda (@banda varchar(50))
precondiciones: nada
entrada: una cadena
salida: una tabla
postcondiciones: devuelve el id, nombre artístico y los años, meses y dias que los miembros de ese grupo han estado en el grupo
*/
alter FUNCTION fn_historicoMiembrosBanda (@banda varchar(50))
RETURNS TABLE AS
RETURN(
		/*SELECT X.ID, X.NombreArtistico, X.Anios, X.Meses-(X.Anios*12) AS Meses, X.Dias-(X.Meses*30) AS Dias FROM(
			SELECT M.ID, M.NombreArtistico, MB.Dias, MB.Dias/30 AS Meses, MB.Dias/365 AS Anios FROM LFBandas AS B
			INNER JOIN(
				SELECT MB.IDMusico, MB.IDBanda, SU M(DATEDIFF(DAY, MB.FechaIncorporacion, MB.FechaFin)) AS Dias FROM (
					SELECT IDBanda, IDMusico, FechaIncorporacion, (CASE 
						WHEN FechaAbandono IS NULL THEN CURRENT_TIMESTAMP
						ELSE FechaAbandono END) AS FechaFin
					FROM LFMusicosBandas --cambiar todo el select por ISNULL
				) as MB
				WHERE MB.IDBanda=(SELECT ID FROM LFBandas WHERE NombreBanda=@banda)
				GROUP BY MB.IDBanda, MB.IDMusico
			) as MB on B.ID=MB.IDBanda
			INNER JOIN LFMusicos AS M on M.ID=MB.IDMusico
			GROUP BY M.ID, M.NombreArtistico, MB.Dias
		) AS X*/

		SELECT X.ID, X.NombreArtistico,
		CASE WHEN X.Dias<0 AND X.Meses<0 THEN X.Anios-2 WHEN X.Dias<0 THEN X.Anios-1 WHEN X.Meses<0 THEN X.Anios-1 WHEN X.Dias>=0 AND X.Meses>=0 THEN X.Anios END AS Anios,
		CASE WHEN X.Meses<0 THEN X.Meses+12 WHEN X.Meses>=0 THEN X.Meses END AS Meses,
		CASE WHEN X.Dias<0 THEN X.Dias+365 WHEN X.Dias>=0 THEN X.Dias END AS Dias FROM(
			SELECT M.ID, M.NombreArtistico, MB.Dias-(MB.Anios*365) AS Dias, MB.Meses-(MB.Anios*12) AS Meses, MB.Dias/365 AS Anios FROM LFBandas AS B
			INNER JOIN(
				SELECT MB.IDMusico, MB.IDBanda, SUM(DATEDIFF(DAY, MB.FechaIncorporacion, MB.FechaFin)) AS Dias,
				SUM(DATEDIFF(MONTH, MB.FechaIncorporacion, MB.FechaFin)) AS Meses, SUM(DATEDIFF(YEAR, MB.FechaIncorporacion, MB.FechaFin)) AS Anios
				FROM (
					SELECT IDBanda, IDMusico, FechaIncorporacion, ISNULL (FechaAbandono, CURRENT_TIMESTAMP) AS FechaFin
					FROM LFMusicosBandas
					WHERE IDBanda=(SELECT ID FROM LFBandas WHERE NombreBanda=@banda)
				) as MB
				GROUP BY MB.IDBanda, MB.IDMusico
			) as MB on B.ID=MB.IDBanda
			INNER JOIN LFMusicos AS M on M.ID=MB.IDMusico
			GROUP BY M.ID, M.NombreArtistico, MB.Dias, Mb.Meses,MB.Anios
		) AS X
	)
GO

SELECT * FROM dbo.fn_historicoMiembrosBanda ('De sevillanas maneras')


--Ejercicio 3
--Algunas veces se organizan ediciones "revival" de un festival, en las que se programan las mismas bandas y las mismas canciones
--que una edición anterior del mismo festival o de otro. Escribe un procedimeinto almacenado que "clone" una edición de un festival.
--Los datos de entrada serán el ID del festival y la fecha de inicio de la edición que queremos clonar y el ID del festival y la
--fecha de inicio prevista para la nueva edición "revival". Todos los datos de esta ueva edición (duración, lema, etc) se copiaran
--del que estamos replicando.

-- IDFestival, fechaInicioAntigua, IDNuevo, fechaNueva
select * from LFEdiciones WHERE IDFestival=10 ORDER BY IDFestival, Ordinal
select * from LFBandasEdiciones WHERE IDFestival=10 ORDER BY IDFestival, Ordinal
select * from LFTemasBandasEdiciones WHERE IDFestival=10 ORDER BY IDFestival, Ordinal

SELECT top 1 * FROM LFEdiciones WHERE IDFestival=1 order by Ordinal desc --AND FechaHoraInicio=SMALLDATETIMEFROMPARTS(2001,12,24,12,4)

GO
/**
interfaz de pr_revivalFestival
cabecera: pr_revivalFestival @id1 int, @fecha1 smalldatetime, @id2 int, @fecha2 smalldatetime
precondiciones: nada
entrada: dos enteros y dos fechas
salida: nada
postcondiciones: pinta en pantalla el resultado de la operacion
*/
ALTER PROCEDURE pr_revivalFestival @id1 int, @fecha1 smalldatetime, @id2 int, @fecha2 smalldatetime
AS
BEGIN
	DECLARE @ordinal tinyint
	DECLARE @ordinal2 tinyint

	IF NOT EXISTS (SELECT * FROM LFEdiciones WHERE IDFestival=@id1 AND FechaHoraInicio=@fecha1)
	BEGIN
		PRINT 'El festival introducido no existe' 
	END
	ELSE
	BEGIN
		SET @ordinal = (SELECT TOP 1 Ordinal FROM LFEdiciones WHERE IDFestival=@id2 ORDER BY Ordinal DESC) --ultima edicion del festival
		SET @ordinal2 = (SELECT Ordinal FROM LFEdiciones WHERE IDFestival=@id1 AND FechaHoraInicio=@fecha1) --edicion del festival a copiar
	

		INSERT INTO LFEdiciones
		(IDFestival, Ordinal, Lema, Lugar, Ciudad, ComunidadAutonoma, FechaHoraInicio)
		(SELECT @id2, (@ordinal+1), E.Lema, E.Lugar, E.Ciudad, E.ComunidadAutonoma, @fecha2
			FROM LFEdiciones AS E WHERE E.IDFestival=@id1 AND E.FechaHoraInicio=@fecha1)

		INSERT INTO LFBandasEdiciones
		(IDBanda, IDFestival, Ordinal, Categoria)
		(SELECT BE.IDBanda, @id2, (@ordinal+1), BE.Categoria
			FROM LFBandasEdiciones AS BE WHERE BE.IDFestival=@id1 AND BE.Ordinal=@ordinal2)

		INSERT INTO LFTemasBandasEdiciones
		(IDBanda, IDFestival, Ordinal, IDTema)
		(SELECT TBE.IDBanda, @id2, (@ordinal+1), TBE.IDTema FROM LFTemasBandasEdiciones AS TBE
			WHERE TBE.IDFestival=@id1 AND TBE.Ordinal=@ordinal2)
	END
END
GO

DECLARE @FEC SMALLDATETIME
SET @FEC = SMALLDATETIMEFROMPARTS(2016, 11, 9, 13, 22)
DECLARE @NEWFEC SMALLDATETIME
SET @NEWFEC = SMALLDATETIMEFROMPARTS(2017, 8, 11, 20, 0)

EXECUTE pr_revivalFestival 10, @FEC, 10, @NEWFEC

--DELETE FROM LFEdiciones WHERE IDFestival=10 AND Ordinal=12
--DELETE FROM LFBandasEdiciones WHERE IDFestival=10 AND Ordinal=12
--DELETE FROM LFTemasBandasEdiciones WHERE IDFestival=10 AND Ordinal=12





--Ejercicio 4
--Realiza una función que nos diga hasta qué punto una banda es fiel a sus estilos. Para ello, deberá contar cuantos temas de cada
--estilo ha interpretado y dividirlos en dos bloques, los que pertenecen a alguno de los estilos de la banda y los que no. Luego se
--calculará el porcentaje de temas que pertenecen a alguno de sus estilos respecto del total.

--Se contarán las interpretaciones, no los temas. Es decir, si un mismo tema se ha interpretado cinco veces contará como cinco, no como uno.

--El dato de entrada será el nombre de la banda y el de salida el índice de fidelidad, con un decimal.

SELECT * FROM LFBandas
SELECT * FROM LFBandasEstilos
select * from LFTemasBandasEdiciones
select * from LFTemas order by Titulo

--TODAS LAS CANCIONES TOCADAS POR UNA BANDA
select TBE.IDTema, T.Titulo, COUNT(TBE.IDTema) as Interpretaciones, T.IDEstilo from LFTemasBandasEdiciones as TBE
inner join LFTemas as T on T.ID=TBE.IDTema
WHERE TBE.IDBanda=3
GROUP BY TBE.IDTema, T.Titulo, T.IDEstilo
ORDER BY T.IDEstilo


--TODAS LAS CANCIONES TOCADAS POR UNA BANDA y que sea de sus estilos
select TBE.IDTema, T.Titulo, COUNT(TBE.IDTema) as Interpretaciones, T.IDEstilo from LFTemasBandasEdiciones as TBE
inner join LFTemas as T on T.ID=TBE.IDTema
WHERE TBE.IDBanda=3
AND T.IDEstilo IN (SELECT BE.IDEstilo FROM LFBandas AS B
					INNER JOIN LFBandasEstilos AS BE ON BE.IDBanda=B.ID
					WHERE B.ID=3
					GROUP BY B.NombreBanda, BE.IDEstilo)
GROUP BY TBE.IDTema, T.Titulo, T.IDEstilo
ORDER BY T.IDEstilo

--COMBINAR

select TBE.IDTema, T.Titulo, COUNT(TBE.IDTema) as Interpretaciones, X.InterpretacionesEstiloBanda, T.IDEstilo from LFTemasBandasEdiciones as TBE
inner join LFTemas as T on T.ID=TBE.IDTema
LEFT JOIN(
	select TBE.IDTema, COUNT(TBE.IDTema) as InterpretacionesEstiloBanda from LFTemasBandasEdiciones as TBE
	inner join LFTemas as T on T.ID=TBE.IDTema
	WHERE TBE.IDBanda=3
	AND T.IDEstilo IN (SELECT BE.IDEstilo FROM LFBandas AS B
						INNER JOIN LFBandasEstilos AS BE ON BE.IDBanda=B.ID
						WHERE B.ID=3
						GROUP BY B.NombreBanda, BE.IDEstilo)
	GROUP BY TBE.IDTema, T.Titulo, T.IDEstilo
) AS X on X.IDTema=TBE.IDTema
WHERE TBE.IDBanda=3
GROUP BY TBE.IDTema, T.Titulo, T.IDEstilo, X.InterpretacionesEstiloBanda
ORDER BY T.IDEstilo


--final
SELECT sum(Y.Interpretaciones) AS Interpretaciones, sum(Y.InterpretacionesEstiloBanda) AS InterpretacionesEstiloBanda FROM(
	select TBE.IDTema, T.Titulo, COUNT(TBE.IDTema) as Interpretaciones, X.InterpretacionesEstiloBanda, T.IDEstilo from LFTemasBandasEdiciones as TBE
	inner join LFTemas as T on T.ID=TBE.IDTema
	LEFT JOIN(
		select TBE.IDTema, COUNT(TBE.IDTema) as InterpretacionesEstiloBanda from LFTemasBandasEdiciones as TBE
		inner join LFTemas as T on T.ID=TBE.IDTema
		WHERE TBE.IDBanda=1
		AND T.IDEstilo IN (SELECT BE.IDEstilo FROM LFBandas AS B
							INNER JOIN LFBandasEstilos AS BE ON BE.IDBanda=B.ID
							WHERE B.ID=1
							GROUP BY B.NombreBanda, BE.IDEstilo)
		GROUP BY TBE.IDTema, T.Titulo, T.IDEstilo
	) AS X on X.IDTema=TBE.IDTema
	WHERE TBE.IDBanda=1
	GROUP BY TBE.IDTema, T.Titulo, T.IDEstilo, X.InterpretacionesEstiloBanda
) AS Y

GO
/**
interfaz de fn_fidelidadEstilosBanda

cabecera: fn_fidelidadEstilosBanda (@id smallint)
precondiciones: la banda existe
entrada: un entero
salida: un decimal
postcondiciones: devuelve el porcentaje de fidelidad de la banda respecto a sus estilos en las canciones que toca
*/
alter FUNCTION fn_fidelidadEstilosBanda (@id smallint)
RETURNS DECIMAL(8,2) AS
BEGIN
	DECLARE @total int
	DECLARE @totalEstilo int
	DECLARE @resultado decimal(8,2)

	SELECT @total=sum(Y.Interpretaciones), @totalEstilo=sum(Y.InterpretacionesEstiloBanda) FROM(
		select TBE.IDTema, T.Titulo, COUNT(TBE.IDTema) as Interpretaciones, X.InterpretacionesEstiloBanda, T.IDEstilo
		from LFTemasBandasEdiciones as TBE
		inner join LFTemas as T on T.ID=TBE.IDTema
		LEFT JOIN(
			select TBE.IDTema, COUNT(TBE.IDTema) as InterpretacionesEstiloBanda
			from LFTemasBandasEdiciones as TBE
			inner join LFTemas as T on T.ID=TBE.IDTema
			WHERE TBE.IDBanda=@id
			AND T.IDEstilo IN (SELECT BE.IDEstilo FROM LFBandas AS B
								INNER JOIN LFBandasEstilos AS BE ON BE.IDBanda=B.ID
								WHERE B.ID=@id)
								--GROUP BY BE.IDEstilo)
			GROUP BY TBE.IDTema, T.Titulo, T.IDEstilo
		) AS X on X.IDTema=TBE.IDTema
		WHERE TBE.IDBanda=@id
		GROUP BY TBE.IDTema, T.Titulo, T.IDEstilo, X.InterpretacionesEstiloBanda
	) AS Y

	SET @resultado = CAST((100*@totalEstilo) AS DECIMAL(8,2))/@total

	RETURN @resultado
END
GO

SELECT dbo.fn_fidelidadEstilosBanda (3) as [Porcentaje de Fidelidad]


--select CAST((100*40) AS DECIMAL(8,2))/274

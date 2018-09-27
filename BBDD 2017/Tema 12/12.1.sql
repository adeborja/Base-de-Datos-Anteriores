CREATE DATABASE Ejemplos
GO
USE Ejemplos
GO

CREATE TABLE Palabras (
	ID SmallInt Not Null Identity Constraint PK_Palabras Primary Key
	,Palabra VarChar(30) Null
) 
GO

--INICIACION

--1.- Queremos que cada vez que se actualice la tabla Palabras aparezca un mensaje diciendo si
--se han añadido, borrado o actualizado filas.
--Pista: Crea tres triggers diferentes
GO

CREATE TRIGGER filasAnadidas ON Palabras
AFTER INSERT AS
BEGIN
	PRINT 'Se han añadido filas'
END

GO

CREATE TRIGGER filasBorradas ON Palabras
AFTER DELETE AS
BEGIN
	PRINT 'se han borrado filas'
END

GO

CREATE TRIGGER filasActualizadas ON Palabras
AFTER UPDATE AS
BEGIN
	PRINT 'Se han actualizado filas'
END

GO

select * from Palabras

INSERT INTO Palabras
(Palabra)
Values
('Hola')

UPDATE Palabras
SET Palabra='Holo' Where Palabra='Hola'

DELETE FROM Palabras WHERE Palabra='Hola'


--2.- Haz un trigger que cada vez que se aumente o disminuya el número de filas de la tabla
--Palabras nos diga cuántas filas hay. 

GO

CREATE TRIGGER filasActualizacion ON Palabras
AFTER INSERT, DELETE AS
BEGIN
	DECLARE @filas int
	SET @filas = (SELECT COUNT(*) FROM Palabras)
	PRINT 'La tabla Palabras tiene '+CAST(@filas AS varchar)+' filas'
END

GO


--MEDIO

--3.- Cada vez que se inserte una fila queremos que se muestre un mensaje indicando
--“Insertada la palabra ________”
GO

CREATE TRIGGER palabraInsertada ON Palabras
AFTER INSERT AS
BEGIN
	DECLARE @palabra varchar(50)
	SELECT @palabra=Palabra FROM inserted
	PRINT 'Se han insertado la palabra '+@palabra
END

GO

--4.- Cada vez que se inserten filas que nos diga “XX filas insertadas”
GO

CREATE TRIGGER filasInsertadas ON Palabras
AFTER INSERT AS
BEGIN
	DECLARE @filas int
	SET @filas = (SELECT COUNT(*) FROM inserted)
	PRINT ''+CAST(@filas AS VARCHAR)+' filas insertadas'
END

GO

INSERT INTO Palabras
(Palabra)
VALUES
('Hole'),('Holi'),('Holu')


--5.- que no permita introducir palabras repetidas (sin usar UNIQUE). 

--ALTER TRIGGER palabrasSinRepetir ON Palabras
--AFTER INSERT AS
--BEGIN
--	--DECLARE @palabra varchar(50)
--	--SET @palabra = (SELECT Palabra FROM inserted)
--	DECLARE @tabla table(Palabro VarChar(30))
--	DECLARE @cantidad int

--	INSERT INTO @tabla
--	(Palabro)
--	(SELECT Palabra FROM inserted
--	INTERSECT
--	SELECT Palabra FROM Palabras)

--	SET @cantidad = (SELECT COUNT(*) FROM @tabla)

--	IF (@cantidad>0)
--	BEGIN
--		ROLLBACK
--	END
--END
GO

alter TRIGGER palabrasSinRepetir ON Palabras
AFTER INSERT AS
BEGIN
	DECLARE @palabra varchar(30)
	DECLARE @cantidad int

	SELECT @palabra=Palabra FROM inserted

	SET @cantidad = (SELECT COUNT(*) FROM Palabras WHERE Palabra=@palabra)

	IF @cantidad>1
	BEGIN
		RAISERROR ('Campo repetido',6,1)
		ROLLBACK
	END
END

GO

INSERT INTO Palabras
(Palabra)
VALUES
('PROBA')

SELECT * FROM Palabras


--Sobre LeoMetro
USE LeoMetroV2
GO

--6.- Comprueba que un pasajero no pueda entrar o salir por la misma estación más de tres
--veces el mismo día




--7.- Haz un trigger que al insertar un viaje compruebe que no hay otro viaje simultáneo

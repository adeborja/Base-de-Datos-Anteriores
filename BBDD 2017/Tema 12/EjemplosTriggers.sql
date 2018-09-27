USE Ejemplos
GO 
CREATE TABLE Palabras2(
	ID SmallInt Not NULL Identity CONSTRAINT PKPalabras2 Primary Key
	,Palabra VarChar(20) Not NULL
)
GO
CREATE TRIGGER Chorrada ON Palabras2 AFTER INSERT,UPDATE AS
BEGIN
	PRINT 'Se va el caimán'
END -- TRIGGER
GO
--Probando
INSERT INTO Palabras2 (Palabra) VALUES ('Azúcar')
INSERT INTO Palabras2 (Palabra) VALUES ('Sacarina')
--Este falla
INSERT INTO Palabras2 (Palabra) VALUES (NULL)
--Este no
UPDATE Palabras2 SET Palabra = 'Gumersinda' WHERE ID = 1000
GO
-- Solo se pueden insertar palabras los días impares
ALTER TRIGGER Chorrada ON Palabras2 AFTER INSERT,UPDATE AS
BEGIN
	IF DAY(GetDate()) % 2 = 0
		ROLLBACK
END -- TRIGGER
GO
INSERT INTO Palabras2 (Palabra) VALUES ('Acerga')
--Cambiamos la fecha
INSERT INTO Palabras2 (Palabra) VALUES ('Zezyzeñorita')
GO
--Propagando el mal
CREATE TRIGGER Posteridad ON Criaturitas AFTER INSERT AS
BEGIN
	INSERT INTO Palabras2 (Palabra) SELECT (Nombre) FROM Inserted
END -- TRIGGER
GO
INSERT INTO Criaturitas (Nombre) VALUES ('Obdulia')
--Cambiamos la fecha
INSERT INTO Criaturitas (Nombre) VALUES ('Aniceto')
GO
-- Genera una fila adicional
CREATE TRIGGER Cena ON Palabras2 AFTER INSERT AS
BEGIN
	DECLARE @PalabraInsertada Varchar(20)
	SELECT @PalabraInsertada = Palabra FROM inserted
	PRINT 'Fila insertada en Palabras2'
	INSERT INTO Palabras2 (Palabra) VALUES ('Otro '+@PalabraInsertada )
END
GO
--Prueba
INSERT INTO Criaturitas (Nombre) VALUES ('Romualdo')
INSERT INTO Criaturitas (Nombre) VALUES ('Eufrasia'),('Sisebuto')

SELECT * FROM Criaturitas
SELECT * FROM Palabras2
GO
CREATE TRIGGER Numerofilas ON Palabras2 AFTER DELETE AS
BEGIN
	DECLARE @Cont SmallInt
	SELECT @cont = COUNT (*) FROM Palabras2
	IF @cont < 10
		BEGIN
		PRINT 'No pueden quedar tan pocas filas en la tabla'
		ROLLBACK
		END
GO
GO
ALTER TRIGGER NumeroFilas ON Palabras2 AFTER INSERT, DELETE AS
BEGIN
	DECLARE @Cont SmallInt
	SELECT @cont = COUNT (*) FROM Palabras2
	IF @cont < 10
		BEGIN
		PRINT 'No pueden quedar tan pocas filas en la tabla'
		ROLLBACK
		END
	ELSE
		IF @cont>20
			BEGIN
			PRINT 'No puede haber tantas filas en la tabla'
			ROLLBACK
			END
END
GO



ALTER TRIGGER Cena2 ON Palabras AFTER INSERT AS
BEGIN
	PRINT 'Fila insertada en Palabras'
	INSERT INTO Palabras2 (ID,Words)
	VALUES (30,'Pajarillo')
END
GO
-- Prueba de INSTEAD OF con vistas
create VIEW PalabrasLargas AS
	SELECT ID, Palabra FROM dbo.Palabras WHERE LEN(Palabra) > 10
GO
CREATE TRIGGER Aviso ON Palabras AFTER INSERT AS
	IF EXISTS (SELECT * FROM Inserted WHERE LEN(Palabra) > 10)
		PRINT 'Lo bueno si breve...'
GO
INSERT INTO Palabras (Palabra) VALUES ('Ornitorrinco')

GO
-- Lo mismo pero haciendo JOIN con la vista
CREATE TRIGGER AvisoLargo ON Palabras AFTER INSERT AS
	IF EXISTS (SELECT * FROM Inserted AS I 
						JOIN PalabrasLargas AS PL ON I.ID = PL.ID)
		PRINT '...dos veces bueno'
GO
INSERT INTO Palabras (Palabra) VALUES ('Estereofónico')

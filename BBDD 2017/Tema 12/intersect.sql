CREATE TABLE Palabras2 (
	ID SmallInt Not Null Identity Constraint PK_Palabras2 Primary Key
	,Palabra VarChar(30) Null
) 


INSERT INTO Palabras2
(Palabra)
Values
('Hola2')

SELECT Palabra FROM Palabras
INTERSECT
SELECT Palabra FROM Palabras2

SELECT * FROM Palabras
SELECT * FROM Palabras2
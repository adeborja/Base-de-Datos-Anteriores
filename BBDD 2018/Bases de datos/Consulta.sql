USE EXAMEN12122017
GO

INSERT INTO Dueños
(ID, nombre, email)
VALUES
(1, 'Angel', 'asd@holo.com'),
(2, 'David', 'asd2@holo.com')

SELECT * FROM Dueños

INSERT INTO Mascotas
(nombre, raza, ID_Dueño)
VALUES
('Cono', 'YorkShire', 1) --('Cono', 'Shawi', 1)

select * from Mascotas
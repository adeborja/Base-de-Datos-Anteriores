USE EXAMEN12122017
GO

ALTER TABLE Due�os ADD CONSTRAINT CK_TAB1 CHECK (email LIKE '%@%.%')

ALTER TABLE Mascotas ADD CONSTRAINT CK_TAB2_2 CHECK (raza in ('yorkshire', 'cocker'))
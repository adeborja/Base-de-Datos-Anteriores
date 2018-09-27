use master
if exists (select * from sysdatabases where name='PRUEBAS_EXAMEN_coches')
begin
	drop database PRUEBAS_EXAMEN_coches
end
go


CREATE DATABASE PRUEBAS_EXAMEN_coches
GO

USE PRUEBAS_EXAMEN_coches
GO

CREATE TABLE Coches(
Matricula varchar(7) not null,
Color varchar(10) null,
Marca varchar(15) not null,
Modelo varchar(15) null,
Puertas int not null,
Tipo_Gasolina varchar(10) not null,
CONSTRAINT PK_Coches PRIMARY KEY (Matricula)
)
GO

CREATE TABLE Gasolineras(
ID smallint not null identity(1,1),
Calle nvarchar(30) not null,
Petrolera varchar(10) not null,
Precio_Diesel_L smallmoney not null,
Precio_Gasolina_L smallmoney not null,
CONSTRAINT PK_Gasolineas PRIMARY KEY (ID)
)
GO

CREATE TABLE Repostajes(
IDfactura smallint not null identity(1,1),
Matricula_Coche varchar(7) not null,
ID_gasolinera smallint not null,
Litros_Repostados real not null,
Facturacion smallmoney not null,
CONSTRAINT PK_Repostajes PRIMARY KEY (IDfactura),
CONSTRAINT FK_Repostajes1 FOREIGN KEY (Matricula_Coche) REFERENCES Coches (Matricula),
CONSTRAINT FK_Repostajes2 FOREIGN KEY (ID_gasolinera) REFERENCES Gasolineras (ID)
)
GO

INSERT INTO Coches
(Matricula,Color,Marca,Modelo,Puertas,Tipo_Gasolina)
VALUES
('4599FFJ','Rojo','Renault','Megane',5,'Diesel'),
('2018FEB','Azul','Peugeot','307',5,'Diesel'),
('2093JAJ','Rojo','Chevrolet','Camaro',3,'Gasolina')
GO

INSERT INTO Gasolineras
(Calle, Petrolera, Precio_Diesel_L, Precio_Gasolina_L)
VALUES
('Mentolados, 20','Cepsa',1.10,1.21),
('Frutas del bosque, S/N','Repsol',1.11,1.20),
('Multivitaminas, 9','Shell',1.09,1.25)
GO



INSERT INTO Repostajes
(Matricula_Coche, ID_gasolinera, Litros_Repostados, Facturacion)
(select (select Matricula from Coches where Marca='Renault'),ID ,10, 10*Precio_Diesel_L
	from Gasolineras
	--where Gasolineras.ID=1
)

INSERT INTO Repostajes
(Matricula_Coche, ID_gasolinera, Litros_Repostados, Facturacion)
(select (select Matricula from Coches where Marca='Renault'),ID ,10/Precio_Diesel_L, 10
	from Gasolineras
	--where Gasolineras.ID=1
)

select * from Gasolineras

select * from Repostajes

delete from Repostajes
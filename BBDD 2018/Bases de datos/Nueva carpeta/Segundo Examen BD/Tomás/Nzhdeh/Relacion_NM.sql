--drop database Relacion_NM

create database Relacion_NM
go
use Relacion_NM
go

create table Barcos
(
	CodigoMMSI tinyint not null,
	Nombre varchar (10),
	PaisDeBandera varchar (10),
	--indicamos que CodigoMMSI es la clave primaria de la tabla Barcos
	constraint PK_Barcos primary key (CodigoMMSI),
)
go

create table Vertidos
(
	ID tinyint not null,
	Longitud varchar(10) not null,
	Latitud varchar (10) not null,
	TipoProducto varchar (10) not null,
	--indicamos que ID es la clave primaria de la tabla Vertidos
	constraint PK_Vertidos primary key (ID), 
)
go 

--creamos una nueva tabla para la relacion N:M con las claves primarias de las dos tablas 
--y si la relacion tuviera atributos tambien estaria en esta nueva tabla

create table Barcos_Vertidos
(
	CodigoMMSI_Barcos tinyint not null,
	ID_Vertidos tinyint not null,
	--indicamos que (CodigoMMSI_Barcos,ID_Vertidos) es la clave primaria de la tabla Barcos_Vertidos
	constraint PK_Barcos_Vertidos primary key (CodigoMMSI_Barcos,ID_Vertidos),
	--indicamos que CodigoMMSI_Barcos y ID_Vertidos son claves ajenas(FOREIGN KEY)
	CONSTRAINT FK_Barcos_Vertidos Foreign Key (CodigoMMSI_Barcos) REFERENCES Barcos (CodigoMMSI) on update cascade on delete cascade,
	CONSTRAINT FK_Vertidos_Barcos Foreign Key (ID_Vertidos) REFERENCES Vertidos (ID) on update cascade on delete cascade,
)
go

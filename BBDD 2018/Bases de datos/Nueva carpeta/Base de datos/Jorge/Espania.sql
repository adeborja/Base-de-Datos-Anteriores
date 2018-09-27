create database VivaEspania
go
use VivaEspania
go



create table Localidades(
	
	ID char(5) not null
		constraint PK_ID_Localidades primary key,
	Nombre varchar(30) not null,
	Poblacion int not null,
	CP_Provincia char (5) not null
)


create table Comunidades(

	ID char(5) not null
		constraint PK_ID_Comunidades primary key,
	Nombre varchar (30) not null,
	Poblacion int not null,
	Superficie int not null,
	ID_Localidad char (5) not null
		constraint FK_IDLocalidad_Comuninades foreign key references Localidades(ID)
		ON DELETE NO ACTION ON UPDATE CASCADE
		constraint UQ_IDLocalidad_Comunidades unique
)
-- alter table Comunidades add constraint UQ_IDLocalidad_Comunidades unique (ID_Localidad)

create table Provincias (
	CP char (5) not null
		constraint PK_CP_Provincia primary key,
	Nombre varchar(30) not null,
	Poblacion int not null,
	Superficie int not null,
	ID_Comunidad char(5) not null
		constraint FK_IDComunidad_Provincias foreign key references Comunidades(ID)
		ON DELETE NO ACTION ON UPDATE NO ACTION,
	ID_Localidad char (5) not null
		constraint FK_IDLocalidad_Provincias foreign key references Localidades(ID)
		ON DELETE NO ACTION ON UPDATE CASCADE	
		constraint UQ_IDLocalidad_Provincias unique
)

-- alter table Provincias add constraint UQ_IDLocalidad_Provincias unique (ID_Localidad)


alter table Localidades add 
	constraint FK_CDProvincia_Localidades foreign key (CP_Provincia) references Provincias(CP)
	ON DELETE NO ACTION ON UPDATE NO ACTION
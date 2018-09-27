--use master
--go
--drop database Relacion_11

create database Relacion_11
go 
use Relacion_11
go

--en este caso la clave de la tabla con cardinalidades 1,1 se propaga a la tabla con cardinalidades 0,1

--cardinalidades minimas y maximas 1,1
create table Asientos
(
	NumeroAsiento tinyint not null,
	constraint PK_Asientos primary key (NumeroAsiento),
)
go

--cardinalidades minimas y maximas 0,1
create table Pasajeros
(
	ID tinyint not null,
	Nombre varchar(15) not null,
	Direccion varchar(30) not null,
	NumeroAsientoAsientos tinyint not null,
	constraint PK_Pasajeros primary key (ID),
	constraint FK_Pasajeros_Asientos foreign key (NumeroAsientoAsientos) references Asientos(NumeroAsiento) on update cascade on delete cascade,
	constraint UQ_Pasajeros_Asientos unique (NumeroAsientoAsientos)--si no ponemos unique no sabremos si es una relacion 1:N o 1:1
)
go


--en este caso se crea una nueva tabla

--cardinalidades minimas y maximas 0,1
create table Entradas
(
	ID tinyint not null,
	Fecha date not null,
	Fila tinyint not null,
	NumeroAsiento tinyint not null,
	constraint PK_Entradas primary key (ID),
)
go

--cardinalidades minimas y maximas 0,1
create table Personas
(
	DNI varchar(9) not null,
	Nombre varchar (10) not null,
	Apellidos varchar(15) not null,
	constraint PK_Personas primary key (DNI),
)
go

create table Entradas_Personas
(
	IDEntrada tinyint not null,
	DNIPersina varchar(9) not null,
	------------------------------------------
	constraint PK_Entradas_Personas primary key (IDEntrada,DNIPersina),
	------------------------------------------
	constraint FK_Entradas_Personas foreign key (IDEntrada) references Entradas(ID) on update cascade on delete cascade,
	constraint UQ_Entradas_Personas unique (IDEntrada),
	------------------------------------------
	constraint FK_Personas_Entradas foreign key (DNIPersina) references Personas(DNI) on update cascade on delete cascade,
	constraint UQ_Personas_Entradas unique (DNIPersina)
)
go

--en el caso de que las cardinalidades minimas y maximas de ambas entidades sean 1,1 fundiremos la tabla
--por ejemplo si suponemos que las cardinalidades minimas y maximas de las tablas ASIENTOS Y PASAJEROS son 1,1 tendremos esto:
	--elijo el nombre (Asiento o Pasajero)
	--creo la tabla 

create table R_Asiento
(
	NumeroAsiento tinyint not null,
	ID tinyint not null,
	Nombre varchar(15) not null,
	Direccion varchar(30) not null,
	constraint PK_R_Asiento primary key (NumeroAsiento,ID),
)


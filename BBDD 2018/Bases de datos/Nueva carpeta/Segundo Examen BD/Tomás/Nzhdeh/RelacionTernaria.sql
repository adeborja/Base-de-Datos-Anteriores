--drop database RelacionTernaria

create database RelacionTernaria
go
use RelacionTernaria
go

create table Pasajero
(
	DNI char(9) not null,
	Nombre varchar(20) not null,
	Apellido varchar(30) not null,
	Direccion varchar (50) not null,
	Telefono char (9) not null,
	--indicamos cual es la clave primaria
	constraint PK_Pasajero primary key(DNI),
)

go

create table Asiento
(
	Fila tinyint not null,
	Numero tinyint not null,
	--indicamos cual es la clave primaria
	constraint PK_Asiento primary key(Fila,Numero),--dos PKs en una misma tabla(Clave compuesta)
)
go

create table Vuelo
(
	Codigo tinyint not null,
	Origen varchar(40) not null,
	Destino varchar(40) not null,
	--indicamos cual es la clave primaria
	constraint PK_Vuelo primary key(Codigo),
)

go

--Si la relacion es N:M:P Se resuelven igual que las N:M o sea creando una nueva tabla
--Si la relacion es N:M:1 Se resuelven igual que las N:M o sea creando una nueva tabla,pero las claves primarias son las PKs de N y M
--Si la relacion es N:1:1 Se resuelven igual que las N:M o sea creando una nueva tabla,pero las clave primaria es la PK de N
create table PasajeroAsientoVuelo
(
	DNIPasajero char(9) not null,
	FilaAsiento tinyint not null,
	NumeroAsiento tinyint not null,
	CodigoVuelo tinyint not null
	constraint PK_PasajeroAsiento primary key(DNIPasajero),
	constraint FK_PasajeroAsiento_Pasajero foreign key (DNIPasajero) references Pasajero (DNI) ON DELETE CASCADE ON UPDATE CASCADE,
	constraint FK_PasajeroAsiento_Asiento foreign key (FilaAsiento,CodigoVuelo) references Asiento (Fila,Numero) ON DELETE CASCADE ON UPDATE CASCADE,
	constraint FK_PasajeroAsiento_Vuelo foreign key (CodigoVuelo) references Vuelo (Codigo) ON DELETE CASCADE ON UPDATE CASCADE,
)

go
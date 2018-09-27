--drop database RelaxingCup
create database RelaxingCup
go
use RelaxingCup
go

--creamos la tabla Cafe
create table Cafes
(
	Nombres char(15) not null,
	Origenes varchar (20) not null,
	Precio decimal (5,2) not null,

	--indicamos cual es la clave primaria
	constraint PK_Cafes primary key (Nombres) 
)
go

--creamos la tabla Propiedad
create table Propiedades
(
	ID tinyint not null,
	descripcion varchar (30) not null,

	--indicamos cual es la clave primaria
	constraint PK_Propiedades primary key (ID) 
)

--creamos la tabla Cliente
create table Clientes
(
	DNI char(9) not null,
	Nombre varchar (20) not null,
	Direccion varchar (30) not null,

	--indicamos cual es la clave primaria
	constraint PK_Clientes primary key (DNI) 
)
go

--creamos la tabla Mezcla
create table Mezclas
(
	Codigo tinyint not null,
	DNICliente char(9) not null,

	--indicamos cual es la clave primaria
	constraint PK_Mezclas primary key (Codigo), 

	--indicamos la clave ajena, como la relacion es 1:N propago la clave primaria de Clientes hacia Mezclas
	constraint FK_Clientes_Mezclas1N foreign key (DNICliente) references Clientes (DNI) on update cascade on delete cascade
)
go

--creamos la tabla CafePropiedad para la relacion N:M 
--entre las tablas Cafes y Propiedades
create table CafesPropiedades
(
	NombreCafes char(15) not null,
	IDPropiedades tinyint not null,

	--indicamos cual es la clave primaria
	constraint PK_Cafes_Propiedades primary key (NombreCafes,IDPropiedades),

	--indicamos cuales son las claves ajenas
	constraint FK_CafesPropiedades foreign key (NombreCafes) references Cafes(Nombres) on update cascade on delete cascade,
	constraint FK_PropiedadesCafes foreign key (IDPropiedades) references Propiedades(ID) on update cascade on delete cascade
)
go

--creamos la tabla CafeMezcla para la relacion N:M 
--entre las tablas Cafes y Mezclas
create table CafesMezclas
(
	NombreCafes char(15) not null,
	CodigoMezclas tinyint not null,
	Proporcion decimal (5,2) not null,

	--indicamos cual es la clave primaria
	constraint PK_Cafes_Mezclas primary key (NombreCafes,CodigoMezclas),

	--indicamos cuales son las claves ajenas
	constraint FK_CafesMezclas foreign key (NombreCafes) references Cafes(Nombres) on update cascade on delete cascade,
	constraint FK_MezclasCafes foreign key (CodigoMezclas) references Mezclas(Codigo) on update cascade on delete cascade,
)
go

--creamos la tabla ClienteMezcla para la relacion N:M 
--entre las tablas Clientes y Mezclas

create table ClientesMezclas
(
	CodigoMezcla tinyint not null,
	DNICliente char(9) not null,

	--indicamos cual es la clave primaria
	constraint PK_ClientesMezclas primary key (CodigoMezcla,DNICliente),

	--indicamos cuales son las claves ajenas
	constraint FK_Clientes_Mezclas foreign key (CodigoMezcla) references Mezclas(Codigo) on update cascade on delete cascade,
	constraint FK_Mezclas_Clientes foreign key (DNICliente) references Clientes(DNI) on delete no action
)
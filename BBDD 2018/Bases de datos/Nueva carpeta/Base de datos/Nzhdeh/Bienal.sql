--use master
--go
--drop database Bienal

create database Bienal
go
use Bienal
go

create table Empresas
(
	CIF char(9) not null,
	Nombres varchar (20) not null,
	Direcciones varchar (30) not null,

	--------------------------------
	constraint PK_Empresas primary key (CIF)
)
go

create table Trabajadores	------TipoTrabajo en la relacion
(
	DNI char(9) not null,
	Nombres varchar (15) not null,
	Apellidos varchar (20) not null,

	--------------------------------
	constraint PK_Trabajadores primary key (DNI)
)
go

create table Espectaculos    ----relacion 1:N flecha hacia funciones
(
	ID tinyint not null,--inventado
	DNITrabajadores char(9) not null,

	--------------------------------
	constraint PK_Espectaculos primary key (ID),

	--------------------------------
	constraint FK_Trabajadores_Coordina_Espectaculos foreign key (DNITrabajadores) references Trabajadores(DNI) on update cascade on delete cascade
)
go

create table Funciones
(
	ID tinyint not null,--inventado
	Fechas datetime not null,
	IDEspectaculo tinyint not null,
	--------------------------------
	constraint PK_Funciones primary key (ID),

	--------------------------------
	constraint FK_Espectaculos_Funciones foreign key (IDEspectaculo) references Espectaculos(ID) on update cascade on delete cascade
)
go

create table Representantes
(
	DNI char(9) not null,
	Nombres varchar (15) not null,
	Apellidos varchar (20) not null,
	Telefonos varchar(15) not null,
	--------------------------------
	constraint PK_Representantes primary key (DNI)
)
go

create table Artistas
(
	DNI char(9) not null,
	Nombres varchar (15) not null,
	Apellidos varchar (20) not null,
	Profecion varchar(15) not null,
	DNIRepresentantes char(9) not null,

	--------------------------------
	constraint PK_Artistas primary key (DNI),

	--------------------------------
	constraint FK_Representantes_Artistas foreign key (DNIRepresentantes) references Representantes(DNI) on update cascade on delete cascade
)
go

create table Espacios
(
	ID char(9) not null,
	Nombres varchar (15) not null,
	Direcciones varchar (20) not null,
	Aforos tinyint not null,
	--------------------------------
	constraint PK_Espacios primary key (ID)
)
go

create table Zonas
(
	Filas tinyint not null,
	Asientos tinyint not null,
	IDEspacios char(9) not null,
	--------------------------------
	constraint PK_Zonas primary key (Filas),

	--------------------------------
	constraint FK_Espacios_Zonas foreign key (IDEspacios) references Espacios(ID) on update cascade on delete cascade
)
go

create table Localidades
(
	CodigoPostal char (5) not null,
	FilasZonas tinyint not null,
	--------------------------------
	constraint PK_Localidades primary key (CodigoPostal),

	--------------------------------
	constraint FK_Zonas_Localidades foreign key (FilasZonas) references Zonas(Filas) on update cascade on delete cascade
)
go

--relacion 1:N convertido en una N:M
create table EmpresasTrabajadores
(
	CIFEmpresas char(9) not null,
	DNITrabajadores char (9) not null,
	TipoTrabajo varchar(10) null,
	

	--------------------------------
	constraint PK_Empresas_Trabajadores primary key (DNITrabajadores),--es una relacion 1:N por eso la clave primaria tiene que ser la de la N

	--------------------------------
	constraint FK_Trabajadores_Empresas foreign key (CIFEmpresas) references Empresas (CIF) on update no action on delete no action,
	constraint FK_Empresas_Trabajadores foreign key (DNITrabajadores) references Trabajadores (DNI) on update cascade on delete cascade
)
go

create table EspectaculosArtistas
(
	IDEspectaculos tinyint not null,
	DNIArtistas char(9) not null,

	--------------------------------
	constraint PK_Espectaculos_Artistas primary key (IDEspectaculos,DNIArtistas),

	--------------------------------
	constraint FK_Artistas_Espectaculos foreign key (IDEspectaculos) references Espectaculos (ID) on update no action on delete no action,
	constraint FK_Espectaculos_Artistas foreign key (DNIArtistas) references Artistas (DNI) on update cascade on delete cascade
)
go

create table EspectaculosEspacios
(
	IDEspectaculos tinyint not null,
	IDEspacios char(9) not null,
	--------------------------------
	constraint PK_Espectaculos_Espacios primary key (IDEspectaculos,IDEspacios),

	--------------------------------
	constraint FK_Espectaculos_Espacios foreign key (IDEspectaculos) references Espectaculos (ID) on update no action on delete no action,
	constraint FK_Espacios_Espectaculos foreign key (IDEspacios) references Espacios (ID) on update cascade on delete cascade
)
go

create table LocalidadesFunciones
(
	CodigoPostalLocalidades char (5) not null,
	IDFunciones tinyint not null,
	--------------------------------
	constraint PK_Localidades_Funciones primary key (CodigoPostalLocalidades,IDFunciones),

	--------------------------------
	constraint FK_Localidades_Funciones foreign key (CodigoPostalLocalidades) references  Localidades (CodigoPostal) on update no action on delete no action,
	constraint FK_Funciones_Localidades foreign key (IDFunciones) references Funciones (ID) on update cascade on delete cascade
)
go

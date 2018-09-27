--use master
--drop database BienalFlamenco201718

CREATE DATABASE BienalFlamenco201718
GO

--restriccion de columna
--fechanac date null constraint ck_nojohnconnor check(fechanac < current_timestamp)

--restriccion de tabla
--constraint ck_tamanopie check (numeropie between 25 and 55)

--restringir valores validos
--nivelingles char(2) null constraint ck_niveleuropeo check (nivelingles in ('A1','A2','B1','B2','C1','C2'))

--casting
--historieta varchar(30) constraint ck_imaginacion check (historieta <> 7+' Pecadores') --la cadena la transforma en entero y da error, hay que castear

--historieta varchar(30) constraint ck_imaginacion check (historieta <> CAST(7 as varchar)+' Pecadores')


USE BienalFlamenco201718
GO

CREATE TABLE Espectaculos(
Nombre nvarchar(40) not null,
Edicion smallint not null,
FechaInicio datetime not null,
FechaFin datetime null,
CONSTRAINT PK_Espectaculos PRIMARY KEY (Nombre, Edicion)
)

CREATE TABLE Representantes(
Nombre nvarchar(25) not null,
Apellidos nvarchar(40) not null,
Telefono char(9) not null,
Email nvarchar(40) null,
DNI char(9) not null,
CONSTRAINT PK_Representantes PRIMARY KEY (DNI),
--CONSTRAINT CK_Representantes CHECK (Telefono LIKE '[6|9][0-9]')
)

CREATE TABLE Artistas(
Nombre nvarchar(25) not null,
Apellidos nvarchar(40) not null,
Telefono char(9) null,
TipoArtista nvarchar(20) not null,
NombreArtistico nvarchar(20) null,
DNI char(9) not null,
CONSTRAINT PK_Artistas PRIMARY KEY (DNI)
)

CREATE TABLE Representantes_Artistas(
DNIArtista char(9) not null,
DNIrepresentante char(9) not null,
CONSTRAINT PK_Representantes_Artistas PRIMARY KEY (DNIArtista, DNIrepresentante),
CONSTRAINT FK_Representantes_Artistas1 FOREIGN KEY (DNIArtista) REFERENCES Artistas(DNI) ON DELETE NO ACTION ON UPDATE CASCADE,
CONSTRAINT FK_Representantes_Artistas2 FOREIGN KEY (DNIrepresentante) REFERENCES Representantes (DNI) ON DELETE NO ACTION ON UPDATE CASCADE
)

CREATE TABLE Espectaculos_Artistas(
NombreEspectaculo nvarchar(40) not null,
EdicionEspectaculo smallint not null,
DNIArtista char(9) not null,
CONSTRAINT PK_Espectaculos_Artistas PRIMARY KEY (NombreEspectaculo, EdicionEspectaculo, DNIArtista),
CONSTRAINT FK_Espectaculos_Artistas1 FOREIGN KEY (NombreEspectaculo, EdicionEspectaculo) REFERENCES Espectaculos(Nombre, Edicion),
CONSTRAINT FK_Espectaculos_Artistas2 FOREIGN KEY (DNIArtista) REFERENCES Artistas(DNI)
)

CREATE TABLE Empresas(
CIF char(9) not null,
Nombre nvarchar(50) not null,
Direccion nvarchar(50) not null,
Telefono char(9) not null,
CONSTRAINT PK_Empresas PRIMARY KEY (CIF)
)

CREATE TABLE Trabajadores(
Nombre nvarchar(25) not null,
Apellidos nvarchar(40) not null,
Telefono char(9) not null,
Direccion nvarchar(40) not null,
TipoTrabajo nvarchar(40) not null,
DNI char(9) not null,
CIFempresa char(9) null --hacer restriccion check https://es.wikipedia.org/wiki/C%C3%B3digo_de_identificaci%C3%B3n_fiscal,
CONSTRAINT PK_Trabajadores PRIMARY KEY (DNI),
CONSTRAINT FK_Trabajadores FOREIGN KEY (CIFempresa) REFERENCES Empresas(CIF)
)

CREATE TABLE Trabajadores_Espectaculos(
DNItrabajador char(9) not null,
NombreEspectaculo nvarchar(40) not null,
EdicionEspectaculo smallint not null,
CONSTRAINT PK_Trabajadores_Espectaculos PRIMARY KEY (DNItrabajador, NombreEspectaculo, EdicionEspectaculo),
CONSTRAINT FK_Trabajadores_Espectaculos1 FOREIGN KEY (NombreEspectaculo, EdicionEspectaculo) REFERENCES Espectaculos(Nombre, Edicion),
CONSTRAINT FK_Trabajadores_Espectaculos2 FOREIGN KEY (DNItrabajador) REFERENCES Trabajadores(DNI)
)

ALTER TABLE Espectaculos
ADD DNIresponsable char(9) not null,
CONSTRAINT FK_Espectaculos FOREIGN KEY (DNIresponsable) REFERENCES Trabajadores (DNI)

CREATE TABLE Espacios(
Nombre nvarchar(50) not null,
Direccion nvarchar(50) not null,
Aforo int not null,
Tipo nvarchar(25) not null,
--LocalidadesNumeradas tinyint not null,
CONSTRAINT PK_Espacios PRIMARY KEY (Nombre, Direccion)
)

ALTER TABLE Espectaculos
	ADD NombreEspacio nvarchar(50) not null,
	DireccionEspacio nvarchar(50) not null,
	CONSTRAINT FK_Espectaculos2 FOREIGN KEY (NombreEspacio, DireccionEspacio) REFERENCES Espacios (Nombre, Direccion)

CREATE TABLE Zonas(
Nombre nvarchar(15) not null,
NombreEspacio nvarchar(50) not null,
DireccionEspacio nvarchar(50) not null,

CONSTRAINT PK_Espacios_Espectaculos PRIMARY KEY (NombreEspectaculo, EdicionEspectaculo, NombreEspacio, DireccionEspacio),
CONSTRAINT FK_Espacios_Espectaculos1 FOREIGN KEY (NombreEspectaculo, EdicionEspectaculo) REFERENCES Espectaculos(Nombre, Edicion),
CONSTRAINT FK_Espacios_Espectaculos2 FOREIGN KEY (NombreEspacio, DireccionEspacio) REFERENCES Espacios (Nombre, Direccion)
)


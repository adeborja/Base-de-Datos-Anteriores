--IF EXISTS(DATABASE Fracking201718)
--USE master
--DROP DATABASE Fracking201718


CREATE DATABASE Fracking201718
GO

USE Fracking201718
GO

CREATE TABLE Zonas(
Ubicacion nvarchar(40) not null,
ID smallint not null,
ExtensionKM2 decimal (7,2) null,
CONSTRAINT PK_Zonas PRIMARY KEY (ID) 
)

CREATE TABLE OrganizacionesEcologicas(
Nombre nvarchar(40) not null,
Telefono char(9) null,
ID smallint not null,
CONSTRAINT PK_OrganizacionesEcologicas PRIMARY KEY (ID),
CONSTRAINT CK_OrganizacionesEcologicas CHECK (Telefono IN('[0-9],[0-9],[0-9],[0-9],[0-9],[0-9],[0-9],[0-9],[0-9]'))
)

CREATE TABLE OrganizacionesEcologicas_Zonas(
IDzona smallint not null,
IDorganizacion smallint not null,
CONSTRAINT PK_OrganizacionesEcologicas_Zonas PRIMARY KEY (IDzona, IDorganizacion),
CONSTRAINT FK_OrganizacionesEcologicas_Zonas1 FOREIGN KEY (IDzona) REFERENCES Zonas(ID),
CONSTRAINT FK_OrganizacionesEcologicas_Zonas2 FOREIGN KEY (IDorganizacion) REFERENCES OrganizacionesEcologicas(ID)
)

CREATE TABLE Protestas(
Lugar nvarchar(50) not null,
Momento datetime not null,
ID smallint not null,
CONSTRAINT PK_Protestas PRIMARY KEY(ID)
)

CREATE TABLE OrganizacionesEcologicas_Protestas(
IDorganizacion smallint not null,
IDprotesta smallint not null,
CONSTRAINT PK_OrganizacionesEcologicas_Protestas PRIMARY KEY (IDorganizacion, IDprotesta),
CONSTRAINT FK_OrganizacionesEcologicas_Protestas1 FOREIGN KEY (IDorganizacion) REFERENCES OrganizacionesEcologicas(ID),
CONSTRAINT FK_OrganizacionesEcologicas_Protestas2 FOREIGN KEY (IDprotesta) REFERENCES Protestas(ID)
)

CREATE TABLE Parcelas(
Extension decimal(7,2) null,
ID smallint not null,
CONSTRAINT PK_Parcelas PRIMARY KEY (ID)
)

CREATE TABLE Propietarios(
Nombre nvarchar(30) not null,
Apellidos nvarchar(30) not null,
Telefono char(9) null,
Direccion nvarchar(50) null,
FavorableASondeo tinyint null, -- no es favorable -> 0 , es favorable -> 1
ID smallint not null,
CONSTRAINT PK_Propietarios PRIMARY KEY(ID),
CONSTRAINT CK_Propietarios CHECK (Telefono IN('[0-9],[0-9],[0-9],[0-9],[0-9],[0-9],[0-9],[0-9],[0-9]'))
)

CREATE TABLE Propietarios_Parcelas(
IDpropietario smallint not null,
IDparcela smallint not null,
CONSTRAINT PK_Propietarios_Parcelas PRIMARY KEY(IDpropietario, IDparcela),
CONSTRAINT FK_Propietarios_Parcelas1 FOREIGN KEY(IDpropietario) REFERENCES Propietarios(ID),
CONSTRAINT FK_Propietarios_Parcelas2 FOREIGN KEY(IDparcela) REFERENCES Parcelas(ID)
)

CREATE TABLE Limites(
ID smallint not null,
Latitud decimal(4,2) not null,
Longitud decimal(5,2) not null,
CONSTRAINT PK_Limites PRIMARY KEY(ID),
CONSTRAINT CK_Limites1 CHECK(Latitud BETWEEN -90 AND 90),
CONSTRAINT CK_Limites2 CHECK(Longitud BETWEEN -180 AND 180)
)

CREATE TABLE Limites_Parcelas(
IDparcela smallint not null,
IDlimite smallint not null,
CONSTRAINT PK_Limites_Parcelas PRIMARY KEY(IDparcela, IDlimite),
CONSTRAINT FK_Limites_Parcelas1 FOREIGN KEY(IDparcela) REFERENCES Parcelas(ID),
CONSTRAINT FK_Limites_Parcelas2 FOREIGN KEY(IDlimite) REFERENCES Limites(ID)
)

CREATE TABLE AdministracionesPublicas(
Nombre nvarchar(60) not null,
ID smallint not null,
CONSTRAINT PK_AdministracionesPublicas PRIMARY KEY(ID)
)

CREATE TABLE AdministracionesPublicas_Parcelas(
IDparcela smallint not null,
IDadministracion smallint not null,
CONSTRAINT PK_AdministracionesPublicas_Parcelas PRIMARY KEY(IDparcela, IDadministracion),
CONSTRAINT FK_AdministracionesPublicas_Parcelas1 FOREIGN KEY(IDparcela) REFERENCES Parcelas(ID),
CONSTRAINT FK_AdministracionesPublicas_Parcelas2 FOREIGN KEY(IDadministracion) REFERENCES AdministracionesPublicas(ID)
)

CREATE TABLE CargosPublicos(
Nombre nvarchar(50) not null,
Apellidos nvarchar(50) not null,
Telefono char(9) null,
Direccion nvarchar(60) null,
ID smallint not null,
CONSTRAINT PK_CargosPublicos PRIMARY KEY(ID),
CONSTRAINT CK_CargosPublicos CHECK (Telefono IN('[0-9],[0-9],[0-9],[0-9],[0-9],[0-9],[0-9],[0-9],[0-9]'))
)

CREATE TABLE Funcionarios(
ID smallint not null,
IDcargoPublico smallint not null,
FechaContratacion smalldatetime null,
CONSTRAINT PK_Funcionarios PRIMARY KEY(ID, IDcargoPublico),
CONSTRAINT FK_Funcionarios FOREIGN KEY(IDcargoPublico) REFERENCES CargosPublicos(ID)
)

CREATE TABLE Politicos(
ID smallint not null,
IDcargoPublico smallint not null,
FechaContratacion smalldatetime null,
CONSTRAINT PK_Politicos PRIMARY KEY(ID), --(ID, IDcargoPublico),
--CONSTRAINT FK_Politicos FOREIGN KEY(IDcargoPublico) REFERENCES CargosPublicos(ID)
)

CREATE TABLE PuntosDebiles(
ID smallint not null,
Descripcion nvarchar(60) not null,
CONSTRAINT PK_PuntosDebiles PRIMARY KEY(ID)
)

CREATE TABLE PuntosDebiles_CargosPublicos(
IDpuntoDebil smallint not null,
IDcargoPublico smallint not null,
CONSTRAINT PK_PuntosDebiles_CargosPublicos PRIMARY KEY(IDpuntoDebil, IDcargoPublico),
CONSTRAINT FK_PuntosDebiles_CargosPublicos1 FOREIGN KEY(IDpuntoDebil) REFERENCES PuntosDebiles(ID),
CONSTRAINT FK_PuntosDebiles_CargosPublicos2 FOREIGN KEY(IDcargoPublico) REFERENCES CargosPublicos(ID)
)

CREATE TABLE Protestas_Politicos(
IDprotesta smallint not null,
IDpolitico smallint not null,
CONSTRAINT PK_Protestas_Politicos PRIMARY KEY(IDprotesta, IDpolitico),
CONSTRAINT FK_Protestas_Politicos1 FOREIGN KEY(IDprotesta) REFERENCES Protestas(ID),
CONSTRAINT FK_Protestas_Politicos2 FOREIGN KEY(IDpolitico) REFERENCES Politicos(ID)
)

CREATE TABLE Espias(
ID smallint not null,
NombreEnClave nvarchar(20) not null,
CONSTRAINT PK_Espias PRIMARY KEY(ID)
)

CREATE TABLE Espias_Protestas(
IDespia smallint not null,
IDprotesta smallint not null,
CONSTRAINT PK_Espias_Protestas PRIMARY KEY(IDespia, IDprotesta),
CONSTRAINT FK_Espias_Protestas1 FOREIGN KEY(IDespia) REFERENCES Espias(ID),
CONSTRAINT FK_Espias_Protestas2 FOREIGN KEY(IDprotesta) REFERENCES Protestas(ID)
)




ALTER TABLE Parcelas
ADD IDzona smallint not null,
CONSTRAINT FK_Parcelas FOREIGN KEY(IDzona) REFERENCES Zonas(ID)

CREATE TABLE CargosPublicos_AdministracionesPublicas(
IDcargoPublico smallint not null,
IDadministracion smallint not null,
CONSTRAINT PK_CargosPublicos_AdministracionesPublicas PRIMARY KEY(IDcargoPublico, IDadministracion),
CONSTRAINT FK_CargosPublicos_AdministracionesPublicas1 FOREIGN KEY(IDcargoPublico) REFERENCES CargosPublicos(ID),
CONSTRAINT FK_CargosPublicos_AdministracionesPublicas2 FOREIGN KEY(IDadministracion) REFERENCES AdministracionesPublicas(ID)
)
--USE master
--DROP DATABASE Cafeses

CREATE DATABASE Cafeses
GO
USE Cafeses
GO

CREATE TABLE Cafes(
nombre nvarchar(20) not null,
origen nvarchar(20) null,
precioKg real not null,
CONSTRAINT PK_Cafes PRIMARY KEY (nombre)
)

GO

CREATE TABLE Propiedades(
ID int not null,
descripcion nvarchar(60) null,
CONSTRAINT PK_Propiedades PRIMARY KEY (ID)
)

GO

CREATE TABLE CafesPropiedades(
nombre_cafe nvarchar(20) not null,
ID_propiedad int not null,
CONSTRAINT PK_CafesPropiedades PRIMARY KEY (nombre_cafe, ID_propiedad),
CONSTRAINT FK_CafesPropiedades1 FOREIGN KEY (nombre_cafe) REFERENCES Cafes(nombre) on delete no action on update cascade,
CONSTRAINT FK_CafesPropiedades2 FOREIGN KEY (ID_propiedad) REFERENCES Propiedades(ID) on delete no action on update cascade
)

GO

CREATE TABLE Clientes(
DNI nvarchar(9) not null,
nombre nvarchar(40) not null,
direccion nvarchar(60) null,
CONSTRAINT PK_Clientes PRIMARY KEY (DNI)
)

GO

CREATE TABLE Mezclas(
Codigo int not null,
nombre nvarchar(20) not null,
DNI_Cliente nvarchar(9) not null,
CONSTRAINT PK_Mezclas PRIMARY KEY (Codigo),
CONSTRAINT FK_Mezclas FOREIGN KEY (DNI_Cliente) REFERENCES Clientes(DNI) on delete no action on update cascade
)

GO

CREATE TABLE CafesMezclas(
nombre_cafe nvarchar(20) not null,
proporcion real not null,
Codigo_mezcla int not null,
CONSTRAINT PK_CafesMezclas PRIMARY KEY (nombre_cafe, Codigo_mezcla),
CONSTRAINT FK_CafesMezclas1 FOREIGN KEY (nombre_cafe) REFERENCES Cafes(nombre) on delete no action on update cascade,
CONSTRAINT FK_CafesMezclas2 FOREIGN KEY (Codigo_mezcla) REFERENCES Mezclas(Codigo) on delete no action on update cascade
)

GO

CREATE TABLE Compras(
DNI_Cliente nvarchar(9) not null,
Codigo_mezcla int not null,
Fecha smalldatetime not null,
Importe smallmoney not null,
CONSTRAINT PK_Compras PRIMARY KEY (DNI_Cliente, Codigo_mezcla),
CONSTRAINT FK_Compras1 FOREIGN KEY (DNI_Cliente) REFERENCES Clientes(DNI) on delete no action on update no action,
CONSTRAINT FK_Compras2 FOREIGN KEY (Codigo_mezcla) REFERENCES Mezclas(Codigo) on delete no action on update no action
)

GO
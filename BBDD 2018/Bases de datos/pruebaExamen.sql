CREATE DATABASE EXAMEN12122017
GO
USE EXAMEN12122017
GO

CREATE TABLE Due�os(
ID smallint not null,
nombre varchar(30) not null,
email varchar(40) null,
CONSTRAINT PK_TAB1 PRIMARY KEY(ID),
CONSTRAINT UQ_TAB1 UNIQUE (email)
)

GO

CREATE TABLE Mascotas(
ID smallint not null IDENTITY,
nombre varchar(15) not null,
raza varchar(30) null,
ID_Due�o smallint not null,
CONSTRAINT PK_TAB2 PRIMARY KEY(ID),
CONSTRAINT FK_TAB2 FOREIGN KEY(ID_Due�o) REFERENCES Due�os(ID),
CONSTRAINT UQ_TAB2 UNIQUE(ID_Due�o)
)
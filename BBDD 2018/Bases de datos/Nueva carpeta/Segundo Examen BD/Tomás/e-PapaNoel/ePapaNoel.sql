CREATE DATABASE ePapaNoel
GO

/*Use master
DROP DATABASE ePapaNoel*/

USE ePapaNoel
GO

CREATE TABLE Persona(
	DNI char(10) NOT NULL
		CONSTRAINT PK_Persona Primary Key,
	FechaNac date NULL,
	Nombre varchar(30) NOT NULL,
	Telefono char(9) NOT NULL
)

CREATE TABLE Ruta(
	ID int NOT NULL
		CONSTRAINT PK_Ruta Primary Key,
	Zona varchar(50) NOT NULL
)

CREATE TABLE Peticion(
	ID int NOT NULL
		CONSTRAINT PK_Peticion Primary Key,
	EsAceptada bit NOT NULL,
	DNI_Persona char(10) NOT NULL,
	ID_Ruta int NOT NULL
)

ALTER TABLE Peticion ADD
	CONSTRAINT FK_Peticion_Persona FOREIGN KEY (DNI_Persona) REFERENCES Persona(DNI)
	ON DELETE NO ACTION
	ON UPDATE NO ACTION

ALTER TABLE Peticion ADD
	CONSTRAINT FK_Peticion_Ruta FOREIGN KEY (ID_Ruta) REFERENCES Ruta(ID)
	ON DELETE NO ACTION
	ON UPDATE NO ACTION

CREATE TABLE Pedido(
	ID int NOT NULL
		CONSTRAINT PK_Pedido Primary Key,
	Fecha date NOT NULL,
	ID_Tienda int NULL
)

ALTER TABLE Pedido ADD
	CONSTRAINT FK_Pedido_Tienda FOREIGN KEY (ID_Tienda) REFERENCES Tienda(ID)
	ON DELETE NO ACTION
	ON UPDATE NO ACTION

CREATE TABLE Tienda(
	ID int NOT NULL
		CONSTRAINT PK_Tienda Primary Key,
	Denominacio varchar(30) NULL,
	Telefono char(9) NOT NULL
)

CREATE TABLE Accion(
	Codigo int NOT NULL
		CONSTRAINT PK_Accion Primary Key,
	Descripcion varchar(50) NULL,
	FechaHora datetime NULL,
	Lugar varchar(40) NULL
)

CREATE TABLE Buena(
	CodigoAccion int NOT NULL
		CONSTRAINT PK_Buena Primary Key,
	Periodico varchar(30) NULL,
	Recompensa int NULL,
)

ALTER TABLE Buena ADD
	CONSTRAINT FK_Buena_Accion FOREIGN KEY (CodigoAccion) REFERENCES Accion(Codigo)
	ON DELETE NO ACTION
	ON UPDATE NO ACTION

CREATE TABLE Mala(
	CodigoAccion int NOT NULL
		CONSTRAINT PK_Mala Primary Key,
	Coste smallmoney NULL,
	Delito varchar(50) NOT NULL
)

ALTER TABLE Mala ADD
	CONSTRAINT FK_Mala_Accion FOREIGN KEY (CodigoAccion) REFERENCES Accion(Codigo)
	ON DELETE NO ACTION
	ON UPDATE NO ACTION

CREATE TABLE Regalo(
	ID int NOT NULL
		CONSTRAINT PK_Regalo Primary Key
)

CREATE TABLE Categoria(
	IDRegalo int NOT NULL
		CONSTRAINT PK_Categoria Primary Key
)

ALTER TABLE Categoria ADD
	CONSTRAINT FK_Categoria_Regalo FOREIGN KEY (IDRegalo) REFERENCES Regalo(ID)
	ON DELETE NO ACTION
	ON UPDATE NO ACTION

CREATE TABLE Producto(
	IDRegalo int NOT NULL
		CONSTRAINT PK_Producto Primary Key
)

ALTER TABLE Producto ADD
	CONSTRAINT FK_Producto_Regalo FOREIGN KEY (IDRegalo) REFERENCES Regalo(ID)
	ON DELETE NO ACTION
	ON UPDATE NO ACTION

--N:M reflexivas

CREATE TABLE ProductoSustituyeProducto(
	ID_Producto1 int NOT NULL,
	ID_Producto2 int NOT NULL,
	CONSTRAINT PK_ProductoSustituyeProducto Primary Key (ID_Producto1, ID_Producto2)
)

ALTER TABLE ProductoSustituyeProducto ADD
	CONSTRAINT FK_Producto_Producto FOREIGN KEY (ID_Producto1) REFERENCES Producto(IDRegalo)
	ON DELETE NO ACTION
	ON UPDATE NO ACTION

ALTER TABLE ProductoSustituyeProducto ADD
	CONSTRAINT FK_Producto2_Producto1 FOREIGN KEY (ID_Producto2) REFERENCES Producto(IDRegalo)
	ON DELETE NO ACTION
	ON UPDATE NO ACTION

CREATE TABLE PersonaInformaPersona(
	DNI_Informante char(10) NOT NULL,
	DNI_Sujeto char(10) NOT NULL,
	CONSTRAINT PK_PersonaInformaPersona Primary Key (DNI_Informante, DNI_Sujeto)
)

ALTER TABLE PersonaInformaPersona ADD
	CONSTRAINT FK_Informante_Sujeto FOREIGN KEY (DNI_Informante) REFERENCES Persona(DNI)
	ON DELETE NO ACTION
	ON UPDATE NO ACTION

ALTER TABLE PersonaInformaPersona ADD
	CONSTRAINT FK_Sujeto_Informante FOREIGN KEY (DNI_Sujeto) REFERENCES Persona(DNI)
	ON DELETE NO ACTION
	ON UPDATE NO ACTION

--N:M

CREATE TABLE Persona_Accion(
	DNI_Persona char(10) NOT NULL,
	Codigo_Accion int NOT NULL,
	Motivo varchar(40) NULL,
	CONSTRAINT PK_Persona_Accion Primary Key (DNI_Persona, Codigo_Accion)
)

ALTER TABLE Persona_Accion ADD
	CONSTRAINT FK_Persona_Accion_Persona FOREIGN KEY (DNI_Persona) REFERENCES Persona(DNI)
	ON DELETE NO ACTION
	ON UPDATE NO ACTION

ALTER TABLE Persona_Accion ADD
	CONSTRAINT FK_Persona_Accion_Accion FOREIGN KEY (Codigo_Accion) REFERENCES Accion(Codigo)
	ON DELETE NO ACTION
	ON UPDATE NO ACTION

CREATE TABLE Persona_Mala(
	DNI_Persona char(10) NOT NULL,
	Codigo_Accion int NOT NULL,
	CONSTRAINT PK_Persona_Mala Primary Key (DNI_Persona, Codigo_Accion)
)

ALTER TABLE Persona_Mala ADD
	CONSTRAINT FK_Persona_Mala_Persona FOREIGN KEY (DNI_Persona) REFERENCES Persona(DNI)
	ON DELETE NO ACTION
	ON UPDATE NO ACTION

ALTER TABLE Persona_Mala ADD
	CONSTRAINT FK_Persona_Mala_Accion FOREIGN KEY (Codigo_Accion) REFERENCES Accion(Codigo)
	ON DELETE NO ACTION
	ON UPDATE NO ACTION

CREATE TABLE Peticion_Regalo(
	ID_Peticion int NOT NULL,
	ID_Regalo int NOT NULL,
	CONSTRAINT PK_Peticion_Regalo Primary Key (ID_Peticion, ID_Regalo)
)

ALTER TABLE Peticion_Regalo ADD
	CONSTRAINT FK_Peticion_Regalo_Peticion FOREIGN KEY (ID_Peticion) REFERENCES Peticion(ID)
	ON DELETE NO ACTION
	ON UPDATE NO ACTION

ALTER TABLE Peticion_Regalo ADD
	CONSTRAINT FK_Peticion_Regalo_Regalo FOREIGN KEY (ID_Regalo) REFERENCES Regalo(ID)
	ON DELETE NO ACTION
	ON UPDATE NO ACTION

CREATE TABLE Producto_Pedido(
	IDRegalo_Producto int NOT NULL,
	ID_Pedido int NOT NULL,
	CONSTRAINT PK_Producto_Pedido Primary Key (IDRegalo_Producto, ID_Pedido)
)

ALTER TABLE Producto_Pedido ADD
	CONSTRAINT FK_Producto_Pedido_Producto FOREIGN KEY (IDRegalo_Producto) REFERENCES Producto(IDRegalo)
	ON DELETE NO ACTION
	ON UPDATE NO ACTION

ALTER TABLE Producto_Pedido ADD
	CONSTRAINT FK_Producto_Pedido_Pedido FOREIGN KEY (ID_Pedido) REFERENCES Pedido(ID)
	ON DELETE NO ACTION
	ON UPDATE NO ACTION

CREATE TABLE Producto_Tienda(
	IDRegalo_Producto int NOT NULL,
	ID_Pedido int NOT NULL,
	CONSTRAINT PK_Producto_Tienda Primary Key (IDRegalo_Producto, ID_Pedido)
)

ALTER TABLE Producto_Tienda ADD
	CONSTRAINT FK_Producto_Tienda_Producto FOREIGN KEY (IDRegalo_Producto) REFERENCES Producto(IDRegalo)
	ON DELETE NO ACTION
	ON UPDATE NO ACTION

ALTER TABLE Producto_Tienda ADD
	CONSTRAINT FK_Producto_Tienda_Pedido FOREIGN KEY (ID_Pedido) REFERENCES Pedido(ID)
	ON DELETE NO ACTION
	ON UPDATE NO ACTION

CREATE TABLE Producto_Categoria(
	IDRegalo_Producto int NOT NULL,
	IDRegalo_Categoria int NOT NULL,
	CONSTRAINT PK_Producto_Categoria Primary Key (IDRegalo_Producto, IDRegalo_Categoria)
)

ALTER TABLE Producto_Categoria ADD
	CONSTRAINT FK_Producto_Categoria_Producto FOREIGN KEY (IDRegalo_Producto) REFERENCES Producto(IDRegalo)
	ON DELETE NO ACTION
	ON UPDATE NO ACTION

ALTER TABLE Producto_Categoria ADD
	CONSTRAINT FK_Producto_Categoria_Categoria FOREIGN KEY (IDRegalo_Categoria) REFERENCES Categoria(IDRegalo)
	ON DELETE NO ACTION
	ON UPDATE NO ACTION

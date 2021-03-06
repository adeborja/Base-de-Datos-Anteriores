CREATE DATABASE BIENAL_BIEN
GO

USE BIENAL_BIEN
GO

--Creamos las tablas con sus claves primarias
CREATE TABLE EMPRESAS(
	CIF INT NOT NULL 
	,NOMBRE VARCHAR(20) NOT NULL
	,DIRECCION VARCHAR(20) NOT NULL
	,CONSTRAINT PK_EMPRESAS PRIMARY KEY (CIF)
	
)

CREATE TABLE TRABAJADORES(
	DNI CHAR(10) NOT NULL  --SIEMPRE CHAR ! RAFA, SE FUERTE
	,NOMBRE VARCHAR(20) NOT NULL --NO SIEMPRE NOT NULL!!!!!
	,DIRECCION VARCHAR(20) NOT NULL
	,TIPOTRABAJO VARCHAR(20) NOT NULL
	,CIF_EMPRESA INT NOT NULL --FK DE EMPRESA
	,CONSTRAINT PK_TRABAJADORES PRIMARY KEY (DNI)
)

CREATE TABLE ESPECTACULOS(
	TIPO_DE_ESPECTACULO VARCHAR(20) NOT NULL
	,ID INT NOT NULL
	,DNI_TRABAJADOR VARCHAR(10) NOT NULL --FK DE TRABAJADORES
	,CONSTRAINT PK_ESPECTACULOS PRIMARY KEY (ID)
)

CREATE TABLE ESPACIOS(
	NOMBRE VARCHAR(20) NOT NULL
	,DIRECCION VARCHAR(20) NOT NULL
	,AFORO INT NOT NULL
	,TIPO VARCHAR(10) NOT NULL
	,DIA DATE NOT NULL
	,HORA VARCHAR(5) NOT NULL
	,ID INT NOT NULL
	,CONSTRAINT PK_ESPACIOS PRIMARY KEY (ID)
)

CREATE TABLE ZONAS(
	NUMFILAS VARCHAR(10) NOT NULL
	,RECINTO VARCHAR(20) NOT NULL
	,ID INT NOT NULL
	,ID_ESPACIO INT NOT NULL --FK DE ESPACIOS
	,CONSTRAINT PK_ZONAS PRIMARY KEY (ID)
)

CREATE TABLE LOCALIDADES(
	ESPECTACULO VARCHAR(20) NOT NULL
	,RECINTO VARCHAR(10) NOT NULL
	,DIA DATE NOT NULL
	,HORA TIME NOT NULL
	-- HAY QUE USAR SMALLDATETIME
	,ZONA VARCHAR(10) NOT NULL
	,FILA VARCHAR(15) NOT NULL
	,NUMASIENTO VARCHAR(15) NOT NULL
	,ID INT NOT NULL
	,ID_ZONAS INT NOT NULL --FK DE ZONAS
	,CONSTRAINT PK_LOCALIDADES PRIMARY KEY (ID)
)

CREATE TABLE FUNCIONES(
	RECINTO VARCHAR(10) NOT NULL
	,DIA DATE NOT NULL -- HAY QUE USAR SMALLDATETIME
	,HORA VARCHAR(5) NOT NULL
	,ID INT NOT NULL
	,CONSTRAINT PK_FUNCIONES PRIMARY KEY (ID)
)

CREATE TABLE ARTISTAS(
	TIPO_ARTISTAS VARCHAR(20) NOT NULL
	,DNI VARCHAR(10) NOT NULL
	,NOMBRE VARCHAR(20) NOT NULL
	,DIRECCION VARCHAR(20) NOT NULL
	,DNI_REPRESENTANTE VARCHAR(10) NULL --FK REPRESENTANTE  --Cardinalidad m�nima: 0, debe ser NULL
	,CONSTRAINT PK_ARTISTAS PRIMARY KEY (DNI)
)

CREATE TABLE REPRESENTANTES(
	DNI VARCHAR(10) NOT NULL
	,NOMBRE VARCHAR(20) NOT NULL
	,DIRECCION VARCHAR(20) NOT NULL
	,CONSTRAINT PK_REPRESENTANTES PRIMARY KEY (DNI)
)

CREATE TABLE ESPECTACULOS_ESPACIOS(
	ID_ESPACIO INT NOT NULL --FK DE ESPACIOS
	,ID_ESPECTACULO INT NOT NULL --FK DE FUNCIONES
	,CONSTRAINT PK_ESPECTACULO_ESPACIO PRIMARY KEY (ID_ESPACIO,ID_ESPECTACULO)
)

CREATE TABLE LOCALIDADES_FUNCIONES(
	ID_LOCALIDAD INT NOT NULL --FK DE LOCALIDADES
	,ID_FUNCION INT NOT NULL --FK DE FUNCIONES
	,CONSTRAINT PK_LOCALIDAD_FUNCION PRIMARY KEY (ID_LOCALIDAD,ID_FUNCION)
)

CREATE TABLE ARTISTAS_ESPECTACULOS(
	DNI_ARTISTA VARCHAR(10) NOT NULL
	,ID_ESPECTACULO INT NOT NULL
	,CONSTRAINT PK_ARTISTAS_ESPECTACULOS PRIMARY KEY (DNI_ARTISTA,ID_ESPECTACULO)
)

CREATE TABLE TRABAJADORES_ESPECTACULOS(
	DNI_TRABAJADOR VARCHAR(10) NOT NULL
	,ID_ESPECTACULO INT NOT NULL
	,CONSTRAINT PK_TRABAJADORES_ESPECTACULOS PRIMARY KEY (DNI_TRABAJADOR,ID_ESPECTACULO)
)

--ALTER TABLE PARA A�ADIR LAS FK

ALTER TABLE TRABAJADORES ADD CONSTRAINT FK_EMPRESA_TRABAJADORES FOREIGN KEY (CIF_EMPRESA) REFERENCES EMPRESAS(CIF)
ALTER TABLE ESPECTACULOS ADD CONSTRAINT FK_TRABAJADOR_ESPECTACULO FOREIGN KEY (DNI_TRABAJADOR) REFERENCES TRABAJADORES(DNI)
ALTER TABLE ZONAS ADD CONSTRAINT FK_ESPACIOS_ZONA FOREIGN KEY (ID_ESPACIO) REFERENCES ESPACIOS(ID)
ALTER TABLE LOCALIDADES ADD CONSTRAINT FK_ZONAS_LOCALIDADES FOREIGN KEY (ID_ZONAS) REFERENCES ZONAS(ID)
ALTER TABLE ARTISTAS ADD CONSTRAINT FK_ARTISTAS_REPRESENTANTE FOREIGN KEY (DNI_REPRESENTANTE) REFERENCES REPRESENTANTES(DNI)
ALTER TABLE ESPECTACULOS_ESPACIOS ADD CONSTRAINT FK_ESP_ESPAC FOREIGN KEY (ID_ESPACIO) REFERENCES ESPACIOS(ID)
ALTER TABLE ESPECTACULOS_ESPACIOS ADD CONSTRAINT FK_ESP_ESPAC_2 FOREIGN KEY (ID_ESPECTACULO) REFERENCES ESPECTACULOS(ID)
ALTER TABLE LOCALIDADES_FUNCIONES ADD CONSTRAINT FK_LOC_FUN FOREIGN KEY (ID_LOCALIDAD) REFERENCES LOCALIDADES(ID)
ALTER TABLE LOCALIDADES_FUNCIONES ADD CONSTRAINT FK_LOC_FUN_2 FOREIGN KEY (ID_FUNCION) REFERENCES FUNCIONES(ID)
ALTER TABLE ARTISTAS_ESPECTACULOS ADD CONSTRAINT FK_ART_ESPEC FOREIGN KEY (DNI_ARTISTA) REFERENCES ARTISTAS(DNI)
ALTER TABLE ARTISTAS_ESPECTACULOS ADD CONSTRAINT FK_ART_ESPEC_2 FOREIGN KEY (ID_ESPECTACULO) REFERENCES ESPECTACULOS(ID)
ALTER TABLE TRABAJADORES_ESPECTACULOS ADD CONSTRAINT FK_TRAB_ESPEC FOREIGN KEY (DNI_TRABAJADOR) REFERENCES TRABAJADORES(DNI)
ALTER TABLE TRABAJADORES_ESPECTACULOS ADD CONSTRAINT FK_TRAB_ESPEC_2 FOREIGN KEY (ID_ESPECTACULO) REFERENCES ESPECTACULOS(ID)

--INTRODUCIMOS LOS CHECK EN LAS TABLAS

ALTER TABLE EMPRESAS ADD CONSTRAINT CK_CIF CHECK (CIF > 0)
ALTER TABLE ZONAS ADD CONSTRAINT CK_FILAS CHECK (NUMFILAS > 0)
ALTER TABLE ARTISTAS ADD CONSTRAINT CK_ARTISTA CHECK (TIPO_ARTISTAS <> 'TERRORISTA')
ALTER TABLE ARTISTAS ADD CONSTRAINT CK_TIPO_ARTISTA CHECK (TIPO_ARTISTAS IN ('CANTAOR','BAILARIN','GUITARRISTA', 'BATERIA'))
ALTER TABLE FUNCIONES ADD CONSTRAINT CK_FUNCIONES_ID CHECK (ID%2 = 0)

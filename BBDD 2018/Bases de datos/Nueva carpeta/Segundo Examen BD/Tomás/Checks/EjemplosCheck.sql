CREATE DATABASE EjemplosCheck
GO

USE EjemplosCheck
GO

/*
1.- DatosRestrictivos. Columnas:
	ID Es un SmallInt autonumérico que se rellenará con números impares.. No admite nulos. Clave primaria
	Nombre: Cadena de tamaño 15. No puede empezar por "N” ni por "X” Añade una restiricción UNIQUE. No admite nulos
	NumPelos: Int con valores comprendidos entre 0 y 145.000
	TipoRopa: Carácter con uno de los siguientes valores: "C”, "F”, "E”, "P”, "B”, ”N”
	NumSuerte: TinyInt. Tiene que ser un número divisible por 3.
	Minutos: TinyInt Con valores comprendidos entre 20 y 85 o entre 120 y 185.
*/

CREATE TABLE DatosRestrictivos(
	ID SmallInt NOT NULL IDENTITY (1,2)	--El primer número significa que empieza a asignar a partir del numero 1 y el segundo numero indica que incrementa el numero asignado en 2, por lo que solo asigna numeros impares.
		CONSTRAINT PK_DatosRestrictivos PRIMARY KEY,
	Nombre char(15) NOT NULL
		CONSTRAINT UQ_Nombre_DatosRestrictivos UNIQUE
		CONSTRAINT CK_Nombre_DatosRestrictivos CHECK (Nombre NOT LIKE'[NX]%'),
	NumPelos int NULL
		CONSTRAINT CK_NumPelos_DatosRestrictivos CHECK (NumPelos BETWEEN 0 AND 145000),
	TipoRopa char(1)  NULL
		CONSTRAINT CK_TipoRopa_DatosRestictivos CHECK (TipoRopa IN ('C', 'F', 'E', 'P', 'B', 'N')),	--IN sirve para solo poder escribir una de las opciones (en este caso todas esas letras)
	NumSuerte tinyint NULL
		CONSTRAINT CK_NumSuerte_DatosRestrictivos CHECK (NumSuerte%3 = 0),  --Como en Java, se pone un % para el resto de la división
	Minutos tinyint NULL
		CONSTRAINT CK_Minutos_DatosRestrictivos CHECK ((Minutos BETWEEN 20 AND 85) OR (Minutos BETWEEN 120 AND 185)),
)

/*
2.- DatosRelacionados. Columnas:
		NombreRelacionado: Cadena de tamaño 15. Define una FK para relacionarla con la columna "Nombre” de la tabla DatosRestrictivos.
		¿Deberíamos poner la misma restricción que en la columna correspondiente?
		¿Qué ocurriría si la ponemos?
		¿Y si no la ponemos?
		PalabraTabu: Cadena de longitud max 20. No admitirá los valores "Barcenas”, "Gurtel”, "Púnica”, "Bankia” ni "sobre”. Tampoco admitirá ninguna palabra terminada en "eo”
		NumRarito: TinyInt menor que 20. No admitirá números primos.
		NumMasgrande: SmallInt. Valores comprendidos entre NumRarito y 1000. Definirlo como clave primaria.
		¿Puede tener valores menores que 20?
*/

CREATE TABLE DatosRelacionados(
	NombreRelacionado char(15) NOT NULL
		CONSTRAINT FK_DatosRelacionados_DatosRestrictivos FOREIGN KEY REFERENCES DatosRestrictivos(Nombre),
	PalabraTabu varchar(20) NULL
		CONSTRAINT CK_PalabraTabu_DatosRelacionales CHECK (PalabraTabu NOT IN ('Barcenas', 'Gurtel', 'Púnica', 'Bankia', 'sobre') OR (PalabraTabu NOT LIKE'%eo')),
	NumRarito tinyint NULL
		CONSTRAINT CK_NumRarito_DatosRelacionales CHECK ((NumRarito<20) AND (NumRarito NOT IN (2, 3, 5, 7, 11, 13, 17, 19))),
	NumMasGrande smallint NOT NULL
		CONSTRAINT PK_NumMasGrande PRIMARY KEY,
		CONSTRAINT CK_NumMasGrande_DatosRelacionados CHECK (NumMasGrande BETWEEN NumRarito AND 1000),
)
--Consultar con un matemático
/*ALTER TABLE DatosRelacionados ADD
	CONSTRAINT CK_NumMasGrande_DatosRelacionados CHECK (NumMasGrande BETWEEN NumRarito AND 1000)*/

/*
3.- DatosAlMogollon. Columnas:
		ID. SmallInt. No admitirá múltiplos de 5. Definirlo como PK
		LimiteSuperior. SmallInt comprendido entre 1500 y 2000.
		OtroNumero. Será mayor que el ID y Menor que LimiteSuperior. Poner UNIQUE
		NumeroQueVinoDelMasAlla: SmallInt FK relacionada con NumMasGrande de la tabla DatosRelacionados
		Etiqueta. Cadena de 3 caracteres. No puede tener los valores "pao”, "peo”, "pio” ni "puo”
*/

CREATE TABLE DatosAlMogollon(
	ID smallint NOT NULL
		CONSTRAINT PK_DatosAlMogollon PRIMARY KEY
		CONSTRAINT CK_ID_DatosAlMogollon CHECK (ID%5!=0),
		--CONSTRAINT CK_ID_DatosAlMogollon CHECK (ID NOT LIKE ('%[05]')),     Like es para cadenas
	LimiteSuperior smallint NULL
		CONSTRAINT CK_LimitesSuperior_DatosAlMogollon CHECK (LimiteSuperior BETWEEN 1500 AND 2000),
	OtroNumero smallint NOT NULL
		CONSTRAINT UQ_OtroNumero_DatosAlMogollon UNIQUE,
		--CONSTRAINT CK_OtroNumero_DatosAlMogollon CHECK (OtroNumero>ID AND OtroNumero<LimiteSuperior),
	NumeroQueVinoDelEspacio smallint NOT NULL
		CONSTRAINT FK_DatosAlMogollon_DatosRelacionados FOREIGN KEY REFERENCES DatosRelacionados(NumMasGrande),
	Etiqueta char(3) NULL
		CONSTRAINT CK_Etiqueta_DatosAlMogollon CHECK (Etiqueta NOT IN ('pao', 'peo', 'pio', 'puo')),
		--CONSTRAINT CK_Etiqueta_DatosAlMogollon CHECK (Etiqueta NOT LIKE 'p[aeiu]o')
)

ALTER TABLE DatosAlMogollon ADD
	CONSTRAINT CK_OtroNumero_DatosAlMogollon CHECK (OtroNumero>ID AND OtroNumero<LimiteSuperior)
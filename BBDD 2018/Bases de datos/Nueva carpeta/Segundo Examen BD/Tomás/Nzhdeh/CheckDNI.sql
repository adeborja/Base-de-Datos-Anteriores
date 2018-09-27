--use master
--go
--drop database CheckDNI

create database CheckDNI
go
use CheckDNI
go

create table Persona
(
	DNI char (9) not null,
	Telefono char (9) null,
	Email varchar (30) null,

	-----------------------
	constraint PK_Persona primary key (DNI)
)
go

alter table Persona add constraint CK_DNI check (DNI like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][A-Z]')
go

alter table Persona add constraint CK_Telefono check (Telefono like '[1-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]')
go

alter table Persona add constraint CK_Email check (Email like '%@%.%')
go

insert into Persona values 
('22446678E','899999299','nzhdeh1991@gmail.com')
go

select * from Persona
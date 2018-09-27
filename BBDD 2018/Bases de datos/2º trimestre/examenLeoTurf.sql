use LeoTurf
go

--ejercicio 1

select C.ID, C.Nombre, DATEDIFF(MONTH,C.FechaNacimiento,CURRENT_TIMESTAMP)/12 as Edad, count(CC.IDCaballo) as [Carreras disputadas],
	MAX(A.Importe) as [Maximo apostado], AVG(A.Importe) as [Apuesta media]
	from LTCaballos as C
inner join LTApuestas as A on C.ID=A.IDCaballo
inner join LTCaballosCarreras as CC on C.ID=CC.IDCaballo
group by C.ID, C.Nombre, C.FechaNacimiento



--ejercicio 2


go
create view LTCampeonesCarreras as
select CC.IDCaballo, CC.IDCarrera, CC.Posicion, CC.Premio1 from LTCaballosCarreras as CC
	where posicion = 1
go
create view LTSubcampeonesCarreras as
select CC.IDCaballo, CC.IDCarrera, CC.Posicion, CC.Premio2 from LTCaballosCarreras as CC
	where posicion = 2
go

--total ganado por campeon
go
create view LTGananciasJugadoresPorCampeon as
select A.IDJugador, sum(A.Importe*Camp.Premio1) as [Total ganado] from LTApuestas as A
inner join LTCampeonesCarreras as Camp on A.IDCarrera=Camp.IDCarrera
where A.IDCaballo = (select IDCaballo from LTCampeonesCarreras where A.IDCarrera=LTCampeonesCarreras.IDCarrera)
group by A.IDJugador
go

--total ganado por subcampeon
go
create view LTGananciasJugadoresPorSubcampeon as
select A.IDJugador, sum(A.Importe*Subcamp.Premio2) as [Total ganado] from LTApuestas as A
inner join LTSubcampeonesCarreras as Subcamp on A.IDCarrera=Subcamp.IDCarrera
where A.IDCaballo = (select IDCaballo from LTSubcampeonesCarreras where A.IDCarrera=LTSubcampeonesCarreras.IDCarrera)
group by A.IDJugador
go

--total apostado por jugador
go
create view LTTotalApuestasPorJugador as
select A.IDJugador, sum(A.Importe) as [Total apostado] from LTApuestas as A
group by A.IDJugador
go


--solucion
select TAJ.IDJugador, J.Nombre, J.Apellidos, TAJ.[Total apostado], ISNULL(GJC.[Total ganado],0)+ISNULL(GJS.[Total ganado],0) as [Total ganado]
	,(ISNULL(GJC.[Total ganado],0)+ISNULL(GJS.[Total ganado],0))/TAJ.[Total apostado]*100 as [Rentabilidad]
	from LTTotalApuestasPorJugador as TAJ
full join LTGananciasJugadoresPorCampeon as GJC on TAJ.IDJugador=GJC.IDJugador
full join LTGananciasJugadoresPorSubcampeon as GJS on TAJ.IDJugador=GJS.IDJugador
inner join LTJugadores as J on TAJ.IDJugador=J.ID


--ejercicio 3

--tenemos en cuenta solo los que llegan en primer lugar

----media
--select IDCarrera, AVG(Importe)as Media from LTApuestas
--group by IDCarrera

----apuestas ganadoras
--select A.ID, A.IDCaballo, A.IDCarrera, A.Importe, A.IDJugador from LTApuestas as A
--inner join LTCaballosCarreras as CC on A.IDCarrera=CC.IDCarrera
--where A.IDCaballo=CC.IDCaballo and CC.Posicion=1 and CC.Premio1 >= 2

--solucion
select J.ID, J.Nombre, J.Apellidos, ApuestasGanadoras.ID, C.Hipodromo, C.Fecha, Cab.Nombre as [Nombre Caballo]
	, ApuestasGanadoras.Importe as [Importe apostado], ApuestasGanadoras.Importe*ApuestasGanadoras.Premio1 as [Importe ganado]--, MediaApuestas.Media/100*150
	from LTJugadores as J
inner join(
	select A.ID, A.IDCaballo, A.IDCarrera, A.Importe, A.IDJugador, CC.Premio1 from LTApuestas as A
	inner join LTCaballosCarreras as CC on A.IDCarrera=CC.IDCarrera
	where A.IDCaballo=CC.IDCaballo and CC.Posicion=1 and CC.Premio1 >= 2
) as ApuestasGanadoras on J.ID=ApuestasGanadoras.IDJugador
full join(
	select IDCarrera, AVG(Importe) as Media from LTApuestas
	group by IDCarrera
) as MediaApuestas on ApuestasGanadoras.IDCarrera=MediaApuestas.IDCarrera
inner join LTCarreras as C on ApuestasGanadoras.IDCarrera=C.ID
inner join LTCaballos as Cab on ApuestasGanadoras.IDCaballo=Cab.ID
where ApuestasGanadoras.Importe>=((MediaApuestas.Media/100)*150)


--ejercicio5a

--actualizar tabla LTCaballosCarreras
go
update LTCaballosCarreras
set Posicion = 1
where IDCarrera = 21 and IDCaballo = (select ID from LTCaballos where Nombre = 'Fiona')

update LTCaballosCarreras
set Posicion = 2
where IDCarrera = 21 and IDCaballo = (select ID from LTCaballos where Nombre = 'Vetonia')

update LTCaballosCarreras
set Posicion = 3
where IDCarrera = 21 and IDCaballo = (select ID from LTCaballos where Nombre = 'Witiza')

update LTCaballosCarreras
set Posicion = 4
where IDCarrera = 21 and IDCaballo = (select ID from LTCaballos where Nombre = 'Sigerico')

update LTCaballosCarreras
set Posicion = 5
where IDCarrera = 21 and IDCaballo = (select ID from LTCaballos where Nombre = 'Galatea')

update LTCaballosCarreras
set Posicion = 6
where IDCarrera = 21 and IDCaballo = (select ID from LTCaballos where Nombre = 'Desdemona')
go


--Actualizar Tabla LTApuntes

--select * from LTCaballosCarreras where IDCarrera=21 order by Posicion
--select * from LTApuestas where IDCarrera=21 and IDCaballo=11 order by IDCaballo
--select * from LTApuntes where IDJugador=28

begin transaction

rollback

commit

GO

create view LTSaldoOrdenActualJugador as
select A.IDJugador, A.Orden, A.Saldo from LTApuntes as A
inner join(
	select IDJugador, MAX(Orden) as Maximo from LTApuntes
	group by IDJugador
) as A2 on A.IDJugador=A2.IDJugador and A.Orden=A2.Maximo

GO

--solucion apuesta campeon, da error debido a que hay una apuesta duplicada para el jugador con id 28

--select A.ID, A.IDJugador, A.Importe*(select Premio1 from LTCaballosCarreras where IDCarrera=21 and Posicion=1)
--	as Ganancia from LTApuestas as A
--where A.IDCarrera=21 and A.IDCaballo = (select IDCaballo from LTCaballosCarreras where IDCarrera=21 and Posicion=1)

insert into LTApuntes
select Ganadores1.IDJugador, (SOAJ.Orden)+1, CURRENT_TIMESTAMP, Ganadores1.Ganancia, SOAJ.Saldo+Ganadores1.Ganancia,
	'Premio por apuesta '+CAST(Ganadores1.ID as varchar)
from(
	select A.ID, A.IDJugador, A.Importe*(select Premio1 from LTCaballosCarreras where IDCarrera=21 and Posicion=1)
	as Ganancia from LTApuestas as A
	where A.IDCarrera=21 and A.IDCaballo = (select IDCaballo from LTCaballosCarreras where IDCarrera=21 and Posicion=1)
) as Ganadores1
inner join LTSaldoOrdenActualJugador as SOAJ on Ganadores1.IDJugador=SOAJ.IDJugador


--solucion apuesta subcampeon, mismo problema que en el anterior, hay una apuesta duplicada

--select A.ID, A.IDJugador, A.Importe*(select Premio1 from LTCaballosCarreras where IDCarrera=21 and Posicion=2)
--	as Ganancia from LTApuestas as A
--where A.IDCarrera=21 and A.IDCaballo = (select IDCaballo from LTCaballosCarreras where IDCarrera=21 and Posicion=2)

insert into LTApuntes
select Ganadores2.IDJugador, (SOAJ.Orden)+1, CURRENT_TIMESTAMP, Ganadores2.Ganancia, SOAJ.Saldo+Ganadores2.Ganancia,
	'Premio por apuesta '+CAST(Ganadores2.ID as varchar)
from(
	select A.ID, A.IDJugador, A.Importe*(select Premio2 from LTCaballosCarreras where IDCarrera=21 and Posicion=2)
	as Ganancia from LTApuestas as A
	where A.IDCarrera=21 and A.IDCaballo = (select IDCaballo from LTCaballosCarreras where IDCarrera=21 and Posicion=2)
) as Ganadores2
inner join LTSaldoOrdenActualJugador as SOAJ on Ganadores2.IDJugador=SOAJ.IDJugador
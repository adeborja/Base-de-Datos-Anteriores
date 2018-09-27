use pubs
go

--1. Título y tipo de todos los libros en los que alguno de los autores vive en California (CA).
--select * from titles
--select * from titleauthor
--select * from authors

select T.title, T.[type] from titles as T
inner join titleauthor as TA on T.title_id=Ta.title_id
inner join authors as A on TA.au_id=A.au_id
where A.state = 'CA'


--2. Título y tipo de todos los libros en los que ninguno de los autores vive en California (CA).
select title, [type] from titles
except
select T.title, T.[type] from titles as T
inner join titleauthor as TA on T.title_id=Ta.title_id
inner join authors as A on TA.au_id=A.au_id
where A.state = 'CA'


--3. Número de libros en los que ha participado cada autor, incluidos los que no han publicado nada.

select A.au_id, count(T.title_id) as [Titulos publicados] from titleauthor as T
right join authors as A on T.au_id=A.au_id
group by A.au_id


--4. Número de libros que ha publicado cada editorial, incluidas las que no han publicado ninguno.

select P.pub_id, count(T.title_id) as [Titulos publicados] from titles as T
right join publishers as P on T.pub_id=P.pub_id
group by P.pub_id


--5. Número de empleados de cada editorial.

select P.pub_id, count(E.emp_id) as Empleados from employee as E
right join publishers as P on E.pub_id=P.pub_id
group by P.pub_id


--6. Calcular la relación entre número de ejemplares publicados y número de empleados de cada editorial, incluyendo el nombre de la misma.

select P.pub_name, 
	cast(cast(LibrosPublicados.[Titulos publicados] as decimal(4,2))/cast(NumeroEmpleados.Empleados as decimal(4,2)) as decimal(4,2))
as [Ratio Libros/Empleados] from publishers as P
inner join(
	select P.pub_id, count(T.title_id) as [Titulos publicados] from titles as T
	inner join publishers as P on T.pub_id=P.pub_id
	group by P.pub_id
) as LibrosPublicados on P.pub_id=LibrosPublicados.pub_id
inner join(
	select P.pub_id, count(E.emp_id) as Empleados from employee as E
	right join publishers as P on E.pub_id=P.pub_id
	group by P.pub_id
) as NumeroEmpleados on P.pub_id=NumeroEmpleados.pub_id

---------

select P.pub_name, 
	cast(cast(NumeroEmpleados.Empleados as decimal(4,2))/cast(LibrosPublicados.[Titulos publicados] as decimal(4,2)) as decimal(4,2))
as [Ratio Empleados/Libros] from publishers as P
inner join(
	select P.pub_id, count(T.title_id) as [Titulos publicados] from titles as T
	inner join publishers as P on T.pub_id=P.pub_id
	group by P.pub_id
) as LibrosPublicados on P.pub_id=LibrosPublicados.pub_id
inner join(
	select P.pub_id, count(E.emp_id) as Empleados from employee as E
	right join publishers as P on E.pub_id=P.pub_id
	group by P.pub_id
) as NumeroEmpleados on P.pub_id=NumeroEmpleados.pub_id


--7. Nombre, Apellidos y ciudad de todos los autores que han trabajado para la editorial "Binnet & Hardley” o "Five Lakes Publishing”

select A.au_fname, A.au_lname, A.city from authors as A
inner join titleauthor as TA on A.au_id=TA.au_id
inner join titles as T on TA.title_id=T.title_id
inner join publishers as P on T.pub_id=P.pub_id
where P.pub_name in ('Binnet & Hardley','Five Lakes Publishing')


--8. Empleados que hayan trabajado en alguna editorial que haya publicado algún libro en el que alguno de los autores
--fuera Marjorie Green o Michael O'Leary.
--select * from employee

--editoriales para las que han trabajado esos dos
select T.pub_id from titles as T
inner join titleauthor as TA on T.title_id=TA.title_id
inner join authors as A on TA.au_id=A.au_id
where A.au_id in (
	select au_id from authors
	where au_fname = 'Marjorie' and au_lname = 'Green'
		or au_fname = 'Michael' and au_lname = 'O''Leary'
)

--resuelto
select E.emp_id from employee as E
inner join publishers as P on E.pub_id=P.pub_id
where P.pub_id in(
	select T.pub_id from titles as T
	inner join titleauthor as TA on T.title_id=TA.title_id
	inner join authors as A on TA.au_id=A.au_id
	where A.au_id in (
		select au_id from authors
		where au_fname = 'Marjorie' and au_lname = 'Green'
			or au_fname = 'Michael' and au_lname = 'O''Leary'
	)
)


--9. Número de ejemplares vendidos de cada libro, especificando el título y el tipo.
select * from sales

select T.title, T.[type],
	case when SUM(S.qty) is null then 0 else SUM(S.qty) end as [Libros vendidos]
from sales as S
right join titles as T on S.title_id=T.title_id
group by T.title, T.[type]


--10. Número de ejemplares de todos sus libros que ha vendido cada autor.


--11. Número de empleados de cada categoría (jobs).


--12. Número de empleados de cada categoría (jobs) que tiene cada editorial, incluyendo aquellas categorías en las que no haya ningún empleado.


--13. Autores que han escrito libros de dos o más tipos diferentes


--14. Empleados que no trabajan actualmente en editoriales que han publicado libros cuya columna notes contenga la palabra "and”



use pubs
go

--1. Numero de libros que tratan de cada tema
--select * from titles

select [type] as Tema, count(title_id) as Cantidqad from titles group by [type]

--2. N�mero de autores diferentes en cada ciudad y estado
--select * from authors

select city, [state], count(au_id) as Cantidad from authors group by city, [state]

--3. Nombre, apellidos, nivel y antig�edad en la empresa de los empleados con un nivel entre 100 y 150.
--select * from employee

select fname, lname, job_lvl, year(CURRENT_TIMESTAMP)-year(hire_date) as Antig�edad from employee
	where job_lvl between 100 and 150

--4. N�mero de editoriales en cada pa�s. Incluye el pa�s.
--select * from publishers

select country, count(pub_id) as Cantidad from publishers group by country

--5. N�mero de unidades vendidas de cada libro en cada a�o (title_id, unidades y a�o).
--select * from sales

select title_id, count(title_id) as Cantidad, year(ord_date) as Anio from sales group by title_id, year(ord_date)

--6. N�mero de autores que han escrito cada libro (title_id y numero de autores).
--select * from titleauthor

select title_id, count(au_id) as Autores from titleauthor group by title_id

--7. ID, Titulo, tipo y precio de los libros cuyo adelanto inicial (advance) tenga un valor superior a $7.000, ordenado por tipo y t�tulo
--select * from titles

select title_id, title, [type], price from titles where advance>7000 order by [type], title
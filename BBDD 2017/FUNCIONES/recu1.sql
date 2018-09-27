USE pubs
GO

--4.- Crea un procedimiento que incremente el nivel de los trabajadores según la siguiente regla:

--Los que trabajen en editoriales que tengan más de 5 autores diferentes y tengan más de 10 años de antigüedad, subirán 5 puntos.
--Los que sólo cumplan la primera condición, subirán 3 puntos.
--Comprueba que no se exceda el nivel máximo asignado a su puesto.

--3 PUNTOS POR EDITORIAL, 2 PUNTOS POR ANTIGÜEDAD, NO SOBREPASAR EL MAXIMO, modificar a 25 años de antigüedad para que todas las modificaciones no sean iguales

select * from employee
select * from jobs --nivel maximo

select * from publishers --id editorial
select * from titles
select * from titleauthor --id autor

--contar autores por editorial
select P.pub_id from titleauthor AS A
INNER JOIN titles AS T ON T.title_id=A.title_id
INNER JOIN publishers AS P ON P.pub_id=T.pub_id
GROUP BY P.pub_id
HAVING COUNT(A.au_id)>5

GO
/**
interfaz de pr_actualizarNivelEmpleados
precondiciones: nada
entrada: nada
salida: nada
postcondiciones: pinta en pantalla el resultado de la operacion
*/
CREATE PROCEDURE pr_actualizarNivelEmpleados
AS
BEGIN
	--crear la tabla temporal
	IF EXISTS (select * from ##employee)
	BEGIN
		DROP TABLE ##employee
	END

	SELECT * INTO ##employee FROM employee
	--fin crear

	UPDATE ##employee
	SET job_lvl = job_lvl+3
	WHERE pub_id IN (select P.pub_id from titleauthor AS A
					INNER JOIN titles AS T ON T.title_id=A.title_id
					INNER JOIN publishers AS P ON P.pub_id=T.pub_id
					GROUP BY P.pub_id
					HAVING COUNT(A.au_id)>5)
	AND job_lvl<(SELECT max_lvl FROM jobs WHERE job_id = ##employee.job_id)

	UPDATE ##employee
	SET job_lvl = job_lvl+2
	WHERE pub_id IN (select P.pub_id from titleauthor AS A
					INNER JOIN titles AS T ON T.title_id=A.title_id
					INNER JOIN publishers AS P ON P.pub_id=T.pub_id
					GROUP BY P.pub_id
					HAVING COUNT(A.au_id)>5)
	AND (DATEDIFF(MONTH, hire_date, CURRENT_TIMESTAMP))>300 --25 años, para que sean 10 años cambiar a 120
	AND job_lvl<(SELECT max_lvl FROM jobs WHERE job_id = ##employee.job_id)

	UPDATE ##employee
	SET job_lvl = (SELECT max_lvl FROM jobs WHERE job_id = ##employee.job_id)
	WHERE job_lvl>(SELECT max_lvl FROM jobs WHERE job_id = ##employee.job_id)

END
GO

SELECT E.emp_id, E.job_id, E.job_lvl, J.max_lvl, E.pub_id, DATEDIFF(MONTH, E.hire_date, CURRENT_TIMESTAMP) AS antiguedad, (J.max_lvl-E.job_lvl) AS DIF FROM ##EMPLOYEE as E
INNER JOIN jobs AS J ON J.job_id=E.job_id
order by E.pub_id

EXECUTE pr_actualizarNivelEmpleados



--5.- Crea una columna “UnidadesVendidas” en la tabla Titles. Asígnale el valor que le corresponda. Crea los triggers
--necesarios en la tabla Sales para mantenerla actualizada

select * from titles
select * from sales

--Crear y actualizar ventas
ALTER TABLE titles
ADD UnidadesVendidas int;


update titles
set UnidadesVendidas =0

update titles
set UnidadesVendidas = (SELECT SUM(qty) FROM sales WHERE title_id=titles.title_id)
WHERE title_id = titles.title_id


--fin crear y actualizar

GO
ALTER TRIGGER tr_actualizarVenta ON sales
AFTER INSERT AS
BEGIN
	UPDATE titles
	SET UnidadesVendidas = UnidadesVendidas+(select SUM(qty) from inserted where title_id = titles.title_id)
	WHERE title_id IN (SELECT title_id FROM inserted GROUP BY title_id)
END
GO

select * from titles --BU1032 -15, BU1111 -25

INSERT INTO sales
(stor_id, ord_num, ord_date, qty, payterms, title_id)
VALUES
('6380', 'XA22', CURRENT_TIMESTAMP, 6, 'by the face', 'BU1032')
,('6380', 'XA23', CURRENT_TIMESTAMP, 6, 'by the face', 'BU1111')

--DELETE FROM sales WHERE ord_num = 'XA22' OR ord_num = 'XA23'



--6.- Crea una función a la que pasemos como parámetro una editorial y un rango de fechas y nos devuelva el total vendido
--por esa editorial en ese periodo.
SELECT * FROM publishers --pub_id, pub_name
SELECT * FROM titles --pub_id, title_id
SELECT * FROM sales --title_id, ord_date

SELECT SUM(S.qty) FROM publishers as P
INNER JOIN titles AS T ON T.pub_id=P.pub_id
INNER JOIN sales AS S ON S.title_id=T.title_id
WHERE ord_date BETWEEN DATETIMEFROMPARTS(2005,1,1,0,0,0,0) AND DATETIMEFROMPARTS(2018,1,1,0,0,0,0)
AND P.pub_id = '1389'

GO
/**
interfaz de fn_ventasEditorialEnIntervalo
cabecera: fn_ventasEditorialEnIntervalo (@id char(4), @inicio datetime, @fin datetime)
precondiciones: nada
entrada: una cadena y dos fechas
salida: una tabla
postcondiciones: devuelve el nombre de las editoriales que han vendido algun libro en el intervalo de tiempo introducido
*/
CREATE FUNCTION fn_ventasEditorialEnIntervalo (@id char(4), @inicio datetime, @fin datetime)
RETURNS int AS
BEGIN
	DECLARE @resultado int

	SELECT @resultado=SUM(S.qty) FROM publishers as P
	INNER JOIN titles AS T ON T.pub_id=P.pub_id
	INNER JOIN sales AS S ON S.title_id=T.title_id
	WHERE ord_date BETWEEN @inicio AND @fin
	AND P.pub_id = @id

	RETURN @resultado
END
GO

DECLARE @INI datetime
DECLARE @FI DATETIME
SET @INI=DATETIMEFROMPARTS(2015,1,1,0,0,0,0)
SET @FI=DATETIMEFROMPARTS(2018,1,1,0,0,0,0)

SELECT dbo.fn_ventasEditorialEnIntervalo('1389', @INI, @FI) AS Ventas




--7.- Crea una función a la que pasemos como parámetro un año y nos devuelva una tabla en la que conste el id, nombre y
--apellidos de cada autor y el total ganado en ese año. Para calcular las ganancias es necesario tener en cuenta las ventas
--de los libros de ese autor, el royalty asignado a cada libro (es el porcentaje que reciben los autores de las ventas y
--depende del libro y del número de ejemplares vendido según la tabla roysched) y el porcentaje de ese royalty que percibe
--cada uno de los autores en caso de que haya más de uno. Este dato se obtiene de la columna royaltyper de la tabla titleauthor

select * from sales
select * from titles
select * from roysched
--select title_id, sum(qty) as cantidad from sales group by title_id
select * from titleauthor order by title_id
SELECT * FROM authors

--VENTAS DE CADA LIBRO
select S.title_id, SUM(S.qty) as cantidad from sales as S
INNER JOIN titles as T on T.title_id=S.title_id
GROUP BY S.title_id

--ROYALTY POR LIBRO
SELECT TC.title_id, TC.cantidad, R.royalty FROM roysched AS R
INNER JOIN (
	select S.title_id, SUM(S.qty) as cantidad from sales as S
	INNER JOIN titles as T on T.title_id=S.title_id
	GROUP BY S.title_id
) AS TC ON TC.title_id=R.title_id
WHERE TC.cantidad BETWEEN R.lorange AND R.hirange

--GANANCIA AUTOR
SELECT A.au_id, A.au_fname, A.au_lname, (TR.cantidad*TR.price*TR.royalty*TA.royaltyper)/10000 AS Ganancias FROM authors AS A
INNER JOIN titleauthor AS TA ON TA.au_id=A.au_id
INNER JOIN (
	SELECT TC.title_id, TC.cantidad, R.royalty, TC.price FROM roysched AS R
	INNER JOIN (
		select S.title_id, SUM(S.qty) as cantidad, T.price from sales as S
		INNER JOIN titles as T on T.title_id=S.title_id
		GROUP BY S.title_id, T.price
	) AS TC ON TC.title_id=R.title_id
	WHERE TC.cantidad BETWEEN R.lorange AND R.hirange
) AS TR ON TR.title_id=TA.title_id

--GananciasTotales
select s.title_id, sum(s.qty) as cantidad, t.price, (sum(s.qty)*t.price) as GananciaTotal, (sum(s.qty)*t.price)/10 as GananciaAutor
from sales as s
inner join titles as t on t.title_id=s.title_id
group by s.title_id, t.price

--totalGananciasAutores
SELECT SUM(X.GananciaAutor) FROM(
	select s.title_id, sum(s.qty) as cantidad, t.price, (sum(s.qty)*t.price) as GananciaTotal, (sum(s.qty)*t.price)/10 as GananciaAutor
	from sales as s
	inner join titles as t on t.title_id=s.title_id
	group by s.title_id, t.price
) AS X

--totalGananciasAutoresDesglosados
SELECT SUM(X.Ganancias) FROM(
	SELECT A.au_fname, A.au_lname, (TR.cantidad*TR.price*TR.royalty*TA.royaltyper)/10000 AS Ganancias FROM authors AS A
	INNER JOIN titleauthor AS TA ON TA.au_id=A.au_id
	INNER JOIN (
		SELECT TC.title_id, TC.cantidad, R.royalty, TC.price FROM roysched AS R
		INNER JOIN (
			select S.title_id, SUM(S.qty) as cantidad, T.price from sales as S
			INNER JOIN titles as T on T.title_id=S.title_id
			GROUP BY S.title_id, T.price
		) AS TC ON TC.title_id=R.title_id
		WHERE TC.cantidad BETWEEN R.lorange AND R.hirange
	) AS TR ON TR.title_id=TA.title_id
) AS X

--todo correcto

GO
/**
interfaz de fn_gananciasAutorEnAnio
cabecera: fn_gananciasAutorEnAnio (@anio int)
precondiciones: nada
entrada: un entero
salida: una tabla
postcondiciones: devuelve una tabla con el id, nombre, apellido y total ganado de todos los autores que han vendido algun libro en el año introducido
*/
CREATE FUNCTION fn_gananciasAutorEnAnio (@anio int)
RETURNS TABLE AS
RETURN(
	SELECT A.au_id, A.au_fname, A.au_lname, (TR.cantidad*TR.price*TR.royalty*TA.royaltyper)/10000 AS Ganancias FROM authors AS A
	INNER JOIN titleauthor AS TA ON TA.au_id=A.au_id
	INNER JOIN (
		SELECT TC.title_id, TC.cantidad, R.royalty, TC.price, TC.ord_date FROM roysched AS R
		INNER JOIN (
			select S.title_id, SUM(S.qty) as cantidad, T.price, S.ord_date from sales as S
			INNER JOIN titles as T on T.title_id=S.title_id
			GROUP BY S.title_id, T.price, S.ord_date
		) AS TC ON TC.title_id=R.title_id
		WHERE TC.cantidad BETWEEN R.lorange AND R.hirange
	) AS TR ON TR.title_id=TA.title_id
	WHERE TR.ord_date BETWEEN SMALLDATETIMEFROMPARTS(@anio,1,1,0,0) AND SMALLDATETIMEFROMPARTS(@anio,12,31,23,59)
)
GO

SELECT * from dbo.fn_gananciasAutorEnAnio (1994)

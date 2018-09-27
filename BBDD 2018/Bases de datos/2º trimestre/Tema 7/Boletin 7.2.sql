use pubs
go


    --1. T�tulo, precio y notas de los libros (titles) que tratan de cocina, ordenados de mayor a menor precio.
	--select * from titles

	select title,price,notes from titles order by price desc

    --2. ID, descripci�n y nivel m�ximo y m�nimo de los puestos de trabajo (jobs) que pueden tener un nivel 110.
	--select * from jobs

	select job_id, job_desc, min_lvl, max_lvl from jobs where min_lvl<=110 and max_lvl>=110

    --3. T�tulo, ID y tema de los libros que contengan la palabra "and� en las notas
	--select * from titles

	select title, title_id, [type] from titles where notes like '%and%'

    --4. Nombre y ciudad de las editoriales (publishers) de los Estados Unidos que no est�n en California ni en Texas
	--select * from publishers

	select pub_name, city from publishers where country = 'USA' and state not in('CA','TX')

    --5. T�tulo, precio, ID de los libros que traten sobre psicolog�a o negocios y cuesten entre diez y 20 d�lares.
	--select * from titles

	select title, price, title_id from titles where [type] in ('psychology','business') and price>=10 and price<=20

    --6. Nombre completo (nombre y apellido) y direcci�n completa de todos los autores que no viven en California ni en Oreg�n.
	--select * from authors

	select au_fname, au_lname, [address], city, [state], zip from authors where [state] not in ('CA','OR')

    --7. Nombre completo y direcci�n completa de todos los autores cuyo apellido empieza por D, G o S.
	
	select au_fname, au_lname, [address], city, [state], zip from authors where au_lname like '[DGS]%'

    --8. ID, nivel y nombre completo de todos los empleados con un nivel inferior a 100, ordenado alfab�ticamente
	select * from 

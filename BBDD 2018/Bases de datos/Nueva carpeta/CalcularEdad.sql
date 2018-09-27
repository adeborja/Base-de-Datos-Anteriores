-- ¿Como calcular una edad?

-- ¿Es buena idea tener una columna "edad"?
-- No

--Primera aproximación
Set Dateformat 'YMD'
-- Año actual - Año de nacimiento
Print Year(Current_Timestamp)-Year ('2001-12-13')

--Segunda aproximación

Print Year(Current_Timestamp -'2001-10-13')-1900

-- Si la fecha no es SmallDateTime
Print Year(Current_Timestamp -CAST('2001-10-13' AS SmallDateTime))-1900

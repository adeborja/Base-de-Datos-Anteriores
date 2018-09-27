use LeoTurf
go

select OBJECT_ID('[LeoTurf].[dbo].[LTApuestas]') as Prueba

go

if (select OBJECT_ID('[LeoTurf].[dbo].[LTApuntes]')) is not null
begin
	print 'existe'
end
else begin
	print 'no existe'
end
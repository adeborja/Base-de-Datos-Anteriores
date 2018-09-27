use LeoTurf
go

--drop procedure numeritorandom

create procedure numeroPorDefecto (@numero int = 0)
as
begin

	print @numero

end

go


exec numeroPorDefecto 3

/*
Medio:
Se usan inserted y deleted. Si es complicado procesar varias filas, supón
que se modifica sólo una.
3.- Cada vez que se inserte una fila queremos que se muestre un mensaje indicando
“Insertada la palabra ________”
*/

go
alter trigger PalabrasInsertadas on Palabrotas
	after insert as 
			declare @palabraFilas varchar(30) --variable donde almacenamos las palabras de inserted
			declare palabrasInsertadas cursor for select Palabra from inserted   -- declaramos el cursor
			open palabrasInsertadas  
			--lectura anticipada
			fetch next from palabrasInsertadas into @palabraFilas  --posiciona el cursor en la primera fila , la primera vez   
			while @@FETCH_STATUS=0  -- mientras queden filas 
				begin
					print 'Insertada la palabra :) ' +@palabraFilas
					--lectura final
					fetch next from palabrasInsertadas into @palabraFilas  -- se pone el la fila siguiente
				end
			close palabrasInsertadas  
			dealLocate palabrasInsertadas  --deja de existir el cursor


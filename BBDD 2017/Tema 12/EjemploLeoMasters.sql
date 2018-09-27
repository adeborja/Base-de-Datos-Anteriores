/*
Ejemplo de como ampliar un trigger SUPER CHECK de una sola fila a varias
Al añadir un bucle hay que asegurarse de recorrer inserted y de añadir un 
indicador para salir del bucle cuando una fila incumpla la condición
*/
--Leo Master REQUISITO 6
--Comprobar que en un partido ambos contrincantes son de la misma modalidad

-- Versión una fila
CREATE TRIGGER MismaModalidad ON LM_Partidos AFTER INSERT AS
BEGIN
	DECLARE @Contrincante1 CHAR (6), @Contrincante2 Char(6), @Edicion SmallInt
	DECLARE @Modalidad1 CHAR(2), @Modalidad2 CHAR(2)
	SELECT @Contrincante1 = Contrincante1, @Contrincante2 = Contrincante2, @Edicion = edicion
		FROM inserted
	SELECT @Modalidad1 = Modalidad FROM LM_Contrincantes 
		WHERE ID=@Contrincante1 AND Edicion = @Edicion
	SELECT @Modalidad2 = Modalidad FROM LM_Contrincantes 
		WHERE ID=@Contrincante2 AND Edicion = @Edicion
	IF @Modalidad1 <> @Modalidad2
		BEGIN
		Raiserror ('Los contrincantes deben ser de la misma modalidad',6,1)
		ROLLBACK
		END
END --TRIGGER MismaModalidad
GO




-- Versión todas las filas
CREATE TRIGGER MismaModalidad ON LM_Partidos AFTER INSERT AS
BEGIN
	--Comprobamos todas las filas de una vez
	IF EXISTS (SELECT * FROM inserted AS I
		Join LM_Contrincantes AS C1 ON I.Contrincante1 = C1.ID AND I.Edicion = C1.Edicion
		Join LM_Contrincantes AS C2 ON I.Contrincante2 = C2.ID AND I.Edicion = C2.Edicion
		Where C1.Modalidad <> C2.Modalidad) -- La condición del If pasa al WHERE
		BEGIN
		Raiserror ('Los contrincantes deben ser de la misma modalidad',6,1)
		ROLLBACK
		END --If
END --TRIGGER MismaModalidad
GO





-- Versión todas las filas arrastrandonos penosamente a recorrer la tabla inserted
CREATE TRIGGER MismaModalidad ON LM_Partidos AFTER INSERT AS
BEGIN
	DECLARE @Contrincante1 CHAR (6), @Contrincante2 Char(6), @Edicion SmallInt
	DECLARE @Modalidad1 CHAR(2), @Modalidad2 CHAR(2)
	--Necesitamos un bucle
	DECLARE @Numero SmallInt = -1, @Cont SmallInt = 1, @NumFilas SmallInt, @Seguimos Bit = 1
	SELECT @NumFilas = Count (*) FROM Inserted
	While @Cont <= @NumFilas AND @Seguimos = 1 -- Añadimos el indicador
	Begin
		-- Tomamos los datos de cada fila
		SELECT TOP 1 @numero= numero, @Contrincante1 = Contrincante1, @Contrincante2 = Contrincante2, @Edicion = edicion
			FROM inserted 
			Where Numero > @numero
			Order By numero
		SELECT @Modalidad1 = Modalidad FROM LM_Contrincantes 
			WHERE ID=@Contrincante1 AND Edicion = @Edicion
		SELECT @Modalidad2 = Modalidad FROM LM_Contrincantes 
			WHERE ID=@Contrincante2 AND Edicion = @Edicion
		-- Hacemos la comprobación
		IF @Modalidad1 <> @Modalidad2
			BEGIN
			Set @Seguimos = 0
			Raiserror ('Los contrincantes deben ser de la misma modalidad',6,1)
			ROLLBACK
			END
		-- Actualizamos la condición del bucle 
		SET @cont += 1
	End -- While
END --TRIGGER MismaModalidad
GO







-- Versión todas las filas arrastrandonos penosamente a recorrer la tabla inserted con un cursor
CREATE TRIGGER MismaModalidad ON LM_Partidos AFTER INSERT AS
BEGIN
	DECLARE @Contrincante1 CHAR (6), @Contrincante2 Char(6), @Edicion SmallInt
	DECLARE @Modalidad1 CHAR(2), @Modalidad2 CHAR(2)
	--Esto es lo que varía
	DECLARE @Numero SmallInt = -1, @Seguimos Bit = 1
	-- Así se declara el cursor. Tomamos solo las columnas que vayamos a necesitar
	DECLARE RecorreInserted CURSOR FOR SELECT Contrincante1, Contrincante2, Edicion FROM Inserted
	Open RecorreInserted
	FETCH NEXT FROM RecorreInserted INTO @Contrincante1, @Contrincante2, @Edicion
	While @@FETCH_STATUS = 0 AND @Seguimos = 1
	Begin
		SELECT @Modalidad1 = Modalidad FROM LM_Contrincantes 
			WHERE ID=@Contrincante1 AND Edicion = @Edicion
		SELECT @Modalidad2 = Modalidad FROM LM_Contrincantes 
			WHERE ID=@Contrincante2 AND Edicion = @Edicion
		IF @Modalidad1 <> @Modalidad2
			BEGIN
			Set @Seguimos = 0
			Raiserror ('Los contrincantes deben ser de la misma modalidad',6,1)
			ROLLBACK
			END
		FETCH NEXT FROM RecorreInserted INTO @Contrincante1, @Contrincante2, @Edicion
	End -- While
	Close RecorreInserted
	Deallocate RecorreInserted
END --TRIGGER MismaModalidad

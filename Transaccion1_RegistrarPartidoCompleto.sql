USE FutPredictDB;
GO
SET XACT_ABORT ON;
GO

-- Partido nuevo, todavía "Programado" (Manchester City vs Liverpool)
IF NOT EXISTS (SELECT 1 FROM Partido WHERE partido_id = 7)
BEGIN
    INSERT INTO Partido (partido_id, fecha, equipo_local_id, equipo_visitante_id, goles_local, goles_visitante, liga_id, temporada_id, estado)
    VALUES (7, '2027-01-20', 3, 4, 0, 0, 2, 2, 'Programado');
END
GO

-- Transacción: registrar un gol y pasar el partido a "En juego"
BEGIN TRANSACTION RegistrarEventoPartido;

BEGIN TRY
    IF NOT EXISTS (
        SELECT 1
        FROM Partido p
        JOIN JugadorEquipo je
            ON je.jugador_id = 5
           AND je.temporada_id = p.temporada_id
           AND je.equipo_id = 3
        WHERE p.partido_id = 7 AND 3 IN (p.equipo_local_id, p.equipo_visitante_id)
    )
    BEGIN
        RAISERROR('El jugador no pertenece al equipo indicado en este partido.', 16, 1);
    END

    INSERT INTO EventoPartido (evento_id, partido_id, equipo_id, jugador_id, tipo_evento, minuto, descripcion)
    VALUES (2, 7, 3, 5, 'Gol', 15, 'Gol de jugada tras contragolpe');

    UPDATE Partido
    SET estado = 'En juego'
    WHERE partido_id = 7;

    COMMIT TRANSACTION RegistrarEventoPartido;
    PRINT 'Evento y estado del partido actualizados correctamente.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION RegistrarEventoPartido;
    PRINT 'Error, se revirtieron los cambios: ' + ERROR_MESSAGE();
END CATCH
GO

-- Verificación
SELECT * FROM Partido WHERE partido_id = 7;
SELECT * FROM EventoPartido WHERE partido_id = 7;
GO


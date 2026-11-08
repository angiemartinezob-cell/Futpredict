--transaccion2 
USE FutPredictDB;
GO

SET XACT_ABORT ON;
GO

BEGIN TRY
    BEGIN TRANSACTION RegistrarEventoPartido;

    -- Verificar que el partido exista
    IF NOT EXISTS (
        SELECT 1
        FROM Partido
        WHERE partido_id = 7
    )
    BEGIN
        RAISERROR('El partido no existe.', 16, 1);
    END;

    -- Verificar que Liverpool participe en el partido
    IF NOT EXISTS (
        SELECT 1
        FROM Partido
        WHERE partido_id = 7
          AND 4 IN (equipo_local_id, equipo_visitante_id)
    )
    BEGIN
        RAISERROR('El equipo no participa en este partido.', 16, 1);
    END;

    -- Verificar que el jugador pertenezca a Liverpool
    IF NOT EXISTS (
        SELECT 1
        FROM JugadorEquipo je
        INNER JOIN Partido p
            ON p.temporada_id = je.temporada_id
        WHERE p.partido_id = 7
          AND je.jugador_id = 7
          AND je.equipo_id = 4
    )
    BEGIN
        RAISERROR('El jugador no pertenece al equipo indicado.', 16, 1);
    END;

    -- Registrar el gol
    INSERT INTO EventoPartido (
        evento_id,
        partido_id,
        equipo_id,
        jugador_id,
        tipo_evento,
        minuto,
        descripcion
    )
    VALUES (
        101,
        7,
        4,
        7,
        'Gol',
        32,
        'Gol de Liverpool'
    );

    -- Actualizar marcador
    UPDATE Partido
    SET goles_visitante = goles_visitante + 1,
        estado = 'En juego'
    WHERE partido_id = 7;

    COMMIT TRANSACTION RegistrarEventoPartido;

    PRINT 'Evento y marcador actualizados correctamente.';
END TRY

BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION RegistrarEventoPartido;

    PRINT 'Ocurrió un error, se revirtieron los cambios: ' + ERROR_MESSAGE();
END CATCH;
GO

SELECT *
FROM Partido
WHERE partido_id = 7;

SELECT *
FROM EventoPartido
WHERE partido_id = 7;
GO





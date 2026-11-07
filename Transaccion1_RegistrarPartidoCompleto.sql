--Transaccion1_RegistrarPartidoCompleto

USE FutPredictDB;
GO

SET XACT_ABORT ON;
GO

BEGIN TRY
    BEGIN TRANSACTION RegistrarPartidoCompleto;

    -- 1. Verificar que el partido no exista
    IF EXISTS (
        SELECT 1
        FROM Partido
        WHERE partido_id = 7
    )
    BEGIN
        RAISERROR('El partido 7 ya se encuentra registrado.', 16, 1);
    END;

    -- 2. Registrar el nuevo partido
    INSERT INTO Partido (
        partido_id,
        fecha,
        equipo_local_id,
        equipo_visitante_id,
        goles_local,
        goles_visitante,
        liga_id,
        temporada_id,
        estado
    )
    VALUES (
        7,
        '2027-01-20',
        3, -- Manchester City
        4, -- Liverpool
        0,
        0,
        2, -- Premier League
        2,
        'Programado'
    );

    -- 3. Verificar que el jugador pertenezca a uno de los equipos del partido
    IF NOT EXISTS (
        SELECT 1
        FROM Partido p
        INNER JOIN JugadorEquipo je
            ON je.jugador_id = 5
            AND je.temporada_id = p.temporada_id
            AND je.equipo_id IN (
                p.equipo_local_id,
                p.equipo_visitante_id
            )
        WHERE p.partido_id = 7
    )
    BEGIN
        RAISERROR(
            'El jugador no pertenece a ninguno de los equipos del partido.',
            16,
            1
        );
    END;

    -- 4. Registrar un evento del partido
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
        100,
        7,
        3,
        5,
        'Gol',
        15,
        'Gol de jugada tras contragolpe'
    );

    -- 5. Actualizar el estado y marcador
    UPDATE Partido
    SET goles_local = 1,
        estado = 'En juego'
    WHERE partido_id = 7;

    COMMIT TRANSACTION RegistrarPartidoCompleto;

    PRINT 'Partido y evento registrados correctamente.';
END TRY

BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION RegistrarPartidoCompleto;

    PRINT 'Error: se revirtieron todos los cambios.';
    PRINT ERROR_MESSAGE();
END CATCH;
GO


-- Verificación
SELECT *
FROM Partido
WHERE partido_id = 7;

SELECT *
FROM EventoPartido
WHERE partido_id = 7;
GO




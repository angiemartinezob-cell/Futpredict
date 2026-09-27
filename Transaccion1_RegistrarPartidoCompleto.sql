USE FutPredictDB;
GO

BEGIN TRANSACTION RegistrarPartidoCompleto;

BEGIN TRY
    -- 1. Actualizar el resultado del partido
    UPDATE Partido
    SET goles_local = 2,
        goles_visitante = 2,
        estado = 'Finalizado'
    WHERE partido_id = 3;

    -- 2. Insertar estadística del jugador 9 en ese partido
    INSERT INTO EstadisticaJugador (
        estadistica_id, partido_id, jugador_id, minutos_jugados, goles, asistencias,
        tiros, pases_completados, recuperaciones, tiros_arco, faltas_cometidas,
        tarjetas_amarillas, tarjetas_rojas, calificacion
    )
    VALUES (22, 3, 9, 90, 1, 0, 3, 30, 4, 2, 1, 0, 0, 7.80);

    -- 3. Insertar estadística del jugador 10 en ese partido
    INSERT INTO EstadisticaJugador (
        estadistica_id, partido_id, jugador_id, minutos_jugados, goles, asistencias,
        tiros, pases_completados, recuperaciones, tiros_arco, faltas_cometidas,
        tarjetas_amarillas, tarjetas_rojas, calificacion
    )
    VALUES (23, 3, 10, 90, 0, 1, 1, 28, 6, 0, 2, 0, 0, 7.20);

    COMMIT TRANSACTION RegistrarPartidoCompleto;
    PRINT 'Partido y estadísticas registrados correctamente (transacción completa).';
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION RegistrarPartidoCompleto;
    PRINT 'Ocurrió un error, se revirtieron todos los cambios: ' + ERROR_MESSAGE();
END CATCH
GO

SELECT * FROM Partido WHERE partido_id = 3;

BEGIN TRANSACTION RegistrarPartidoCompleto;

BEGIN TRY
    UPDATE Partido
    SET goles_local = 2, goles_visitante = 2, estado = 'Finalizado'
    WHERE partido_id = 3;

    INSERT INTO EstadisticaJugador (
        estadistica_id, partido_id, jugador_id, minutos_jugados, goles, asistencias,
        tiros, pases_completados, recuperaciones, tiros_arco, faltas_cometidas,
        tarjetas_amarillas, tarjetas_rojas, calificacion
    )
    VALUES (22, 3, 13, 90, 1, 0, 3, 30, 4, 2, 1, 0, 0, 7.80);

    INSERT INTO EstadisticaJugador (
        estadistica_id, partido_id, jugador_id, minutos_jugados, goles, asistencias,
        tiros, pases_completados, recuperaciones, tiros_arco, faltas_cometidas,
        tarjetas_amarillas, tarjetas_rojas, calificacion
    )
    VALUES (23, 3, 14, 90, 0, 1, 1, 28, 6, 0, 2, 0, 0, 7.20);

    COMMIT TRANSACTION RegistrarPartidoCompleto;
    PRINT 'Partido y estadísticas registrados correctamente (transacción completa).';
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION RegistrarPartidoCompleto;
    PRINT 'Ocurrió un error, se revirtieron todos los cambios: ' + ERROR_MESSAGE();
END CATCH
GO

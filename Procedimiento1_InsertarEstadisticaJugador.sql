USE FutPredictDB;
GO

CREATE OR ALTER PROCEDURE sp_InsertarEstadisticaJugador
    @estadistica_id INT,
    @partido_id INT,
    @jugador_id INT,
    @minutos_jugados INT,
    @goles INT,
    @asistencias INT,
    @tiros INT,
    @pases_completados INT,
    @recuperaciones INT,
    @tiros_arco INT,
    @faltas_cometidas INT,
    @tarjetas_amarillas INT,
    @tarjetas_rojas INT,
    @calificacion DECIMAL(4,2) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1 FROM EstadisticaJugador
        WHERE partido_id = @partido_id AND jugador_id = @jugador_id
    )
    BEGIN
        RAISERROR('Ya existe un registro de estadísticas para este jugador en este partido.', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (
        SELECT 1
        FROM Partido p
        JOIN JugadorEquipo je
            ON je.jugador_id = @jugador_id
           AND je.temporada_id = p.temporada_id
           AND je.equipo_id IN (p.equipo_local_id, p.equipo_visitante_id)
        WHERE p.partido_id = @partido_id
    )
    BEGIN
        RAISERROR('El jugador no pertenece a ninguno de los equipos que disputan este partido.', 16, 1);
        RETURN;
    END

    INSERT INTO EstadisticaJugador (
        estadistica_id, partido_id, jugador_id, minutos_jugados, goles, asistencias,
        tiros, pases_completados, recuperaciones, tiros_arco, faltas_cometidas,
        tarjetas_amarillas, tarjetas_rojas, calificacion
    )
    VALUES (
        @estadistica_id, @partido_id, @jugador_id, @minutos_jugados, @goles, @asistencias,
        @tiros, @pases_completados, @recuperaciones, @tiros_arco, @faltas_cometidas,
        @tarjetas_amarillas, @tarjetas_rojas, @calificacion
    );

    PRINT 'Estadística registrada correctamente.';
END
GO

-- Prueba válida: el jugador 2 es del Barcelona y juega el partido 6
EXEC sp_InsertarEstadisticaJugador
    @estadistica_id = 31, @partido_id = 6, @jugador_id = 2,
    @minutos_jugados = 90, @goles = 0, @asistencias = 1,
    @tiros = 2, @pases_completados = 45, @recuperaciones = 6,
    @tiros_arco = 1, @faltas_cometidas = 0, @tarjetas_amarillas = 0,
    @tarjetas_rojas = 0, @calificacion = 7.80;
GO

EXEC sp_InsertarEstadisticaJugador
    @estadistica_id = 30, @partido_id = 1, @jugador_id = 5,
    @minutos_jugados = 90, @goles = 1, @asistencias = 0,
    @tiros = 3, @pases_completados = 30, @recuperaciones = 5,
    @tiros_arco = 2, @faltas_cometidas = 1, @tarjetas_amarillas = 0,
    @tarjetas_rojas = 0, @calificacion = 7.50;



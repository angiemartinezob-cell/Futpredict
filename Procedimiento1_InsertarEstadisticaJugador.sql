USE FutPredictDB;
GO

CREATE PROCEDURE sp_InsertarEstadisticaJugador
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

    -- Regla de negocio: no permitir un segundo registro para el mismo jugador y partido
    IF EXISTS (
        SELECT 1 FROM EstadisticaJugador
        WHERE partido_id = @partido_id AND jugador_id = @jugador_id
    )
    BEGIN
        RAISERROR('Ya existe un registro de estadísticas para este jugador en este partido.', 16, 1);
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

EXEC sp_InsertarEstadisticaJugador
    @estadistica_id = 21, @partido_id = 1, @jugador_id = 5,
    @minutos_jugados = 90, @goles = 1, @asistencias = 0,
    @tiros = 3, @pases_completados = 30, @recuperaciones = 5,
    @tiros_arco = 2, @faltas_cometidas = 1, @tarjetas_amarillas = 0,
    @tarjetas_rojas = 0, @calificacion = 7.50;
    
--Funcion1
USE FutPredictDB;
GO

CREATE OR ALTER FUNCTION dbo.fn_PromedioCalificacionJugador
(
    @jugador_id INT
)
RETURNS DECIMAL(4,2)
AS
BEGIN
    DECLARE @promedio DECIMAL(4,2);

    SELECT @promedio = AVG(calificacion)
    FROM EstadisticaJugador
    WHERE jugador_id = @jugador_id;

    RETURN @promedio;
END;
GO
--se prueba con el jugador 1
SELECT
    nombre AS jugador,
    dbo.fn_PromedioCalificacionJugador(jugador_id) AS promedio_calificacion
FROM Jugador
WHERE jugador_id = 1;
GO


-- FUNCION 2
USE FutPredictDB;
GO

CREATE OR ALTER FUNCTION dbo.fn_HistorialJugador
(
    @jugador_id INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        r.jugador_id,
        r.jugador,
        r.equipo,
        r.partido_id,
        r.fecha,
        r.equipo_local,
        r.equipo_visitante,
        r.minutos_jugados,
        r.goles,
        r.asistencias,
        r.tiros,
        r.tiros_arco,
        r.pases_completados,
        r.recuperaciones,
        r.calificacion
    FROM dbo.vw_RendimientoJugadores AS r
    WHERE r.jugador_id = @jugador_id
);
GO

--Prueba
SELECT *
FROM dbo.fn_HistorialJugador(1);
GO

--Funcion 3
USE FutPredictDB;
GO

CREATE OR ALTER FUNCTION dbo.fn_TotalContribucionesJugador
(
    @jugador_id INT
)
RETURNS INT
AS
BEGIN
    DECLARE @total INT;

    SELECT @total =
        ISNULL(SUM(goles), 0) + ISNULL(SUM(asistencias), 0)
    FROM EstadisticaJugador
    WHERE jugador_id = @jugador_id;

    RETURN @total;
END;
GO

--se prueba
SELECT
    nombre AS jugador,
    dbo.fn_TotalContribucionesJugador(jugador_id) AS contribuciones
FROM Jugador
WHERE jugador_id = 1;
GO

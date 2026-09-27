USE FutPredictDB;
GO

CREATE OR ALTER PROCEDURE sp_ObtenerRendimientoJugador
    @jugador_id INT,
    @fecha_limite DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        j.jugador_id,
        j.nombre,
        COUNT(ej.estadistica_id) AS partidos_jugados,
        AVG(CAST(ej.goles AS DECIMAL(5,2))) AS promedio_goles,
        AVG(CAST(ej.asistencias AS DECIMAL(5,2))) AS promedio_asistencias,
        AVG(ej.calificacion) AS promedio_calificacion
    FROM Jugador j
    LEFT JOIN (
        EstadisticaJugador ej
        JOIN Partido p
            ON p.partido_id = ej.partido_id
           AND (@fecha_limite IS NULL OR p.fecha < @fecha_limite)
    ) ON ej.jugador_id = j.jugador_id
    WHERE j.jugador_id = @jugador_id
    GROUP BY j.jugador_id, j.nombre;
END
GO

-- Pruebas
EXEC sp_ObtenerRendimientoJugador @jugador_id = 5;
GO
EXEC sp_ObtenerRendimientoJugador @jugador_id = 5, @fecha_limite = '2026-09-13';
GO


CREATE PROCEDURE sp_ObtenerRendimientoJugador
    @jugador_id INT
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
    LEFT JOIN EstadisticaJugador ej ON j.jugador_id = ej.jugador_id
    WHERE j.jugador_id = @jugador_id
    GROUP BY j.jugador_id, j.nombre;
END
GO

EXEC sp_ObtenerRendimientoJugador @jugador_id = 5;


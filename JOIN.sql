--JOIN1
USE FutPredictDB;
GO

SELECT
    p.partido_id,
    p.fecha,
    el.nombre AS equipo_local,
    p.goles_local,
    p.goles_visitante,
    ev.nombre AS equipo_visitante,
    l.nombre AS liga,
    t.nombre AS temporada,
    p.estado
FROM Partido p
INNER JOIN Equipo el
    ON p.equipo_local_id = el.equipo_id
INNER JOIN Equipo ev
    ON p.equipo_visitante_id = ev.equipo_id
INNER JOIN Liga l
    ON p.liga_id = l.liga_id
INNER JOIN Temporada t
    ON p.temporada_id = t.temporada_id
ORDER BY p.fecha;
GO


--JOIN2 
USE FutPredictDB;
GO

SELECT
    j.jugador_id,
    j.nombre AS jugador,
    e.nombre AS equipo,
    p.fecha,
    el.nombre AS equipo_local,
    ev.nombre AS equipo_visitante,
    ej.minutos_jugados,
    ej.goles,
    ej.asistencias,
    ej.tiros,
    ej.tiros_arco,
    ej.pases_completados,
    ej.recuperaciones,
    ej.calificacion
FROM EstadisticaJugador ej
INNER JOIN Jugador j
    ON ej.jugador_id = j.jugador_id
INNER JOIN Partido p
    ON ej.partido_id = p.partido_id
INNER JOIN JugadorEquipo je
    ON j.jugador_id = je.jugador_id
    AND p.temporada_id = je.temporada_id
INNER JOIN Equipo e
    ON je.equipo_id = e.equipo_id
INNER JOIN Equipo el
    ON p.equipo_local_id = el.equipo_id
INNER JOIN Equipo ev
    ON p.equipo_visitante_id = ev.equipo_id
WHERE e.equipo_id IN (p.equipo_local_id, p.equipo_visitante_id)
ORDER BY p.fecha, e.nombre, j.nombre;
GO


--JOIN3
USE FutPredictDB;
GO

SELECT
    p.partido_id,
    p.fecha,
    e.nombre AS equipo,
    rival.nombre AS rival,
    l.nombre AS liga,
    t.nombre AS temporada,
    ee.posesion,
    ee.tiros,
    ee.tiros_arco,
    ee.corners,
    ee.faltas,
    ee.tarjetas_amarillas,
    ee.tarjetas_rojas,
    CASE
        WHEN e.equipo_id = p.equipo_local_id THEN p.goles_local
        ELSE p.goles_visitante
    END AS goles_equipo,
    CASE
        WHEN e.equipo_id = p.equipo_local_id THEN p.goles_visitante
        ELSE p.goles_local
    END AS goles_rival
FROM EstadisticaEquipo ee
INNER JOIN Equipo e
    ON ee.equipo_id = e.equipo_id
INNER JOIN Partido p
    ON ee.partido_id = p.partido_id
INNER JOIN Equipo rival
    ON rival.equipo_id =
       CASE
           WHEN e.equipo_id = p.equipo_local_id
               THEN p.equipo_visitante_id
           ELSE p.equipo_local_id
       END
INNER JOIN Liga l
    ON p.liga_id = l.liga_id
INNER JOIN Temporada t
    ON p.temporada_id = t.temporada_id
ORDER BY p.fecha, e.nombre;
GO


--INNER JOIN muestra solo registros que tienen coincidencia en ambas tablas.
--LEFT JOIN conserva todos los registros de la tabla izquierda, aunque no tengan coincidencia en la derecha.
USE FutPredictDB;
GO

SELECT
    j.jugador_id,
    j.nombre AS jugador,
    e.nombre AS equipo,
    ej.partido_id,
    ej.minutos_jugados,
    ej.goles,
    ej.asistencias,
    ej.calificacion
FROM Jugador j
INNER JOIN JugadorEquipo je
    ON j.jugador_id = je.jugador_id
INNER JOIN Equipo e
    ON je.equipo_id = e.equipo_id
LEFT JOIN EstadisticaJugador ej
    ON j.jugador_id = ej.jugador_id
ORDER BY e.nombre, j.nombre;
GO

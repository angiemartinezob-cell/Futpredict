-- Triggers de auditoria (EstadisticaJugador, Partido) y validacion
-- de reglas de negocio (proteger jugador con stats, validar convocatoria)

USE FutPredictDB;
GO
CREATE OR ALTER TRIGGER trg_Auditoria_EstadisticaJugador
ON EstadisticaJugador
AFTER INSERT, UPDATE, DELETE
AS
BEGIN


UPDATE EstadisticaJugador SET goles = 3 WHERE estadistica_id = 1;

SELECT * FROM Auditoria ORDER BY auditoria_id DESC;


SELECT * FROM Jugador WHERE jugador_id = 1;

INSERT INTO EventoPartido (evento_id, partido_id, equipo_id, jugador_id, tipo_evento, minuto, descripcion)
VALUES (1, 1, 2, 1, 'Gol', 10, 'Prueba inválida - debe fallar');

INSERT INTO EventoPartido (evento_id, partido_id, equipo_id, jugador_id, tipo_evento, minuto, descripcion)
VALUES (1, 1, 1, 1, 'Gol', 23, 'Gol de cabeza');

SELECT * FROM EventoPartido;

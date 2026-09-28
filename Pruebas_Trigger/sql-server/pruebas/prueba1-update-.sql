USE FutPredictDB;
GO

-- Prueba 1: actualizar una estadistica existente
-- Resultado esperado: debe aparecer un registro UPDATE en Auditoria

UPDATE EstadisticaJugador SET goles = 3 WHERE estadistica_id = 1;

SELECT * FROM Auditoria ORDER BY auditoria_id DESC;

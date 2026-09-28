USE FutPredictDB;
GO


-- PRUEBA 5: Actualizar el estado de un partido
-- Objetivo: Probar el trigger trg_Auditoria_Partido
-- Resultado esperado: Se debe generar un registro UPDATE en Auditoria con tabla_afectada = 'Partido'


-- 1. Modificar estado o marcador de un partido
UPDATE Partido 
SET estado = 'En juego', goles_local = 1, goles_visitante = 0 
WHERE partido_id = 1;

-- 2. Verificar que el trigger guardó el log en Auditoria
SELECT * FROM Auditoria 
WHERE tabla_afectada = 'Partido' 
ORDER BY auditoria_id DESC;

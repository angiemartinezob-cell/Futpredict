USE FutPredictDB;
GO

-- PRUEBA 5: Actualizar el estado de un partido
-- Objetivo: probar el trigger trg_Auditoria_Partido
-- Resultado esperado: generar un registro UPDATE en Auditoria

-- Estado actual del partido
SELECT *
FROM Partido
WHERE partido_id = 7;
GO

-- Actualizar el partido de "En juego" a "Finalizado"
UPDATE Partido
SET estado = 'Finalizado'
WHERE partido_id = 7;
GO

-- Verificar que el trigger registró el cambio
SELECT * FROM Auditoria
WHERE tabla_afectada = 'Partido'
  AND registro_id = 7
ORDER BY auditoria_id DESC;
GO

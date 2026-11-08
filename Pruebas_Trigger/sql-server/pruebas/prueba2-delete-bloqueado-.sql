USE FutPredictDB;
GO

-- Prueba 2: intentar borrar un jugador que YA TIENE estadisticas registradas
-- Resultado esperado: DEBE FALLAR con el mensaje del trigger
-- trg_ProtegerJugadorConEstadisticas

DELETE FROM Jugador WHERE jugador_id = 1;

-- Verificacion: el jugador debe seguir existiendo
SELECT * FROM Jugador WHERE jugador_id = 1;

USE FutPredictDB;
GO

-- Prueba 3: intentar insertar un evento con un jugador que NO pertenece a ese equipo
-- jugador_id=1 (Marlos/Barcelona=equipo 1) insertado con equipo_id=2 (Real Madrid)
-- Resultado esperado: DEBE FALLAR con el mensaje del trigger
-- trg_ValidarJugadorEnEventoPartido

INSERT INTO EventoPartido (evento_id, partido_id, equipo_id, jugador_id, tipo_evento, minuto, descripcion)
VALUES (1, 1, 2, 1, 'Gol', 10, 'Prueba invalida - debe fallar');

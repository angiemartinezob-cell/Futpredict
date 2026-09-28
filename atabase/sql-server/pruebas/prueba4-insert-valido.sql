		USE FutPredictDB;
		GO

		-- Prueba 4: insertar un evento con un jugador que SI pertenece a ese equipo
		-- jugador_id=1 (Marlos/Barcelona=equipo 1) insertado con equipo_id=1 (correcto)
		-- Resultado esperado: DEBE FUNCIONAR sin errores

		INSERT INTO EventoPartido (evento_id, partido_id, equipo_id, jugador_id, tipo_evento, minuto, descripcion)
		VALUES (4, 1, 1, 1, 'Gol', 23, 'Gol de cabeza');


		-- Verificacion: debe aparecer la fila insertada
		SELECT * FROM EventoPartido;

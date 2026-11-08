		USE FutPredictDB;
GO

-- Prueba 4: insertar un evento con un jugador que SÍ pertenece a ese equipo
-- jugador_id = 1 pertenece a Barcelona (equipo_id = 1)
-- Resultado esperado: DEBE FUNCIONAR sin errores

INSERT INTO EventoPartido (
    evento_id,
    partido_id,
    equipo_id,
    jugador_id,
    tipo_evento,
    minuto,
    descripcion
)
VALUES (
    103,
    1,                  -- Barcelona vs Real Madrid
    1,                  -- Barcelona
    1,                  -- Jugador de Barcelona
    'Tarjeta amarilla',
    23,
    'Tarjeta amarilla por falta'
);

-- Verificación: debe aparecer el evento
SELECT * FROM EventoPartido
WHERE evento_id = 103;
GO

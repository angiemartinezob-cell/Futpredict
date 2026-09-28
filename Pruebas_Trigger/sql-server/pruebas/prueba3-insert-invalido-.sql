USE FutPredictDB;
GO

-- Prueba 3: intentar insertar un evento con un jugador
-- que NO pertenece al equipo indicado.
-- Resultado esperado: DEBE FALLAR por el trigger
-- trg_ValidarJugadorEnEventoPartido

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
    102,
    1,  -- Barcelona vs Real Madrid
    2,  -- Real Madrid
    1,  -- Jugador del Barcelona
    'Gol',
    10,
    'Prueba invalida - debe fallar'
);

-- Verificación: el evento 102 NO debe haberse insertado
SELECT *
FROM EventoPartido
WHERE evento_id = 102;
GO

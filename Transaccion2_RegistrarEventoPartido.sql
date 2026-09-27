BEGIN TRANSACTION RegistrarEventoPartido;

BEGIN TRY
    -- 1. Insertar el evento (ej. un gol)
    INSERT INTO EventoPartido (evento_id, partido_id, equipo_id, jugador_id, tipo_evento, minuto, descripcion)
    VALUES (1, 3, 5, 13, 'Gol', 67, 'Gol de cabeza tras córner');

    -- 2. Actualizar el estado del partido a "En juego" (o el que corresponda)
    UPDATE Partido
    SET estado = 'En juego'
    WHERE partido_id = 3;

    COMMIT TRANSACTION RegistrarEventoPartido;
    PRINT 'Evento y estado del partido actualizados correctamente.';
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION RegistrarEventoPartido;
    PRINT 'Ocurrió un error, se revirtieron los cambios: ' + ERROR_MESSAGE();
END CATCH
GO



USE FutPredictDB;
GO

CREATE PROCEDURE sp_ActualizarResultadoPartido
    @partido_id INT,
    @goles_local INT,
    @goles_visitante INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Partido WHERE partido_id = @partido_id)
    BEGIN
        RAISERROR('El partido especificado no existe.', 16, 1);
        RETURN;
    END

    IF @goles_local < 0 OR @goles_visitante < 0
    BEGIN
        RAISERROR('Los goles no pueden ser negativos.', 16, 1);
        RETURN;
    END

    UPDATE Partido
    SET goles_local = @goles_local,
        goles_visitante = @goles_visitante,
        estado = 'Finalizado'
    WHERE partido_id = @partido_id;

    PRINT 'Resultado del partido actualizado correctamente.';
END
GO

EXEC sp_ActualizarResultadoPartido @partido_id = 1, @goles_local = 3, @goles_visitante = 1;

SELECT * FROM Partido WHERE partido_id = 1;


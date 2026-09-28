

USE FutPredictDB;
GO

-- 1. TABLA AUDITORIA (necesaria para que los triggers guarden el log)

IF OBJECT_ID('dbo.Auditoria', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Auditoria (
        auditoria_id     INT IDENTITY(1,1) PRIMARY KEY,
        tabla_afectada    VARCHAR(50)  NOT NULL,
        operacion         VARCHAR(10)  NOT NULL,
        registro_id       INT          NOT NULL,
        usuario_db        VARCHAR(100) NOT NULL DEFAULT SUSER_SNAME(),
        fecha             DATETIME     NOT NULL DEFAULT GETDATE(),
        detalle           VARCHAR(500) NULL,
        CONSTRAINT CK_Auditoria_Operacion CHECK (operacion IN ('INSERT','UPDATE','DELETE'))
    );
END
GO

-- 2. TRIGGER: Auditoría de EstadisticaJugador

CREATE OR ALTER TRIGGER trg_Auditoria_EstadisticaJugador
ON EstadisticaJugador
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Auditoria (tabla_afectada, operacion, registro_id, detalle)
    SELECT
        'EstadisticaJugador', 'INSERT', i.estadistica_id,
        CONCAT('Jugador ', i.jugador_id, ' en partido ', i.partido_id,
               ' -> Goles: ', i.goles, ', Asistencias: ', i.asistencias,
               ', Minutos: ', i.minutos_jugados)
    FROM inserted i
    LEFT JOIN deleted d ON d.estadistica_id = i.estadistica_id
    WHERE d.estadistica_id IS NULL;

    INSERT INTO Auditoria (tabla_afectada, operacion, registro_id, detalle)
    SELECT
        'EstadisticaJugador', 'UPDATE', i.estadistica_id,
        CONCAT('Goles: ', d.goles, ' -> ', i.goles,
               ' | Asistencias: ', d.asistencias, ' -> ', i.asistencias,
               ' | Calificación: ', ISNULL(CAST(d.calificacion AS VARCHAR), 'NULL'),
               ' -> ', ISNULL(CAST(i.calificacion AS VARCHAR), 'NULL'))
    FROM inserted i
    JOIN deleted d ON d.estadistica_id = i.estadistica_id;

    INSERT INTO Auditoria (tabla_afectada, operacion, registro_id, detalle)
    SELECT
        'EstadisticaJugador', 'DELETE', d.estadistica_id,
        CONCAT('Registro eliminado - Jugador ', d.jugador_id, ' en partido ', d.partido_id)
    FROM deleted d
    LEFT JOIN inserted i ON i.estadistica_id = d.estadistica_id
    WHERE i.estadistica_id IS NULL;
END
GO

-- 3. TRIGGER: Auditoría de Partido

CREATE OR ALTER TRIGGER trg_Auditoria_Partido
ON Partido
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Auditoria (tabla_afectada, operacion, registro_id, detalle)
    SELECT
        'Partido', 'INSERT', i.partido_id,
        CONCAT('Nuevo partido creado, estado: ', i.estado)
    FROM inserted i
    LEFT JOIN deleted d ON d.partido_id = i.partido_id
    WHERE d.partido_id IS NULL;

    INSERT INTO Auditoria (tabla_afectada, operacion, registro_id, detalle)
    SELECT
        'Partido', 'UPDATE', i.partido_id,
        CONCAT('Estado: ', d.estado, ' -> ', i.estado,
               ' | Marcador: ', d.goles_local, '-', d.goles_visitante,
               ' -> ', i.goles_local, '-', i.goles_visitante)
    FROM inserted i
    JOIN deleted d ON d.partido_id = i.partido_id
    WHERE i.estado <> d.estado OR i.goles_local <> d.goles_local OR i.goles_visitante <> d.goles_visitante;

    INSERT INTO Auditoria (tabla_afectada, operacion, registro_id, detalle)
    SELECT
        'Partido', 'DELETE', d.partido_id,
        CONCAT('Partido eliminado, estado que tenía: ', d.estado)
    FROM deleted d
    LEFT JOIN inserted i ON i.partido_id = d.partido_id
    WHERE i.partido_id IS NULL;
END
GO


-- 4. TRIGGER: Proteger jugador con estadísticas (no dejar borrarlo)

CREATE OR ALTER TRIGGER trg_ProtegerJugadorConEstadisticas
ON Jugador
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM deleted d
        JOIN EstadisticaJugador e ON e.jugador_id = d.jugador_id
    )
    BEGIN
        RAISERROR('No se puede eliminar un jugador que ya tiene estadísticas registradas.', 16, 1);
        RETURN;
    END

    DELETE FROM Jugador WHERE jugador_id IN (SELECT jugador_id FROM deleted);
END
GO



-- 5. TRIGGER: Validar que el jugador pertenezca al equipo (Regla 1)

CREATE OR ALTER TRIGGER trg_ValidarJugadorEnEventoPartido
ON EventoPartido
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN Partido p ON p.partido_id = i.partido_id
        WHERE i.jugador_id IS NOT NULL
          AND NOT EXISTS (
              SELECT 1 FROM JugadorEquipo je
              WHERE je.jugador_id = i.jugador_id
                AND je.equipo_id = i.equipo_id
                AND je.temporada_id = p.temporada_id
                AND je.fecha_inicio <= p.fecha
                AND (je.fecha_fin IS NULL OR je.fecha_fin >= p.fecha)
          )
    )
    BEGIN
        RAISERROR('El jugador no pertenece a ese equipo en la fecha de ese partido.', 16, 1);
        RETURN;
    END

    INSERT INTO EventoPartido (evento_id, partido_id, equipo_id, jugador_id, tipo_evento, minuto, descripcion)
    SELECT evento_id, partido_id, equipo_id, jugador_id, tipo_evento, minuto, descripcion
    FROM inserted;
END
GO

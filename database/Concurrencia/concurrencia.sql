USE FutPredictDB;
GO

-- Para probar este script, debes abrir DOS VENTANAS DE CONSULTA separadas en SSMS.
-- Ventana 1 = Sesión 1 (Modifica datos)
-- Ventana 2 = Sesión 2 (Lee datos bajo diferentes niveles de aislamiento)


/*
USE FutPredictDB;
GO

BEGIN TRANSACTION;

-- Actualizamos temporalmente los goles de un jugador
UPDATE EstadisticaJugador
SET goles = 99
WHERE estadistica_id = 1;

PRINT '>> Sesión 1: Transacción abierta. Se cambiaron los goles a 99 (SIN COMMIT).';

-- Pausa de 20 segundos para dar tiempo a ejecutar la Sesión 2
WAITFOR DELAY '00:00:20';

-- Revertimos el cambio para dejar la base de datos limpia
ROLLBACK TRANSACTION;
PRINT '>> Sesión 1: ROLLBACK ejecutado. El cambio a 99 goles fue descartado.';
*/



-- DEMOSTRACIÓN A: Lectura Sucia (Dirty Read) con READ UNCOMMITTED
-- Mientras la Sesión 1 tiene la transacción abierta sin hacer COMMIT, 
-- la Sesión 2 puede "ver" el valor modificado (99 goles).

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT 
    estadistica_id, 
    jugador_id, 
    goles AS goles_detectados,
    'Lectura Sucia (READ UNCOMMITTED)' AS tipo_lectura
FROM EstadisticaJugador 
WHERE estadistica_id = 1;
GO


-- DEMOSTRACIÓN B: Control de Concurrencia con READ COMMITTED (Predeterminado)
-- Si ejecutamos esta consulta mientras la Sesión 1 tiene la transacción abierta,
-- SQL Server BLOQUEA esta consulta hasta que la Sesión 1 haga COMMIT o ROLLBACK,
-- garantizando la integridad de los datos.

SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

SELECT 
    estadistica_id, 
    jugador_id, 
    goles AS goles_detectados,
    'Lectura Consistente (READ COMMITTED)' AS tipo_lectura
FROM EstadisticaJugador 
WHERE estadistica_id = 1;
GO

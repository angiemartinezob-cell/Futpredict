USE FutPredictDB;
GO


-- PARTE A: CTE NORMAL (Common Table Expression)
-- Objetivo: Calcular métricas acumuladas y promedios de rendimiento de los 
--           jugadores y clasificarlos según su nivel de aporte ofensivo.


WITH CTE_RendimientoJugadores AS (
    -- 1. Consulta base: agrupa las estadísticas por jugador
    SELECT 
        j.jugador_id,
        j.nombre AS nombre_jugador,
        j.posicion,
        COUNT(e.partido_id) AS total_partidos,
        ISNULL(SUM(e.goles), 0) AS total_goles,
        ISNULL(SUM(e.asistencias), 0) AS total_asistencias,
        ISNULL(AVG(CAST(e.minutos_jugados AS FLOAT)), 0) AS promedio_minutos
    FROM Jugador j
    LEFT JOIN EstadisticaJugador e ON j.jugador_id = e.jugador_id
    GROUP BY j.jugador_id, j.nombre, j.posicion
),
CTE_ClasificacionAporte AS (
    -- 2. Segunda CTE: calcula el total de participaciones directas en gol
    SELECT 
        jugador_id,
        nombre_jugador,
        posicion,
        total_partidos,
        total_goles,
        total_asistencias,
        (total_goles + total_asistencias) AS participaciones_gol,
        ROUND(promedio_minutos, 1) AS promedio_minutos,
        CASE 
            WHEN (total_goles + total_asistencias) >= 5 THEN 'Aporte Alto (Titular Clave)'
            WHEN (total_goles + total_asistencias) BETWEEN 1 AND 4 THEN 'Aporte Medio (Rotación)'
            ELSE 'Sin Aporte Directo'
        END AS categoria_rendimiento
    FROM CTE_RendimientoJugadores
)
-- 3. Consulta final que consume la CTE
SELECT 
    jugador_id,
    nombre_jugador,
    posicion,
    total_partidos,
    total_goles,
    total_asistencias,
    participaciones_gol,
    promedio_minutos,
    categoria_rendimiento
FROM CTE_ClasificacionAporte
ORDER BY participaciones_gol DESC, promedio_minutos DESC;
GO


-- ============================================================================
-- PARTE B: CTE RECURSIVA (Jerarquía Organigrama del Club)
-- Objetivo: Recorrer la cadena de mando del cuerpo técnico y líderes del club 
--           (Director Deportivo -> DT -> Asistentes -> Capitanes) generando el 
--           nivel jerárquico y la ruta completa de mando.
-- ============================================================================

-- Preparación: Creamos una estructura jerárquica en una tabla temporal para la demostración
IF OBJECT_ID('tempdb..#OrganigramaClub') IS NOT NULL 
    DROP TABLE #OrganigramaClub;

CREATE TABLE #OrganigramaClub (
    empleado_id INT PRIMARY KEY,
    nombre      VARCHAR(100) NOT NULL,
    cargo       VARCHAR(100) NOT NULL,
    jefe_id     INT NULL -- Auto-referencia a la misma tabla
);

-- Inserción de datos con estructura de árbol (padres e hijos)
INSERT INTO #OrganigramaClub (empleado_id, nombre, cargo, jefe_id) VALUES 
(1, 'Carlos Bianchi', 'Director Deportivo', NULL),       -- Nivel 1 (Líder Supremo)
(2, 'Lionel Scaloni', 'Director Técnico', 1),            -- Nivel 2 (Depende de Carlos Bianchi)
(3, 'Pablo Aimar', 'Asistente Técnico Principal', 2),    -- Nivel 3 (Depende de Scaloni)
(4, 'Walter Samuel', 'Analista Táctico', 2),             -- Nivel 3 (Depende de Scaloni)
(5, 'Lionel Messi', 'Capitán de Campo', 3),              -- Nivel 4 (Depende de Aimar)
(6, 'Angel Di Maria', 'Sub-Capitán', 3);                 -- Nivel 4 (Depende de Aimar)


-- CONSULTA CON CTE RECURSIVA
WITH CTE_JerarquiaClub AS (
    -- 1. CASO ANCLA (Base): Selecciona el nodo raíz (quien no tiene jefe, jefe_id IS NULL)
    SELECT 
        empleado_id,
        nombre,
        cargo,
        jefe_id,
        1 AS nivel,
        CAST(nombre AS VARCHAR(500)) AS ruta_de_mando
    FROM #OrganigramaClub
    WHERE jefe_id IS NULL

    UNION ALL

    -- 2. PASO RECURSIVO: Se une a sí misma buscando los subordinados (hijos)
    SELECT 
        sub.empleado_id,
        sub.nombre,
        sub.cargo,
        sub.jefe_id,
        padre.nivel + 1 AS nivel,
        CAST(padre.ruta_de_mando + ' -> ' + sub.nombre AS VARCHAR(500)) AS ruta_de_mando
    FROM #OrganigramaClub sub
    INNER JOIN CTE_JerarquiaClub padre ON sub.jefe_id = padre.empleado_id
)
-- 3. Consulta final ordenada por nivel de jerarquía
SELECT 
    nivel,
    REPLICATE('', nivel - 1) + nombre AS organigrama_visual,
    cargo,
    ruta_de_mando
FROM CTE_JerarquiaClub
ORDER BY nivel, empleado_id;
GO

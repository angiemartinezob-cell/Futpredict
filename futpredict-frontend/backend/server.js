const express = require('express');
const cors = require('cors');
const { sql, obtenerPool } = require('./conexion');

const app = express();

app.use(cors());
app.use(express.json());

app.get('/api', (req, res) => {
  res.json({
    mensaje: '¡Bienvenido a la API de FutPredict!',
    estado: 'Servidor funcionando correctamente'
  });
});


// Ejecuta una consulta SQL con el pool compartido y responde en JSON.
// Todas las rutas siguen el mismo patrón que tenía /api/equipos.
async function responderConsulta(res, descripcion, ejecutar) {
  try {
    const pool = await obtenerPool();
    const datos = await ejecutar(pool);
    res.json(datos);
  } catch (error) {
    console.error(`Error al consultar ${descripcion}:`, error.message);
    res.status(500).json({
      mensaje: `No se pudieron consultar los ${descripcion}`
    });
  }
}

// Consultar equipos registrados
app.get('/api/equipos', (req, res) =>
  responderConsulta(res, 'equipos', async (pool) => {
    const resultado = await pool.request().query(`
      SELECT equipo_id, nombre, pais
      FROM Equipo
      ORDER BY equipo_id
    `);
    return resultado.recordset;
  })
);

// Contadores del dashboard (subconsultas)
app.get('/api/resumen', (req, res) =>
  responderConsulta(res, 'indicadores', async (pool) => {
    const resultado = await pool.request().query(`
      SELECT
        (SELECT COUNT(*) FROM Jugador) AS jugadores,
        (SELECT COUNT(*) FROM Equipo)  AS equipos,
        (SELECT COUNT(*) FROM Partido) AS partidos,
        (SELECT COUNT(*) FROM Liga)    AS ligas
    `);
    return resultado.recordset[0];
  })
);

// Jugadores con su equipo actual y totales.
// Jugador no tiene equipo_id: el equipo se obtiene de JugadorEquipo (CTE)
// y los promedios con las funciones de Funciones.sql.
app.get('/api/jugadores', (req, res) =>
  responderConsulta(res, 'jugadores', async (pool) => {
    const resultado = await pool.request().query(`
      WITH EquipoActual AS (
        SELECT
          je.jugador_id,
          e.nombre AS equipo,
          ROW_NUMBER() OVER (
            PARTITION BY je.jugador_id
            ORDER BY je.temporada_id DESC, je.fecha_inicio DESC
          ) AS orden
        FROM JugadorEquipo je
        INNER JOIN Equipo e
          ON e.equipo_id = je.equipo_id
      )
      SELECT
        j.jugador_id,
        j.nombre,
        j.posicion,
        CONVERT(CHAR(10), j.fecha_nacimiento, 23) AS fecha_nacimiento,
        ea.equipo,
        COUNT(ej.estadistica_id) AS partidos_jugados,
        ISNULL(SUM(ej.goles), 0) AS goles,
        ISNULL(SUM(ej.asistencias), 0) AS asistencias,
        dbo.fn_PromedioCalificacionJugador(j.jugador_id) AS calificacion_promedio,
        dbo.fn_TotalContribucionesJugador(j.jugador_id) AS contribuciones
      FROM Jugador j
      LEFT JOIN EquipoActual ea
        ON ea.jugador_id = j.jugador_id
       AND ea.orden = 1
      LEFT JOIN EstadisticaJugador ej
        ON ej.jugador_id = j.jugador_id
      GROUP BY j.jugador_id, j.nombre, j.posicion, j.fecha_nacimiento, ea.equipo
      ORDER BY j.jugador_id
    `);
    return resultado.recordset;
  })
);

// Rendimiento e historial de un jugador
// (procedimiento sp_ObtenerRendimientoJugador + función fn_HistorialJugador).
// El id se envía como parámetro para evitar inyección SQL.
app.get('/api/jugadores/:id/rendimiento', async (req, res) => {
  const jugadorId = Number.parseInt(req.params.id, 10);

  if (!Number.isInteger(jugadorId) || jugadorId <= 0) {
    return res.status(400).json({ mensaje: 'El id del jugador no es válido' });
  }

  return responderConsulta(res, 'datos del jugador', async (pool) => {
    const resumen = await pool.request()
      .input('jugador_id', sql.Int, jugadorId)
      .execute('sp_ObtenerRendimientoJugador');

    const historial = await pool.request()
      .input('jugador_id', sql.Int, jugadorId)
      .query(`
        SELECT *
        FROM dbo.fn_HistorialJugador(@jugador_id)
        ORDER BY fecha DESC
      `);

    return {
      resumen: resumen.recordset[0] || null,
      historial: historial.recordset
    };
  });
});

// Partidos (vista vw_PartidosDetallados de VISTAS.sql)
app.get('/api/partidos', (req, res) =>
  responderConsulta(res, 'partidos', async (pool) => {
    const resultado = await pool.request().query(`
      SELECT
        partido_id,
        CONVERT(CHAR(10), fecha, 23) AS fecha, -- 'AAAA-MM-DD', evita desfases de zona horaria
        equipo_local,
        goles_local,
        goles_visitante,
        equipo_visitante,
        liga,
        temporada,
        estado
      FROM dbo.vw_PartidosDetallados
      ORDER BY fecha DESC, partido_id DESC
    `);
    return resultado.recordset;
  })
);

// Ligas con la cantidad de equipos y partidos (subconsultas correlacionadas)
app.get('/api/ligas', (req, res) =>
  responderConsulta(res, 'ligas', async (pool) => {
    const resultado = await pool.request().query(`
      SELECT
        l.liga_id,
        l.nombre,
        l.pais,
        l.tipo,
        (SELECT COUNT(*) FROM EquipoCompeticion ec WHERE ec.liga_id = l.liga_id) AS equipos,
        (SELECT COUNT(*) FROM Partido p WHERE p.liga_id = l.liga_id) AS partidos
      FROM Liga l
      ORDER BY l.liga_id
    `);
    return resultado.recordset;
  })
);

// Rendimiento acumulado por equipo (vista vw_RendimientoEquipos de VISTAS.sql)
app.get('/api/estadisticas/equipos', (req, res) =>
  responderConsulta(res, 'estadísticas de equipos', async (pool) => {
    const resultado = await pool.request().query(`
      SELECT
        equipo,
        COUNT(*) AS partidos,
        SUM(CASE WHEN goles_equipo > goles_rival THEN 1 ELSE 0 END) AS ganados,
        SUM(CASE WHEN goles_equipo = goles_rival THEN 1 ELSE 0 END) AS empatados,
        SUM(CASE WHEN goles_equipo < goles_rival THEN 1 ELSE 0 END) AS perdidos,
        SUM(goles_equipo) AS goles_favor,
        SUM(goles_rival) AS goles_contra,
        SUM(CASE
              WHEN goles_equipo > goles_rival THEN 3
              WHEN goles_equipo = goles_rival THEN 1
              ELSE 0
            END) AS puntos,
        CAST(AVG(posesion) AS DECIMAL(5,2)) AS posesion_promedio,
        SUM(tiros) AS tiros,
        SUM(tiros_arco) AS tiros_arco
      FROM dbo.vw_RendimientoEquipos
      GROUP BY equipo
      ORDER BY puntos DESC, (SUM(goles_equipo) - SUM(goles_rival)) DESC, equipo
    `);
    return resultado.recordset;
  })
);

// Rutas de MongoDB (Unidad 2). Se cargan solo si el paquete "mongodb" está instalado,
// para que la API de SQL Server siga funcionando aunque MongoDB no esté configurado.
try {
  app.use('/api/mongo', require('./rutasMongo'));
} catch (error) {
  console.warn('Rutas de MongoDB desactivadas:', error.message);
}

const PORT = process.env.PORT || 3001;

app.listen(PORT, () => {
  console.log(`FutPredict API funcionando en http://localhost:${PORT}`);
});
// =====================================================================
// FutPredict - Consultas en MongoDB (Unidad 2)
// Ejecutar en mongosh:   mongosh futpredict consultas_futpredict.js
// o copiar cada bloque en la pestaña "Mongosh" de MongoDB Compass.
// Requiere haber ejecutado antes migracion_sql_a_mongo.py
// =====================================================================

db = db.getSiblingDB('futpredict');

function titulo(texto) {
  print('\n========== ' + texto + ' ==========');
}

// ---------------------------------------------------------------------
// 1. EMBEDDING: un partido completo en UNA sola consulta.
//    En SQL Server se necesitan JOIN con Equipo (x2), Liga, Temporada,
//    EstadisticaEquipo, EstadisticaJugador y EventoPartido.
// ---------------------------------------------------------------------
titulo('1. Partido 1 completo (embedding)');
printjson(db.partidos.findOne({ _id: 1 }));

// ---------------------------------------------------------------------
// 2. Consultas con filtros, proyección y orden (find)
//    Partidos finalizados de LaLiga o Premier League, más recientes primero.
// ---------------------------------------------------------------------
titulo('2. Partidos finalizados de LaLiga o Premier League');
db.partidos.find(
  { estado: 'Finalizado', 'liga.nombre': { $in: ['LaLiga', 'Premier League'] } },
  { _id: 1, fecha: 1, 'local.nombre': 1, 'local.goles': 1,
    'visitante.nombre': 1, 'visitante.goles': 1 }
).sort({ fecha: -1 }).forEach(printjson);

// ---------------------------------------------------------------------
// 3. REFERENCING + $lookup: tabla de goleadores.
//    Las estadísticas están incrustadas en el partido, pero el nombre y la
//    posición del jugador se traen de la colección jugadores (≈ LEFT JOIN).
// ---------------------------------------------------------------------
titulo('3. Top 5 de jugadores por goles + asistencias ($unwind, $group, $lookup)');
db.partidos.aggregate([
  { $match: { estado: 'Finalizado' } },
  { $unwind: '$estadisticas_jugadores' },
  { $group: {
      _id: '$estadisticas_jugadores.jugador_id',
      partidos: { $sum: 1 },
      goles: { $sum: '$estadisticas_jugadores.goles' },
      asistencias: { $sum: '$estadisticas_jugadores.asistencias' },
      calificacion_promedio: { $avg: '$estadisticas_jugadores.calificacion' }
  } },
  { $addFields: { contribuciones: { $add: ['$goles', '$asistencias'] } } },
  { $sort: { contribuciones: -1, calificacion_promedio: -1 } },
  { $limit: 5 },
  { $lookup: { from: 'jugadores', localField: '_id', foreignField: '_id', as: 'jugador' } },
  { $unwind: { path: '$jugador', preserveNullAndEmptyArrays: true } },
  { $project: {
      _id: 0,
      jugador_id: '$_id',
      nombre: '$jugador.nombre',
      posicion: '$jugador.posicion',
      partidos: 1, goles: 1, asistencias: 1, contribuciones: 1,
      calificacion_promedio: { $round: ['$calificacion_promedio', 2] }
  } }
]).forEach(printjson);

// ---------------------------------------------------------------------
// 4. Tabla de posiciones: cada partido aporta una fila al local y otra al
//    visitante. Equivale a la vista vw_RendimientoEquipos de SQL Server.
// ---------------------------------------------------------------------
titulo('4. Tabla de posiciones por equipo');
db.partidos.aggregate([
  { $match: { estado: 'Finalizado' } },
  { $project: {
      filas: [
        { equipo: '$local.nombre', gf: '$local.goles', gc: '$visitante.goles',
          posesion: '$local.estadisticas.posesion' },
        { equipo: '$visitante.nombre', gf: '$visitante.goles', gc: '$local.goles',
          posesion: '$visitante.estadisticas.posesion' }
      ]
  } },
  { $unwind: '$filas' },
  { $group: {
      _id: '$filas.equipo',
      pj: { $sum: 1 },
      g: { $sum: { $cond: [{ $gt: ['$filas.gf', '$filas.gc'] }, 1, 0] } },
      e: { $sum: { $cond: [{ $eq: ['$filas.gf', '$filas.gc'] }, 1, 0] } },
      p: { $sum: { $cond: [{ $lt: ['$filas.gf', '$filas.gc'] }, 1, 0] } },
      gf: { $sum: '$filas.gf' },
      gc: { $sum: '$filas.gc' },
      posesion_promedio: { $avg: '$filas.posesion' }
  } },
  { $addFields: {
      puntos: { $add: [{ $multiply: ['$g', 3] }, '$e'] },
      diferencia: { $subtract: ['$gf', '$gc'] }
  } },
  { $sort: { puntos: -1, diferencia: -1, _id: 1 } }
]).forEach(printjson);

// ---------------------------------------------------------------------
// 5. $lookup con pipeline (let + $expr): para cada jugador, solo los
//    partidos en los que marcó al menos un gol.
// ---------------------------------------------------------------------
titulo('5. Jugadores con los partidos en los que anotaron ($lookup con pipeline)');
db.jugadores.aggregate([
  { $lookup: {
      from: 'partidos',
      let: { jid: '$_id' },
      pipeline: [
        { $unwind: '$estadisticas_jugadores' },
        { $match: { $expr: { $and: [
            { $eq: ['$estadisticas_jugadores.jugador_id', '$$jid'] },
            { $gt: ['$estadisticas_jugadores.goles', 0] }
        ] } } },
        { $project: { _id: 0, partido_id: '$_id', fecha: 1,
                      goles: '$estadisticas_jugadores.goles',
                      local: '$local.nombre', visitante: '$visitante.nombre' } }
      ],
      as: 'partidos_con_gol'
  } },
  { $match: { 'partidos_con_gol.0': { $exists: true } } },
  { $project: { nombre: 1, posicion: 1, partidos_con_gol: 1 } }
]).forEach(printjson);

// ---------------------------------------------------------------------
// 6. $lookup sobre un arreglo incrustado: plantilla de cada equipo.
//    jugadores.trayectoria es un arreglo; $lookup busca dentro de él.
// ---------------------------------------------------------------------
titulo('6. Plantilla de cada equipo (lookup sobre arreglo)');
db.equipos.aggregate([
  { $lookup: {
      from: 'jugadores',
      localField: '_id',
      foreignField: 'trayectoria.equipo_id',
      as: 'plantilla'
  } },
  { $project: { _id: 0, equipo: '$nombre', pais: 1,
                jugadores: '$plantilla.nombre', total: { $size: '$plantilla' } } }
]).forEach(printjson);

// ---------------------------------------------------------------------
// 7. Agrupación simple: jugadores por posición.
// ---------------------------------------------------------------------
titulo('7. Jugadores por posición');
db.jugadores.aggregate([
  { $group: { _id: '$posicion', total: { $sum: 1 }, jugadores: { $push: '$nombre' } } },
  { $sort: { total: -1 } }
]).forEach(printjson);

// ---------------------------------------------------------------------
// 8. Índices y explain(): la búsqueda por jugador dentro del arreglo usa
//    el índice estadisticas_jugadores.jugador_id (IXSCAN, no COLLSCAN).
// ---------------------------------------------------------------------
titulo('8. explain() de la búsqueda de partidos de un jugador');
const plan = db.partidos.find({ 'estadisticas_jugadores.jugador_id': 5 })
  .explain('executionStats');
printjson({
  etapa: plan.queryPlanner.winningPlan.inputStage
    ? plan.queryPlanner.winningPlan.inputStage.stage
    : plan.queryPlanner.winningPlan.stage,
  documentos_examinados: plan.executionStats.totalDocsExamined,
  documentos_devueltos: plan.executionStats.nReturned,
  tiempo_ms: plan.executionStats.executionTimeMillis
});

// ---------------------------------------------------------------------
// 9. Validación con $jsonSchema: este documento debe ser RECHAZADO
//    (goles negativos y estado no permitido), igual que los CHECK de SQL Server.
// ---------------------------------------------------------------------
titulo('9. Prueba del validador $jsonSchema (debe fallar)');
try {
  db.partidos.insertOne({
    _id: 999, fecha: new Date(), estado: 'Cancelado',
    local: { equipo_id: 1, goles: -1 }, visitante: { equipo_id: 2, goles: 0 }
  });
  print('ERROR: el documento inválido fue aceptado');
} catch (e) {
  print('Correcto: MongoDB rechazó el documento -> ' + e.message);
}

// ---------------------------------------------------------------------
// 10. Totales para comparar con SQL Server
//     SELECT COUNT(*), SUM(goles_local + goles_visitante) FROM Partido;
// ---------------------------------------------------------------------
titulo('10. Totales para validar contra SQL Server');
db.partidos.aggregate([
  { $group: { _id: null, partidos: { $sum: 1 },
              goles: { $sum: { $add: ['$local.goles', '$visitante.goles'] } } } },
  { $project: { _id: 0 } }
]).forEach(printjson);

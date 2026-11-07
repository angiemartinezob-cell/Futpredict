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

// =====================================================================
// CONSULTAS 11 A 14: los ejercicios del taller del 26 de octubre
// aplicados a los datos de FutPredict.
// =====================================================================

// ---------------------------------------------------------------------
// 11. $elemMatch: partidos en los que EL MISMO jugador marcó y asistió.
//     Con dos condiciones separadas, MongoDB acepta el partido si un
//     jugador marcó y OTRO distinto dio una asistencia (resultado de más).
//     $elemMatch exige que ambas condiciones se cumplan en el mismo elemento.
// ---------------------------------------------------------------------
titulo('11. $elemMatch: el mismo jugador marcó y asistió');
const conElemMatch = db.partidos.find(
  { estadisticas_jugadores: { $elemMatch: { goles: { $gte: 1 }, asistencias: { $gte: 1 } } } },
  { _id: 1 }
).toArray().map((p) => p._id);

const condicionesSeparadas = db.partidos.find(
  { 'estadisticas_jugadores.goles': { $gte: 1 }, 'estadisticas_jugadores.asistencias': { $gte: 1 } },
  { _id: 1 }
).toArray().map((p) => p._id);

printjson({ con_elemMatch: conElemMatch, condiciones_separadas: condicionesSeparadas });
print('Los partidos que solo aparecen con condiciones separadas tienen el gol y la asistencia en jugadores distintos.');

// ---------------------------------------------------------------------
// 12. $addFields con $map: control de calidad de los datos.
//     $map extrae los goles de cada jugador, $sum los suma y se comparan
//     con el marcador del partido. Si no coinciden, falta una estadística.
// ---------------------------------------------------------------------
titulo('12. $addFields con $map: goles de jugadores frente al marcador');
db.partidos.aggregate([
  { $addFields: {
      goles_jugadores: {
        $sum: { $map: { input: '$estadisticas_jugadores', as: 'e', in: '$$e.goles' } }
      },
      goles_marcador: { $add: ['$local.goles', '$visitante.goles'] }
  } },
  { $project: {
      _id: 1,
      partido: { $concat: ['$local.nombre', ' vs ', '$visitante.nombre'] },
      goles_marcador: 1,
      goles_jugadores: 1,
      revision: {
        $cond: [{ $eq: ['$goles_marcador', '$goles_jugadores'] },
                'Coincide', 'Revisar: faltan estadísticas']
      }
  } },
  { $sort: { _id: 1 } }
]).forEach(printjson);

// ---------------------------------------------------------------------
// 13. $lookup de uno a muchos: cuántos partidos tiene cada liga.
//     Las ligas sin partidos (Champions League) aparecen con 0 gracias a
//     que $lookup devuelve un arreglo vacío y $size lo cuenta como 0.
// ---------------------------------------------------------------------
titulo('13. $lookup uno a muchos: partidos por liga (incluye las que tienen 0)');
db.ligas.aggregate([
  { $lookup: {
      from: 'partidos',
      localField: '_id',
      foreignField: 'liga.liga_id',
      as: 'partidos'
  } },
  { $project: { _id: 0, liga: '$nombre', tipo: 1, partidos: { $size: '$partidos' } } },
  { $sort: { partidos: -1, liga: 1 } }
]).forEach(printjson);

// ---------------------------------------------------------------------
// 14. Tres colecciones: goles y asistencias por posición.
//     partidos ($unwind de las estadísticas) -> jugadores (posición)
//     -> equipos (nombre). Al final se comprueba que la suma por posición
//     coincide con el total de goles de los jugadores.
// ---------------------------------------------------------------------
titulo('14. Tres colecciones: aporte por posición');
const porPosicion = db.partidos.aggregate([
  { $unwind: '$estadisticas_jugadores' },
  { $lookup: { from: 'jugadores', localField: 'estadisticas_jugadores.jugador_id',
               foreignField: '_id', as: 'jugador' } },
  { $unwind: '$jugador' },
  { $lookup: { from: 'equipos', localField: 'estadisticas_jugadores.equipo_id',
               foreignField: '_id', as: 'equipo' } },
  { $unwind: { path: '$equipo', preserveNullAndEmptyArrays: true } },
  { $group: {
      _id: '$jugador.posicion',
      goles: { $sum: '$estadisticas_jugadores.goles' },
      asistencias: { $sum: '$estadisticas_jugadores.asistencias' },
      calificacion_promedio: { $avg: '$estadisticas_jugadores.calificacion' },
      equipos: { $addToSet: '$equipo.nombre' }
  } },
  { $project: {
      _id: 0, posicion: '$_id', goles: 1, asistencias: 1,
      calificacion_promedio: { $round: ['$calificacion_promedio', 2] },
      equipos: { $size: '$equipos' }
  } },
  { $sort: { goles: -1 } }
]).toArray();
porPosicion.forEach((fila) => printjson(fila));

const sumaPorPosicion = porPosicion.reduce((total, fila) => total + fila.goles, 0);
const totalGoles = db.partidos.aggregate([
  { $unwind: '$estadisticas_jugadores' },
  { $group: { _id: null, n: { $sum: '$estadisticas_jugadores.goles' } } }
]).toArray()[0].n;
print('Comprobación: suma por posición = ' + sumaPorPosicion +
      ' | total de goles de jugadores = ' + totalGoles +
      (sumaPorPosicion === totalGoles ? '  -> Coincide' : '  -> No coincide'));

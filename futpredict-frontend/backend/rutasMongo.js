// Rutas de la API que leen desde MongoDB (Unidad 2).
// Requiere: npm install mongodb   y haber ejecutado database/mongodb/migracion_sql_a_mongo.py
const express = require('express');
const { MongoClient } = require('mongodb'); // si no está instalado, server.js omite estas rutas

const router = express.Router();

const cliente = new MongoClient(process.env.MONGO_URI || 'mongodb://localhost:27017', {
  serverSelectionTimeoutMS: 3000
});
let conexion = null;

async function obtenerDb() {
  if (!conexion) {
    conexion = cliente.connect().catch((error) => {
      conexion = null;
      throw error;
    });
  }
  await conexion;
  return cliente.db(process.env.MONGO_DB || 'futpredict');
}

async function responder(res, descripcion, ejecutar) {
  try {
    const db = await obtenerDb();
    res.json(await ejecutar(db));
  } catch (error) {
    console.error(`Error en MongoDB (${descripcion}):`, error.message);
    res.status(500).json({ mensaje: `No se pudo consultar ${descripcion} en MongoDB` });
  }
}

// Top de jugadores por goles + asistencias ($unwind + $group + $lookup)
router.get('/goleadores', (req, res) =>
  responder(res, 'los goleadores', (db) =>
    db.collection('partidos').aggregate([
      { $match: { estado: 'Finalizado' } },
      { $unwind: '$estadisticas_jugadores' },
      { $group: {
          _id: '$estadisticas_jugadores.jugador_id',
          equipo_id: { $last: '$estadisticas_jugadores.equipo_id' },
          partidos: { $sum: 1 },
          goles: { $sum: '$estadisticas_jugadores.goles' },
          asistencias: { $sum: '$estadisticas_jugadores.asistencias' },
          calificacion: { $avg: '$estadisticas_jugadores.calificacion' }
      } },
      { $addFields: { contribuciones: { $add: ['$goles', '$asistencias'] } } },
      { $sort: { contribuciones: -1, calificacion: -1 } },
      { $limit: 5 },
      { $lookup: { from: 'jugadores', localField: '_id', foreignField: '_id', as: 'jugador' } },
      { $lookup: { from: 'equipos', localField: 'equipo_id', foreignField: '_id', as: 'equipo' } },
      { $project: {
          _id: 0,
          jugador_id: '$_id',
          nombre: { $first: '$jugador.nombre' },
          posicion: { $first: '$jugador.posicion' },
          equipo: { $first: '$equipo.nombre' },
          partidos: 1, goles: 1, asistencias: 1, contribuciones: 1,
          calificacion: { $round: ['$calificacion', 2] }
      } }
    ]).toArray()
  )
);

// Promedios por liga calculados con el Aggregation Framework
router.get('/ligas', (req, res) =>
  responder(res, 'el resumen por liga', (db) =>
    db.collection('partidos').aggregate([
      { $match: { estado: 'Finalizado' } },
      { $group: {
          _id: '$liga.nombre',
          partidos: { $sum: 1 },
          goles: { $sum: { $add: ['$local.goles', '$visitante.goles'] } },
          tiros: { $sum: { $add: [
            { $ifNull: ['$local.estadisticas.tiros', 0] },
            { $ifNull: ['$visitante.estadisticas.tiros', 0] }
          ] } }
      } },
      { $project: {
          _id: 0,
          liga: '$_id',
          partidos: 1,
          goles: 1,
          goles_por_partido: { $round: [{ $divide: ['$goles', '$partidos'] }, 2] },
          tiros_por_partido: { $round: [{ $divide: ['$tiros', '$partidos'] }, 2] }
      } },
      { $sort: { goles_por_partido: -1 } }
    ]).toArray()
  )
);

module.exports = router;

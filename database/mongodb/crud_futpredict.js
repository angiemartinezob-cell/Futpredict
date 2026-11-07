// =====================================================================
// FutPredict - Operaciones CRUD en MongoDB (Unidad 2, tema 2.5)
// Ejecutar:  mongosh futpredict crud_futpredict.js
//
// El script trabaja con un partido de PRUEBA (_id: 900) y al final lo borra.
// Los cambios sobre datos reales (renombrar un equipo) se revierten,
// así que la base queda igual que después de la migración.
//
// Nota: en mongosh los números son Double por defecto. Como el validador
// $jsonSchema exige enteros en los goles, se usa NumberInt().
// =====================================================================

db = db.getSiblingDB('futpredict');

function titulo(texto) {
  print('\n========== ' + texto + ' ==========');
}

// Por si una ejecución anterior se interrumpió
db.partidos.deleteOne({ _id: 900 });

// ---------------------------------------------------------------------
// C - CREATE: insertOne
// Un partido programado con todo su contenido en un solo documento.
// Pasa el validador: estado permitido, fecha tipo Date y goles enteros >= 0.
// ---------------------------------------------------------------------
titulo('C. insertOne: crear un partido programado');
const creado = db.partidos.insertOne({
  _id: 900,
  fecha: new Date('2027-02-14'),
  estado: 'Programado',
  liga: { liga_id: 1, nombre: 'LaLiga' },
  temporada: { temporada_id: 2, nombre: '2026/2027' },
  local: { equipo_id: 2, nombre: 'Real Madrid', goles: NumberInt(0), estadisticas: null },
  visitante: { equipo_id: 1, nombre: 'FC Barcelona', goles: NumberInt(0), estadisticas: null },
  estadisticas_jugadores: [],
  eventos: []
});
printjson(creado);

// ---------------------------------------------------------------------
// R - READ: find con filtro y proyección
// ---------------------------------------------------------------------
titulo('R. find: partidos programados');
db.partidos.find(
  { estado: 'Programado' },
  { fecha: 1, 'local.nombre': 1, 'visitante.nombre': 1, estado: 1 }
).forEach(printjson);

// ---------------------------------------------------------------------
// U - UPDATE 1: $set -> el partido empieza
// ---------------------------------------------------------------------
titulo('U1. updateOne con $set: el partido pasa a "En juego"');
printjson(db.partidos.updateOne({ _id: 900 }, { $set: { estado: 'En juego' } }));

// ---------------------------------------------------------------------
// U - UPDATE 2: $push + $inc en la MISMA operación.
// Se agrega el evento dentro del arreglo y se actualiza el marcador.
// En SQL Server esto requiere INSERT en EventoPartido + UPDATE en Partido
// dentro de una transacción (Transaccion2 de la Unidad 1). Aquí basta una
// sola operación, que es atómica porque todo está en el mismo documento.
// ---------------------------------------------------------------------
titulo('U2. updateOne con $push y $inc: gol del Real Madrid');
printjson(db.partidos.updateOne(
  { _id: 900 },
  {
    $push: {
      eventos: {
        evento_id: NumberInt(900),
        minuto: NumberInt(27),
        tipo: 'Gol',
        equipo_id: NumberInt(2),
        jugador_id: NumberInt(3),
        descripcion: 'Gol de cabeza'
      }
    },
    $inc: { 'local.goles': NumberInt(1) }
  }
));
printjson(db.partidos.findOne({ _id: 900 }, { estado: 1, local: 1, visitante: 1, eventos: 1 }));

// ---------------------------------------------------------------------
// U - UPDATE 3: el validador también protege las actualizaciones
// ---------------------------------------------------------------------
titulo('U3. updateOne inválido: estado "Cancelado" (debe fallar)');
try {
  db.partidos.updateOne({ _id: 900 }, { $set: { estado: 'Cancelado' } });
  print('ERROR: la actualización inválida fue aceptada');
} catch (e) {
  print('Correcto: MongoDB rechazó la actualización -> ' + e.message);
}

// ---------------------------------------------------------------------
// U - UPDATE 4: updateMany -> costo de la duplicación (embedding)
// El nombre del equipo está copiado en equipos, partidos y en la trayectoria
// de los jugadores. Si cambia, hay que actualizarlo en TODOS esos lugares.
// (Mismo análisis del taller del 19 de octubre con el precio del producto P1.)
// ---------------------------------------------------------------------
titulo('U4. updateMany: renombrar "Juventus" en todas las colecciones');
const cambios = {
  equipos: db.equipos.updateOne({ _id: 6 }, { $set: { nombre: 'Juventus FC' } }).modifiedCount,
  partidos_local: db.partidos.updateMany(
    { 'local.equipo_id': 6 }, { $set: { 'local.nombre': 'Juventus FC' } }).modifiedCount,
  partidos_visitante: db.partidos.updateMany(
    { 'visitante.equipo_id': 6 }, { $set: { 'visitante.nombre': 'Juventus FC' } }).modifiedCount,
  trayectorias: db.jugadores.updateMany(
    { 'trayectoria.equipo_id': 6 },
    { $set: { 'trayectoria.$[t].equipo': 'Juventus FC' } },
    { arrayFilters: [{ 't.equipo_id': 6 }] }).modifiedCount
};
printjson(cambios);
print('En SQL Server bastaría un solo UPDATE en la tabla Equipo, porque el nombre no se repite.');

// Se revierte para dejar los datos como estaban
db.equipos.updateOne({ _id: 6 }, { $set: { nombre: 'Juventus' } });
db.partidos.updateMany({ 'local.equipo_id': 6 }, { $set: { 'local.nombre': 'Juventus' } });
db.partidos.updateMany({ 'visitante.equipo_id': 6 }, { $set: { 'visitante.nombre': 'Juventus' } });
db.jugadores.updateMany(
  { 'trayectoria.equipo_id': 6 },
  { $set: { 'trayectoria.$[t].equipo': 'Juventus' } },
  { arrayFilters: [{ 't.equipo_id': 6 }] }
);
print('Cambio revertido: el equipo vuelve a llamarse "Juventus".');

// ---------------------------------------------------------------------
// U - UPDATE 5: $pull -> quitar un evento registrado por error
// ---------------------------------------------------------------------
titulo('U5. updateOne con $pull: anular el gol (revisión del VAR)');
printjson(db.partidos.updateOne(
  { _id: 900 },
  { $pull: { eventos: { evento_id: 900 } }, $inc: { 'local.goles': NumberInt(-1) } }
));
printjson(db.partidos.findOne({ _id: 900 }, { local: 1, eventos: 1 }));

// ---------------------------------------------------------------------
// D - DELETE: deleteOne
// En SQL Server, borrar un partido con eventos y estadísticas exige borrar
// primero las filas hijas (por las claves foráneas). Aquí el partido y todo
// lo incrustado se eliminan juntos.
// ---------------------------------------------------------------------
titulo('D. deleteOne: eliminar el partido de prueba');
printjson(db.partidos.deleteOne({ _id: 900 }));
print('Partidos en la colección: ' + db.partidos.countDocuments({}));

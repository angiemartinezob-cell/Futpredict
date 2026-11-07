# FutPredict en MongoDB (Unidad 2)

Migración de la base relacional `FutPredictDB` (SQL Server) a la base documental
`futpredict` (MongoDB), siguiendo el mismo proceso del taller del 26 de octubre
(VentasDB → ventas), pero aplicado a los datos del proyecto.

## NoSQL y diferencias con SQL en FutPredict

### ¿Qué es NoSQL?

NoSQL (*Not only SQL*) agrupa los motores que no guardan la información en tablas
relacionadas con un esquema fijo. Los cuatro tipos principales son:

| Tipo | Cómo guarda los datos | Ejemplo |
|---|---|---|
| Documental | Documentos JSON/BSON con campos, arreglos y subdocumentos | **MongoDB** |
| Clave-valor | Una clave y su valor | Redis |
| Columnar | Familias de columnas distribuidas | Cassandra |
| Grafos | Nodos y relaciones | Neo4j |

### ¿Por qué MongoDB para FutPredict?

Un partido es, por naturaleza, un **objeto con partes**: dos equipos con su marcador y sus
estadísticas, una lista de jugadores con su rendimiento y una lista de eventos por minuto.
En SQL Server esa información queda repartida en 7 tablas; en MongoDB cabe en un documento
que se lee completo, que es exactamente lo que necesita la pantalla de un partido.

Además, las estadísticas que se registran pueden cambiar con el tiempo (por ejemplo,
agregar *xG* o kilómetros recorridos): en MongoDB se agrega el campo a los partidos nuevos
sin modificar la estructura de los anteriores, mientras que en SQL Server habría que hacer
`ALTER TABLE`.

### SQL Server frente a MongoDB con ejemplos del proyecto

| Aspecto | SQL Server (Unidad 1) | MongoDB (Unidad 2) |
|---|---|---|
| Estructura | 10 tablas normalizadas | 5 colecciones; partidos con datos incrustados |
| Esquema | Fijo: `CREATE TABLE` | Flexible, controlado con `$jsonSchema` |
| Leer un partido completo | `vw_PartidosDetallados` + JOIN con estadísticas y eventos (7 tablas) | `db.partidos.findOne({ _id: 1 })` |
| Relacionar datos | `JOIN` | Incrustar, o `$lookup` cuando se referencia |
| Integridad | Claves foráneas y `CHECK` (por ejemplo, `CK_Partido_Estado`) | Validador `$jsonSchema` y reglas de la aplicación; no hay claves foráneas |
| Registrar un gol | Transacción: `INSERT` en `EventoPartido` + `UPDATE` en `Partido` (`Transaccion2`) | Un solo `updateOne` con `$push` + `$inc`, atómico por documento |
| Cambiar el nombre de un equipo | Un `UPDATE` en `Equipo` | `updateMany` en equipos, partidos y trayectorias (dato duplicado) |
| Reportes | Vistas, funciones y procedimientos | Aggregation Framework (`$group`, `$unwind`, `$lookup`) |
| Escalamiento | Vertical (servidor más potente) | Horizontal (*sharding*) cuando el volumen lo exige |

**Conclusión:** SQL Server sigue siendo la fuente principal, porque garantiza la integridad
(un jugador solo tiene estadísticas en partidos de su equipo, sin duplicados). MongoDB se usa
como copia orientada a la lectura y al análisis, que es donde su modelo documental rinde más.

## 1. Archivos

| Archivo | Propósito |
|---|---|
| `migracion_sql_a_mongo.py` | ETL: extrae las 10 tablas, las transforma en documentos, las carga y valida conteos y totales |
| `consultas_futpredict.js` | 10 consultas de demostración: `find`, agregación, `$lookup` (simple, con pipeline y sobre arreglos), índices con `explain()` y validación `$jsonSchema` |
| `crud_futpredict.js` | Operaciones CRUD completas: `insertOne`, `find`, `updateOne` (`$set`, `$push`, `$inc`, `$pull`), `updateMany` con `arrayFilters` y `deleteOne` |
| `requirements.txt` | Librerías de Python (`pymongo`, `mssql-python`) |

## 2. Cómo ejecutarlo

```bash
# 1. Tener MongoDB Community Server en ejecución (puerto 27017)
# 2. Desde esta carpeta:
pip install -r requirements.txt
python migracion_sql_a_mongo.py

# 3. Consultas de demostración y operaciones CRUD
mongosh futpredict consultas_futpredict.js
mongosh futpredict crud_futpredict.js
```

`mongosh` es el MongoDB Shell (se instala con `winget install MongoDB.Shell`). La consola
integrada de Compass no admite `load()`, pero se pueden pegar allí los bloques uno por uno.

Con SQL Server Express, antes de ejecutar el script:
`set DB_SERVER=localhost\SQLEXPRESS` (CMD) o `$env:DB_SERVER="localhost\SQLEXPRESS"` (PowerShell).

## 3. Modelo documental

| SQL Server | MongoDB | Estrategia |
|---|---|---|
| `Liga`, `Temporada` | `ligas`, `temporadas` | Colecciones de referencia (pocas filas, casi no cambian) |
| `Equipo` + `EquipoCompeticion` | `equipos.competiciones[]` | **Embedding**: 1 a pocos, se lee junto con el equipo |
| `Jugador` + `JugadorEquipo` | `jugadores.trayectoria[]` | **Embedding**: el historial de clubes se consulta con el jugador |
| `Partido` + `EstadisticaEquipo` | `partidos.local.estadisticas`, `partidos.visitante.estadisticas` | **Embedding**: exactamente 2 por partido |
| `EstadisticaJugador` | `partidos.estadisticas_jugadores[]` | **Embedding** en el partido + **referencing** al jugador (`jugador_id`) |
| `EventoPartido` | `partidos.eventos[]` | **Embedding**: siempre se muestran con el partido |

Ejemplo de documento de `partidos`:

```js
{
  _id: 1,
  fecha: ISODate("2026-09-10"),
  estado: "Finalizado",
  liga: { liga_id: 1, nombre: "LaLiga" },
  temporada: { temporada_id: 2, nombre: "2026/2027" },
  local:     { equipo_id: 1, nombre: "FC Barcelona", goles: 2,
               estadisticas: { posesion: 56, tiros: 14, tiros_arco: 7, ... } },
  visitante: { equipo_id: 2, nombre: "Real Madrid", goles: 1, estadisticas: { ... } },
  estadisticas_jugadores: [
    { jugador_id: 1, equipo_id: 1, minutos_jugados: 90, goles: 2, asistencias: 0,
      calificacion: 8.7, ... }
  ],
  eventos: [ { minuto: 15, tipo: "Gol", equipo_id: 3, jugador_id: 5, ... } ]
}
```

### ¿Por qué las estadísticas de los jugadores van dentro del partido y no dentro del jugador?

- Un partido tiene un número **acotado** de jugadores (22 titulares + suplentes), así que
  el documento nunca se acerca al límite de 16 MB.
- Un jugador, en cambio, acumula partidos **sin límite** temporada tras temporada: si
  incrustáramos sus partidos, el documento crecería indefinidamente.
- La pantalla de un partido necesita todo junto (marcador, estadísticas, eventos) → 1 lectura.
- Los datos personales del jugador se guardan una sola vez en `jugadores` y se traen con
  `$lookup` cuando se necesitan (tabla de goleadores).

### Duplicación controlada

Los nombres de equipo y liga se copian dentro de `partidos` (*patrón de referencia extendida*)
para no hacer `$lookup` en cada consulta. Son datos que casi no cambian; si un equipo cambia
de nombre, hay que actualizarlo en ambos lugares (es el mismo análisis del taller del 19 de
octubre: qué pasa cuando cambia el precio de P1 en los pedidos incrustados).

### Tipos

| SQL Server | MongoDB |
|---|---|
| `int` | `Int32` |
| `date` | `Date` |
| `decimal(5,2)` / `decimal(4,2)` (posesión, calificación) | `Double` (son métricas de análisis, no valores monetarios) |
| `varchar` | `String` |
| `NULL` | `null` |

### Reglas de negocio en MongoDB

Las claves foráneas y los `CHECK` no se trasladan solos. Se conservaron así:

- `$jsonSchema` en `partidos`: estado permitido, goles ≥ 0, calificación entre 0 y 10.
- El script valida que cada estadística de jugador quede asociada a uno de los dos equipos
  del partido (regla de negocio 1).
- Índices en `fecha`, `estadisticas_jugadores.jugador_id`, `local.equipo_id`,
  `visitante.equipo_id` y `trayectoria.equipo_id`.

## 4. Validación esperada (datos iniciales)

| Comprobación | SQL Server | MongoDB |
|---|---|---|
| Ligas / Temporadas / Equipos / Jugadores / Partidos | 6 / 2 / 10 / 20 / 5 | 6 / 2 / 10 / 20 / 5 documentos |
| EquipoCompeticion | 10 filas | 10 elementos incrustados |
| JugadorEquipo | 20 filas | 20 elementos incrustados |
| EstadisticaJugador | 20 filas | 20 elementos incrustados |
| EstadisticaEquipo | 10 filas | 10 subdocumentos |
| Total de goles | 17 | 17 |

Si ya se ejecutaron las transacciones de la Unidad 1, aparecerá además el partido 7 con sus
eventos y los valores cambiarán; lo importante es que ambas columnas coincidan.

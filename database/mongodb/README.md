# FutPredict en MongoDB (Unidad 2)

Migración de la base relacional `FutPredictDB` (SQL Server) a la base documental
`futpredict` (MongoDB), siguiendo el mismo proceso del taller del 26 de octubre
(VentasDB → ventas), pero aplicado a los datos del proyecto.

## 1. Archivos

| Archivo | Propósito |
|---|---|
| `migracion_sql_a_mongo.py` | ETL: extrae las 10 tablas, las transforma en documentos, las carga y valida conteos y totales |
| `consultas_futpredict.js` | 10 consultas de demostración: `find`, agregación, `$lookup` (simple, con pipeline y sobre arreglos), índices con `explain()` y validación `$jsonSchema` |
| `requirements.txt` | Librerías de Python (`pymongo`, `mssql-python`) |

## 2. Cómo ejecutarlo

```bash
# 1. Tener MongoDB Community Server en ejecución (puerto 27017)
# 2. Desde esta carpeta:
pip install -r requirements.txt
python migracion_sql_a_mongo.py

# 3. Consultas de demostración
mongosh futpredict consultas_futpredict.js
```

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

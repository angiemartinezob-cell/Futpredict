# FutPredict

## Participantes y roles

| Participante | Usuario de GitHub | Rol / responsabilidad actual |
|---|---|---|
| Angie Sofia Martínez Obando | `angiemartinezob-cell` | Modelamiento de la base de datos, consultas multitabla (JOINs), vistas y funciones |
| Julissa Fernanda Murillo Zapata | `Jullsm038` | Procedimientos almacenados y transacciones |
| Obed Arango Ricardo | `obedarangori-art` | Triggers, CTE/recursividad y control de concurrencia|


## Descripción y alcance del problema

En el fútbol se genera una gran cantidad de información durante los partidos y las temporadas, como datos de jugadores, equipos, resultados y diferentes estadísticas de rendimiento. Aunque esta información puede ser muy útil, cuando se encuentra dispersa o no está organizada de una forma adecuada, puede ser más difícil analizarla, comparar jugadores y aprovechar los datos históricos para encontrar patrones.

FutPredict busca reunir y organizar esta información para facilitar su consulta y análisis. El proyecto tendrá en cuenta datos relacionados con jugadores, equipos, partidos, temporadas y estadísticas de rendimiento. Con esta información se podrán generar indicadores, hacer comparaciones y analizar cómo ha evolucionado el rendimiento de los jugadores y los equipos.

Como parte del alcance del proyecto, también se integrarán diferentes formas de almacenamiento y análisis de datos trabajadas durante el curso, incluyendo una base de datos relacional (SQL Server) y una base de datos NoSQL (MongoDB). A partir de los datos históricos se podrá estudiar posteriormente la incorporación de modelos predictivos para estimar el rendimiento de los jugadores en próximos partidos.

La información obtenida estará orientada a apoyar a entrenadores y analistas en el seguimiento y comparación de jugadores y en la toma de decisiones deportivas. Las posibles predicciones funcionarían como apoyo para el análisis y no buscarían reemplazar la decisión de los profesionales.


## Posibles usuarios del sistema

- **Entrenador:** consulta el rendimiento de los jugadores y equipos para apoyar decisiones deportivas.
- **Analista deportivo:** analiza estadísticas, compara jugadores y busca patrones de rendimiento.
- **Preparador físico:** consulta información sobre el rendimiento de los jugadores para hacer seguimiento a su evolución.
- **Administrador:** gestiona la información y el funcionamiento general del sistema.


## Entidades actuales

Actualmente, el modelo relacional de FutPredictDB está compuesto por las siguientes entidades:

- Liga
- Temporada
- Equipo
- Jugador
- Partido
- JugadorEquipo
- EquipoCompeticion
- EstadisticaJugador
- EstadisticaEquipo
- EventoPartido
- Auditoria (registro de cambios generado por los triggers)


## Reglas de negocio

1. **Registro de estadísticas:** un jugador solo puede tener estadísticas registradas en partidos en los que participe y esté relacionado con uno de los equipos involucrados en el encuentro.

2. **Relación entre partido, liga y temporada:** cada partido debe estar asociado a una liga y a una temporada específica, ya que esta información es necesaria para organizar y comparar correctamente los datos históricos.

3. **Un solo registro de estadísticas por jugador y partido:** no se pueden registrar dos conjuntos de estadísticas para un mismo jugador en el mismo partido, con el fin de evitar duplicados que puedan afectar los resultados de los análisis.

4. **Un solo registro de estadísticas por equipo y partido:** cada equipo puede tener solamente un registro de estadísticas asociado a un mismo partido.

5. **Valores válidos en las estadísticas:** los valores registrados para goles, tiros, asistencias, faltas, tarjetas y demás estadísticas numéricas deben ser iguales o mayores a cero.

6. **Equipos diferentes en un partido:** un equipo no puede aparecer al mismo tiempo como local y visitante en un mismo partido.

7. **Rangos válidos:** la posesión debe encontrarse entre 0 y 100 y la calificación de un jugador entre 0 y 10.

8. **Historial de jugadores:** la relación entre jugador y equipo se administra mediante la entidad `JugadorEquipo`, permitiendo conservar información del equipo y temporada a la que perteneció un jugador.


## ¿Por qué consideramos que el proyecto es suficientemente complejo?

Consideramos que FutPredict es un proyecto complejo porque no se enfoca solamente en guardar información, sino también en organizarla, relacionarla, validarla y analizarla usando diferentes herramientas.

Durante la primera unidad se trabaja con SQL Server para administrar la información principal mediante un modelo relacional compuesto por diferentes entidades relacionadas entre sí. Sobre esta estructura se implementan consultas multitabla, vistas, funciones, procedimientos almacenados, transacciones, triggers y otros mecanismos propios de SQL Server.

En la segunda unidad el proyecto se amplió con MongoDB: la información se migró a un modelo documental y se consulta con el Aggregation Framework desde la misma aplicación.

A medida que exista suficiente información histórica también se podrá estudiar la incorporación de modelos predictivos orientados al rendimiento deportivo.

Todo esto hace necesario conectar diferentes componentes y garantizar que la información almacenada sea consistente, válida y útil para el análisis.


## Avance actual - Unidad 1

Durante la primera unidad se ha desarrollado la base de datos relacional de FutPredict en Microsoft SQL Server.

Actualmente se cuenta con:

- Modelamiento y normalización de la base de datos.
- Inserción de datos de prueba.
- Consultas multitabla mediante `INNER JOIN` y `LEFT JOIN`.
- Vistas para consultar partidos y rendimiento.
- Funciones escalares y funciones con valor de tabla.
- Procedimientos almacenados.
- Transacciones con control de errores.
- Triggers para auditoría y aplicación de reglas de negocio.
- CTE y consultas recursivas.
- Control de concurrencia y niveles de aislamiento.

El proyecto podrá ajustarse y ampliarse a medida que avancen las siguientes unidades del curso.

Los scripts deben ejecutarse en el orden indicado en [`database/ORDEN_EJECUCION.md`](database/ORDEN_EJECUCION.md).


## Avance actual - Unidad 2 (NoSQL y MongoDB)

La información de `FutPredictDB` se migró a una base documental `futpredict` en MongoDB
mediante un proceso ETL en Python. El diseño y las decisiones están documentados en
[`database/mongodb/README.md`](database/mongodb/README.md).

- **Modelado documental:** colecciones `partidos`, `jugadores`, `equipos`, `ligas` y `temporadas`.
- **Embedding:** estadísticas de equipo, estadísticas de jugadores y eventos dentro de cada partido;
  trayectoria de clubes dentro de cada jugador; competiciones dentro de cada equipo.
- **Referencing:** cada estadística de jugador guarda `jugador_id`, que se resuelve con `$lookup`.
- **Migración validada:** conteos de filas frente a documentos y totales de goles en ambos motores.
- **Consultas avanzadas:** `find` con operadores, Aggregation Framework (`$match`, `$unwind`,
  `$group`, `$project`, `$addFields`, `$sort`), `$lookup` simple, con pipeline y sobre arreglos.
- **Optimización y reglas:** índices revisados con `explain()` y validación con `$jsonSchema`.
- **Integración con la aplicación:** la sección *Análisis* consulta MongoDB a través de la API.


## Arquitectura de la aplicación

```text
SQL Server (FutPredictDB) ──► API Node.js/Express ──► React (Vite)
        │                          ▲
        └── ETL Python ──► MongoDB (futpredict)
```

| Ruta de la API | Fuente | Objeto de base de datos utilizado |
|---|---|---|
| `GET /api/resumen` | SQL Server | Subconsultas de conteo |
| `GET /api/equipos` | SQL Server | Tabla `Equipo` |
| `GET /api/jugadores` | SQL Server | CTE + `JugadorEquipo` + `fn_PromedioCalificacionJugador` + `fn_TotalContribucionesJugador` |
| `GET /api/jugadores/:id/rendimiento` | SQL Server | `sp_ObtenerRendimientoJugador` + `fn_HistorialJugador` |
| `GET /api/partidos` | SQL Server | Vista `vw_PartidosDetallados` |
| `GET /api/ligas` | SQL Server | Subconsultas correlacionadas sobre `Liga` |
| `GET /api/estadisticas/equipos` | SQL Server | Vista `vw_RendimientoEquipos` |
| `GET /api/mongo/goleadores` | MongoDB | `$unwind` + `$group` + `$lookup` |
| `GET /api/mongo/ligas` | MongoDB | `$group` + `$project` |


## Cómo ejecutar el proyecto

**Requisitos:** SQL Server (Developer o Express), SSMS, ODBC Driver 18 for SQL Server,
Node.js, y para la Unidad 2: MongoDB Community Server, MongoDB Compass y Python 3.

1. **Base de datos:** ejecutar los scripts según [`database/ORDEN_EJECUCION.md`](database/ORDEN_EJECUCION.md).
2. **Backend:**
   ```bash
   cd futpredict-frontend/backend
   copy .env.example .env        # en Windows; ajustar DB_SERVER si se usa SQLEXPRESS
   npm install
   npm install mongodb           # solo para las rutas de la Unidad 2
   npm run probar-conexion       # debe mostrar: Equipos registrados: 10
   npm start                     # http://localhost:3001/api
   ```
3. **Frontend** (en otra terminal):
   ```bash
   cd futpredict-frontend
   npm install
   npm run dev
   ```
4. **MongoDB (Unidad 2):** ver [`database/mongodb/README.md`](database/mongodb/README.md).


## Flujo de trabajo en Git

- `main` está protegida: los cambios entran solo mediante *pull request* aprobado por otro integrante.
- Cada integrante trabaja en su rama (`angie`, `julissa`, `Obed`) y abre un *pull request* hacia `main`.
- Commits pequeños y descriptivos, de uno a dos por integrante cada semana.


## Uso de IA

Durante el desarrollo de FutPredict utilizaremos herramientas de inteligencia artificial como apoyo para resolver dudas, entender algunos conceptos, buscar ideas y revisar código o documentación.

También podremos apoyarnos en la IA para algunas partes del análisis de datos y, posteriormente, para explorar posibles modelos predictivos.

Antes de utilizar cualquier resultado generado mediante inteligencia artificial, este será revisado y validado por los integrantes del equipo para comprobar que tenga sentido dentro del proyecto.

La IA será una herramienta de apoyo, pero el desarrollo, las decisiones de diseño y la validación del proyecto serán realizados y revisados por los integrantes del equipo.

### Metodología de desarrollo con IA

1. **Contexto primero:** antes de pedir código se comparte el estado real del proyecto
   (scripts SQL, estructura de tablas, archivos existentes).
2. **Cambios pequeños:** la IA propone un cambio a la vez, indicando el archivo y la sección
   exacta que se modifica, sin rehacer archivos completos.
3. **Verificación humana:** cada consulta se ejecuta en SSMS o MongoDB Compass y cada ruta de
   la API se prueba en el navegador antes de hacer commit.
4. **Trazabilidad:** los commits en los que participó un asistente de IA lo indican en el mensaje.

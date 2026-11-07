# Orden de ejecución de los scripts de SQL Server

Los scripts de la Unidad 1 quedaron repartidos entre las ramas de cada integrante
(`angie`, `julissa`, `Obed`). Esta guía indica en qué orden ejecutarlos en SSMS para
que **todos los computadores tengan exactamente los mismos objetos** (tablas, vistas,
funciones, procedimientos y triggers) que necesita la API.

> Si en tu computador ya existe `FutPredictDB`, puedes empezar desde el paso 2.
> Todos los objetos usan `CREATE OR ALTER`, así que volver a ejecutarlos no genera errores.

| Paso | Archivo | Qué crea | ¿Lo usa la API? |
|---|---|---|---|
| 1 | `FutPredictDB.sql` | Base de datos, 10 tablas, restricciones y datos de prueba | Sí |
| 2 | `VISTAS.sql` | `vw_PartidosDetallados`, `vw_RendimientoJugadores`, `vw_RendimientoEquipos` | Sí |
| 3 | `Funciones.sql` | `fn_PromedioCalificacionJugador`, `fn_HistorialJugador`, `fn_TotalContribucionesJugador` (la 2 depende de la vista `vw_RendimientoJugadores`) | Sí |
| 4 | `Procedimiento2_ObtenerRendimientoJugador.sql` | `sp_ObtenerRendimientoJugador` | Sí |
| 5 | `database/Trigger/triggers.sql` | Tabla `Auditoria` y 4 triggers | No (actúan solos) |
| 6 | `Procedimiento1_InsertarEstadisticaJugador.sql` y `Procedimiento3_ActualizarResultadoPartido.sql` | Procedimientos de escritura | No, por ahora |
| 7 | `Transaccion1_RegistrarPartidoCompleto.sql` y luego `Transaccion2_RegistrarEventoPartido.sql` | Partido 7 (City vs Liverpool) y sus eventos | — |
| 8 | `JOIN.sql`, `database/CTE/cte_normal_y_recursiva.sql`, `database/Concurrencia/concurrencia.sql`, `Pruebas_Trigger/...` | Consultas de demostración (no crean objetos) | No |

## Cuidados al ejecutar las pruebas

- **Los bloques de prueba modifican datos.** Por ejemplo, la prueba de
  `Procedimiento3_ActualizarResultadoPartido.sql` cambia el marcador del partido 1 a 3-1,
  y `prueba1-update-.sql` cambia los goles de la estadística 1 a 4. Después de eso, el
  marcador ya no coincide con las estadísticas. Para la sustentación conviene ejecutar
  solo la parte `CREATE OR ALTER` de cada archivo, o volver a crear la base con el paso 1.
- La prueba válida de `Procedimiento1` usa el partido 7, que solo existe después de
  ejecutar `Transaccion1` (paso 7). Por eso los procedimientos se crean en el paso 6,
  pero su prueba debe ejecutarse después del paso 7.
- Los triggers deben existir **antes** de las transacciones para que la tabla
  `Auditoria` registre la creación del partido 7.

## Verificación rápida

Después de ejecutar los pasos 1 a 4, esta consulta debe devolver 7 filas:

```sql
USE FutPredictDB;
SELECT name, type_desc
FROM sys.objects
WHERE name IN ('vw_PartidosDetallados', 'vw_RendimientoJugadores', 'vw_RendimientoEquipos',
               'fn_PromedioCalificacionJugador', 'fn_HistorialJugador',
               'fn_TotalContribucionesJugador', 'sp_ObtenerRendimientoJugador');
```

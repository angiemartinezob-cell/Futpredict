# Futpredict

## Participantes y roles iniciales

| Participante | Usuario de GitHub | Rol inicial |
|---|---|---|
| Angie Sofia Martínez Obando | `angiemartinezob` | Por definir |
| Julissa Fernanda Murillo Zapata | `Jullsm038` | Por definir |
| Obed Arango Ricardo | `obedarangori` | Por definir |


## Descripción y alcance del problema

En el fútbol se genera una gran cantidad de información durante los partidos y las temporadas, como datos de jugadores, equipos, resultados y diferentes estadísticas de rendimiento. Aunque esta información puede ser muy útil, cuando se encuentra dispersa o no está organizada de una forma adecuada, puede ser más difícil analizarla, comparar jugadores y aprovechar los datos históricos para encontrar patrones.

FutPredict busca reunir y organizar esta información para facilitar su consulta y análisis. El proyecto tendrá en cuenta datos relacionados con jugadores, equipos, partidos, temporadas y estadísticas de rendimiento. Con esta información se podrán generar indicadores, hacer comparaciones y analizar cómo ha evolucionado el rendimiento de los jugadores y los equipos.

Como parte del alcance del proyecto, también se integrarán diferentes formas de almacenamiento y análisis de datos trabajadas durante el curso, incluyendo una base de datos relacional, una base de datos NoSQL y una estructura orientada al análisis de información. A partir de los datos históricos se incorporará un modelo predictivo para estimar el rendimiento de los jugadores en próximos partidos.

La información obtenida estará orientada a apoyar a entrenadores y analistas en el seguimiento y comparación de jugadores y en la toma de decisiones deportivas. La predicción será un apoyo para el análisis y no busca reemplazar la decisión de los profesionales.

## Posibles usuarios del sistema

- **Entrenador:** consulta el rendimiento de los jugadores y las predicciones para apoyar decisiones deportivas.
- **Analista deportivo:** analiza estadísticas, compara jugadores y busca patrones de rendimiento.
- **Preparador físico:** consulta información sobre el rendimiento de los jugadores para hacer seguimiento a su evolución.
- **Administrador:** gestiona la información y el funcionamiento general del sistema.


## Entidades preliminares

- Jugador
- Equipo
- Partido
- Competencia
- Temporada
- Posición
- Estadística
- Entrenamiento
- Usuario
- Predicción

  
## Reglas de negocio

1. **Registro de estadísticas:** un jugador solo puede tener estadísticas registradas en partidos en los que haya participado o haya sido convocado. Esto permite evitar información asociada a jugadores que no hicieron parte del encuentro.

2. **Relación entre partido, competencia y temporada:** cada partido debe estar asociado a una competencia y a una temporada específica, ya que esta información es necesaria para organizar y comparar correctamente los datos históricos.

3. **Un solo registro de estadísticas por jugador y partido:** no se pueden registrar dos conjuntos de estadísticas para un mismo jugador en el mismo partido, con el fin de evitar duplicados que puedan afectar los resultados de los análisis.

4. **Valores válidos en las estadísticas:** los valores registrados para las estadísticas de los jugadores deben ser iguales o mayores a cero, evitando datos que no tengan sentido dentro del contexto del sistema.

5. **Información disponible para las predicciones:** las predicciones del rendimiento de un jugador deben utilizar únicamente información disponible antes del partido que se desea analizar, para evitar que datos posteriores afecten el resultado de la predicción.

## ¿Por qué consideramos que el proyecto es suficientemente complejo?

Consideramos que FutPredict es un proyecto complejo porque no se enfoca solamente en guardar información, sino también en organizarla, integrarla y analizarla usando diferentes herramientas.

Durante el proyecto se trabajará con SQL Server para manejar la información principal, MongoDB para almacenar otro tipo de datos y herramientas de análisis para poder consultar y visualizar la información. También se tendrán en cuenta el Data Warehouse, el Data Mart y el Data Lake para trabajar con los datos desde diferentes enfoques.

Además, el proyecto incluirá un modelo predictivo que utilizará los datos históricos para estimar el rendimiento de los jugadores. Todo esto hace que tengamos que conectar varias partes y cuidar que la información sea correcta y útil para el análisis.

## Uso de IA

Durante el desarrollo de FutPredict utilizaremos herramientas de inteligencia artificial como apoyo para resolver dudas, entender algunos conceptos, buscar ideas y revisar código o documentación.

También podremos apoyarnos en la IA para algunas partes del análisis de datos y del modelo predictivo. Antes de utilizar cualquier resultado, lo revisaremos y comprobaremos que tenga sentido para el proyecto.

La IA será una herramienta de apoyo, pero el desarrollo y las decisiones del proyecto serán realizados y revisados por los integrantes del equipo.

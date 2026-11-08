"""
FutPredict - Migración de SQL Server (FutPredictDB) a MongoDB (futpredict)
==========================================================================

Unidad 2 - Bases de Datos Avanzadas.

Proceso ETL:
  E  Extracción:     se leen las 10 tablas de FutPredictDB.
  T  Transformación: las filas se convierten en documentos (embedding / referencing).
  L  Carga:          se insertan en MongoDB, se crean validación ($jsonSchema) e índices.
  +  Validación:     se comparan conteos y totales entre SQL Server y MongoDB.

Uso (desde la carpeta database/mongodb):
    pip install -r requirements.txt
    python migracion_sql_a_mongo.py

Variables de entorno opcionales (mismos nombres que backend/.env):
    DB_SERVER    (por defecto: localhost; con Express: localhost\\SQLEXPRESS)
    DB_DATABASE  (por defecto: FutPredictDB)
    MONGO_URI    (por defecto: mongodb://localhost:27017)
    MONGO_DB     (por defecto: futpredict)

El script es repetible: borra y vuelve a crear las colecciones en cada ejecución.
La base de SQL Server solo se lee; nunca se modifica.
"""

import os
from datetime import date, datetime
from decimal import Decimal

TABLAS = [
    "Liga", "Temporada", "Equipo", "Jugador", "Partido", "JugadorEquipo",
    "EquipoCompeticion", "EstadisticaJugador", "EstadisticaEquipo", "EventoPartido",
]


# ---------------------------------------------------------------------------
# Conversión de tipos SQL Server -> BSON
# ---------------------------------------------------------------------------
def a_bson(valor):
    """date -> datetime (BSON Date), decimal -> double, el resto sin cambios."""
    if isinstance(valor, datetime):
        return valor
    if isinstance(valor, date):
        return datetime(valor.year, valor.month, valor.day)
    if isinstance(valor, Decimal):
        return float(valor)
    return valor


def limpiar(fila):
    """Convierte los tipos de una fila (dict)."""
    return {campo: a_bson(valor) for campo, valor in fila.items()}


# ---------------------------------------------------------------------------
# E - Extracción
# ---------------------------------------------------------------------------
def conectar_sql_server():
    servidor = os.getenv("DB_SERVER", "localhost")
    base = os.getenv("DB_DATABASE", "FutPredictDB")
    try:
        # Controlador usado en clase (no necesita ODBC aparte)
        from mssql_python import connect
        cadena = (
            f"Server={servidor};Database={base};"
            "Trusted_Connection=yes;Encrypt=yes;TrustServerCertificate=yes;"
        )
        return connect(cadena)
    except ImportError:
        # Alternativa: pyodbc con el mismo ODBC Driver 18 que usa el backend
        import pyodbc
        cadena = (
            "Driver={ODBC Driver 18 for SQL Server};"
            f"Server={servidor};Database={base};"
            "Trusted_Connection=yes;Encrypt=yes;TrustServerCertificate=yes;"
        )
        return pyodbc.connect(cadena)


def extraer_tablas(conexion):
    """Devuelve {nombre_tabla: [filas como dict]}."""
    tablas = {}
    cursor = conexion.cursor()
    for tabla in TABLAS:
        cursor.execute(f"SELECT * FROM dbo.{tabla}")
        columnas = [col[0] for col in cursor.description]
        tablas[tabla] = [limpiar(dict(zip(columnas, fila))) for fila in cursor.fetchall()]
        print(f"  {tabla:<20} {len(tablas[tabla]):>4} filas")
    cursor.close()
    return tablas


# ---------------------------------------------------------------------------
# T - Transformación (modelado documental)
# ---------------------------------------------------------------------------
def agrupar(filas, campo):
    grupos = {}
    for fila in filas:
        grupos.setdefault(fila[campo], []).append(fila)
    return grupos


def construir_documentos(t):
    """
    Recibe las tablas extraídas y devuelve {coleccion: [documentos]}.

    Decisiones de diseño (ver database/mongodb/README.md):
      - ligas, temporadas: colecciones pequeñas de referencia.
      - equipos: incrusta sus competiciones (EquipoCompeticion) -> relación 1 a pocos.
      - jugadores: incrusta su trayectoria (JugadorEquipo) -> 1 a pocos, se lee con el jugador.
      - partidos: incrusta estadísticas de equipo, de jugadores y eventos -> siempre se leen
        con el partido y su tamaño está acotado (~22 jugadores, decenas de eventos).
        Los jugadores se REFERENCIAN (jugador_id) porque se consultan por separado
        y sus partidos crecerían sin límite si se incrustaran en el jugador.
    """
    ligas = {l["liga_id"]: l for l in t["Liga"]}
    temporadas = {x["temporada_id"]: x for x in t["Temporada"]}
    equipos = {e["equipo_id"]: e for e in t["Equipo"]}

    competiciones = agrupar(t["EquipoCompeticion"], "equipo_id")
    trayectorias = agrupar(t["JugadorEquipo"], "jugador_id")
    est_jugadores = agrupar(t["EstadisticaJugador"], "partido_id")
    est_equipos = agrupar(t["EstadisticaEquipo"], "partido_id")
    eventos = agrupar(t["EventoPartido"], "partido_id")

    def nombre(diccionario, clave):
        fila = diccionario.get(clave)
        return fila["nombre"] if fila else None

    docs = {}

    docs["ligas"] = [
        {"_id": l["liga_id"], "nombre": l["nombre"], "pais": l["pais"], "tipo": l["tipo"]}
        for l in t["Liga"]
    ]

    docs["temporadas"] = [
        {"_id": x["temporada_id"], "nombre": x["nombre"],
         "fecha_inicio": x["fecha_inicio"], "fecha_fin": x["fecha_fin"]}
        for x in t["Temporada"]
    ]

    docs["equipos"] = [
        {
            "_id": e["equipo_id"],
            "nombre": e["nombre"],
            "pais": e["pais"],
            "competiciones": [
                {
                    "liga_id": c["liga_id"],
                    "liga": nombre(ligas, c["liga_id"]),
                    "temporada_id": c["temporada_id"],
                    "temporada": nombre(temporadas, c["temporada_id"]),
                }
                for c in competiciones.get(e["equipo_id"], [])
            ],
        }
        for e in t["Equipo"]
    ]

    docs["jugadores"] = [
        {
            "_id": j["jugador_id"],
            "nombre": j["nombre"],
            "fecha_nacimiento": j["fecha_nacimiento"],
            "posicion": j["posicion"],
            "trayectoria": [
                {
                    "equipo_id": je["equipo_id"],
                    "equipo": nombre(equipos, je["equipo_id"]),
                    "temporada_id": je["temporada_id"],
                    "temporada": nombre(temporadas, je["temporada_id"]),
                    "fecha_inicio": je["fecha_inicio"],
                    "fecha_fin": je["fecha_fin"],
                }
                for je in sorted(trayectorias.get(j["jugador_id"], []),
                                 key=lambda r: r["fecha_inicio"])
            ],
        }
        for j in t["Jugador"]
    ]

    def estadisticas_equipo(partido_id, equipo_id):
        for fila in est_equipos.get(partido_id, []):
            if fila["equipo_id"] == equipo_id:
                return {
                    "posesion": fila["posesion"],
                    "tiros": fila["tiros"],
                    "tiros_arco": fila["tiros_arco"],
                    "corners": fila["corners"],
                    "faltas": fila["faltas"],
                    "tarjetas_amarillas": fila["tarjetas_amarillas"],
                    "tarjetas_rojas": fila["tarjetas_rojas"],
                }
        return None

    def equipo_del_jugador(jugador_id, partido):
        """Equipo (local o visitante) al que pertenecía el jugador en esa temporada."""
        for je in trayectorias.get(jugador_id, []):
            if (je["temporada_id"] == partido["temporada_id"]
                    and je["equipo_id"] in (partido["equipo_local_id"],
                                            partido["equipo_visitante_id"])):
                return je["equipo_id"]
        return None

    docs["partidos"] = []
    for p in t["Partido"]:
        pid = p["partido_id"]
        docs["partidos"].append({
            "_id": pid,
            "fecha": p["fecha"],
            "estado": p["estado"],
            "liga": {"liga_id": p["liga_id"], "nombre": nombre(ligas, p["liga_id"])},
            "temporada": {"temporada_id": p["temporada_id"],
                          "nombre": nombre(temporadas, p["temporada_id"])},
            "local": {
                "equipo_id": p["equipo_local_id"],
                "nombre": nombre(equipos, p["equipo_local_id"]),
                "goles": p["goles_local"],
                "estadisticas": estadisticas_equipo(pid, p["equipo_local_id"]),
            },
            "visitante": {
                "equipo_id": p["equipo_visitante_id"],
                "nombre": nombre(equipos, p["equipo_visitante_id"]),
                "goles": p["goles_visitante"],
                "estadisticas": estadisticas_equipo(pid, p["equipo_visitante_id"]),
            },
            "estadisticas_jugadores": [
                {
                    "estadistica_id": ej["estadistica_id"],
                    "jugador_id": ej["jugador_id"],          # referencia a jugadores._id
                    "equipo_id": equipo_del_jugador(ej["jugador_id"], p),
                    "minutos_jugados": ej["minutos_jugados"],
                    "goles": ej["goles"],
                    "asistencias": ej["asistencias"],
                    "tiros": ej["tiros"],
                    "tiros_arco": ej["tiros_arco"],
                    "pases_completados": ej["pases_completados"],
                    "recuperaciones": ej["recuperaciones"],
                    "faltas_cometidas": ej["faltas_cometidas"],
                    "tarjetas_amarillas": ej["tarjetas_amarillas"],
                    "tarjetas_rojas": ej["tarjetas_rojas"],
                    "calificacion": ej["calificacion"],
                }
                for ej in est_jugadores.get(pid, [])
            ],
            "eventos": [
                {
                    "evento_id": ev["evento_id"],
                    "minuto": ev["minuto"],
                    "tipo": ev["tipo_evento"],
                    "equipo_id": ev["equipo_id"],
                    "jugador_id": ev["jugador_id"],
                    "descripcion": ev["descripcion"],
                }
                for ev in sorted(eventos.get(pid, []), key=lambda r: r["minuto"])
            ],
        })

    return docs


# ---------------------------------------------------------------------------
# L - Carga
# ---------------------------------------------------------------------------
VALIDADOR_PARTIDOS = {
    "$jsonSchema": {
        "bsonType": "object",
        "required": ["_id", "fecha", "estado", "local", "visitante"],
        "properties": {
            "fecha": {"bsonType": "date"},
            "estado": {"enum": ["Programado", "En juego", "Finalizado", "Suspendido"]},
            "local": {
                "bsonType": "object",
                "required": ["equipo_id", "goles"],
                "properties": {"goles": {"bsonType": "int", "minimum": 0}},
            },
            "visitante": {
                "bsonType": "object",
                "required": ["equipo_id", "goles"],
                "properties": {"goles": {"bsonType": "int", "minimum": 0}},
            },
            "estadisticas_jugadores": {
                "bsonType": "array",
                "items": {
                    "bsonType": "object",
                    "required": ["jugador_id", "goles", "asistencias"],
                    "properties": {
                        "goles": {"bsonType": "int", "minimum": 0},
                        "asistencias": {"bsonType": "int", "minimum": 0},
                        "calificacion": {"bsonType": ["double", "null"],
                                         "minimum": 0, "maximum": 10},
                    },
                },
            },
        },
    }
}


def cargar(db, docs):
    for nombre_coleccion in docs:
        db.drop_collection(nombre_coleccion)

    # Reglas de negocio trasladadas a MongoDB: estado válido, goles >= 0, calificación 0-10
    db.create_collection("partidos", validator=VALIDADOR_PARTIDOS)

    for nombre_coleccion, documentos in docs.items():
        if documentos:
            db[nombre_coleccion].insert_many(documentos)
        print(f"  {nombre_coleccion:<12} {len(documentos):>4} documentos")

    # Índices para los campos que filtran, ordenan o enlazan con $lookup
    db.partidos.create_index([("fecha", -1)])
    db.partidos.create_index([("estadisticas_jugadores.jugador_id", 1)])
    db.partidos.create_index([("local.equipo_id", 1)])
    db.partidos.create_index([("visitante.equipo_id", 1)])
    db.jugadores.create_index([("trayectoria.equipo_id", 1)])


# ---------------------------------------------------------------------------
# Validación SQL Server vs MongoDB
# ---------------------------------------------------------------------------
def valor_sql(conexion, consulta):
    cursor = conexion.cursor()
    cursor.execute(consulta)
    valor = cursor.fetchone()[0]
    cursor.close()
    return int(valor or 0)


def valor_mongo(coleccion, pipeline):
    resultado = list(coleccion.aggregate(pipeline))
    return int(resultado[0]["n"]) if resultado else 0


def contar_arreglo(campo):
    return [{"$unwind": f"${campo}"}, {"$count": "n"}]


def validar(conexion, db):
    p = db.partidos
    comprobaciones = [
        ("Ligas", "SELECT COUNT(*) FROM Liga", db.ligas.count_documents({})),
        ("Temporadas", "SELECT COUNT(*) FROM Temporada", db.temporadas.count_documents({})),
        ("Equipos", "SELECT COUNT(*) FROM Equipo", db.equipos.count_documents({})),
        ("Jugadores", "SELECT COUNT(*) FROM Jugador", db.jugadores.count_documents({})),
        ("Partidos", "SELECT COUNT(*) FROM Partido", p.count_documents({})),
        ("EquipoCompeticion (incrustado)", "SELECT COUNT(*) FROM EquipoCompeticion",
         valor_mongo(db.equipos, contar_arreglo("competiciones"))),
        ("JugadorEquipo (incrustado)", "SELECT COUNT(*) FROM JugadorEquipo",
         valor_mongo(db.jugadores, contar_arreglo("trayectoria"))),
        ("EstadisticaJugador (incrustado)", "SELECT COUNT(*) FROM EstadisticaJugador",
         valor_mongo(p, contar_arreglo("estadisticas_jugadores"))),
        ("EstadisticaEquipo (incrustado)", "SELECT COUNT(*) FROM EstadisticaEquipo",
         p.count_documents({"local.estadisticas": {"$ne": None}})
         + p.count_documents({"visitante.estadisticas": {"$ne": None}})),
        ("EventoPartido (incrustado)", "SELECT COUNT(*) FROM EventoPartido",
         valor_mongo(p, contar_arreglo("eventos"))),
        ("Total goles de partidos", "SELECT SUM(goles_local + goles_visitante) FROM Partido",
         valor_mongo(p, [{"$group": {"_id": None,
                                     "n": {"$sum": {"$add": ["$local.goles",
                                                             "$visitante.goles"]}}}}])),
        ("Total goles de jugadores", "SELECT SUM(goles) FROM EstadisticaJugador",
         valor_mongo(p, [{"$unwind": "$estadisticas_jugadores"},
                         {"$group": {"_id": None,
                                     "n": {"$sum": "$estadisticas_jugadores.goles"}}}])),
    ]

    print(f"\n  {'Comprobación':<34}{'SQL Server':>11}{'MongoDB':>10}  Resultado")
    print("  " + "-" * 66)
    todo_ok = True
    for descripcion, consulta, en_mongo in comprobaciones:
        en_sql = valor_sql(conexion, consulta)
        ok = en_sql == en_mongo
        todo_ok = todo_ok and ok
        print(f"  {descripcion:<34}{en_sql:>11}{en_mongo:>10}  {'OK' if ok else 'DIFERENTE'}")

    sin_equipo = valor_mongo(p, [
        {"$unwind": "$estadisticas_jugadores"},
        {"$match": {"estadisticas_jugadores.equipo_id": None}},
        {"$count": "n"},
    ])
    if sin_equipo:
        todo_ok = False
        print(f"\n  Atención: {sin_equipo} estadísticas de jugador sin equipo asociado "
              "(revisar JugadorEquipo).")
    return todo_ok


# ---------------------------------------------------------------------------
def main():
    from pymongo import MongoClient

    print("1. Extrayendo datos de SQL Server...")
    conexion = conectar_sql_server()
    tablas = extraer_tablas(conexion)

    print("\n2. Transformando filas en documentos...")
    docs = construir_documentos(tablas)

    print("\n3. Cargando en MongoDB...")
    cliente = MongoClient(os.getenv("MONGO_URI", "mongodb://localhost:27017"))
    db = cliente[os.getenv("MONGO_DB", "futpredict")]
    cargar(db, docs)

    print("\n4. Validando la migración...")
    ok = validar(conexion, db)
    print("\nMigración validada correctamente." if ok
          else "\nLa validación encontró diferencias: revisar antes de usar los datos.")

    conexion.close()
    cliente.close()


if __name__ == "__main__":
    main()

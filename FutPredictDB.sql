CREATE DATABASE FutPredictDB;

USE FutPredictDB;


CREATE TABLE Equipo (
    equipo_id INT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    pais VARCHAR(50) NOT NULL,
    liga VARCHAR(100) NOT NULL
);

CREATE TABLE Jugador (
    jugador_id INT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    fecha_nacimiento DATE NOT NULL,
    posicion VARCHAR(50) NOT NULL,
    equipo_id INT NOT NULL,
    FOREIGN KEY (equipo_id) REFERENCES Equipo(equipo_id)
);

CREATE TABLE Partido (
    partido_id INT PRIMARY KEY,
    fecha DATE NOT NULL,
    competencia VARCHAR(100) NOT NULL,
    temporada VARCHAR(20) NOT NULL,
    equipo_local_id INT NOT NULL,
    equipo_visitante_id INT NOT NULL,
    goles_local INT NOT NULL,
    goles_visitante INT NOT NULL,
    FOREIGN KEY (equipo_local_id) REFERENCES Equipo(equipo_id),
    FOREIGN KEY (equipo_visitante_id) REFERENCES Equipo(equipo_id)
);

CREATE TABLE EstadisticaJugador (
    estadistica_id INT PRIMARY KEY,
    partido_id INT NOT NULL,
    jugador_id INT NOT NULL,
    minutos_jugados INT NOT NULL,
    goles INT NOT NULL,
    asistencias INT NOT NULL,
    tiros INT NOT NULL,
    pases_completados INT NOT NULL,
    recuperaciones INT NOT NULL,
    faltas INT NOT NULL,
    tarjetas INT NOT NULL,
    FOREIGN KEY (partido_id) REFERENCES Partido(partido_id),
    FOREIGN KEY (jugador_id) REFERENCES Jugador(jugador_id),
    CONSTRAINT UQ_EstadisticaJugador UNIQUE (partido_id, jugador_id)
);

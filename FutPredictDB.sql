USE [master]
GO
/****** Objeto: Database [FutPredictDB] Fecha de script: 24/09/2026 7:08:43 p. m. ******/
CREATE DATABASE [FutPredictDB]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'FutPredictDB', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL17.SQLEXPRESS\MSSQL\DATA\FutPredictDB.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'FutPredictDB_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL17.SQLEXPRESS\MSSQL\DATA\FutPredictDB_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT, LEDGER = OFF
GO
ALTER DATABASE [FutPredictDB] SET COMPATIBILITY_LEVEL = 170
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [FutPredictDB].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [FutPredictDB] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [FutPredictDB] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [FutPredictDB] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [FutPredictDB] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [FutPredictDB] SET ARITHABORT OFF 
GO
ALTER DATABASE [FutPredictDB] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [FutPredictDB] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [FutPredictDB] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [FutPredictDB] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [FutPredictDB] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [FutPredictDB] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [FutPredictDB] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [FutPredictDB] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [FutPredictDB] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [FutPredictDB] SET  ENABLE_BROKER 
GO
ALTER DATABASE [FutPredictDB] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [FutPredictDB] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [FutPredictDB] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [FutPredictDB] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [FutPredictDB] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [FutPredictDB] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [FutPredictDB] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [FutPredictDB] SET RECOVERY FULL 
GO
ALTER DATABASE [FutPredictDB] SET  MULTI_USER 
GO
ALTER DATABASE [FutPredictDB] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [FutPredictDB] SET DB_CHAINING OFF 
GO
ALTER DATABASE [FutPredictDB] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [FutPredictDB] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [FutPredictDB] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [FutPredictDB] SET OPTIMIZED_LOCKING = OFF 
GO
ALTER DATABASE [FutPredictDB] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO
ALTER DATABASE [FutPredictDB] SET QUERY_STORE = ON
GO
ALTER DATABASE [FutPredictDB] SET QUERY_STORE (OPERATION_MODE = READ_WRITE, CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 30), DATA_FLUSH_INTERVAL_SECONDS = 900, INTERVAL_LENGTH_MINUTES = 60, MAX_STORAGE_SIZE_MB = 1000, QUERY_CAPTURE_MODE = AUTO, SIZE_BASED_CLEANUP_MODE = AUTO, MAX_PLANS_PER_QUERY = 200, WAIT_STATS_CAPTURE_MODE = ON)
GO
USE [FutPredictDB]
GO
/****** Objeto: Table [dbo].[Equipo] Fecha de script: 24/09/2026 7:08:44 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Equipo](
	[equipo_id] [int] NOT NULL,
	[nombre] [varchar](100) NOT NULL,
	[pais] [varchar](50) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[equipo_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [dbo].[EquipoCompeticion] Fecha de script: 24/09/2026 7:08:44 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EquipoCompeticion](
	[equipo_competicion_id] [int] NOT NULL,
	[equipo_id] [int] NOT NULL,
	[liga_id] [int] NOT NULL,
	[temporada_id] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[equipo_competicion_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [dbo].[EstadisticaEquipo] Fecha de script: 24/09/2026 7:08:44 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EstadisticaEquipo](
	[estadistica_equipo_id] [int] NOT NULL,
	[partido_id] [int] NOT NULL,
	[equipo_id] [int] NOT NULL,
	[posesion] [decimal](5, 2) NULL,
	[tiros] [int] NOT NULL,
	[tiros_arco] [int] NOT NULL,
	[corners] [int] NOT NULL,
	[faltas] [int] NOT NULL,
	[tarjetas_amarillas] [int] NOT NULL,
	[tarjetas_rojas] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[estadistica_equipo_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [dbo].[EstadisticaJugador] Fecha de script: 24/09/2026 7:08:44 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EstadisticaJugador](
	[estadistica_id] [int] NOT NULL,
	[partido_id] [int] NOT NULL,
	[jugador_id] [int] NOT NULL,
	[minutos_jugados] [int] NOT NULL,
	[goles] [int] NOT NULL,
	[asistencias] [int] NOT NULL,
	[tiros] [int] NOT NULL,
	[pases_completados] [int] NOT NULL,
	[recuperaciones] [int] NOT NULL,
	[tiros_arco] [int] NOT NULL,
	[faltas_cometidas] [int] NOT NULL,
	[tarjetas_amarillas] [int] NOT NULL,
	[tarjetas_rojas] [int] NOT NULL,
	[calificacion] [decimal](4, 2) NULL,
PRIMARY KEY CLUSTERED 
(
	[estadistica_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [dbo].[EventoPartido] Fecha de script: 24/09/2026 7:08:44 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EventoPartido](
	[evento_id] [int] NOT NULL,
	[partido_id] [int] NOT NULL,
	[equipo_id] [int] NOT NULL,
	[jugador_id] [int] NULL,
	[tipo_evento] [varchar](30) NOT NULL,
	[minuto] [int] NOT NULL,
	[descripcion] [varchar](200) NULL,
PRIMARY KEY CLUSTERED 
(
	[evento_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [dbo].[Jugador] Fecha de script: 24/09/2026 7:08:44 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Jugador](
	[jugador_id] [int] NOT NULL,
	[nombre] [varchar](100) NOT NULL,
	[fecha_nacimiento] [date] NOT NULL,
	[posicion] [varchar](50) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[jugador_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [dbo].[JugadorEquipo] Fecha de script: 24/09/2026 7:08:44 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[JugadorEquipo](
	[jugador_equipo_id] [int] NOT NULL,
	[jugador_id] [int] NOT NULL,
	[equipo_id] [int] NOT NULL,
	[temporada_id] [int] NOT NULL,
	[fecha_inicio] [date] NOT NULL,
	[fecha_fin] [date] NULL,
PRIMARY KEY CLUSTERED 
(
	[jugador_equipo_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [dbo].[Liga] Fecha de script: 24/09/2026 7:08:44 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Liga](
	[liga_id] [int] NOT NULL,
	[nombre] [varchar](100) NOT NULL,
	[pais] [varchar](50) NOT NULL,
	[tipo] [varchar](30) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[liga_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [dbo].[Partido] Fecha de script: 24/09/2026 7:08:44 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Partido](
	[partido_id] [int] NOT NULL,
	[fecha] [date] NOT NULL,
	[equipo_local_id] [int] NOT NULL,
	[equipo_visitante_id] [int] NOT NULL,
	[goles_local] [int] NOT NULL,
	[goles_visitante] [int] NOT NULL,
	[liga_id] [int] NULL,
	[temporada_id] [int] NULL,
	[estado] [varchar](20) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[partido_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Objeto: Table [dbo].[Temporada] Fecha de script: 24/09/2026 7:08:44 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Temporada](
	[temporada_id] [int] NOT NULL,
	[nombre] [varchar](20) NOT NULL,
	[fecha_inicio] [date] NOT NULL,
	[fecha_fin] [date] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[temporada_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
INSERT [dbo].[Equipo] ([equipo_id], [nombre], [pais]) VALUES (1, N'FC Barcelona', N'España')
INSERT [dbo].[Equipo] ([equipo_id], [nombre], [pais]) VALUES (2, N'Real Madrid', N'España')
INSERT [dbo].[Equipo] ([equipo_id], [nombre], [pais]) VALUES (3, N'Manchester City', N'Inglaterra')
INSERT [dbo].[Equipo] ([equipo_id], [nombre], [pais]) VALUES (4, N'Liverpool', N'Inglaterra')
INSERT [dbo].[Equipo] ([equipo_id], [nombre], [pais]) VALUES (5, N'Inter de Milan', N'Italia')
INSERT [dbo].[Equipo] ([equipo_id], [nombre], [pais]) VALUES (6, N'Juventus', N'Italia')
INSERT [dbo].[Equipo] ([equipo_id], [nombre], [pais]) VALUES (7, N'Bayern Munich', N'Alemania')
INSERT [dbo].[Equipo] ([equipo_id], [nombre], [pais]) VALUES (8, N'Borussia Dortmund', N'Alemania')
INSERT [dbo].[Equipo] ([equipo_id], [nombre], [pais]) VALUES (9, N'Paris Saint-Germain', N'Francia')
INSERT [dbo].[Equipo] ([equipo_id], [nombre], [pais]) VALUES (10, N'Olympique de Marseille', N'Francia')
GO
INSERT [dbo].[EquipoCompeticion] ([equipo_competicion_id], [equipo_id], [liga_id], [temporada_id]) VALUES (1, 1, 1, 2)
INSERT [dbo].[EquipoCompeticion] ([equipo_competicion_id], [equipo_id], [liga_id], [temporada_id]) VALUES (2, 2, 1, 2)
INSERT [dbo].[EquipoCompeticion] ([equipo_competicion_id], [equipo_id], [liga_id], [temporada_id]) VALUES (3, 3, 2, 2)
INSERT [dbo].[EquipoCompeticion] ([equipo_competicion_id], [equipo_id], [liga_id], [temporada_id]) VALUES (4, 4, 2, 2)
INSERT [dbo].[EquipoCompeticion] ([equipo_competicion_id], [equipo_id], [liga_id], [temporada_id]) VALUES (5, 5, 3, 2)
INSERT [dbo].[EquipoCompeticion] ([equipo_competicion_id], [equipo_id], [liga_id], [temporada_id]) VALUES (6, 6, 3, 2)
INSERT [dbo].[EquipoCompeticion] ([equipo_competicion_id], [equipo_id], [liga_id], [temporada_id]) VALUES (7, 7, 4, 2)
INSERT [dbo].[EquipoCompeticion] ([equipo_competicion_id], [equipo_id], [liga_id], [temporada_id]) VALUES (8, 8, 4, 2)
INSERT [dbo].[EquipoCompeticion] ([equipo_competicion_id], [equipo_id], [liga_id], [temporada_id]) VALUES (9, 9, 5, 2)
INSERT [dbo].[EquipoCompeticion] ([equipo_competicion_id], [equipo_id], [liga_id], [temporada_id]) VALUES (10, 10, 5, 2)
GO
INSERT [dbo].[EstadisticaEquipo] ([estadistica_equipo_id], [partido_id], [equipo_id], [posesion], [tiros], [tiros_arco], [corners], [faltas], [tarjetas_amarillas], [tarjetas_rojas]) VALUES (1, 1, 1, CAST(56.00 AS Decimal(5, 2)), 14, 7, 6, 10, 2, 0)
INSERT [dbo].[EstadisticaEquipo] ([estadistica_equipo_id], [partido_id], [equipo_id], [posesion], [tiros], [tiros_arco], [corners], [faltas], [tarjetas_amarillas], [tarjetas_rojas]) VALUES (2, 1, 2, CAST(44.00 AS Decimal(5, 2)), 11, 5, 4, 13, 3, 0)
INSERT [dbo].[EstadisticaEquipo] ([estadistica_equipo_id], [partido_id], [equipo_id], [posesion], [tiros], [tiros_arco], [corners], [faltas], [tarjetas_amarillas], [tarjetas_rojas]) VALUES (3, 2, 3, CAST(61.00 AS Decimal(5, 2)), 17, 9, 8, 8, 1, 0)
INSERT [dbo].[EstadisticaEquipo] ([estadistica_equipo_id], [partido_id], [equipo_id], [posesion], [tiros], [tiros_arco], [corners], [faltas], [tarjetas_amarillas], [tarjetas_rojas]) VALUES (4, 2, 4, CAST(39.00 AS Decimal(5, 2)), 12, 6, 3, 11, 2, 0)
INSERT [dbo].[EstadisticaEquipo] ([estadistica_equipo_id], [partido_id], [equipo_id], [posesion], [tiros], [tiros_arco], [corners], [faltas], [tarjetas_amarillas], [tarjetas_rojas]) VALUES (5, 3, 5, CAST(52.00 AS Decimal(5, 2)), 10, 4, 5, 12, 2, 0)
INSERT [dbo].[EstadisticaEquipo] ([estadistica_equipo_id], [partido_id], [equipo_id], [posesion], [tiros], [tiros_arco], [corners], [faltas], [tarjetas_amarillas], [tarjetas_rojas]) VALUES (6, 3, 6, CAST(48.00 AS Decimal(5, 2)), 9, 4, 4, 14, 3, 0)
INSERT [dbo].[EstadisticaEquipo] ([estadistica_equipo_id], [partido_id], [equipo_id], [posesion], [tiros], [tiros_arco], [corners], [faltas], [tarjetas_amarillas], [tarjetas_rojas]) VALUES (7, 4, 7, CAST(58.00 AS Decimal(5, 2)), 15, 8, 7, 9, 1, 0)
INSERT [dbo].[EstadisticaEquipo] ([estadistica_equipo_id], [partido_id], [equipo_id], [posesion], [tiros], [tiros_arco], [corners], [faltas], [tarjetas_amarillas], [tarjetas_rojas]) VALUES (8, 4, 8, CAST(42.00 AS Decimal(5, 2)), 8, 3, 2, 15, 4, 0)
INSERT [dbo].[EstadisticaEquipo] ([estadistica_equipo_id], [partido_id], [equipo_id], [posesion], [tiros], [tiros_arco], [corners], [faltas], [tarjetas_amarillas], [tarjetas_rojas]) VALUES (9, 5, 9, CAST(63.00 AS Decimal(5, 2)), 19, 11, 9, 7, 1, 0)
INSERT [dbo].[EstadisticaEquipo] ([estadistica_equipo_id], [partido_id], [equipo_id], [posesion], [tiros], [tiros_arco], [corners], [faltas], [tarjetas_amarillas], [tarjetas_rojas]) VALUES (10, 5, 10, CAST(37.00 AS Decimal(5, 2)), 7, 3, 2, 16, 3, 1)
GO
INSERT [dbo].[EstadisticaJugador] ([estadistica_id], [partido_id], [jugador_id], [minutos_jugados], [goles], [asistencias], [tiros], [pases_completados], [recuperaciones], [tiros_arco], [faltas_cometidas], [tarjetas_amarillas], [tarjetas_rojas], [calificacion]) VALUES (1, 1, 1, 90, 2, 0, 5, 42, 6, 3, 1, 0, 0, CAST(8.70 AS Decimal(4, 2)))
INSERT [dbo].[EstadisticaJugador] ([estadistica_id], [partido_id], [jugador_id], [minutos_jugados], [goles], [asistencias], [tiros], [pases_completados], [recuperaciones], [tiros_arco], [faltas_cometidas], [tarjetas_amarillas], [tarjetas_rojas], [calificacion]) VALUES (2, 1, 2, 90, 0, 1, 2, 55, 8, 1, 2, 1, 0, CAST(7.80 AS Decimal(4, 2)))
INSERT [dbo].[EstadisticaJugador] ([estadistica_id], [partido_id], [jugador_id], [minutos_jugados], [goles], [asistencias], [tiros], [pases_completados], [recuperaciones], [tiros_arco], [faltas_cometidas], [tarjetas_amarillas], [tarjetas_rojas], [calificacion]) VALUES (3, 1, 3, 90, 1, 0, 4, 35, 5, 2, 1, 0, 0, CAST(7.90 AS Decimal(4, 2)))
INSERT [dbo].[EstadisticaJugador] ([estadistica_id], [partido_id], [jugador_id], [minutos_jugados], [goles], [asistencias], [tiros], [pases_completados], [recuperaciones], [tiros_arco], [faltas_cometidas], [tarjetas_amarillas], [tarjetas_rojas], [calificacion]) VALUES (4, 1, 4, 90, 0, 1, 1, 48, 7, 0, 2, 1, 0, CAST(7.20 AS Decimal(4, 2)))
INSERT [dbo].[EstadisticaJugador] ([estadistica_id], [partido_id], [jugador_id], [minutos_jugados], [goles], [asistencias], [tiros], [pases_completados], [recuperaciones], [tiros_arco], [faltas_cometidas], [tarjetas_amarillas], [tarjetas_rojas], [calificacion]) VALUES (5, 2, 5, 90, 2, 0, 6, 39, 4, 4, 1, 0, 0, CAST(9.00 AS Decimal(4, 2)))
INSERT [dbo].[EstadisticaJugador] ([estadistica_id], [partido_id], [jugador_id], [minutos_jugados], [goles], [asistencias], [tiros], [pases_completados], [recuperaciones], [tiros_arco], [faltas_cometidas], [tarjetas_amarillas], [tarjetas_rojas], [calificacion]) VALUES (6, 2, 6, 90, 1, 1, 3, 61, 10, 2, 1, 0, 0, CAST(8.30 AS Decimal(4, 2)))
INSERT [dbo].[EstadisticaJugador] ([estadistica_id], [partido_id], [jugador_id], [minutos_jugados], [goles], [asistencias], [tiros], [pases_completados], [recuperaciones], [tiros_arco], [faltas_cometidas], [tarjetas_amarillas], [tarjetas_rojas], [calificacion]) VALUES (7, 2, 7, 90, 2, 0, 5, 32, 4, 3, 2, 0, 0, CAST(8.50 AS Decimal(4, 2)))
INSERT [dbo].[EstadisticaJugador] ([estadistica_id], [partido_id], [jugador_id], [minutos_jugados], [goles], [asistencias], [tiros], [pases_completados], [recuperaciones], [tiros_arco], [faltas_cometidas], [tarjetas_amarillas], [tarjetas_rojas], [calificacion]) VALUES (8, 2, 8, 90, 0, 1, 2, 50, 9, 1, 1, 1, 0, CAST(7.40 AS Decimal(4, 2)))
INSERT [dbo].[EstadisticaJugador] ([estadistica_id], [partido_id], [jugador_id], [minutos_jugados], [goles], [asistencias], [tiros], [pases_completados], [recuperaciones], [tiros_arco], [faltas_cometidas], [tarjetas_amarillas], [tarjetas_rojas], [calificacion]) VALUES (9, 3, 9, 90, 1, 0, 4, 37, 5, 2, 1, 0, 0, CAST(8.10 AS Decimal(4, 2)))
INSERT [dbo].[EstadisticaJugador] ([estadistica_id], [partido_id], [jugador_id], [minutos_jugados], [goles], [asistencias], [tiros], [pases_completados], [recuperaciones], [tiros_arco], [faltas_cometidas], [tarjetas_amarillas], [tarjetas_rojas], [calificacion]) VALUES (10, 3, 10, 90, 0, 1, 1, 58, 11, 0, 2, 1, 0, CAST(7.50 AS Decimal(4, 2)))
INSERT [dbo].[EstadisticaJugador] ([estadistica_id], [partido_id], [jugador_id], [minutos_jugados], [goles], [asistencias], [tiros], [pases_completados], [recuperaciones], [tiros_arco], [faltas_cometidas], [tarjetas_amarillas], [tarjetas_rojas], [calificacion]) VALUES (11, 3, 11, 90, 1, 0, 3, 34, 5, 2, 2, 0, 0, CAST(8.00 AS Decimal(4, 2)))
INSERT [dbo].[EstadisticaJugador] ([estadistica_id], [partido_id], [jugador_id], [minutos_jugados], [goles], [asistencias], [tiros], [pases_completados], [recuperaciones], [tiros_arco], [faltas_cometidas], [tarjetas_amarillas], [tarjetas_rojas], [calificacion]) VALUES (12, 3, 12, 90, 0, 1, 2, 52, 8, 1, 1, 1, 0, CAST(7.60 AS Decimal(4, 2)))
INSERT [dbo].[EstadisticaJugador] ([estadistica_id], [partido_id], [jugador_id], [minutos_jugados], [goles], [asistencias], [tiros], [pases_completados], [recuperaciones], [tiros_arco], [faltas_cometidas], [tarjetas_amarillas], [tarjetas_rojas], [calificacion]) VALUES (13, 4, 13, 90, 2, 0, 5, 40, 5, 3, 1, 0, 0, CAST(8.80 AS Decimal(4, 2)))
INSERT [dbo].[EstadisticaJugador] ([estadistica_id], [partido_id], [jugador_id], [minutos_jugados], [goles], [asistencias], [tiros], [pases_completados], [recuperaciones], [tiros_arco], [faltas_cometidas], [tarjetas_amarillas], [tarjetas_rojas], [calificacion]) VALUES (14, 4, 14, 90, 0, 1, 1, 64, 12, 0, 1, 0, 0, CAST(8.00 AS Decimal(4, 2)))
INSERT [dbo].[EstadisticaJugador] ([estadistica_id], [partido_id], [jugador_id], [minutos_jugados], [goles], [asistencias], [tiros], [pases_completados], [recuperaciones], [tiros_arco], [faltas_cometidas], [tarjetas_amarillas], [tarjetas_rojas], [calificacion]) VALUES (15, 4, 15, 90, 0, 0, 3, 31, 4, 1, 2, 1, 0, CAST(6.80 AS Decimal(4, 2)))
INSERT [dbo].[EstadisticaJugador] ([estadistica_id], [partido_id], [jugador_id], [minutos_jugados], [goles], [asistencias], [tiros], [pases_completados], [recuperaciones], [tiros_arco], [faltas_cometidas], [tarjetas_amarillas], [tarjetas_rojas], [calificacion]) VALUES (16, 4, 16, 90, 0, 0, 2, 45, 7, 1, 2, 1, 0, CAST(7.00 AS Decimal(4, 2)))
INSERT [dbo].[EstadisticaJugador] ([estadistica_id], [partido_id], [jugador_id], [minutos_jugados], [goles], [asistencias], [tiros], [pases_completados], [recuperaciones], [tiros_arco], [faltas_cometidas], [tarjetas_amarillas], [tarjetas_rojas], [calificacion]) VALUES (17, 5, 17, 90, 3, 0, 7, 41, 3, 5, 0, 0, 0, CAST(9.50 AS Decimal(4, 2)))
INSERT [dbo].[EstadisticaJugador] ([estadistica_id], [partido_id], [jugador_id], [minutos_jugados], [goles], [asistencias], [tiros], [pases_completados], [recuperaciones], [tiros_arco], [faltas_cometidas], [tarjetas_amarillas], [tarjetas_rojas], [calificacion]) VALUES (18, 5, 18, 90, 1, 2, 4, 60, 9, 3, 1, 0, 0, CAST(9.00 AS Decimal(4, 2)))
INSERT [dbo].[EstadisticaJugador] ([estadistica_id], [partido_id], [jugador_id], [minutos_jugados], [goles], [asistencias], [tiros], [pases_completados], [recuperaciones], [tiros_arco], [faltas_cometidas], [tarjetas_amarillas], [tarjetas_rojas], [calificacion]) VALUES (19, 5, 19, 90, 1, 0, 3, 29, 4, 2, 2, 0, 0, CAST(7.30 AS Decimal(4, 2)))
INSERT [dbo].[EstadisticaJugador] ([estadistica_id], [partido_id], [jugador_id], [minutos_jugados], [goles], [asistencias], [tiros], [pases_completados], [recuperaciones], [tiros_arco], [faltas_cometidas], [tarjetas_amarillas], [tarjetas_rojas], [calificacion]) VALUES (20, 5, 20, 90, 0, 1, 1, 44, 10, 0, 3, 1, 0, CAST(6.90 AS Decimal(4, 2)))
GO
INSERT [dbo].[Jugador] ([jugador_id], [nombre], [fecha_nacimiento], [posicion]) VALUES (1, N'Jugador Barcelona 1', CAST(N'2000-01-10' AS Date), N'Delantero')
INSERT [dbo].[Jugador] ([jugador_id], [nombre], [fecha_nacimiento], [posicion]) VALUES (2, N'Jugador Barcelona 2', CAST(N'2001-03-15' AS Date), N'Mediocampista')
INSERT [dbo].[Jugador] ([jugador_id], [nombre], [fecha_nacimiento], [posicion]) VALUES (3, N'Jugador Real Madrid 1', CAST(N'1999-05-20' AS Date), N'Delantero')
INSERT [dbo].[Jugador] ([jugador_id], [nombre], [fecha_nacimiento], [posicion]) VALUES (4, N'Jugador Real Madrid 2', CAST(N'2000-08-12' AS Date), N'Mediocampista')
INSERT [dbo].[Jugador] ([jugador_id], [nombre], [fecha_nacimiento], [posicion]) VALUES (5, N'Jugador Manchester City 1', CAST(N'2000-07-21' AS Date), N'Delantero')
INSERT [dbo].[Jugador] ([jugador_id], [nombre], [fecha_nacimiento], [posicion]) VALUES (6, N'Jugador Manchester City 2', CAST(N'2001-02-11' AS Date), N'Defensa')
INSERT [dbo].[Jugador] ([jugador_id], [nombre], [fecha_nacimiento], [posicion]) VALUES (7, N'Jugador Liverpool 1', CAST(N'1999-09-14' AS Date), N'Delantero')
INSERT [dbo].[Jugador] ([jugador_id], [nombre], [fecha_nacimiento], [posicion]) VALUES (8, N'Jugador Liverpool 2', CAST(N'2002-04-25' AS Date), N'Mediocampista')
INSERT [dbo].[Jugador] ([jugador_id], [nombre], [fecha_nacimiento], [posicion]) VALUES (9, N'Jugador Inter 1', CAST(N'2000-06-17' AS Date), N'Delantero')
INSERT [dbo].[Jugador] ([jugador_id], [nombre], [fecha_nacimiento], [posicion]) VALUES (10, N'Jugador Inter 2', CAST(N'2001-11-03' AS Date), N'Defensa')
INSERT [dbo].[Jugador] ([jugador_id], [nombre], [fecha_nacimiento], [posicion]) VALUES (11, N'Jugador Juventus 1', CAST(N'1999-12-08' AS Date), N'Delantero')
INSERT [dbo].[Jugador] ([jugador_id], [nombre], [fecha_nacimiento], [posicion]) VALUES (12, N'Jugador Juventus 2', CAST(N'2002-01-19' AS Date), N'Mediocampista')
INSERT [dbo].[Jugador] ([jugador_id], [nombre], [fecha_nacimiento], [posicion]) VALUES (13, N'Jugador Bayern 1', CAST(N'2000-10-05' AS Date), N'Delantero')
INSERT [dbo].[Jugador] ([jugador_id], [nombre], [fecha_nacimiento], [posicion]) VALUES (14, N'Jugador Bayern 2', CAST(N'2001-05-13' AS Date), N'Defensa')
INSERT [dbo].[Jugador] ([jugador_id], [nombre], [fecha_nacimiento], [posicion]) VALUES (15, N'Jugador Dortmund 1', CAST(N'2002-07-29' AS Date), N'Delantero')
INSERT [dbo].[Jugador] ([jugador_id], [nombre], [fecha_nacimiento], [posicion]) VALUES (16, N'Jugador Dortmund 2', CAST(N'2000-03-22' AS Date), N'Mediocampista')
INSERT [dbo].[Jugador] ([jugador_id], [nombre], [fecha_nacimiento], [posicion]) VALUES (17, N'Jugador PSG 1', CAST(N'1999-04-16' AS Date), N'Delantero')
INSERT [dbo].[Jugador] ([jugador_id], [nombre], [fecha_nacimiento], [posicion]) VALUES (18, N'Jugador PSG 2', CAST(N'2001-08-09' AS Date), N'Mediocampista')
INSERT [dbo].[Jugador] ([jugador_id], [nombre], [fecha_nacimiento], [posicion]) VALUES (19, N'Jugador Marseille 1', CAST(N'2000-02-27' AS Date), N'Delantero')
INSERT [dbo].[Jugador] ([jugador_id], [nombre], [fecha_nacimiento], [posicion]) VALUES (20, N'Jugador Marseille 2', CAST(N'2002-06-01' AS Date), N'Defensa')
GO
INSERT [dbo].[JugadorEquipo] ([jugador_equipo_id], [jugador_id], [equipo_id], [temporada_id], [fecha_inicio], [fecha_fin]) VALUES (1, 1, 1, 2, CAST(N'2026-07-01' AS Date), NULL)
INSERT [dbo].[JugadorEquipo] ([jugador_equipo_id], [jugador_id], [equipo_id], [temporada_id], [fecha_inicio], [fecha_fin]) VALUES (2, 2, 1, 2, CAST(N'2026-07-01' AS Date), NULL)
INSERT [dbo].[JugadorEquipo] ([jugador_equipo_id], [jugador_id], [equipo_id], [temporada_id], [fecha_inicio], [fecha_fin]) VALUES (3, 3, 2, 2, CAST(N'2026-07-01' AS Date), NULL)
INSERT [dbo].[JugadorEquipo] ([jugador_equipo_id], [jugador_id], [equipo_id], [temporada_id], [fecha_inicio], [fecha_fin]) VALUES (4, 4, 2, 2, CAST(N'2026-07-01' AS Date), NULL)
INSERT [dbo].[JugadorEquipo] ([jugador_equipo_id], [jugador_id], [equipo_id], [temporada_id], [fecha_inicio], [fecha_fin]) VALUES (5, 5, 3, 2, CAST(N'2026-07-01' AS Date), NULL)
INSERT [dbo].[JugadorEquipo] ([jugador_equipo_id], [jugador_id], [equipo_id], [temporada_id], [fecha_inicio], [fecha_fin]) VALUES (6, 6, 3, 2, CAST(N'2026-07-01' AS Date), NULL)
INSERT [dbo].[JugadorEquipo] ([jugador_equipo_id], [jugador_id], [equipo_id], [temporada_id], [fecha_inicio], [fecha_fin]) VALUES (7, 7, 4, 2, CAST(N'2026-07-01' AS Date), NULL)
INSERT [dbo].[JugadorEquipo] ([jugador_equipo_id], [jugador_id], [equipo_id], [temporada_id], [fecha_inicio], [fecha_fin]) VALUES (8, 8, 4, 2, CAST(N'2026-07-01' AS Date), NULL)
INSERT [dbo].[JugadorEquipo] ([jugador_equipo_id], [jugador_id], [equipo_id], [temporada_id], [fecha_inicio], [fecha_fin]) VALUES (9, 9, 5, 2, CAST(N'2026-07-01' AS Date), NULL)
INSERT [dbo].[JugadorEquipo] ([jugador_equipo_id], [jugador_id], [equipo_id], [temporada_id], [fecha_inicio], [fecha_fin]) VALUES (10, 10, 5, 2, CAST(N'2026-07-01' AS Date), NULL)
INSERT [dbo].[JugadorEquipo] ([jugador_equipo_id], [jugador_id], [equipo_id], [temporada_id], [fecha_inicio], [fecha_fin]) VALUES (11, 11, 6, 2, CAST(N'2026-07-01' AS Date), NULL)
INSERT [dbo].[JugadorEquipo] ([jugador_equipo_id], [jugador_id], [equipo_id], [temporada_id], [fecha_inicio], [fecha_fin]) VALUES (12, 12, 6, 2, CAST(N'2026-07-01' AS Date), NULL)
INSERT [dbo].[JugadorEquipo] ([jugador_equipo_id], [jugador_id], [equipo_id], [temporada_id], [fecha_inicio], [fecha_fin]) VALUES (13, 13, 7, 2, CAST(N'2026-07-01' AS Date), NULL)
INSERT [dbo].[JugadorEquipo] ([jugador_equipo_id], [jugador_id], [equipo_id], [temporada_id], [fecha_inicio], [fecha_fin]) VALUES (14, 14, 7, 2, CAST(N'2026-07-01' AS Date), NULL)
INSERT [dbo].[JugadorEquipo] ([jugador_equipo_id], [jugador_id], [equipo_id], [temporada_id], [fecha_inicio], [fecha_fin]) VALUES (15, 15, 8, 2, CAST(N'2026-07-01' AS Date), NULL)
INSERT [dbo].[JugadorEquipo] ([jugador_equipo_id], [jugador_id], [equipo_id], [temporada_id], [fecha_inicio], [fecha_fin]) VALUES (16, 16, 8, 2, CAST(N'2026-07-01' AS Date), NULL)
INSERT [dbo].[JugadorEquipo] ([jugador_equipo_id], [jugador_id], [equipo_id], [temporada_id], [fecha_inicio], [fecha_fin]) VALUES (17, 17, 9, 2, CAST(N'2026-07-01' AS Date), NULL)
INSERT [dbo].[JugadorEquipo] ([jugador_equipo_id], [jugador_id], [equipo_id], [temporada_id], [fecha_inicio], [fecha_fin]) VALUES (18, 18, 9, 2, CAST(N'2026-07-01' AS Date), NULL)
INSERT [dbo].[JugadorEquipo] ([jugador_equipo_id], [jugador_id], [equipo_id], [temporada_id], [fecha_inicio], [fecha_fin]) VALUES (19, 19, 10, 2, CAST(N'2026-07-01' AS Date), NULL)
INSERT [dbo].[JugadorEquipo] ([jugador_equipo_id], [jugador_id], [equipo_id], [temporada_id], [fecha_inicio], [fecha_fin]) VALUES (20, 20, 10, 2, CAST(N'2026-07-01' AS Date), NULL)
GO
INSERT [dbo].[Liga] ([liga_id], [nombre], [pais], [tipo]) VALUES (1, N'LaLiga', N'España', N'Liga')
INSERT [dbo].[Liga] ([liga_id], [nombre], [pais], [tipo]) VALUES (2, N'Premier League', N'Inglaterra', N'Liga')
INSERT [dbo].[Liga] ([liga_id], [nombre], [pais], [tipo]) VALUES (3, N'Serie A', N'Italia', N'Liga')
INSERT [dbo].[Liga] ([liga_id], [nombre], [pais], [tipo]) VALUES (4, N'Bundesliga', N'Alemania', N'Liga')
INSERT [dbo].[Liga] ([liga_id], [nombre], [pais], [tipo]) VALUES (5, N'Ligue 1', N'Francia', N'Liga')
INSERT [dbo].[Liga] ([liga_id], [nombre], [pais], [tipo]) VALUES (6, N'Champions League', N'Europa', N'Internacional')
GO
INSERT [dbo].[Partido] ([partido_id], [fecha], [equipo_local_id], [equipo_visitante_id], [goles_local], [goles_visitante], [liga_id], [temporada_id], [estado]) VALUES (1, CAST(N'2026-09-10' AS Date), 1, 2, 2, 1, 1, 2, N'Finalizado')
INSERT [dbo].[Partido] ([partido_id], [fecha], [equipo_local_id], [equipo_visitante_id], [goles_local], [goles_visitante], [liga_id], [temporada_id], [estado]) VALUES (2, CAST(N'2026-09-12' AS Date), 3, 4, 3, 2, 2, 2, N'Finalizado')
INSERT [dbo].[Partido] ([partido_id], [fecha], [equipo_local_id], [equipo_visitante_id], [goles_local], [goles_visitante], [liga_id], [temporada_id], [estado]) VALUES (3, CAST(N'2026-09-14' AS Date), 5, 6, 1, 1, 3, 2, N'Finalizado')
INSERT [dbo].[Partido] ([partido_id], [fecha], [equipo_local_id], [equipo_visitante_id], [goles_local], [goles_visitante], [liga_id], [temporada_id], [estado]) VALUES (4, CAST(N'2026-09-16' AS Date), 7, 8, 2, 0, 4, 2, N'Finalizado')
INSERT [dbo].[Partido] ([partido_id], [fecha], [equipo_local_id], [equipo_visitante_id], [goles_local], [goles_visitante], [liga_id], [temporada_id], [estado]) VALUES (5, CAST(N'2026-09-18' AS Date), 9, 10, 4, 1, 5, 2, N'Finalizado')
GO
INSERT [dbo].[Temporada] ([temporada_id], [nombre], [fecha_inicio], [fecha_fin]) VALUES (1, N'2025/2026', CAST(N'2025-07-01' AS Date), CAST(N'2026-06-30' AS Date))
INSERT [dbo].[Temporada] ([temporada_id], [nombre], [fecha_inicio], [fecha_fin]) VALUES (2, N'2026/2027', CAST(N'2026-07-01' AS Date), CAST(N'2027-06-30' AS Date))
GO
/****** Objeto: Index [UQ_EquipoCompeticion] Fecha de script: 24/09/2026 7:08:44 p. m. ******/
ALTER TABLE [dbo].[EquipoCompeticion] ADD  CONSTRAINT [UQ_EquipoCompeticion] UNIQUE NONCLUSTERED 
(
	[equipo_id] ASC,
	[liga_id] ASC,
	[temporada_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Objeto: Index [UQ_EstadisticaEquipo] Fecha de script: 24/09/2026 7:08:44 p. m. ******/
ALTER TABLE [dbo].[EstadisticaEquipo] ADD  CONSTRAINT [UQ_EstadisticaEquipo] UNIQUE NONCLUSTERED 
(
	[partido_id] ASC,
	[equipo_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Objeto: Index [UQ_EstadisticaJugador] Fecha de script: 24/09/2026 7:08:44 p. m. ******/
ALTER TABLE [dbo].[EstadisticaJugador] ADD  CONSTRAINT [UQ_EstadisticaJugador] UNIQUE NONCLUSTERED 
(
	[partido_id] ASC,
	[jugador_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Objeto: Index [UQ_JugadorEquipo] Fecha de script: 24/09/2026 7:08:44 p. m. ******/
ALTER TABLE [dbo].[JugadorEquipo] ADD  CONSTRAINT [UQ_JugadorEquipo] UNIQUE NONCLUSTERED 
(
	[jugador_id] ASC,
	[equipo_id] ASC,
	[temporada_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[EstadisticaEquipo] ADD  DEFAULT ((0)) FOR [tiros]
GO
ALTER TABLE [dbo].[EstadisticaEquipo] ADD  DEFAULT ((0)) FOR [tiros_arco]
GO
ALTER TABLE [dbo].[EstadisticaEquipo] ADD  DEFAULT ((0)) FOR [corners]
GO
ALTER TABLE [dbo].[EstadisticaEquipo] ADD  DEFAULT ((0)) FOR [faltas]
GO
ALTER TABLE [dbo].[EstadisticaEquipo] ADD  DEFAULT ((0)) FOR [tarjetas_amarillas]
GO
ALTER TABLE [dbo].[EstadisticaEquipo] ADD  DEFAULT ((0)) FOR [tarjetas_rojas]
GO
ALTER TABLE [dbo].[EstadisticaJugador] ADD  CONSTRAINT [DF_EstadisticaJugador_TirosArco]  DEFAULT ((0)) FOR [tiros_arco]
GO
ALTER TABLE [dbo].[EstadisticaJugador] ADD  CONSTRAINT [DF_EstadisticaJugador_Faltas]  DEFAULT ((0)) FOR [faltas_cometidas]
GO
ALTER TABLE [dbo].[EstadisticaJugador] ADD  CONSTRAINT [DF_EstadisticaJugador_Amarillas]  DEFAULT ((0)) FOR [tarjetas_amarillas]
GO
ALTER TABLE [dbo].[EstadisticaJugador] ADD  CONSTRAINT [DF_EstadisticaJugador_Rojas]  DEFAULT ((0)) FOR [tarjetas_rojas]
GO
ALTER TABLE [dbo].[Partido] ADD  CONSTRAINT [DF_Partido_Estado]  DEFAULT ('Programado') FOR [estado]
GO
ALTER TABLE [dbo].[EquipoCompeticion]  WITH CHECK ADD  CONSTRAINT [FK_EquipoCompeticion_Equipo] FOREIGN KEY([equipo_id])
REFERENCES [dbo].[Equipo] ([equipo_id])
GO
ALTER TABLE [dbo].[EquipoCompeticion] CHECK CONSTRAINT [FK_EquipoCompeticion_Equipo]
GO
ALTER TABLE [dbo].[EquipoCompeticion]  WITH CHECK ADD  CONSTRAINT [FK_EquipoCompeticion_Liga] FOREIGN KEY([liga_id])
REFERENCES [dbo].[Liga] ([liga_id])
GO
ALTER TABLE [dbo].[EquipoCompeticion] CHECK CONSTRAINT [FK_EquipoCompeticion_Liga]
GO
ALTER TABLE [dbo].[EquipoCompeticion]  WITH CHECK ADD  CONSTRAINT [FK_EquipoCompeticion_Temporada] FOREIGN KEY([temporada_id])
REFERENCES [dbo].[Temporada] ([temporada_id])
GO
ALTER TABLE [dbo].[EquipoCompeticion] CHECK CONSTRAINT [FK_EquipoCompeticion_Temporada]
GO
ALTER TABLE [dbo].[EstadisticaEquipo]  WITH CHECK ADD  CONSTRAINT [FK_EstadisticaEquipo_Equipo] FOREIGN KEY([equipo_id])
REFERENCES [dbo].[Equipo] ([equipo_id])
GO
ALTER TABLE [dbo].[EstadisticaEquipo] CHECK CONSTRAINT [FK_EstadisticaEquipo_Equipo]
GO
ALTER TABLE [dbo].[EstadisticaEquipo]  WITH CHECK ADD  CONSTRAINT [FK_EstadisticaEquipo_Partido] FOREIGN KEY([partido_id])
REFERENCES [dbo].[Partido] ([partido_id])
GO
ALTER TABLE [dbo].[EstadisticaEquipo] CHECK CONSTRAINT [FK_EstadisticaEquipo_Partido]
GO
ALTER TABLE [dbo].[EstadisticaJugador]  WITH CHECK ADD FOREIGN KEY([jugador_id])
REFERENCES [dbo].[Jugador] ([jugador_id])
GO
ALTER TABLE [dbo].[EstadisticaJugador]  WITH CHECK ADD FOREIGN KEY([partido_id])
REFERENCES [dbo].[Partido] ([partido_id])
GO
ALTER TABLE [dbo].[EventoPartido]  WITH CHECK ADD  CONSTRAINT [FK_EventoPartido_Equipo] FOREIGN KEY([equipo_id])
REFERENCES [dbo].[Equipo] ([equipo_id])
GO
ALTER TABLE [dbo].[EventoPartido] CHECK CONSTRAINT [FK_EventoPartido_Equipo]
GO
ALTER TABLE [dbo].[EventoPartido]  WITH CHECK ADD  CONSTRAINT [FK_EventoPartido_Jugador] FOREIGN KEY([jugador_id])
REFERENCES [dbo].[Jugador] ([jugador_id])
GO
ALTER TABLE [dbo].[EventoPartido] CHECK CONSTRAINT [FK_EventoPartido_Jugador]
GO
ALTER TABLE [dbo].[EventoPartido]  WITH CHECK ADD  CONSTRAINT [FK_EventoPartido_Partido] FOREIGN KEY([partido_id])
REFERENCES [dbo].[Partido] ([partido_id])
GO
ALTER TABLE [dbo].[EventoPartido] CHECK CONSTRAINT [FK_EventoPartido_Partido]
GO
ALTER TABLE [dbo].[JugadorEquipo]  WITH CHECK ADD  CONSTRAINT [FK_JugadorEquipo_Equipo] FOREIGN KEY([equipo_id])
REFERENCES [dbo].[Equipo] ([equipo_id])
GO
ALTER TABLE [dbo].[JugadorEquipo] CHECK CONSTRAINT [FK_JugadorEquipo_Equipo]
GO
ALTER TABLE [dbo].[JugadorEquipo]  WITH CHECK ADD  CONSTRAINT [FK_JugadorEquipo_Jugador] FOREIGN KEY([jugador_id])
REFERENCES [dbo].[Jugador] ([jugador_id])
GO
ALTER TABLE [dbo].[JugadorEquipo] CHECK CONSTRAINT [FK_JugadorEquipo_Jugador]
GO
ALTER TABLE [dbo].[JugadorEquipo]  WITH CHECK ADD  CONSTRAINT [FK_JugadorEquipo_Temporada] FOREIGN KEY([temporada_id])
REFERENCES [dbo].[Temporada] ([temporada_id])
GO
ALTER TABLE [dbo].[JugadorEquipo] CHECK CONSTRAINT [FK_JugadorEquipo_Temporada]
GO
ALTER TABLE [dbo].[Partido]  WITH CHECK ADD FOREIGN KEY([equipo_local_id])
REFERENCES [dbo].[Equipo] ([equipo_id])
GO
ALTER TABLE [dbo].[Partido]  WITH CHECK ADD FOREIGN KEY([equipo_visitante_id])
REFERENCES [dbo].[Equipo] ([equipo_id])
GO
ALTER TABLE [dbo].[Partido]  WITH CHECK ADD  CONSTRAINT [FK_Partido_Liga] FOREIGN KEY([liga_id])
REFERENCES [dbo].[Liga] ([liga_id])
GO
ALTER TABLE [dbo].[Partido] CHECK CONSTRAINT [FK_Partido_Liga]
GO
ALTER TABLE [dbo].[Partido]  WITH CHECK ADD  CONSTRAINT [FK_Partido_Temporada] FOREIGN KEY([temporada_id])
REFERENCES [dbo].[Temporada] ([temporada_id])
GO
ALTER TABLE [dbo].[Partido] CHECK CONSTRAINT [FK_Partido_Temporada]
GO
ALTER TABLE [dbo].[EstadisticaEquipo]  WITH CHECK ADD  CONSTRAINT [CK_EstadisticaEquipo_Posesion] CHECK  (([posesion] IS NULL OR [posesion]>=(0) AND [posesion]<=(100)))
GO
ALTER TABLE [dbo].[EstadisticaEquipo] CHECK CONSTRAINT [CK_EstadisticaEquipo_Posesion]
GO
ALTER TABLE [dbo].[EstadisticaEquipo]  WITH CHECK ADD  CONSTRAINT [CK_EstadisticaEquipo_Valores] CHECK  (([tiros]>=(0) AND [tiros_arco]>=(0) AND [corners]>=(0) AND [faltas]>=(0) AND [tarjetas_amarillas]>=(0) AND [tarjetas_rojas]>=(0)))
GO
ALTER TABLE [dbo].[EstadisticaEquipo] CHECK CONSTRAINT [CK_EstadisticaEquipo_Valores]
GO
ALTER TABLE [dbo].[EstadisticaJugador]  WITH CHECK ADD  CONSTRAINT [CK_EstadisticaJugador_Calificacion] CHECK  (([calificacion] IS NULL OR [calificacion]>=(0) AND [calificacion]<=(10)))
GO
ALTER TABLE [dbo].[EstadisticaJugador] CHECK CONSTRAINT [CK_EstadisticaJugador_Calificacion]
GO
ALTER TABLE [dbo].[EstadisticaJugador]  WITH CHECK ADD  CONSTRAINT [CK_EstadisticaJugador_Valores] CHECK  (([minutos_jugados]>=(0) AND [goles]>=(0) AND [asistencias]>=(0) AND [tiros]>=(0) AND [pases_completados]>=(0) AND [tiros_arco]>=(0) AND [faltas_cometidas]>=(0) AND [tarjetas_amarillas]>=(0) AND [tarjetas_rojas]>=(0)))
GO
ALTER TABLE [dbo].[EstadisticaJugador] CHECK CONSTRAINT [CK_EstadisticaJugador_Valores]
GO
ALTER TABLE [dbo].[EventoPartido]  WITH CHECK ADD  CONSTRAINT [CK_EventoPartido_Minuto] CHECK  (([minuto]>=(0) AND [minuto]<=(130)))
GO
ALTER TABLE [dbo].[EventoPartido] CHECK CONSTRAINT [CK_EventoPartido_Minuto]
GO
ALTER TABLE [dbo].[EventoPartido]  WITH CHECK ADD  CONSTRAINT [CK_EventoPartido_Tipo] CHECK  (([tipo_evento]='Penal' OR [tipo_evento]='Sustitucion' OR [tipo_evento]='Tarjeta roja' OR [tipo_evento]='Tarjeta amarilla' OR [tipo_evento]='Autogol' OR [tipo_evento]='Gol'))
GO
ALTER TABLE [dbo].[EventoPartido] CHECK CONSTRAINT [CK_EventoPartido_Tipo]
GO
ALTER TABLE [dbo].[JugadorEquipo]  WITH CHECK ADD  CONSTRAINT [CK_JugadorEquipo_Fechas] CHECK  (([fecha_fin] IS NULL OR [fecha_fin]>=[fecha_inicio]))
GO
ALTER TABLE [dbo].[JugadorEquipo] CHECK CONSTRAINT [CK_JugadorEquipo_Fechas]
GO
ALTER TABLE [dbo].[Partido]  WITH CHECK ADD  CONSTRAINT [CK_Partido_Equipos] CHECK  (([equipo_local_id]<>[equipo_visitante_id]))
GO
ALTER TABLE [dbo].[Partido] CHECK CONSTRAINT [CK_Partido_Equipos]
GO
ALTER TABLE [dbo].[Partido]  WITH CHECK ADD  CONSTRAINT [CK_Partido_Estado] CHECK  (([estado]='Suspendido' OR [estado]='Finalizado' OR [estado]='En juego' OR [estado]='Programado'))
GO
ALTER TABLE [dbo].[Partido] CHECK CONSTRAINT [CK_Partido_Estado]
GO
ALTER TABLE [dbo].[Temporada]  WITH CHECK ADD  CONSTRAINT [CK_Temporada_Fechas] CHECK  (([fecha_fin]>[fecha_inicio]))
GO
ALTER TABLE [dbo].[Temporada] CHECK CONSTRAINT [CK_Temporada_Fechas]
GO
USE [master]
GO
ALTER DATABASE [FutPredictDB] SET  READ_WRITE 
GO

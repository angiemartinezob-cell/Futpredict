
import { useEffect, useState } from 'react';
import {
  Activity,
  ArrowRight,
  ArrowUpRight,
  BarChart3,
  Bell,
  CalendarDays,
  ChevronDown,
  CircleHelp,
  ClipboardList,
  Home,
  LogOut,
  Menu,
  Search,
  Shield,
  ShieldCheck,
  Trophy,
  Users,
  X,
  Zap,
  Mail,
  LockKeyhole,
  Eye,
  EyeOff,
} from 'lucide-react';

import futpredictMark from './assets/futpredict-mark.svg';
import './LoginPremium.css';

// CONEXIÓN CON LA API (SQL Server y MongoDB)
// Se puede cambiar con la variable VITE_API_URL en un archivo .env del frontend.
const API_URL =
  import.meta.env.VITE_API_URL || 'http://localhost:3001';

// Consulta una ruta de la API y devuelve { datos, cargando, error }.
function useApi(ruta, valorInicial = []) {
  const [datos, setDatos] = useState(valorInicial);
  const [cargando, setCargando] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    let activo = true;

    async function cargar() {
      try {
        const respuesta = await fetch(`${API_URL}${ruta}`);

        if (!respuesta.ok) {
          throw new Error(`No se pudo consultar ${ruta}`);
        }

        const resultado = await respuesta.json();
        if (activo) setDatos(resultado);
      } catch (err) {
        if (activo) setError(err.message);
      } finally {
        if (activo) setCargando(false);
      }
    }

    cargar();

    return () => {
      activo = false;
    };
  }, [ruta]);

  return { datos, cargando, error };
}

// Iniciales para los escudos y avatares: "Inter de Milan" -> "IM"
function obtenerIniciales(nombre = '') {
  return nombre
    .split(' ')
    .filter(
      (palabra) =>
        palabra &&
        !['de', 'del', 'la', 'el'].includes(palabra.toLowerCase())
    )
    .slice(0, 2)
    .map((palabra) => palabra[0])
    .join('')
    .toUpperCase();
}

// '2026-09-10' -> '10 sep 2026' (sin conversiones de zona horaria)
const MESES = ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];

function formatearFecha(fecha = '') {
  const [anio, mes, dia] = fecha.slice(0, 10).split('-');
  if (!anio || !mes || !dia) return fecha;
  return `${Number(dia)} ${MESES[Number(mes) - 1]} ${anio}`;
}

function formatearCalificacion(valor) {
  return valor === null || valor === undefined
    ? '—'
    : Number(valor).toFixed(1);
}

// Adapta las filas de la API al formato que ya usaban las tarjetas
function adaptarJugador(jugador) {
  return {
    id: jugador.jugador_id,
    name: jugador.nombre,
    position: jugador.posicion,
    team: jugador.equipo || 'Sin equipo',
    goals: jugador.goles,
    assists: jugador.asistencias,
    rating: jugador.calificacion_promedio,
    initials: obtenerIniciales(jugador.nombre),
  };
}

function adaptarPartido(partido) {
  return {
    id: partido.partido_id,
    home: partido.equipo_local,
    away: partido.equipo_visitante,
    homeScore: partido.goles_local,
    awayScore: partido.goles_visitante,
    date: formatearFecha(partido.fecha),
    status: partido.estado,
    league: partido.liga,
    initials: [
      obtenerIniciales(partido.equipo_local),
      obtenerIniciales(partido.equipo_visitante),
    ],
  };
}

// Mensajes de carga / error / vacío con el mismo estilo de la sección Equipos
function EstadoCarga({ cargando, error, vacio, que }) {
  if (cargando) {
    return <p className="empty-state">Cargando {que} desde FutPredict...</p>;
  }

  if (error) {
    return (
      <p className="empty-state" role="alert" style={{ color: '#b91c1c' }}>
        No se pudieron cargar los {que}. Verifica que el servidor esté funcionando.
      </p>
    );
  }

  if (vacio) {
    return <p className="empty-state">Todavía no hay {que} en la base de datos.</p>;
  }

  return null;
}

const menuItems = [
  { label: 'Dashboard', icon: Home },
  { label: 'Jugadores', icon: Users },
  { label: 'Equipos', icon: Shield },
  { label: 'Partidos', icon: Trophy },
  { label: 'Estadísticas', icon: BarChart3 },
  { label: 'Análisis', icon: Activity },
];

// LOGIN PREMIUM
function Login({ onLogin }) {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [rememberMe, setRememberMe] = useState(false);
  const [helpMessage, setHelpMessage] = useState(false);

  function handleSubmit(event) {
    event.preventDefault();

    // Inicio de sesión demostrativo.
    // La autenticación real se integrará con el backend.
    onLogin();
  }

  return (
    <main className="login-page premium-login">
      <section
        className="premium-hero"
        aria-label="FutPredict: inteligencia deportiva"
      >
        <div
          className="premium-hero-photo"
          aria-hidden="true"
        />

        <div
          className="premium-hero-orbit"
          aria-hidden="true"
        />

        <div className="premium-brand">
          <img
            src={futpredictMark}
            alt="Logo FutPredict"
            className="premium-brand-icon"
          />

          <div className="premium-brand-copy">
            <div className="premium-brand-name">
              FUT<span>PREDICT</span>
            </div>

            <div className="premium-brand-caption">
              ANÁLISIS DEPORTIVO
            </div>
          </div>
        </div>

        <div className="premium-hero-content">
          <div className="premium-kicker" aria-hidden="true">
  <svg viewBox="0 0 280 76" fill="none">
    <g
      stroke="currentColor"
      strokeWidth="1.8"
      strokeLinecap="round"
      strokeLinejoin="round"
    >
      <path d="M8 39 H55 L73 39 L87 18 L108 59 L128 27 L143 39 H200 L216 24 H252" />
      <path d="M143 39 L159 55 H186" opacity="0.38" />
      <path d="M55 39 L70 56 H90" opacity="0.38" />
      <path d="M200 39 L217 53 H247" opacity="0.38" />
    </g>

    {[ [8,39], [252,24], [186,55], [90,56], [247,53] ].map(
      ([cx, cy], index) => (
        <circle
          key={index}
          cx={cx}
          cy={cy}
          r={index === 1 ? 4 : 3}
          fill="currentColor"
        />
      )
    )}
  </svg>
</div>

          <h1>
            Más allá
            <br />
            del <em>marcador.</em>
          </h1>

         

          <div className="premium-benefits">
            <span>
              <BarChart3 size={22} />
              Estadísticas
              <br />
              reales
            </span>

            <span>
              <Users size={22} />
              Análisis de
              <br />
              jugadores
            </span>

            <span>
              <ShieldCheck size={23} />
              Decisiones
              <br />
              más inteligentes
            </span>
          </div>
        </div>
      </section>

      <section className="premium-auth">
        <form
          className="premium-form"
          onSubmit={handleSubmit}
        >
          <div className="premium-mobile-brand">
            <img src={futpredictMark} alt="" />

            <strong>
              FUT<span>PREDICT</span>
            </strong>
          </div>

          <span className="eyebrow green-text">
            WELCOME <span aria-hidden="true"></span>
          </span>

          <h2>Inicia sesión</h2>

          <p className="premium-subtitle">
            Ingresa para explorar los datos del fútbol.
          </p>

          <label htmlFor="email">
            Correo electrónico
          </label>

          <div className="premium-field">
            <Mail size={20} aria-hidden="true" />

            <input
              id="email"
              name="email"
              type="email"
              autoComplete="email"
              placeholder="nombre@ejemplo.com"
              value={email}
              onChange={(event) =>
                setEmail(event.target.value)
              }
              required
            />
          </div>

          <label htmlFor="password">
            Contraseña
          </label>

          <div className="premium-field">
            <LockKeyhole
              size={20}
              aria-hidden="true"
            />

            <input
              id="password"
              name="password"
              type={showPassword ? 'text' : 'password'}
              autoComplete="current-password"
              placeholder="Ingresa tu contraseña"
              value={password}
              onChange={(event) =>
                setPassword(event.target.value)
              }
              required
            />

            <button
              className="premium-password-toggle"
              type="button"
              onClick={() =>
                setShowPassword((value) => !value)
              }
              aria-label={
                showPassword
                  ? 'Ocultar contraseña'
                  : 'Mostrar contraseña'
              }
              aria-pressed={showPassword}
            >
              {showPassword ? (
                <Eye size={19} />
              ) : (
                <EyeOff size={19} />
              )}
            </button>
          </div>

          <div className="premium-form-options">
            <label className="premium-remember">
              <input
                type="checkbox"
                checked={rememberMe}
                onChange={(event) =>
                  setRememberMe(event.target.checked)
                }
              />
              Recordarme
            </label>

            <button
              type="button"
              className="premium-forgot"
              onClick={() =>
                setHelpMessage((value) => !value)
              }
            >
              ¿Olvidaste tu contraseña?
            </button>
          </div>

          {helpMessage && (
            <p className="premium-help" role="status">
              La recuperación de contraseña estará
              disponible cuando se integre el acceso real.
            </p>
          )}

          <button
            className="premium-submit"
            type="submit"
          >
            Ingresar
            <ArrowRight size={20} />
          </button>

         
        </form>
      </section>
    </main>
  );
}

// TARJETAS DE ESTADÍSTICAS
function StatCard({
  title,
  value,
  note,
  icon: Icon,
  trend,
}) {
  return (
    <article className="stat-card">
      <div className="stat-top">
        <span className="stat-title">
          {title}
        </span>

        <span className="stat-icon">
          <Icon size={21} />
        </span>
      </div>

      <div className="stat-value">
        {value}
      </div>

      <div className="stat-bottom">
        <span className="stat-note">
          {note}
        </span>

        {trend && (
          <span className="trend">
            <ArrowUpRight size={15} />
            {trend}
          </span>
        )}
      </div>
    </article>
  );
}

// DASHBOARD Y SECCIONES
function Dashboard({
  activePage,
  setActivePage,
}) {
  const [search, setSearch] = useState('');
  const [mobileMenu, setMobileMenu] = useState(false);
  const [equipos, setEquipos] = useState([]);
const [cargandoEquipos, setCargandoEquipos] = useState(true);
const [errorEquipos, setErrorEquipos] = useState('');

useEffect(() => {
  async function cargarEquipos() {
    try {
      const respuesta = await fetch(`${API_URL}/api/equipos`);

      if (!respuesta.ok) {
        throw new Error('No se pudieron cargar los equipos');
      }

      const datos = await respuesta.json();
      setEquipos(datos);
    } catch (error) {
      setErrorEquipos(error.message);
    } finally {
      setCargandoEquipos(false);
    }
  }

  cargarEquipos();
}, []);

  // Datos de SQL Server
  const resumen = useApi('/api/resumen', null);
  const jugadoresApi = useApi('/api/jugadores');
  const partidosApi = useApi('/api/partidos');
  const ligasApi = useApi('/api/ligas');
  const tablaEquiposApi = useApi('/api/estadisticas/equipos');

  // Datos de MongoDB (Unidad 2)
  const goleadoresMongo = useApi('/api/mongo/goleadores');
  const ligasMongo = useApi('/api/mongo/ligas');

  const players = jugadoresApi.datos.map(adaptarJugador);
  const matches = partidosApi.datos.map(adaptarPartido);
  const recentMatches = matches.slice(0, 4);

  // Jugadores destacados: mejor calificación promedio (fn_PromedioCalificacionJugador)
  const featuredPlayers = [...players]
    .filter((player) => player.rating !== null && player.rating !== undefined)
    .sort((a, b) => b.rating - a.rating)
    .slice(0, 3);

  // Valor de un contador del dashboard según el estado de /api/resumen
  const contador = (campo) =>
    resumen.cargando ? '...' : resumen.error || !resumen.datos ? '—' : resumen.datos[campo];

  const filteredPlayers = players.filter((player) =>
    `${player.name} ${player.team} ${player.position}`
      .toLowerCase()
      .includes(search.toLowerCase())
  );

  const pageDescriptions = {
    Dashboard:
      'Una visión general del rendimiento futbolístico.',
    Jugadores:
      'Explora y compara el rendimiento de los jugadores.',
    Equipos:
      'Consulta los equipos registrados en FutPredict.',
    Partidos:
      'Revisa resultados y encuentros registrados.',
    Estadísticas:
      'Consulta los indicadores disponibles en la plataforma.',
    Análisis:
      'Explora el rendimiento a partir de los datos deportivos.',
  };

  return (
    <div className="app-shell">
      {mobileMenu && (
        <button
          className="mobile-overlay"
          onClick={() => setMobileMenu(false)}
          aria-label="Cerrar menú"
        />
      )}

      <aside
        className={`sidebar ${
          mobileMenu ? 'sidebar-open' : ''
        }`}
      >
        <div className="sidebar-brand">
          <div className="brand-mark">
            <Activity size={24} />
          </div>

          <div className="brand-name">
            FUT<span>PREDICT</span>
            <small>SPORTS ANALYTICS</small>
          </div>

          <button
            className="close-menu"
            onClick={() => setMobileMenu(false)}
            aria-label="Cerrar menú"
          >
            <X size={20} />
          </button>
        </div>

        <div className="menu-caption">
          MENÚ PRINCIPAL
        </div>

        <nav className="nav-menu">
          {menuItems.map(({ label, icon: Icon }) => (
            <button
              key={label}
              className={`nav-item ${
                activePage === label
                  ? 'nav-active'
                  : ''
              }`}
              onClick={() => {
                setActivePage(label);
                setMobileMenu(false);
              }}
            >
              <Icon size={19} />
              <span>{label}</span>

              {activePage === label && (
                <span className="active-indicator" />
              )}
            </button>
          ))}
        </nav>

        <div className="sidebar-bottom">
          <div className="help-card">
            <div className="help-icon">
              <CircleHelp size={20} />
            </div>

            <strong>¿Necesitas ayuda?</strong>

            <p>
              Explora los datos y conoce mejor el juego.
            </p>
          </div>

          <div className="sidebar-user">
            <div className="user-avatar">
              JF
            </div>

            <div className="user-info">
              <strong>Julissa</strong>
              <span>Analista</span>
            </div>

            <ChevronDown size={16} />
          </div>
        </div>
      </aside>

      <main className="main-area">
        <header className="topbar">
          <button
            className="mobile-menu-button"
            onClick={() => setMobileMenu(true)}
            aria-label="Abrir menú"
          >
            <Menu size={22} />
          </button>

          <div className="breadcrumb">
            FutPredict <span>/</span>{' '}
            <strong>{activePage}</strong>
          </div>

          <div className="topbar-actions">
            <div className="search-box">
              <Search size={17} />

              <input
                aria-label="Buscar jugadores"
                placeholder="Buscar jugadores..."
                value={search}
                onChange={(event) => {
                  setSearch(event.target.value);
                  setActivePage('Jugadores');
                }}
              />

              <kbd>⌘ K</kbd>
            </div>

            <button
              className="icon-button notification-button"
              aria-label="Notificaciones"
            >
              <Bell size={19} />
              <i />
            </button>

            <div className="topbar-avatar">
              JF
            </div>
          </div>
        </header>

        <div className="page-content">
          <section className="welcome-row">
            <div>
              <div className="eyebrow green-text">
                <span className="live-dot" />
                {' '}PLATAFORMA DE ANÁLISIS DEPORTIVO
              </div>

              <h1>
                {activePage === 'Dashboard'
                  ? 'Panel de control'
                  : activePage}
              </h1>

              <p>
                {pageDescriptions[activePage]}
              </p>
            </div>

            <div className="date-chip">
              <CalendarDays size={17} />
              Temporada 2026/2027
            </div>
          </section>

          {/* DASHBOARD */}
          {activePage === 'Dashboard' && (
            <>
              <section className="stats-grid">
                <StatCard
                  title="Jugadores"
                  value={contador('jugadores')}
                  note="Registrados en la base de datos"
                  icon={Users}
                />

                <StatCard
                  title="Equipos"
                  value={cargandoEquipos ? '...' : errorEquipos ? '—' : equipos.length}
                  note="Equipos registrados"
                  icon={Shield}
                />

                <StatCard
                  title="Partidos"
                  value={contador('partidos')}
                  note="Encuentros registrados"
                  icon={Trophy}
                />

                <StatCard
                  title="Ligas"
                  value={contador('ligas')}
                  note="Competiciones registradas"
                  icon={BarChart3}
                />
              </section>

              <section className="content-grid">
                <article className="panel matches-panel">
                  <div className="panel-heading">
                    <div>
                      <h2>Partidos recientes</h2>
                      <p>
                        Resultados registrados en la plataforma
                      </p>
                    </div>

                    <button
                      className="text-button"
                      onClick={() =>
                        setActivePage('Partidos')
                      }
                    >
                      Ver todos
                      <ArrowRight size={16} />
                    </button>
                  </div>

                  <EstadoCarga
                    cargando={partidosApi.cargando}
                    error={partidosApi.error}
                    vacio={matches.length === 0}
                    que="partidos"
                  />

                  <div className="matches-list">
                    {recentMatches.map((match) => (
                      <div
                        className="match-row"
                        key={match.id}
                      >
                        <div className="match-date">
                          {match.date}
                        </div>

                        <div className="match-teams">
                          <div className="match-team">
                            <div className="team-badge">
                              {match.initials[0]}
                            </div>
                            <span>{match.home}</span>
                          </div>

                          <div className="match-team">
                            <div className="team-badge">
                              {match.initials[1]}
                            </div>
                            <span>{match.away}</span>
                          </div>
                        </div>

                        <div className="match-score">
                          <strong>
                            {match.homeScore}
                          </strong>
                          <strong>
                            {match.awayScore}
                          </strong>
                        </div>

                        <span className="status-pill">
                          {match.status}
                        </span>
                      </div>
                    ))}
                  </div>

                  <div className="panel-footer">
                    <ClipboardList size={16} />
                    Datos consultados en SQL Server
                    (vista vw_PartidosDetallados)
                  </div>
                </article>

                <article className="panel leaders-panel">
                  <div className="panel-heading">
                    <div>
                      <h2>Jugadores destacados</h2>
                      <p>
                        Mejor calificación promedio
                      </p>
                    </div>

                    <button
                      className="small-icon-button"
                      onClick={() =>
                        setActivePage('Jugadores')
                      }
                      aria-label="Ver jugadores"
                    >
                      <ArrowRight size={17} />
                    </button>
                  </div>

                  <EstadoCarga
                    cargando={jugadoresApi.cargando}
                    error={jugadoresApi.error}
                    vacio={featuredPlayers.length === 0}
                    que="jugadores"
                  />

                  <div className="leaders-list">
                    {featuredPlayers.map((player, index) => (
                      <div
                        className="leader-row"
                        key={player.id}
                      >
                        <div
                          className={`player-avatar player-color-${index}`}
                        >
                          {player.initials}
                        </div>

                        <div className="leader-info">
                          <strong>
                            {player.name}
                          </strong>
                          <span>
                            {player.team}
                          </span>
                        </div>

                        <div className="rating">
                          <Trophy size={13} />
                          {formatearCalificacion(player.rating)}
                        </div>
                      </div>
                    ))}
                  </div>

                  <button
                    className="outline-button"
                    onClick={() =>
                      setActivePage('Jugadores')
                    }
                  >
                    Explorar jugadores
                    <ArrowRight size={16} />
                  </button>
                </article>
              </section>

              <section className="insight-banner">
                <div className="insight-icon">
                  <Zap size={23} />
                </div>

                <div>
                  <strong>
                    Los datos cuentan una historia
                  </strong>

                  <p>
                    Compara estadísticas, revisa resultados
                    y encuentra patrones de rendimiento.
                  </p>
                </div>

                <button
                  onClick={() =>
                    setActivePage('Análisis')
                  }
                >
                  Explorar análisis
                  <ArrowRight size={16} />
                </button>
              </section>
            </>
          )}

          {/* JUGADORES */}
          {activePage === 'Jugadores' && (
            <section className="panel directory-panel">
              <div className="panel-heading">
                <div>
                  <h2>Directorio de jugadores</h2>

                  <p>
                    {filteredPlayers.length} de {players.length} jugadores
                    registrados en la base de datos
                  </p>
                </div>
              </div>

              <EstadoCarga
                cargando={jugadoresApi.cargando}
                error={jugadoresApi.error}
                vacio={false}
                que="jugadores"
              />

              <div className="player-grid">
                {filteredPlayers.map((player, index) => (
                  <article
                    className="player-card"
                    key={player.id}
                  >
                    <div
                      className={`player-cover cover-${index % 3}`}
                    >
                      <div className="player-large-avatar">
                        {player.initials}
                      </div>

                      <span className="rating-badge">
                        <Trophy size={13} />
                        {formatearCalificacion(player.rating)}
                      </span>
                    </div>

                    <div className="player-card-content">
                      <span className="position-label">
                        {player.position}
                      </span>

                      <h3>{player.name}</h3>
                      <p>{player.team}</p>

                      <div className="player-metrics">
                        <div>
                          <strong>
                            {player.goals}
                          </strong>
                          <span>Goles</span>
                        </div>

                        <div>
                          <strong>
                            {player.assists}
                          </strong>
                          <span>Asistencias</span>
                        </div>

                        <div>
                          <strong>
                            {formatearCalificacion(player.rating)}
                          </strong>
                          <span>Calificación</span>
                        </div>
                      </div>
                    </div>
                  </article>
                ))}

                {!jugadoresApi.cargando &&
                  !jugadoresApi.error &&
                  filteredPlayers.length === 0 && (
                  <p className="empty-state">
                    No se encontraron jugadores
                    con esa búsqueda.
                  </p>
                )}
              </div>

              <p className="demo-disclaimer">
                Equipo actual según JugadorEquipo; calificación
                promedio calculada con fn_PromedioCalificacionJugador.
              </p>
            </section>
          )}

          {/* EQUIPOS */}
          {activePage === 'Equipos' && (
            <section className="panel directory-panel">
              <div className="panel-heading">
                <div>
                  <h2>Equipos registrados</h2>
                  <p>
                    Equipos incluidos en los datos de FutPredict.
                  </p>
                </div>
              </div>

            {cargandoEquipos && (
                <p>Cargando equipos desde FutPredict...</p>
              )}

              {errorEquipos && (
                <p role="alert" style={{ color: '#b91c1c' }}>
                  No se pudieron cargar los equipos. Verifica que el servidor esté funcionando.
                </p>
              )}

              {!cargandoEquipos && !errorEquipos && equipos.length === 0 && (
                <p>No hay equipos registrados en la base de datos.</p>
              )}


              <div className="team-grid">
                {equipos.map(({ nombre: name, pais: country }, index) => (
                  <article
                    className="team-card"
                    key={name}
                  >
                    <div
                      className={`team-logo team-logo-${index % 4}`}
                    >
                      {name
                     .split(' ')
                    .filter((palabra) => !['de', 'del', 'la', 'el'].includes(palabra.toLowerCase()))
                    .slice(0, 2)
                    .map((palabra) => palabra[0])
                    .join('')
                    .toUpperCase()}
                    </div>

                    <div>
                      <h3>{name}</h3>
                      <p>
                        <Shield size={14} />
                        {country}
                      </p>
                    </div>

                    <ArrowRight
                      className="team-arrow"
                      size={18}
                    />
                  </article>
                ))}
              </div>

              <p className="demo-disclaimer">
                Los escudos son marcadores gráficos
                temporales; se pueden reemplazar
                por imágenes de los equipos.
              </p>
            </section>
          )}

          {/* PARTIDOS */}
          {activePage === 'Partidos' && (
            <section className="panel directory-panel">
              <div className="panel-heading">
                <div>
                  <h2>Resultados de partidos</h2>
                  <p>
                    {matches.length} encuentros registrados
                    en la base de datos.
                  </p>
                </div>
              </div>

              <EstadoCarga
                cargando={partidosApi.cargando}
                error={partidosApi.error}
                vacio={matches.length === 0}
                que="partidos"
              />

              <div className="matches-list full-matches">
                {matches.map((match) => (
                  <div
                    className="match-row"
                    key={match.id}
                  >
                    <div className="match-date">
                      {match.date}
                    </div>

                    <div className="match-teams">
                      <div className="match-team">
                        <div className="team-badge">
                          {match.initials[0]}
                        </div>
                        <span>{match.home}</span>
                      </div>

                      <div className="match-team">
                        <div className="team-badge">
                          {match.initials[1]}
                        </div>
                        <span>{match.away}</span>
                      </div>
                    </div>

                    <div className="match-score">
                      <strong>
                        {match.homeScore}
                      </strong>
                      <strong>
                        {match.awayScore}
                      </strong>
                    </div>

                    <span className="status-pill">
                      {match.status}
                    </span>
                  </div>
                ))}
              </div>
            </section>
          )}

          {/* ESTADÍSTICAS Y ANÁLISIS */}
          {(activePage === 'Estadísticas' ||
            activePage === 'Análisis') && (
            <section className="analysis-grid">
              <article className="panel analysis-card">
                <div className="analysis-symbol">
                  <BarChart3 size={24} />
                </div>

                <h2>Rendimiento de jugadores</h2>

                <p>
                  Consulta goles, asistencias,
                  minutos jugados y calificaciones.
                </p>

                <button
                  className="text-button"
                  onClick={() =>
                    setActivePage('Jugadores')
                  }
                >
                  Ver jugadores
                  <ArrowRight size={16} />
                </button>
              </article>

              <article className="panel analysis-card">
                <div className="analysis-symbol">
                  <Shield size={24} />
                </div>

                <h2>Rendimiento de equipos</h2>

                <p>
                  Explora resultados y estadísticas
                  asociadas a cada equipo.
                </p>

                <button
                  className="text-button"
                  onClick={() =>
                    setActivePage('Equipos')
                  }
                >
                  Ver equipos
                  <ArrowRight size={16} />
                </button>
              </article>

              <article className="panel analysis-card">
                <div className="analysis-symbol">
                  <Activity size={24} />
                </div>

                <h2>Modelos predictivos</h2>

                <p>
                  Espacio preparado para incorporar
                  análisis predictivo en una etapa posterior.
                </p>

                <span className="coming-soon">
                  Próximamente
                </span>
              </article>
            </section>
          )}

          {/* ESTADÍSTICAS: datos de SQL Server */}
          {activePage === 'Estadísticas' && (
            <section className="data-sections">
              <article className="panel directory-panel">
                <div className="panel-heading">
                  <div>
                    <h2>Rendimiento por equipo</h2>
                    <p>
                      Calculado en SQL Server a partir de la vista
                      vw_RendimientoEquipos.
                    </p>
                  </div>
                </div>

                <EstadoCarga
                  cargando={tablaEquiposApi.cargando}
                  error={tablaEquiposApi.error}
                  vacio={tablaEquiposApi.datos.length === 0}
                  que="estadísticas de equipos"
                />

                {tablaEquiposApi.datos.length > 0 && (
                  <div className="table-wrapper">
                    <table className="data-table">
                      <thead>
                        <tr>
                          <th>Equipo</th>
                          <th>PJ</th>
                          <th>G</th>
                          <th>E</th>
                          <th>P</th>
                          <th>GF</th>
                          <th>GC</th>
                          <th>Posesión</th>
                          <th>Pts</th>
                        </tr>
                      </thead>
                      <tbody>
                        {tablaEquiposApi.datos.map((fila) => (
                          <tr key={fila.equipo}>
                            <td>{fila.equipo}</td>
                            <td>{fila.partidos}</td>
                            <td>{fila.ganados}</td>
                            <td>{fila.empatados}</td>
                            <td>{fila.perdidos}</td>
                            <td>{fila.goles_favor}</td>
                            <td>{fila.goles_contra}</td>
                            <td>
                              {fila.posesion_promedio === null
                                ? '—'
                                : `${Number(fila.posesion_promedio).toFixed(1)}%`}
                            </td>
                            <td><strong>{fila.puntos}</strong></td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  </div>
                )}
              </article>

              <article className="panel directory-panel">
                <div className="panel-heading">
                  <div>
                    <h2>Ligas registradas</h2>
                    <p>
                      Competiciones con su cantidad de equipos y partidos.
                    </p>
                  </div>
                </div>

                <EstadoCarga
                  cargando={ligasApi.cargando}
                  error={ligasApi.error}
                  vacio={ligasApi.datos.length === 0}
                  que="ligas"
                />

                {ligasApi.datos.length > 0 && (
                  <div className="table-wrapper">
                    <table className="data-table">
                      <thead>
                        <tr>
                          <th>Liga</th>
                          <th>País</th>
                          <th>Tipo</th>
                          <th>Equipos</th>
                          <th>Partidos</th>
                        </tr>
                      </thead>
                      <tbody>
                        {ligasApi.datos.map((liga) => (
                          <tr key={liga.liga_id}>
                            <td>{liga.nombre}</td>
                            <td>{liga.pais}</td>
                            <td>{liga.tipo}</td>
                            <td>{liga.equipos}</td>
                            <td>{liga.partidos}</td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  </div>
                )}
              </article>
            </section>
          )}

          {/* ANÁLISIS: datos de MongoDB (Unidad 2) */}
          {activePage === 'Análisis' && (
            <section className="data-sections">
              <article className="panel directory-panel">
                <div className="panel-heading">
                  <div>
                    <h2>Jugadores con más aportes de gol</h2>
                    <p>
                      Aggregation Framework de MongoDB:
                      $unwind, $group y $lookup.
                    </p>
                  </div>
                </div>

                {goleadoresMongo.cargando && (
                  <p className="empty-state">Consultando MongoDB...</p>
                )}

                {goleadoresMongo.error && (
                  <p className="empty-state">
                    MongoDB no está disponible. Ejecuta la migración
                    (database/mongodb) e instala el paquete mongodb en el backend.
                  </p>
                )}

                {goleadoresMongo.datos.length > 0 && (
                  <div className="table-wrapper">
                    <table className="data-table">
                      <thead>
                        <tr>
                          <th>Jugador</th>
                          <th>Equipo</th>
                          <th>Goles</th>
                          <th>Asist.</th>
                          <th>G+A</th>
                          <th>Calif.</th>
                        </tr>
                      </thead>
                      <tbody>
                        {goleadoresMongo.datos.map((fila) => (
                          <tr key={fila.jugador_id}>
                            <td>{fila.nombre}</td>
                            <td>{fila.equipo || '—'}</td>
                            <td>{fila.goles}</td>
                            <td>{fila.asistencias}</td>
                            <td><strong>{fila.contribuciones}</strong></td>
                            <td>{formatearCalificacion(fila.calificacion)}</td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  </div>
                )}
              </article>

              <article className="panel directory-panel">
                <div className="panel-heading">
                  <div>
                    <h2>Promedios por liga</h2>
                    <p>Goles y tiros por partido calculados en MongoDB.</p>
                  </div>
                </div>

                {ligasMongo.cargando && (
                  <p className="empty-state">Consultando MongoDB...</p>
                )}

                {ligasMongo.error && (
                  <p className="empty-state">MongoDB no está disponible.</p>
                )}

                {ligasMongo.datos.length > 0 && (
                  <div className="table-wrapper">
                    <table className="data-table">
                      <thead>
                        <tr>
                          <th>Liga</th>
                          <th>Partidos</th>
                          <th>Goles</th>
                          <th>Goles/partido</th>
                          <th>Tiros/partido</th>
                        </tr>
                      </thead>
                      <tbody>
                        {ligasMongo.datos.map((fila) => (
                          <tr key={fila.liga}>
                            <td>{fila.liga}</td>
                            <td>{fila.partidos}</td>
                            <td>{fila.goles}</td>
                            <td><strong>{fila.goles_por_partido}</strong></td>
                            <td>{fila.tiros_por_partido}</td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  </div>
                )}
              </article>
            </section>
          )}

          <footer className="page-footer">
            <span>© 2026 FutPredict</span>

            <span>
              Proyecto académico · Analítica deportiva
            </span>
          </footer>
        </div>
      </main>
    </div>
  );
}

// COMPONENTE PRINCIPAL
export default function App() {
  const [loggedIn, setLoggedIn] = useState(false);
  const [activePage, setActivePage] =
    useState('Dashboard');

  if (!loggedIn) {
    return (
      <Login
        onLogin={() => setLoggedIn(true)}
      />
    );
  }

  return (
    <>
      <Dashboard
        activePage={activePage}
        setActivePage={setActivePage}
      />

      <button
        className="logout-button"
        onClick={() => setLoggedIn(false)}
        title="Cerrar sesión"
        aria-label="Cerrar sesión"
      >
        <LogOut size={18} />
      </button>
    </>
  );
}

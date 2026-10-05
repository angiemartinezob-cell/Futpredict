
import { useState } from 'react';
import {
  Activity,
  ArrowDownRight,
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
} from 'lucide-react';

const players = [
  { name: 'Jugador Barcelona 1', position: 'Delantero', team: 'FC Barcelona', goals: 8, assists: 4, rating: 9.2, initials: 'JB' },
  { name: 'Jugador Madrid 1', position: 'Mediocampista', team: 'Real Madrid', goals: 5, assists: 6, rating: 8.8, initials: 'JM' },
  { name: 'Jugador City 1', position: 'Delantero', team: 'Manchester City', goals: 7, assists: 3, rating: 8.6, initials: 'JC' },
];

const matches = [
  { home: 'FC Barcelona', away: 'Real Madrid', homeScore: 2, awayScore: 1, date: '10 sep 2026', status: 'Finalizado', initials: ['FC', 'RM'] },
  { home: 'Manchester City', away: 'Liverpool', homeScore: 3, awayScore: 2, date: '12 sep 2026', status: 'Finalizado', initials: ['MC', 'LI'] },
  { home: 'Inter de Milan', away: 'Juventus', homeScore: 1, awayScore: 1, date: '14 sep 2026', status: 'Finalizado', initials: ['IN', 'JU'] },
  { home: 'Bayern Munich', away: 'Borussia Dortmund', homeScore: 2, awayScore: 0, date: '16 sep 2026', status: 'Finalizado', initials: ['BM', 'BD'] },
];

const menuItems = [
  { label: 'Dashboard', icon: Home },
  { label: 'Jugadores', icon: Users },
  { label: 'Equipos', icon: Shield },
  { label: 'Partidos', icon: Trophy },
  { label: 'Estadísticas', icon: BarChart3 },
  { label: 'Análisis', icon: Activity },
];

function Login({ onLogin }) {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');

  function handleSubmit(event) {
    event.preventDefault();
    onLogin();
  }

  return (
    <main className="login-page">
      <div className="login-decoration">
        <div className="pitch pitch-one" />
        <div className="pitch pitch-two" />
        <div className="login-brand">
          <div className="brand-mark"><Activity size={29} /></div>
          <span>FUT<span className="brand-light">PREDICT</span></span>
        </div>
        <div className="login-message">
          <span className="eyebrow">DATOS QUE MARCAN LA DIFERENCIA</span>
          <h1>El fútbol se juega.<br />Los datos lo explican.</h1>
          <p>Analiza el rendimiento, compara jugadores y descubre nuevas perspectivas del juego.</p>
          <div className="login-features">
            <span><Activity size={17} /> Análisis deportivo</span>
            <span><ShieldCheck size={17} /> Datos centralizados</span>
          </div>
        </div>
        <span className="login-footer">FUTPREDICT · ANALÍTICA DEPORTIVA</span>
      </div>

      <section className="login-form-side">
        <form className="login-card" onSubmit={handleSubmit}>
          <div className="mobile-brand">
            <div className="brand-mark"><Activity size={24} /></div>
            <strong>FUT<span className="brand-light">PREDICT</span></strong>
          </div>
          <span className="eyebrow green-text">BIENVENIDO DE NUEVO</span>
          <h2>Inicia sesión</h2>
          <p className="muted">Ingresa para explorar los datos del fútbol.</p>

          <label htmlFor="email">Correo electrónico</label>
          <input
            id="email"
            type="email"
            placeholder="nombre@ejemplo.com"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            required
          />

          <label htmlFor="password">Contraseña</label>
          <input
            id="password"
            type="password"
            placeholder="Ingresa tu contraseña"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            required
          />

          <button className="primary-button login-button" type="submit">
            Ingresar <ArrowRight size={18} />
          </button>
          <p className="demo-note">
            Prototipo académico: el inicio de sesión es demostrativo y todavía no valida usuarios.
          </p>
        </form>
      </section>
    </main>
  );
}

function StatCard({ title, value, note, icon: Icon, trend }) {
  return (
    <article className="stat-card">
      <div className="stat-top">
        <span className="stat-title">{title}</span>
        <span className="stat-icon"><Icon size={21} /></span>
      </div>
      <div className="stat-value">{value}</div>
      <div className="stat-bottom">
        <span className="stat-note">{note}</span>
        {trend && <span className="trend"><ArrowUpRight size={15} /> {trend}</span>}
      </div>
    </article>
  );
}

function Dashboard({ activePage, setActivePage }) {
  const [search, setSearch] = useState('');
  const [mobileMenu, setMobileMenu] = useState(false);

  const filteredPlayers = players.filter((player) =>
    `${player.name} ${player.team} ${player.position}`
      .toLowerCase()
      .includes(search.toLowerCase())
  );

  const pageDescriptions = {
    Dashboard: 'Una visión general del rendimiento futbolístico.',
    Jugadores: 'Explora y compara el rendimiento de los jugadores.',
    Equipos: 'Consulta los equipos registrados en FutPredict.',
    Partidos: 'Revisa resultados y encuentros registrados.',
    Estadísticas: 'Consulta los indicadores disponibles en la plataforma.',
    Análisis: 'Explora el rendimiento a partir de los datos deportivos.',
  };

  return (
    <div className="app-shell">
      {mobileMenu && <button className="mobile-overlay" onClick={() => setMobileMenu(false)} aria-label="Cerrar menú" />}

      <aside className={`sidebar ${mobileMenu ? 'sidebar-open' : ''}`}>
        <div className="sidebar-brand">
          <div className="brand-mark"><Activity size={24} /></div>
          <div className="brand-name">FUT<span>PREDICT</span><small>SPORTS ANALYTICS</small></div>
          <button className="close-menu" onClick={() => setMobileMenu(false)} aria-label="Cerrar menú"><X size={20} /></button>
        </div>

        <div className="menu-caption">MENÚ PRINCIPAL</div>
        <nav className="nav-menu">
          {menuItems.map(({ label, icon: Icon }) => (
            <button
              key={label}
              className={`nav-item ${activePage === label ? 'nav-active' : ''}`}
              onClick={() => { setActivePage(label); setMobileMenu(false); }}
            >
              <Icon size={19} />
              <span>{label}</span>
              {activePage === label && <span className="active-indicator" />}
            </button>
          ))}
        </nav>

        <div className="sidebar-bottom">
          <div className="help-card">
            <div className="help-icon"><CircleHelp size={20} /></div>
            <strong>¿Necesitas ayuda?</strong>
            <p>Explora los datos y conoce mejor el juego.</p>
          </div>
          <div className="sidebar-user">
            <div className="user-avatar">JF</div>
            <div className="user-info"><strong>Julissa</strong><span>Analista</span></div>
            <ChevronDown size={16} />
          </div>
        </div>
      </aside>

      <main className="main-area">
        <header className="topbar">
          <button className="mobile-menu-button" onClick={() => setMobileMenu(true)} aria-label="Abrir menú"><Menu size={22} /></button>
          <div className="breadcrumb">FutPredict <span>/</span> <strong>{activePage}</strong></div>
          <div className="topbar-actions">
            <div className="search-box">
              <Search size={17} />
              <input
                aria-label="Buscar jugadores"
                placeholder="Buscar jugadores..."
                value={search}
                onChange={(e) => { setSearch(e.target.value); setActivePage('Jugadores'); }}
              />
              <kbd>⌘ K</kbd>
            </div>
            <button className="icon-button notification-button" aria-label="Notificaciones"><Bell size={19} /><i /></button>
            <div className="topbar-avatar">JF</div>
          </div>
        </header>

        <div className="page-content">
          <section className="welcome-row">
            <div>
              <div className="eyebrow green-text"><span className="live-dot" /> PLATAFORMA DE ANÁLISIS DEPORTIVO</div>
              <h1>{activePage === 'Dashboard' ? 'Panel de control' : activePage}</h1>
              <p>{pageDescriptions[activePage]}</p>
            </div>
            <div className="date-chip"><CalendarDays size={17} /> Temporada 2026/2027</div>
          </section>

          {activePage === 'Dashboard' && (
            <>
              <section className="stats-grid">
                <StatCard title="Jugadores" value="20" note="Registrados en la base de datos" icon={Users} />
                <StatCard title="Equipos" value="10" note="Equipos registrados" icon={Shield} />
                <StatCard title="Partidos" value="5" note="Encuentros registrados" icon={Trophy} />
                <StatCard title="Ligas" value="6" note="Competiciones registradas" icon={BarChart3} />
              </section>

              <section className="content-grid">
                <article className="panel matches-panel">
                  <div className="panel-heading">
                    <div><h2>Partidos recientes</h2><p>Resultados registrados en la plataforma</p></div>
                    <button className="text-button" onClick={() => setActivePage('Partidos')}>Ver todos <ArrowRight size={16} /></button>
                  </div>
                  <div className="matches-list">
                    {matches.map((match) => (
                      <div className="match-row" key={`${match.home}-${match.away}`}>
                        <div className="match-date">{match.date}</div>
                        <div className="match-teams">
                          <div className="match-team">
                            <div className="team-badge">{match.initials[0]}</div>
                            <span>{match.home}</span>
                          </div>
                          <div className="match-team">
                            <div className="team-badge">{match.initials[1]}</div>
                            <span>{match.away}</span>
                          </div>
                        </div>
                        <div className="match-score">
                          <strong>{match.homeScore}</strong><strong>{match.awayScore}</strong>
                        </div>
                        <span className="status-pill">{match.status}</span>
                      </div>
                    ))}
                  </div>
                  <div className="panel-footer"><ClipboardList size={16} /> Datos de ejemplo basados en los registros del proyecto</div>
                </article>

                <article className="panel leaders-panel">
                  <div className="panel-heading">
                    <div><h2>Jugadores destacados</h2><p>Ejemplo de rendimiento individual</p></div>
                    <button className="small-icon-button" onClick={() => setActivePage('Jugadores')} aria-label="Ver jugadores"><ArrowRight size={17} /></button>
                  </div>
                  <div className="leaders-list">
                    {players.map((player, index) => (
                      <div className="leader-row" key={player.name}>
                        <div className={`player-avatar player-color-${index}`}>{player.initials}</div>
                        <div className="leader-info"><strong>{player.name}</strong><span>{player.team}</span></div>
                        <div className="rating"><Trophy size={13} /> {player.rating.toFixed(1)}</div>
                      </div>
                    ))}
                  </div>
                  <button className="outline-button" onClick={() => setActivePage('Jugadores')}>Explorar jugadores <ArrowRight size={16} /></button>
                </article>
              </section>

              <section className="insight-banner">
                <div className="insight-icon"><Zap size={23} /></div>
                <div><strong>Los datos cuentan una historia</strong><p>Compara estadísticas, revisa resultados y encuentra patrones de rendimiento.</p></div>
                <button onClick={() => setActivePage('Análisis')}>Explorar análisis <ArrowRight size={16} /></button>
              </section>
            </>
          )}

          {activePage === 'Jugadores' && (
            <section className="panel directory-panel">
              <div className="panel-heading">
                <div><h2>Directorio de jugadores</h2><p>{filteredPlayers.length} jugadores en esta vista de demostración</p></div>
              </div>
              <div className="player-grid">
                {filteredPlayers.map((player, index) => (
                  <article className="player-card" key={player.name}>
                    <div className={`player-cover cover-${index % 3}`}><div className="player-large-avatar">{player.initials}</div><span className="rating-badge"><Trophy size={13} /> {player.rating.toFixed(1)}</span></div>
                    <div className="player-card-content">
                      <span className="position-label">{player.position}</span>
                      <h3>{player.name}</h3><p>{player.team}</p>
                      <div className="player-metrics"><div><strong>{player.goals}</strong><span>Goles</span></div><div><strong>{player.assists}</strong><span>Asistencias</span></div><div><strong>{player.rating.toFixed(1)}</strong><span>Calificación</span></div></div>
                    </div>
                  </article>
                ))}
                {filteredPlayers.length === 0 && <p className="empty-state">No se encontraron jugadores con esa búsqueda.</p>}
              </div>
              <p className="demo-disclaimer">Esta vista usa datos ilustrativos. Próximo paso: consultar todos los jugadores desde la API.</p>
            </section>
          )}

          {activePage === 'Equipos' && (
            <section className="panel directory-panel">
              <div className="panel-heading"><div><h2>Equipos registrados</h2><p>Equipos incluidos en los datos de FutPredict.</p></div></div>
              <div className="team-grid">
                {[
                  ['FC Barcelona', 'España', 'FC'], ['Real Madrid', 'España', 'RM'],
                  ['Manchester City', 'Inglaterra', 'MC'], ['Liverpool', 'Inglaterra', 'LI'],
                  ['Inter de Milan', 'Italia', 'IN'], ['Juventus', 'Italia', 'JU'],
                  ['Bayern Munich', 'Alemania', 'BM'], ['Borussia Dortmund', 'Alemania', 'BD'],
                  ['Paris Saint-Germain', 'Francia', 'PS'], ['Olympique de Marseille', 'Francia', 'OM'],
                ].map(([name, country, initials], index) => (
                  <article className="team-card" key={name}>
                    <div className={`team-logo team-logo-${index % 4}`}>{initials}</div>
                    <div><h3>{name}</h3><p><Shield size={14} /> {country}</p></div>
                    <ArrowRight className="team-arrow" size={18} />
                  </article>
                ))}
              </div>
              <p className="demo-disclaimer">Los escudos son marcadores gráficos temporales; se pueden reemplazar por imágenes de los equipos.</p>
            </section>
          )}

          {activePage === 'Partidos' && (
            <section className="panel directory-panel">
              <div className="panel-heading"><div><h2>Resultados de partidos</h2><p>Encuentros de ejemplo registrados en la base de datos.</p></div></div>
              <div className="matches-list full-matches">
                {matches.map((match) => (
                  <div className="match-row" key={`${match.home}-${match.away}`}>
                    <div className="match-date">{match.date}</div>
                    <div className="match-teams">
                      <div className="match-team"><div className="team-badge">{match.initials[0]}</div><span>{match.home}</span></div>
                      <div className="match-team"><div className="team-badge">{match.initials[1]}</div><span>{match.away}</span></div>
                    </div>
                    <div className="match-score"><strong>{match.homeScore}</strong><strong>{match.awayScore}</strong></div>
                    <span className="status-pill">{match.status}</span>
                  </div>
                ))}
              </div>
            </section>
          )}

          {(activePage === 'Estadísticas' || activePage === 'Análisis') && (
            <section className="analysis-grid">
              <article className="panel analysis-card"><div className="analysis-symbol"><BarChart3 size={24} /></div><h2>Rendimiento de jugadores</h2><p>Consulta goles, asistencias, minutos jugados y calificaciones.</p><button className="text-button" onClick={() => setActivePage('Jugadores')}>Ver jugadores <ArrowRight size={16} /></button></article>
              <article className="panel analysis-card"><div className="analysis-symbol"><Shield size={24} /></div><h2>Rendimiento de equipos</h2><p>Explora resultados y estadísticas asociadas a cada equipo.</p><button className="text-button" onClick={() => setActivePage('Equipos')}>Ver equipos <ArrowRight size={16} /></button></article>
              <article className="panel analysis-card"><div className="analysis-symbol"><Activity size={24} /></div><h2>Modelos predictivos</h2><p>Espacio preparado para incorporar análisis predictivo en una etapa posterior.</p><span className="coming-soon">Próximamente</span></article>
            </section>
          )}

          <footer className="page-footer"><span>© 2026 FutPredict</span><span>Proyecto académico · Analítica deportiva</span></footer>
        </div>
      </main>
    </div>
  );
}

export default function App() {
  const [loggedIn, setLoggedIn] = useState(false);
  const [activePage, setActivePage] = useState('Dashboard');

  if (!loggedIn) return <Login onLogin={() => setLoggedIn(true)} />;

  return (
    <>
      <Dashboard activePage={activePage} setActivePage={setActivePage} />
      <button className="logout-button" onClick={() => setLoggedIn(false)} title="Cerrar sesión" aria-label="Cerrar sesión">
        <LogOut size={18} />
      </button>
    </>
  );
}

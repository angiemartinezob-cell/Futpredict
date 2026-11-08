// Conexión compartida con SQL Server.
// Los datos de conexión se leen del archivo .env (ver .env.example) para que
// cada integrante pueda usar su propia instancia sin modificar el código.
const path = require('path');
const sql = require('mssql/msnodesqlv8');

require('dotenv').config({ path: path.join(__dirname, '.env') });

const servidor = process.env.DB_SERVER || 'localhost';
const baseDatos = process.env.DB_DATABASE || 'FutPredictDB';
const driver = process.env.DB_DRIVER || 'ODBC Driver 18 for SQL Server';

const dbConfig = {
  connectionString:
    `Driver={${driver}};` +
    `Server=${servidor};` +
    `Database=${baseDatos};` +
    'Trusted_Connection=Yes;' +
    'Encrypt=Yes;' +
    'TrustServerCertificate=Yes;'
};

// Se reutiliza un solo pool de conexiones para todas las rutas,
// en lugar de abrir y cerrar una conexión en cada petición.
let poolPromise = null;

function obtenerPool() {
  if (!poolPromise) {
    poolPromise = new sql.ConnectionPool(dbConfig)
      .connect()
      .catch((error) => {
        poolPromise = null; // permite reintentar en la siguiente petición
        throw error;
      });
  }

  return poolPromise;
}

module.exports = { sql, dbConfig, obtenerPool };

const express = require('express');
const cors = require('cors');
const sql = require('mssql/msnodesqlv8');
require('dotenv').config();

const app = express();

app.use(cors());
app.use(express.json());

app.get('/api', (req, res) => {
  res.json({
    mensaje: '¡Bienvenido a la API de FutPredict!',
    estado: 'Servidor funcionando correctamente'
  });
});


// Configuración de la conexión con SQL Server
const dbConfig = {
  connectionString:
    'Driver={ODBC Driver 18 for SQL Server};' +
    'Server=localhost;' +
    'Database=FutPredictDB;' +
    'Trusted_Connection=Yes;' +
    'Encrypt=Yes;' +
    'TrustServerCertificate=Yes;'
};

// Consultar equipos registrados
app.get('/api/equipos', async (req, res) => {
  let conexion;

  try {
    conexion = await new sql.ConnectionPool(dbConfig).connect();

    const resultado = await conexion.request().query(`
      SELECT equipo_id, nombre, pais
      FROM Equipo
      ORDER BY equipo_id
    `);

    res.json(resultado.recordset);

  } catch (error) {
    console.error('Error al consultar equipos:', error.message);

    res.status(500).json({
      mensaje: 'No se pudieron consultar los equipos'
    });

  } finally {
    if (conexion) {
      await conexion.close();
    }
  }
});

const PORT = process.env.PORT || 3001;

app.listen(PORT, () => {
  console.log(`FutPredict API funcionando en http://localhost:${PORT}`);
});
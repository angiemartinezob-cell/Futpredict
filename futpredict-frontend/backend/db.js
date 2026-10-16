const sql = require('mssql/msnodesqlv8');

const config = {
  connectionString:
    'Driver={ODBC Driver 18 for SQL Server};' +
    'Server=localhost;' +
    'Database=FutPredictDB;' +
    'Trusted_Connection=Yes;' +
    'Encrypt=Yes;' +
    'TrustServerCertificate=Yes;'
};

async function probarConexion() {
  try {
    const conexion = await sql.connect(config);

    console.log('Conexión exitosa a FutPredictDB');

    const resultado = await conexion.request().query(`
      SELECT COUNT(*) AS TotalEquipos
      FROM Equipo
    `);

    console.log('Equipos registrados:', resultado.recordset[0].TotalEquipos);

  } catch (error) {
    console.error('Error de conexión:', error.message);
  } finally {
    await sql.close();
  }
}

probarConexion();
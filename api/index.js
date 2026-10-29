require('dotenv').config();
const app = require('./src/app');
const db = require('./src/config/database');

const PORT = process.env.PORT || 3000;

// Tes koneksi database sebelum memulai server
db.getConnection()
  .then((conn) => {
    console.log('✓ Terhubung ke basis data MySQL JejakMagang.');
    conn.release();

    app.listen(PORT, '0.0.0.0', () => {
      console.log(`===============================================`);
      console.log(`🚀 API JejakMagang aktif di http://localhost:${PORT}`);
      console.log(`   Healthcheck: http://localhost:${PORT}/api/health`);
      console.log(`===============================================`);
    });
  })
  .catch((err) => {
    console.error('✗ Gagal menghubungkan ke basis data MySQL:', err.message);
    process.exit(1);
  });


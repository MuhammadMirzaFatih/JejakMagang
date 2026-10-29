const fs = require('fs');
const path = require('path');
const mysql = require('mysql2/promise');
require('dotenv').config({ path: path.join(__dirname, '../../.env') });

async function runSeed() {
  console.log('Menjalankan migrasi skema dan pengisian data seed...');

  const connection = await mysql.createConnection({
    host: process.env.DB_HOST || '127.0.0.1',
    port: parseInt(process.env.DB_PORT || '3306', 10),
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '',
    multipleStatements: true
  });

  try {
    const schemaPath = path.join(__dirname, '../../../db/schema.sql');
    const seedPath = path.join(__dirname, '../../../db/seed.sql');

    const schemaSql = fs.readFileSync(schemaPath, 'utf8');
    const seedSql = fs.readFileSync(seedPath, 'utf8');

    console.log('1. Mengeksekusi schema.sql...');
    await connection.query(schemaSql);
    console.log('✓ Skema tabel berhasil dibuat.');

    console.log('2. Mengeksekusi seed.sql...');
    await connection.query(seedSql);
    console.log('✓ Data seed berhasil dimasukkan.');

    console.log('Selesai! Basis data siap digunakan.');
  } catch (error) {
    console.error('Gagal menjalankan seed:', error);
    process.exit(1);
  } finally {
    await connection.end();
  }
}

runSeed();


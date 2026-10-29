const express = require('express');
const cors = require('cors');

const authRoutes = require('./routes/authRoutes');
const lamaranRoutes = require('./routes/lamaranRoutes');
const statistikRoutes = require('./routes/statistikRoutes');

const app = express();

// Middleware dasar
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Log sederhana untuk pemantauan request
app.use((req, res, next) => {
  console.log(`[${new Date().toISOString()}] ${req.method} ${req.originalUrl}`);
  next();
});

// Endpoint Cek Kesehatan Server
app.get('/api/health', (req, res) => {
  res.status(200).json({
    status: 'OK',
    message: 'Server API JejakMagang berjalan dengan baik.',
    timestamp: new Date().toISOString()
  });
});

// Pendaftaran Rute API
app.use('/api/auth', authRoutes);
app.use('/api/lamaran', lamaranRoutes);
app.use('/api/statistik', statistikRoutes);

// Penanganan Rute Tidak Ditemukan (404)
app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: `Rute '${req.originalUrl}' tidak ditemukan pada server API.`
  });
});

// Penanganan Kesalahan Global (500)
app.use((err, req, res, next) => {
  console.error('Unhandled error:', err);
  res.status(500).json({
    success: false,
    message: 'Terjadi kesalahan internal pada server.',
    error: process.env.NODE_ENV === 'development' ? err.message : undefined
  });
});

module.exports = app;


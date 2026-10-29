const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const db = require('../config/database');

// Helper regex email
const isValidEmail = (email) => {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
};

// Registrasi pengguna baru
const register = async (req, res) => {
  try {
    const { nama, email, password } = req.body;

    // Validasi isian wajib
    if (!nama || !email || !password) {
      return res.status(400).json({
        success: false,
        message: 'Nama, email, dan kata sandi wajib diisi.'
      });
    }

    if (nama.trim().length < 2) {
      return res.status(400).json({
        success: false,
        message: 'Nama minimal 2 karakter.'
      });
    }

    if (!isValidEmail(email)) {
      return res.status(400).json({
        success: false,
        message: 'Format email tidak valid.'
      });
    }

    if (password.length < 6) {
      return res.status(400).json({
        success: false,
        message: 'Kata sandi minimal harus 6 karakter.'
      });
    }

    // Cek apakah email sudah terdaftar
    const [existingUsers] = await db.query(
      'SELECT id FROM users WHERE email = ? LIMIT 1',
      [email.trim().toLowerCase()]
    );

    if (existingUsers.length > 0) {
      return res.status(409).json({
        success: false,
        message: 'Email sudah terdaftar. Silakan gunakan email lain atau masuk.'
      });
    }

    // Enkripsi kata sandi
    const saltRounds = 10;
    const hashedPassword = await bcrypt.hash(password, saltRounds);

    // Simpan ke basis data
    const [result] = await db.query(
      'INSERT INTO users (nama, email, password) VALUES (?, ?, ?)',
      [nama.trim(), email.trim().toLowerCase(), hashedPassword]
    );

    const userId = result.insertId;

    // Buat token JWT
    const secret = process.env.JWT_SECRET || 'rahasia_super_aman_jejakmagang_2026_jwt_token_key!';
    const token = jwt.sign(
      { id: userId, email: email.trim().toLowerCase(), nama: nama.trim() },
      secret,
      { expiresIn: process.env.JWT_EXPIRES_IN || '7d' }
    );

    return res.status(201).json({
      success: true,
      message: 'Pendaftaran akun berhasil.',
      token,
      user: {
        id: userId,
        nama: nama.trim(),
        email: email.trim().toLowerCase()
      }
    });
  } catch (error) {
    console.error('Error saat register:', error);
    return res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan pada server saat mendaftarkan akun.'
    });
  }
};

// Masuk (Login)
const login = async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({
        success: false,
        message: 'Email dan kata sandi wajib diisi.'
      });
    }

    // Cari pengguna berdasarkan email
    const [users] = await db.query(
      'SELECT id, nama, email, password FROM users WHERE email = ? LIMIT 1',
      [email.trim().toLowerCase()]
    );

    if (users.length === 0) {
      return res.status(401).json({
        success: false,
        message: 'Email atau kata sandi salah.'
      });
    }

    const user = users[0];

    // Bandingkan kata sandi
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(401).json({
        success: false,
        message: 'Email atau kata sandi salah.'
      });
    }

    // Buat token JWT
    const secret = process.env.JWT_SECRET || 'rahasia_super_aman_jejakmagang_2026_jwt_token_key!';
    const token = jwt.sign(
      { id: user.id, email: user.email, nama: user.nama },
      secret,
      { expiresIn: process.env.JWT_EXPIRES_IN || '7d' }
    );

    return res.status(200).json({
      success: true,
      message: 'Berhasil masuk ke aplikasi.',
      token,
      user: {
        id: user.id,
        nama: user.nama,
        email: user.email
      }
    });
  } catch (error) {
    console.error('Error saat login:', error);
    return res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan pada server saat proses masuk.'
    });
  }
};

// Dapatkan profil pengguna saat ini
const getMe = async (req, res) => {
  try {
    const userId = req.user.id;
    const [users] = await db.query(
      'SELECT id, nama, email, created_at FROM users WHERE id = ? LIMIT 1',
      [userId]
    );

    if (users.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Pengguna tidak ditemukan.'
      });
    }

    return res.status(200).json({
      success: true,
      user: users[0]
    });
  } catch (error) {
    console.error('Error saat getMe:', error);
    return res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan saat mengambil profil pengguna.'
    });
  }
};

module.exports = {
  register,
  login,
  getMe
};


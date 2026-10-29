const jwt = require('jsonwebtoken');

// Middleware untuk memverifikasi token JWT
const verifyToken = (req, res, next) => {
  const authHeader = req.headers['authorization'] || req.headers['Authorization'];

  if (!authHeader) {
    return res.status(401).json({
      success: false,
      message: 'Akses ditolak. Token otentikasi tidak ditemukan.'
    });
  }

  // Format header: Bearer <token>
  const parts = authHeader.split(' ');
  if (parts.length !== 2 || parts[0] !== 'Bearer') {
    return res.status(401).json({
      success: false,
      message: 'Format token tidak valid. Gunakan format "Bearer <token>".'
    });
  }

  const token = parts[1];

  try {
    const secret = process.env.JWT_SECRET || 'rahasia_super_aman_jejakmagang_2026_jwt_token_key!';
    const decoded = jwt.verify(token, secret);
    req.user = decoded;
    next();
  } catch (error) {
    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({
        success: false,
        message: 'Sesi telah berakhir. Silakan masuk kembali.'
      });
    }
    return res.status(401).json({
      success: false,
      message: 'Token otentikasi tidak sah atau telah kedaluwarsa.'
    });
  }
};

module.exports = { verifyToken };


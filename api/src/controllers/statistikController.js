const db = require('../config/database');

// Mengambil ringkasan statistik lamaran pengguna
const getStatistik = async (req, res) => {
  try {
    const userId = req.user.id;

    // Hitung total dan status
    const [statusCounts] = await db.query(
      `SELECT 
        COUNT(*) AS total_lamaran,
        SUM(CASE WHEN status = 'menunggu' THEN 1 ELSE 0 END) AS menunggu,
        SUM(CASE WHEN status = 'lolos' THEN 1 ELSE 0 END) AS lolos,
        SUM(CASE WHEN status = 'ditolak' THEN 1 ELSE 0 END) AS ditolak,
        SUM(CASE WHEN is_prioritas = 1 THEN 1 ELSE 0 END) AS prioritas,
        SUM(CASE WHEN tenggat < CURDATE() AND status = 'menunggu' THEN 1 ELSE 0 END) AS lewat_tenggat
      FROM lamaran 
      WHERE user_id = ?`,
      [userId]
    );

    // Hitung per tahap
    const [tahapCounts] = await db.query(
      `SELECT 
        SUM(CASE WHEN tahap = 'kirim_berkas' THEN 1 ELSE 0 END) AS kirim_berkas,
        SUM(CASE WHEN tahap = 'tes' THEN 1 ELSE 0 END) AS tes,
        SUM(CASE WHEN tahap = 'wawancara' THEN 1 ELSE 0 END) AS wawancara,
        SUM(CASE WHEN tahap = 'hasil' THEN 1 ELSE 0 END) AS hasil
      FROM lamaran 
      WHERE user_id = ?`,
      [userId]
    );

    const stats = statusCounts[0] || {};
    const tahaps = tahapCounts[0] || {};

    const total = parseInt(stats.total_lamaran || 0, 10);
    const menunggu = parseInt(stats.menunggu || 0, 10);
    const lolos = parseInt(stats.lolos || 0, 10);
    const ditolak = parseInt(stats.ditolak || 0, 10);
    const prioritas = parseInt(stats.prioritas || 0, 10);
    const lewatTenggat = parseInt(stats.lewat_tenggat || 0, 10);

    return res.status(200).json({
      success: true,
      data: {
        total_lamaran: total,
        status: {
          menunggu,
          lolos,
          ditolak
        },
        tahap: {
          kirim_berkas: parseInt(tahaps.kirim_berkas || 0, 10),
          tes: parseInt(tahaps.tes || 0, 10),
          wawancara: parseInt(tahaps.wawancara || 0, 10),
          hasil: parseInt(tahaps.hasil || 0, 10)
        },
        prioritas,
        lewat_tenggat: lewatTenggat
      }
    });
  } catch (error) {
    console.error('Error saat getStatistik:', error);
    return res.status(500).json({
      success: false,
      message: 'Gagal memuat ringkasan statistik.'
    });
  }
};

module.exports = {
  getStatistik
};


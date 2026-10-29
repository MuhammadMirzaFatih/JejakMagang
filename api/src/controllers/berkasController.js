const db = require('../config/database');

// Helper untuk memastikan kepemilikan lamaran
const verifyLamaranOwner = async (lamaranId, userId) => {
  const [rows] = await db.query(
    'SELECT id FROM lamaran WHERE id = ? AND user_id = ? LIMIT 1',
    [lamaranId, userId]
  );
  return rows.length > 0;
};

// Dapatkan daftar berkas persyaratan untuk lamaran tertentu
const getBerkas = async (req, res) => {
  try {
    const userId = req.user.id;
    const lamaranId = req.params.id;

    const isOwner = await verifyLamaranOwner(lamaranId, userId);
    if (!isOwner) {
      return res.status(404).json({
        success: false,
        message: 'Lamaran tidak ditemukan atau Anda tidak memiliki akses.'
      });
    }

    const [rows] = await db.query(
      'SELECT id, lamaran_id, nama_berkas, sudah_siap, updated_at FROM berkas_lamaran WHERE lamaran_id = ? ORDER BY id ASC',
      [lamaranId]
    );

    const formatted = rows.map((r) => ({
      ...r,
      sudah_siap: Boolean(r.sudah_siap)
    }));

    const total = formatted.length;
    const siap = formatted.filter((b) => b.sudah_siap).length;
    const persentase = total > 0 ? Math.round((siap / total) * 100) : 0;

    return res.status(200).json({
      success: true,
      data: {
        total_berkas: total,
        berkas_siap: siap,
        persentase_berkas: persentase,
        daftar_berkas: formatted
      }
    });
  } catch (error) {
    console.error('Error saat getBerkas:', error);
    return res.status(500).json({
      success: false,
      message: 'Gagal mengambil daftar berkas persyaratan.'
    });
  }
};

// Toggle status kesiapan berkas
const toggleBerkasStatus = async (req, res) => {
  try {
    const userId = req.user.id;
    const { id: lamaranId, berkasId } = req.params;
    const { sudah_siap } = req.body;

    const isOwner = await verifyLamaranOwner(lamaranId, userId);
    if (!isOwner) {
      return res.status(404).json({
        success: false,
        message: 'Lamaran tidak ditemukan atau Anda tidak memiliki akses.'
      });
    }

    const [existing] = await db.query(
      'SELECT id, sudah_siap FROM berkas_lamaran WHERE id = ? AND lamaran_id = ? LIMIT 1',
      [berkasId, lamaranId]
    );

    if (existing.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Berkas tidak ditemukan.'
      });
    }

    const newStatus = typeof sudah_siap === 'boolean'
      ? sudah_siap
      : !existing[0].sudah_siap;

    await db.query(
      'UPDATE berkas_lamaran SET sudah_siap = ? WHERE id = ? AND lamaran_id = ?',
      [newStatus, berkasId, lamaranId]
    );

    // Hitung ulang progress kelengkapan
    const [allBerkas] = await db.query(
      'SELECT id, sudah_siap FROM berkas_lamaran WHERE lamaran_id = ?',
      [lamaranId]
    );

    const total = allBerkas.length;
    const siap = allBerkas.filter((b) => Boolean(b.sudah_siap)).length;
    const persentase = total > 0 ? Math.round((siap / total) * 100) : 0;

    return res.status(200).json({
      success: true,
      message: 'Status kesiapan berkas berhasil diperbarui.',
      data: {
        berkas_id: parseInt(berkasId, 10),
        sudah_siap: newStatus,
        total_berkas: total,
        berkas_siap: siap,
        persentase_berkas: persentase
      }
    });
  } catch (error) {
    console.error('Error saat toggleBerkasStatus:', error);
    return res.status(500).json({
      success: false,
      message: 'Gagal mengubah status berkas.'
    });
  }
};

module.exports = {
  getBerkas,
  toggleBerkasStatus
};


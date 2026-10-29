const db = require('../config/database');

// Helper untuk memastikan kepemilikan lamaran oleh pengguna yang sedang login
const verifyLamaranOwner = async (lamaranId, userId) => {
  const [rows] = await db.query(
    'SELECT id FROM lamaran WHERE id = ? AND user_id = ? LIMIT 1',
    [lamaranId, userId]
  );
  return rows.length > 0;
};

// Dapatkan daftar catatan persiapan wawancara untuk lamaran tertentu
const getCatatanWawancara = async (req, res) => {
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
      `SELECT id, lamaran_id, pertanyaan, jawaban, hal_dipelajari, created_at, updated_at 
       FROM catatan_wawancara 
       WHERE lamaran_id = ? 
       ORDER BY id DESC`,
      [lamaranId]
    );

    return res.status(200).json({
      success: true,
      data: rows
    });
  } catch (error) {
    console.error('Error saat getCatatanWawancara:', error);
    return res.status(500).json({
      success: false,
      message: 'Gagal mengambil catatan persiapan wawancara.'
    });
  }
};

// Tambah catatan persiapan wawancara baru
const createCatatanWawancara = async (req, res) => {
  try {
    const userId = req.user.id;
    const lamaranId = req.params.id;
    const { pertanyaan, jawaban, hal_dipelajari } = req.body;

    const isOwner = await verifyLamaranOwner(lamaranId, userId);
    if (!isOwner) {
      return res.status(404).json({
        success: false,
        message: 'Lamaran tidak ditemukan atau Anda tidak memiliki akses.'
      });
    }

    if (!pertanyaan || pertanyaan.trim() === '') {
      return res.status(400).json({
        success: false,
        message: 'Pertanyaan wawancara wajib diisi.'
      });
    }

    const [result] = await db.query(
      `INSERT INTO catatan_wawancara (lamaran_id, pertanyaan, jawaban, hal_dipelajari) 
       VALUES (?, ?, ?, ?)`,
      [
        lamaranId,
        pertanyaan.trim(),
        jawaban ? jawaban.trim() : null,
        hal_dipelajari ? hal_dipelajari.trim() : null
      ]
    );

    return res.status(201).json({
      success: true,
      message: 'Catatan persiapan wawancara berhasil ditambahkan.',
      data: {
        id: result.insertId,
        lamaran_id: parseInt(lamaranId, 10),
        pertanyaan: pertanyaan.trim(),
        jawaban: jawaban ? jawaban.trim() : null,
        hal_dipelajari: hal_dipelajari ? hal_dipelajari.trim() : null
      }
    });
  } catch (error) {
    console.error('Error saat createCatatanWawancara:', error);
    return res.status(500).json({
      success: false,
      message: 'Gagal menambahkan catatan persiapan wawancara.'
    });
  }
};

// Ubah catatan persiapan wawancara
const updateCatatanWawancara = async (req, res) => {
  try {
    const userId = req.user.id;
    const { id: lamaranId, noteId } = req.params;
    const { pertanyaan, jawaban, hal_dipelajari } = req.body;

    const isOwner = await verifyLamaranOwner(lamaranId, userId);
    if (!isOwner) {
      return res.status(404).json({
        success: false,
        message: 'Lamaran tidak ditemukan atau Anda tidak memiliki akses.'
      });
    }

    if (!pertanyaan || pertanyaan.trim() === '') {
      return res.status(400).json({
        success: false,
        message: 'Pertanyaan wawancara wajib diisi.'
      });
    }

    const [existingNote] = await db.query(
      'SELECT id FROM catatan_wawancara WHERE id = ? AND lamaran_id = ? LIMIT 1',
      [noteId, lamaranId]
    );

    if (existingNote.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Catatan wawancara tidak ditemukan.'
      });
    }

    await db.query(
      `UPDATE catatan_wawancara 
       SET pertanyaan = ?, jawaban = ?, hal_dipelajari = ? 
       WHERE id = ? AND lamaran_id = ?`,
      [
        pertanyaan.trim(),
        jawaban ? jawaban.trim() : null,
        hal_dipelajari ? hal_dipelajari.trim() : null,
        noteId,
        lamaranId
      ]
    );

    return res.status(200).json({
      success: true,
      message: 'Catatan persiapan wawancara berhasil diperbarui.'
    });
  } catch (error) {
    console.error('Error saat updateCatatanWawancara:', error);
    return res.status(500).json({
      success: false,
      message: 'Gagal memperbarui catatan persiapan wawancara.'
    });
  }
};

// Hapus catatan persiapan wawancara
const deleteCatatanWawancara = async (req, res) => {
  try {
    const userId = req.user.id;
    const { id: lamaranId, noteId } = req.params;

    const isOwner = await verifyLamaranOwner(lamaranId, userId);
    if (!isOwner) {
      return res.status(404).json({
        success: false,
        message: 'Lamaran tidak ditemukan atau Anda tidak memiliki akses.'
      });
    }

    const [existingNote] = await db.query(
      'SELECT id FROM catatan_wawancara WHERE id = ? AND lamaran_id = ? LIMIT 1',
      [noteId, lamaranId]
    );

    if (existingNote.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Catatan wawancara tidak ditemukan.'
      });
    }

    await db.query(
      'DELETE FROM catatan_wawancara WHERE id = ? AND lamaran_id = ?',
      [noteId, lamaranId]
    );

    return res.status(200).json({
      success: true,
      message: 'Catatan wawancara berhasil dihapus.'
    });
  } catch (error) {
    console.error('Error saat deleteCatatanWawancara:', error);
    return res.status(500).json({
      success: false,
      message: 'Gagal menghapus catatan wawancara.'
    });
  }
};

module.exports = {
  getCatatanWawancara,
  createCatatanWawancara,
  updateCatatanWawancara,
  deleteCatatanWawancara
};


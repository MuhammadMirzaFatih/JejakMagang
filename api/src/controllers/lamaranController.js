const db = require('../config/database');

// Helper regex email
const isValidEmail = (email) => {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
};

// Dapatkan daftar seluruh lamaran milik pengguna yang sedang login
const getAllLamaran = async (req, res) => {
  try {
    const userId = req.user.id;
    const { tahap, status, search } = req.query;

    let query = `
      SELECT 
        l.id,
        l.user_id,
        l.nama_perusahaan,
        l.posisi,
        DATE_FORMAT(l.tanggal_lamar, '%Y-%m-%d') AS tanggal_lamar,
        DATE_FORMAT(l.tenggat, '%Y-%m-%d') AS tenggat,
        l.tautan_lowongan,
        l.nama_kontak_hrd,
        l.email_kontak_hrd,
        l.tahap,
        l.status,
        l.is_prioritas,
        l.catatan_hasil,
        l.created_at,
        l.updated_at,
        (SELECT COUNT(*) FROM berkas_lamaran b WHERE b.lamaran_id = l.id) AS total_berkas,
        (SELECT COUNT(*) FROM berkas_lamaran b WHERE b.lamaran_id = l.id AND b.sudah_siap = 1) AS berkas_siap,
        CASE 
          WHEN l.tenggat < CURDATE() AND l.status = 'menunggu' THEN 1 
          ELSE 0 
        END AS is_overdue
      FROM lamaran l
      WHERE l.user_id = ?
    `;

    const params = [userId];

    if (tahap && tahap !== 'semua') {
      query += ` AND l.tahap = ?`;
      params.push(tahap);
    }

    if (status && status !== 'semua') {
      query += ` AND l.status = ?`;
      params.push(status);
    }

    if (search && search.trim() !== '') {
      query += ` AND (l.nama_perusahaan LIKE ? OR l.posisi LIKE ?)`;
      params.push(`%${search.trim()}%`, `%${search.trim()}%`);
    }

    // Urutan: Prioritas utama di paling atas, kemudian tenggat terdekat
    query += ` ORDER BY l.is_prioritas DESC, l.tenggat ASC, l.id DESC`;

    const [rows] = await db.query(query, params);

    // Hitung persentase berkas
    const results = rows.map((row) => ({
      ...row,
      is_prioritas: Boolean(row.is_prioritas),
      is_overdue: Boolean(row.is_overdue),
      persentase_berkas: row.total_berkas > 0 ? Math.round((row.berkas_siap / row.total_berkas) * 100) : 0
    }));

    return res.status(200).json({
      success: true,
      data: results
    });
  } catch (error) {
    console.error('Error saat getAllLamaran:', error);
    return res.status(500).json({
      success: false,
      message: 'Gagal mengambil daftar lamaran.'
    });
  }
};

// Dapatkan detail satu lamaran beserta riwayat tahap, berkas, dan catatan wawancara
const getLamaranById = async (req, res) => {
  try {
    const userId = req.user.id;
    const lamaranId = req.params.id;

    // Ambil data lamaran
    const [rows] = await db.query(
      `SELECT 
        l.id,
        l.user_id,
        l.nama_perusahaan,
        l.posisi,
        DATE_FORMAT(l.tanggal_lamar, '%Y-%m-%d') AS tanggal_lamar,
        DATE_FORMAT(l.tenggat, '%Y-%m-%d') AS tenggat,
        l.tautan_lowongan,
        l.nama_kontak_hrd,
        l.email_kontak_hrd,
        l.tahap,
        l.status,
        l.is_prioritas,
        l.catatan_hasil,
        l.created_at,
        l.updated_at,
        CASE 
          WHEN l.tenggat < CURDATE() AND l.status = 'menunggu' THEN 1 
          ELSE 0 
        END AS is_overdue
      FROM lamaran l
      WHERE l.id = ? AND l.user_id = ?
      LIMIT 1`,
      [lamaranId, userId]
    );

    if (rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Lamaran tidak ditemukan atau Anda tidak memiliki akses.'
      });
    }

    const lamaran = rows[0];
    lamaran.is_prioritas = Boolean(lamaran.is_prioritas);
    lamaran.is_overdue = Boolean(lamaran.is_overdue);

    // Ambil riwayat garis waktu (timeline)
    const [riwayat] = await db.query(
      `SELECT 
        id,
        lamaran_id,
        tahap,
        DATE_FORMAT(tanggal, '%Y-%m-%d') AS tanggal,
        keterangan,
        created_at
      FROM riwayat_tahap
      WHERE lamaran_id = ?
      ORDER BY tanggal ASC, id ASC`,
      [lamaranId]
    );

    // Ambil daftar berkas persyaratan
    const [berkas] = await db.query(
      `SELECT 
        id,
        lamaran_id,
        nama_berkas,
        sudah_siap,
        updated_at
      FROM berkas_lamaran
      WHERE lamaran_id = ?
      ORDER BY id ASC`,
      [lamaranId]
    );

    // Ambil catatan persiapan wawancara
    const [wawancara] = await db.query(
      `SELECT 
        id,
        lamaran_id,
        pertanyaan,
        jawaban,
        hal_dipelajari,
        created_at,
        updated_at
      FROM catatan_wawancara
      WHERE lamaran_id = ?
      ORDER BY id DESC`,
      [lamaranId]
    );

    const berkasFormatted = berkas.map((b) => ({
      ...b,
      sudah_siap: Boolean(b.sudah_siap)
    }));

    const totalBerkas = berkasFormatted.length;
    const berkasSiap = berkasFormatted.filter((b) => b.sudah_siap).length;
    const persentaseBerkas = totalBerkas > 0 ? Math.round((berkasSiap / totalBerkas) * 100) : 0;

    return res.status(200).json({
      success: true,
      data: {
        ...lamaran,
        total_berkas: totalBerkas,
        berkas_siap: berkasSiap,
        persentase_berkas: persentaseBerkas,
        riwayat,
        berkas: berkasFormatted,
        catatan_wawancara: wawancara
      }
    });
  } catch (error) {
    console.error('Error saat getLamaranById:', error);
    return res.status(500).json({
      success: false,
      message: 'Gagal mengambil detail lamaran.'
    });
  }
};

// Tambah lamaran baru
const createLamaran = async (req, res) => {
  const connection = await db.getConnection();
  try {
    const userId = req.user.id;
    const {
      nama_perusahaan,
      posisi,
      tanggal_lamar,
      tenggat,
      tautan_lowongan,
      nama_kontak_hrd,
      email_kontak_hrd,
      is_prioritas = false,
      tahap = 'kirim_berkas',
      status = 'menunggu'
    } = req.body;

    // 1. Validasi isian wajib
    if (!nama_perusahaan || !posisi || !tanggal_lamar || !tenggat) {
      return res.status(400).json({
        success: false,
        message: 'Nama perusahaan, posisi, tanggal lamar, dan tenggat wajib diisi.'
      });
    }

    // 2. Validasi tanggal: tenggat tidak boleh sebelum tanggal lamar
    const tglLamar = new Date(tanggal_lamar);
    const tglTenggat = new Date(tenggat);
    if (isNaN(tglLamar.getTime()) || isNaN(tglTenggat.getTime())) {
      return res.status(400).json({
        success: false,
        message: 'Format tanggal lamar atau tenggat tidak valid.'
      });
    }

    if (tglTenggat < tglLamar) {
      return res.status(400).json({
        success: false,
        message: 'Tanggal tenggat tidak boleh sebelum tanggal lamar.'
      });
    }

    // 3. Validasi email HRD jika diisi
    if (email_kontak_hrd && email_kontak_hrd.trim() !== '' && !isValidEmail(email_kontak_hrd.trim())) {
      return res.status(400).json({
        success: false,
        message: 'Format email kontak HRD tidak valid.'
      });
    }

    // 4. Aturan status vs tahap
    let finalStatus = 'menunggu';
    if (tahap === 'hasil') {
      if (['lolos', 'ditolak'].includes(status)) {
        finalStatus = status;
      }
    }

    await connection.beginTransaction();

    // 5. Simpan ke tabel lamaran
    const [result] = await connection.query(
      `INSERT INTO lamaran (
        user_id, nama_perusahaan, posisi, tanggal_lamar, tenggat,
        tautan_lowongan, nama_kontak_hrd, email_kontak_hrd,
        tahap, status, is_prioritas
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [
        userId,
        nama_perusahaan.trim(),
        posisi.trim(),
        tanggal_lamar,
        tenggat,
        tautan_lowongan ? tautan_lowongan.trim() : null,
        nama_kontak_hrd ? nama_kontak_hrd.trim() : null,
        email_kontak_hrd ? email_kontak_hrd.trim() : null,
        tahap,
        finalStatus,
        Boolean(is_prioritas)
      ]
    );

    const newLamaranId = result.insertId;

    // 6. Buat 4 berkas persyaratan default
    const berkasDefault = ['CV', 'Surat Lamaran', 'Portofolio', 'Transkrip'];
    for (const namaBerkas of berkasDefault) {
      await connection.query(
        'INSERT INTO berkas_lamaran (lamaran_id, nama_berkas, sudah_siap) VALUES (?, ?, FALSE)',
        [newLamaranId, namaBerkas]
      );
    }

    // 7. Buat entri riwayat garis waktu awal
    const keteranganAwal = tahap === 'kirim_berkas'
      ? 'Lamaran pertama kali didaftarkan.'
      : `Lamaran dibuat pada tahap ${tahap}.`;

    await connection.query(
      'INSERT INTO riwayat_tahap (lamaran_id, tahap, tanggal, keterangan) VALUES (?, ?, ?, ?)',
      [newLamaranId, tahap, tanggal_lamar, keteranganAwal]
    );

    await connection.commit();

    return res.status(201).json({
      success: true,
      message: 'Lamaran berhasil ditambahkan.',
      data: {
        id: newLamaranId,
        nama_perusahaan: nama_perusahaan.trim(),
        posisi: posisi.trim(),
        tanggal_lamar,
        tenggat,
        tahap,
        status: finalStatus,
        is_prioritas: Boolean(is_prioritas)
      }
    });
  } catch (error) {
    await connection.rollback();
    console.error('Error saat createLamaran:', error);
    return res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan pada server saat menambahkan lamaran.'
    });
  } finally {
    connection.release();
  }
};

// Ubah data pokok lamaran
const updateLamaran = async (req, res) => {
  try {
    const userId = req.user.id;
    const lamaranId = req.params.id;
    const {
      nama_perusahaan,
      posisi,
      tanggal_lamar,
      tenggat,
      tautan_lowongan,
      nama_kontak_hrd,
      email_kontak_hrd,
      is_prioritas
    } = req.body;

    // Pastikan lamaran milik user yang aktif
    const [existing] = await db.query(
      'SELECT id, tanggal_lamar, tenggat FROM lamaran WHERE id = ? AND user_id = ? LIMIT 1',
      [lamaranId, userId]
    );

    if (existing.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Lamaran tidak ditemukan atau Anda tidak memiliki akses.'
      });
    }

    // Validasi isian wajib jika dikirimkan
    if (!nama_perusahaan || !posisi || !tanggal_lamar || !tenggat) {
      return res.status(400).json({
        success: false,
        message: 'Nama perusahaan, posisi, tanggal lamar, dan tenggat wajib diisi.'
      });
    }

    const tglLamar = new Date(tanggal_lamar);
    const tglTenggat = new Date(tenggat);
    if (tglTenggat < tglLamar) {
      return res.status(400).json({
        success: false,
        message: 'Tanggal tenggat tidak boleh sebelum tanggal lamar.'
      });
    }

    if (email_kontak_hrd && email_kontak_hrd.trim() !== '' && !isValidEmail(email_kontak_hrd.trim())) {
      return res.status(400).json({
        success: false,
        message: 'Format email kontak HRD tidak valid.'
      });
    }

    await db.query(
      `UPDATE lamaran SET 
        nama_perusahaan = ?,
        posisi = ?,
        tanggal_lamar = ?,
        tenggat = ?,
        tautan_lowongan = ?,
        nama_kontak_hrd = ?,
        email_kontak_hrd = ?,
        is_prioritas = ?
      WHERE id = ? AND user_id = ?`,
      [
        nama_perusahaan.trim(),
        posisi.trim(),
        tanggal_lamar,
        tenggat,
        tautan_lowongan ? tautan_lowongan.trim() : null,
        nama_kontak_hrd ? nama_kontak_hrd.trim() : null,
        email_kontak_hrd ? email_kontak_hrd.trim() : null,
        Boolean(is_prioritas),
        lamaranId,
        userId
      ]
    );

    return res.status(200).json({
      success: true,
      message: 'Data lamaran berhasil diperbarui.'
    });
  } catch (error) {
    console.error('Error saat updateLamaran:', error);
    return res.status(500).json({
      success: false,
      message: 'Gagal memperbarui data lamaran.'
    });
  }
};

// Hapus lamaran beserta seluruh relasinya
const deleteLamaran = async (req, res) => {
  try {
    const userId = req.user.id;
    const lamaranId = req.params.id;

    const [existing] = await db.query(
      'SELECT id, nama_perusahaan FROM lamaran WHERE id = ? AND user_id = ? LIMIT 1',
      [lamaranId, userId]
    );

    if (existing.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Lamaran tidak ditemukan atau Anda tidak memiliki akses.'
      });
    }

    await db.query('DELETE FROM lamaran WHERE id = ? AND user_id = ?', [lamaranId, userId]);

    return res.status(200).json({
      success: true,
      message: `Lamaran untuk ${existing[0].nama_perusahaan} berhasil dihapus.`
    });
  } catch (error) {
    console.error('Error saat deleteLamaran:', error);
    return res.status(500).json({
      success: false,
      message: 'Gagal menghapus lamaran.'
    });
  }
};

// Ubah tahap dan status lamaran (otomatis menambahkan garis waktu / timeline)
const updateTahap = async (req, res) => {
  const connection = await db.getConnection();
  try {
    const userId = req.user.id;
    const lamaranId = req.params.id;
    const { tahap, status, tanggal, keterangan } = req.body;

    const validTahap = ['kirim_berkas', 'tes', 'wawancara', 'hasil'];
    if (!tahap || !validTahap.includes(tahap)) {
      return res.status(400).json({
        success: false,
        message: 'Tahap yang dipilih tidak valid.'
      });
    }

    const [existing] = await connection.query(
      'SELECT id, tahap, status FROM lamaran WHERE id = ? AND user_id = ? LIMIT 1',
      [lamaranId, userId]
    );

    if (existing.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Lamaran tidak ditemukan atau Anda tidak memiliki akses.'
      });
    }

    // Tentukan status berdasarkan tahap
    let finalStatus = 'menunggu';
    if (tahap === 'hasil') {
      if (['lolos', 'ditolak'].includes(status)) {
        finalStatus = status;
      } else {
        finalStatus = existing[0].status === 'lolos' || existing[0].status === 'ditolak'
          ? existing[0].status
          : 'lolos';
      }
    }

    const tglTimeline = tanggal || new Date().toISOString().split('T')[0];
    const defaultKeterangan = `Berpindah ke tahap ${tahap.replace('_', ' ')}.`;

    await connection.beginTransaction();

    // Perbarui lamaran
    await connection.query(
      'UPDATE lamaran SET tahap = ?, status = ? WHERE id = ? AND user_id = ?',
      [tahap, finalStatus, lamaranId, userId]
    );

    // Tambah riwayat timeline
    await connection.query(
      'INSERT INTO riwayat_tahap (lamaran_id, tahap, tanggal, keterangan) VALUES (?, ?, ?, ?)',
      [lamaranId, tahap, tglTimeline, keterangan ? keterangan.trim() : defaultKeterangan]
    );

    await connection.commit();

    return res.status(200).json({
      success: true,
      message: 'Tahapan seleksi berhasil diperbarui.',
      data: {
        tahap,
        status: finalStatus
      }
    });
  } catch (error) {
    await connection.rollback();
    console.error('Error saat updateTahap:', error);
    return res.status(500).json({
      success: false,
      message: 'Gagal memperbarui tahapan seleksi.'
    });
  } finally {
    connection.release();
  }
};

// Toggle status prioritas
const togglePrioritas = async (req, res) => {
  try {
    const userId = req.user.id;
    const lamaranId = req.params.id;
    const { is_prioritas } = req.body;

    const [existing] = await db.query(
      'SELECT id, is_prioritas FROM lamaran WHERE id = ? AND user_id = ? LIMIT 1',
      [lamaranId, userId]
    );

    if (existing.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Lamaran tidak ditemukan atau Anda tidak memiliki akses.'
      });
    }

    const newPriority = typeof is_prioritas === 'boolean'
      ? is_prioritas
      : !existing[0].is_prioritas;

    await db.query(
      'UPDATE lamaran SET is_prioritas = ? WHERE id = ? AND user_id = ?',
      [newPriority, lamaranId, userId]
    );

    return res.status(200).json({
      success: true,
      message: newPriority ? 'Ditandai sebagai lamaran prioritas.' : 'Prioritas lamaran dibatalkan.',
      data: { is_prioritas: newPriority }
    });
  } catch (error) {
    console.error('Error saat togglePrioritas:', error);
    return res.status(500).json({
      success: false,
      message: 'Gagal mengubah status prioritas.'
    });
  }
};

// Simpan catatan evaluasi hasil akhir
const updateCatatanHasil = async (req, res) => {
  try {
    const userId = req.user.id;
    const lamaranId = req.params.id;
    const { catatan_hasil, status } = req.body;

    const [existing] = await db.query(
      'SELECT id, tahap FROM lamaran WHERE id = ? AND user_id = ? LIMIT 1',
      [lamaranId, userId]
    );

    if (existing.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Lamaran tidak ditemukan atau Anda tidak memiliki akses.'
      });
    }

    let updateQuery = 'UPDATE lamaran SET catatan_hasil = ?';
    const params = [catatan_hasil ? catatan_hasil.trim() : null];

    if (status && ['lolos', 'ditolak', 'menunggu'].includes(status)) {
      updateQuery += ', status = ?';
      params.push(status);
    }

    updateQuery += ' WHERE id = ? AND user_id = ?';
    params.push(lamaranId, userId);

    await db.query(updateQuery, params);

    return res.status(200).json({
      success: true,
      message: 'Catatan hasil akhir berhasil disimpan.'
    });
  } catch (error) {
    console.error('Error saat updateCatatanHasil:', error);
    return res.status(500).json({
      success: false,
      message: 'Gagal menyimpan catatan hasil akhir.'
    });
  }
};

module.exports = {
  getAllLamaran,
  getLamaranById,
  createLamaran,
  updateLamaran,
  deleteLamaran,
  updateTahap,
  togglePrioritas,
  updateCatatanHasil
};


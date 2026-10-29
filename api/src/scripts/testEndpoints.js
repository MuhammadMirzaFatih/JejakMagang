const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '../../.env') });
const app = require('../app');
const http = require('http');

let server;
let baseUrl;

function request(method, path, body = null, token = null) {
  return new Promise((resolve, reject) => {
    const url = new URL(path, baseUrl);
    const options = {
      method: method.toUpperCase(),
      hostname: url.hostname,
      port: url.port,
      path: url.pathname + url.search,
      headers: {
        'Content-Type': 'application/json'
      }
    };

    if (token) {
      options.headers['Authorization'] = `Bearer ${token}`;
    }

    const req = http.request(options, (res) => {
      let data = '';
      res.on('data', (chunk) => { data += chunk; });
      res.on('end', () => {
        try {
          const parsed = JSON.parse(data);
          resolve({ status: res.statusCode, body: parsed });
        } catch (e) {
          resolve({ status: res.statusCode, raw: data });
        }
      });
    });

    req.on('error', (err) => reject(err));

    if (body) {
      req.write(JSON.stringify(body));
    }
    req.end();
  });
}

function assert(condition, message) {
  if (!condition) {
    throw new Error(`Assertion FAILED: ${message}`);
  }
  console.log(`  ✓ ${message}`);
}

async function runTests() {
  const PORT = 3001; // Port uji
  server = app.listen(PORT);
  baseUrl = `http://127.0.0.1:${PORT}`;
  console.log(`\n=== MEMULAI PENGUJIAN ENDPOINT API DI ${baseUrl} ===\n`);

  try {
    // 1. Healthcheck
    console.log('[1] Tes Healthcheck');
    let res = await request('GET', '/api/health');
    assert(res.status === 200 && res.body.status === 'OK', 'GET /api/health berhasil');

    // 2. Auth Login (Seed User)
    console.log('\n[2] Tes Login Pengguna Contoh');
    res = await request('POST', '/api/auth/login', {
      email: 'budi@mahasiswa.id',
      password: 'Password123!'
    });
    assert(res.status === 200, 'Login dengan akun contoh berhasil');
    assert(res.body.token !== undefined, 'Mendapatkan JWT token');
    const budiToken = res.body.token;

    // 3. Auth Login Gagal
    console.log('\n[3] Tes Login Kata Sandi Salah');
    res = await request('POST', '/api/auth/login', {
      email: 'budi@mahasiswa.id',
      password: 'PasswordSalah!'
    });
    assert(res.status === 401, 'Login ditolak dengan kode 401 untuk password salah');

    // 4. Auth Register User Baru
    console.log('\n[4] Tes Pendaftaran Pengguna Baru');
    const randomEmail = `test_${Date.now()}@mahasiswa.id`;
    res = await request('POST', '/api/auth/register', {
      nama: 'Mahasiswa Penguji',
      email: randomEmail,
      password: 'Password123!'
    });
    assert(res.status === 201, 'Registrasi pengguna baru berhasil');
    const testUserToken = res.body.token;

    // 5. Profil Pengguna (GET /api/auth/me)
    console.log('\n[5] Tes GET /api/auth/me');
    res = await request('GET', '/api/auth/me', null, testUserToken);
    assert(res.status === 200 && res.body.user.email === randomEmail, 'GET /api/auth/me mengembalikan data profil');

    // 6. Validasi Tambah Lamaran (Tanggal tenggat < tanggal lamar)
    console.log('\n[6] Tes Validasi Tenggat Sebelum Tanggal Lamar');
    res = await request('POST', '/api/lamaran', {
      nama_perusahaan: 'PT Salah Tanggal',
      posisi: 'QA Intern',
      tanggal_lamar: '2026-10-25',
      tenggat: '2026-10-20' // invalid: sebelum tanggal lamar
    }, testUserToken);
    assert(res.status === 400, 'Validasi menolak tenggat yang lebih awal dari tanggal lamar');

    // 7. Tambah Lamaran Berhasil
    console.log('\n[7] Tes Tambah Lamaran Baru');
    res = await request('POST', '/api/lamaran', {
      nama_perusahaan: 'Startup Unicorn',
      posisi: 'Flutter Engineer Intern',
      tanggal_lamar: '2026-10-20',
      tenggat: '2026-11-20',
      tautan_lowongan: 'https://unicorn.io/careers/flutter',
      nama_kontak_hrd: 'Dewi Lestari',
      email_kontak_hrd: 'dewi@unicorn.io',
      is_prioritas: true,
      tahap: 'kirim_berkas'
    }, testUserToken);
    assert(res.status === 201, 'Lamaran baru berhasil ditambahkan');
    const newLamaranId = res.body.data.id;
    assert(newLamaranId > 0, 'Mendapatkan ID lamaran baru');

    // 8. Ambil Detail Lamaran & Pastikan Berkas + Timeline Terbentuk Otomatis
    console.log('\n[8] Tes GET /api/lamaran/:id (Detail, 4 Berkas Default, Initial Timeline)');
    res = await request('GET', `/api/lamaran/${newLamaranId}`, null, testUserToken);
    assert(res.status === 200, 'Detail lamaran berhasil diambil');
    assert(res.body.data.berkas.length === 4, '4 berkas default otomatis dibuat (CV, Surat Lamaran, Portofolio, Transkrip)');
    assert(res.body.data.riwayat.length === 1, '1 entri garis waktu awal otomatis dibuat');
    assert(res.body.data.is_prioritas === true, 'Status prioritas tersimpan benar');

    // 9. Update Pokok Lamaran
    console.log('\n[9] Tes PUT /api/lamaran/:id (Ubah Data Pokok)');
    res = await request('PUT', `/api/lamaran/${newLamaranId}`, {
      nama_perusahaan: 'Startup Unicorn Asia',
      posisi: 'Senior Flutter Intern',
      tanggal_lamar: '2026-10-20',
      tenggat: '2026-11-25',
      tautan_lowongan: 'https://unicorn.io/careers/flutter-sr',
      nama_kontak_hrd: 'Dewi Lestari',
      email_kontak_hrd: 'dewi@unicorn.io',
      is_prioritas: true
    }, testUserToken);
    assert(res.status === 200, 'Pembaruan data lamaran berhasil');

    // 10. Update Tahapan Seleksi (PATCH /api/lamaran/:id/tahap)
    console.log('\n[10] Tes PATCH /api/lamaran/:id/tahap (Pindah Tahap & Tambah Garis Waktu)');
    res = await request('PATCH', `/api/lamaran/${newLamaranId}/tahap`, {
      tahap: 'tes',
      tanggal: '2026-10-27',
      keterangan: 'Lolos berkas dan menerima link tes teknis.'
    }, testUserToken);
    assert(res.status === 200, 'Tahapan berhasil dipindahkan ke tes');

    // Verifikasi riwayat bertambah
    res = await request('GET', `/api/lamaran/${newLamaranId}`, null, testUserToken);
    assert(res.body.data.tahap === 'tes', 'Tahap sekarang adalah tes');
    assert(res.body.data.riwayat.length === 2, 'Riwayat garis waktu bertambah menjadi 2 entri');

    // 11. Toggle Prioritas
    console.log('\n[11] Tes PATCH /api/lamaran/:id/prioritas');
    res = await request('PATCH', `/api/lamaran/${newLamaranId}/prioritas`, {
      is_prioritas: false
    }, testUserToken);
    assert(res.status === 200 && res.body.data.is_prioritas === false, 'Prioritas berhasil diubah menjadi false');

    // 12. Checklist Berkas Persyaratan (PATCH /api/lamaran/:id/berkas/:berkasId)
    console.log('\n[12] Tes Centang Berkas Persyaratan');
    const berkasId = res.body.data ? 1 : 1;
    // Ambil list berkas
    let berkasRes = await request('GET', `/api/lamaran/${newLamaranId}/berkas`, null, testUserToken);
    const firstBerkasId = berkasRes.body.data.daftar_berkas[0].id;
    res = await request('PATCH', `/api/lamaran/${newLamaranId}/berkas/${firstBerkasId}`, {
      sudah_siap: true
    }, testUserToken);
    assert(res.status === 200 && res.body.data.sudah_siap === true, 'Kesiapan berkas berhasil dicentang');
    assert(res.body.data.berkas_siap === 1 && res.body.data.persentase_berkas === 25, 'Persentase kesiapan berkas terhitung 25%');

    // 13. CRUD Catatan Persiapan Wawancara
    console.log('\n[13] Tes CRUD Catatan Persiapan Wawancara');
    // POST
    res = await request('POST', `/api/lamaran/${newLamaranId}/wawancara`, {
      pertanyaan: 'Bagaimana mengatasi memory leak di Flutter?',
      jawaban: 'Gunakan dispose() pada controller dan stream subscription.',
      hal_dipelajari: 'Memory profiler di Flutter DevTools.'
    }, testUserToken);
    assert(res.status === 201, 'Catatan wawancara berhasil ditambahkan');
    const noteId = res.body.data.id;

    // GET
    res = await request('GET', `/api/lamaran/${newLamaranId}/wawancara`, null, testUserToken);
    assert(res.status === 200 && res.body.data.length === 1, 'Daftar catatan wawancara berhasil diambil');

    // PUT
    res = await request('PUT', `/api/lamaran/${newLamaranId}/wawancara/${noteId}`, {
      pertanyaan: 'Bagaimana mengatasi memory leak di Flutter? (Revisi)',
      jawaban: 'Dispose controller, cancel stream listener, dan hindari static context retention.',
      hal_dipelajari: 'DevTools Memory Profiler dan leak_tracker.'
    }, testUserToken);
    assert(res.status === 200, 'Catatan wawancara berhasil diubah');

    // 14. Pindah Tahap ke Hasil & Catatan Evaluasi Akhir
    console.log('\n[14] Tes Tahap Hasil & Catatan Hasil Evaluasi');
    res = await request('PATCH', `/api/lamaran/${newLamaranId}/tahap`, {
      tahap: 'hasil',
      status: 'lolos',
      tanggal: '2026-10-29',
      keterangan: 'Menerima surat penawaran kerja (Offering Letter).'
    }, testUserToken);
    assert(res.status === 200 && res.body.data.status === 'lolos', 'Pindah ke tahap hasil lolos berhasil');

    res = await request('PATCH', `/api/lamaran/${newLamaranId}/catatan-hasil`, {
      catatan_hasil: 'Persiapan interview DevTools sangat membantu menjawab pertanyaan teknis!',
      status: 'lolos'
    }, testUserToken);
    assert(res.status === 200, 'Catatan evaluasi hasil akhir berhasil disimpan');

    // 15. Ringkasan Statistik
    console.log('\n[15] Tes GET /api/statistik');
    res = await request('GET', '/api/statistik', null, testUserToken);
    assert(res.status === 200, 'GET /api/statistik berhasil');
    assert(res.body.data.total_lamaran === 1, 'Total lamaran terhitung 1');
    assert(res.body.data.status.lolos === 1, 'Status lolos terhitung 1');

    // 16. Isolasi Pengguna (User Isolation)
    console.log('\n[16] Tes Isolasi Data Pengguna');
    res = await request('GET', `/api/lamaran/${newLamaranId}`, null, budiToken);
    assert(res.status === 404, 'Pengguna Budi tidak dapat mengakses lamaran milik Pengguna Lain (404)');

    // 17. Hapus Catatan Wawancara & Hapus Lamaran
    console.log('\n[17] Tes Hapus Catatan & Hapus Lamaran');
    res = await request('DELETE', `/api/lamaran/${newLamaranId}/wawancara/${noteId}`, null, testUserToken);
    assert(res.status === 200, 'Catatan wawancara berhasil dihapus');

    res = await request('DELETE', `/api/lamaran/${newLamaranId}`, null, testUserToken);
    assert(res.status === 200, 'Lamaran berhasil dihapus dengan konfirmasi');

    // Pastikan sudah terhapus
    res = await request('GET', `/api/lamaran/${newLamaranId}`, null, testUserToken);
    assert(res.status === 404, 'Lamaran tidak ditemukan setelah dihapus');

    console.log('\n======================================================');
    console.log('🎉 SEMUA 17 UJI ENDPOINT API BERHASIL DENGAN SEMPURNA!');
    console.log('======================================================\n');
  } catch (error) {
    console.error('\n❌ PENGUJIAN GAGAL:', error);
    process.exitCode = 1;
  } finally {
    if (server) {
      server.close();
    }
    process.exit(process.exitCode || 0);
  }
}

runTests();

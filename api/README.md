# Backend API REST JejakMagang

Layanan API RESTful untuk aplikasi **JejakMagang**, dibangun menggunakan **Node.js (Express)** dan **MySQL** dengan kueri SQL langsung (`mysql2`) tanpa ORM.

## Fitur Utama API
- Otentikasi Pengguna: Pendaftaran, login, dan validasi sesi dengan JWT.
- Keamanan Kata Sandi: Enkripsi dengan `bcryptjs`.
- Manajemen Lamaran (CRUD): Nama perusahaan, posisi, tanggal lamar, tenggat, kontak HRD, tautan lowongan, dan prioritas.
- Tahapan Seleksi & Garis Waktu: Perubahan tahap ('kirim_berkas', 'tes', 'wawancara', 'hasil') otomatis tercatat di garis waktu (`riwayat_tahap`).
- Catatan Persiapan Wawancara: Manajemen pertanyaan, jawaban, dan hal yang perlu dipelajari per lamaran.
- Daftar Berkas Persyaratan: Pelacakan kelengkapan 4 berkas utama (CV, Surat Lamaran, Portofolio, Transkrip).
- Ringkasan Statistik: Penghitungan agregat status (menunggu, lolos, ditolak) dan sebaran tahapan seleksi.

---

## Prasyarat
- **Node.js** v18+ atau v20+
- **MySQL** v8.0+ atau MariaDB aktif di port `3306`

---

## Langkah Instalasi & Menjalankan

### 1. Masuk ke Direktori API
```bash
cd api
```

### 2. Salin Berkas Lingkungan (.env)
```bash
cp .env.example .env
```
Sesuaikan konfigurasi port dan kredensial MySQL pada `.env` jika berbeda dengan default:
```env
PORT=3000
DB_HOST=127.0.0.1
DB_PORT=3306
DB_USER=root
DB_PASSWORD=
DB_NAME=jejakmagang
JWT_SECRET=rahasia_super_aman_jejakmagang_2026_jwt_token_key!
```

### 3. Pasang Dependensi
```bash
npm install
```

### 4. Migrasi & Pengisian Data Contoh (Seed)
Jalankan perintah ini untuk membuat tabel basis data dan data contoh otomatis:
```bash
npm run seed
```

### 5. Jalankan Server API
Untuk mode produksi:
```bash
npm start
```

Untuk mode pengembangan (dengan nodemon auto-reload):
```bash
npm run dev
```

Server akan aktif di `http://localhost:3000` (atau `http://0.0.0.0:3000`).

---

## Akun Pengguna Contoh
- **Email**: `budi@mahasiswa.id`
- **Kata Sandi**: `Password123!`

---

## Ringkasan Endpoint

| Metode | Endpoint | Deskripsi | Auth |
|---|---|---|---|
| GET | `/api/health` | Cek status server | Tidak |
| POST | `/api/auth/register` | Daftar akun baru | Tidak |
| POST | `/api/auth/login` | Masuk & peroleh JWT token | Tidak |
| GET | `/api/auth/me` | Profil pengguna saat ini | Ya |
| GET | `/api/lamaran` | Daftar lamaran (filter tahap, status, pencarian) | Ya |
| POST | `/api/lamaran` | Tambah lamaran baru | Ya |
| GET | `/api/lamaran/:id` | Detail lengkap lamaran, timeline, berkas, wawancara | Ya |
| PUT | `/api/lamaran/:id` | Ubah data lamaran | Ya |
| DELETE | `/api/lamaran/:id` | Hapus lamaran | Ya |
| PATCH | `/api/lamaran/:id/tahap` | Pindah tahap seleksi & status | Ya |
| PATCH | `/api/lamaran/:id/prioritas` | Tandai prioritas | Ya |
| PATCH | `/api/lamaran/:id/catatan-hasil` | Simpan evaluasi hasil akhir | Ya |
| GET | `/api/lamaran/:id/wawancara` | Daftar catatan wawancara | Ya |
| POST | `/api/lamaran/:id/wawancara` | Tambah catatan wawancara | Ya |
| PUT | `/api/lamaran/:id/wawancara/:noteId`| Ubah catatan wawancara | Ya |
| DELETE | `/api/lamaran/:id/wawancara/:noteId`| Hapus catatan wawancara | Ya |
| GET | `/api/lamaran/:id/berkas` | Daftar berkas & progres | Ya |
| PATCH | `/api/lamaran/:id/berkas/:berkasId` | Centang kesiapan berkas | Ya |
| GET | `/api/statistik` | Ringkasan statistik lamaran | Ya |


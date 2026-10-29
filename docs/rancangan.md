# Dokumen Rancangan JejakMagang

Dokumen ini merangkum rancangan arsitektur, basis data, endpoint API, dan struktur proyek untuk aplikasi mobile **JejakMagang**.

---

## 1. Arsitektur & Teknologi

- **Frontend**: Flutter (Dart)
  - State Management: `provider`
  - Navigasi: `go_router`
  - HTTP Client: `http`
  - Visualisasi Grafik: `fl_chart`
  - Notifikasi Lokal: `flutter_local_notifications` (notifikasi pengingat tenggat H-3 dan H-1 pukul 08:00)
  - Penyimpanan Kredensial/Token: `flutter_secure_storage`
  - Preferensi Tema (Mode Gelap): `shared_preferences`
- **Backend (API)**:
  - Runtime: Node.js (Express.js)
  - Driver Basis Data: `mysql2` (kueri SQL langsung tanpa ORM)
  - Autentikasi: JSON Web Token (JWT)
  - Hashing Kata Sandi: `bcryptjs`
- **Basis Data**:
  - MySQL 8.x / MariaDB
  - Skrip pembuatan tabel: `db/schema.sql`
  - Skrip data contoh: `db/seed.sql`

---

## 2. Rancangan Basis Data (MySQL)

### Tabel `users`
Menyimpan informasi pengguna aplikasi.
| Kolom | Tipe Data | Atribut | Keterangan |
|---|---|---|---|
| `id` | INT | PRIMARY KEY, AUTO_INCREMENT | ID unik pengguna |
| `nama` | VARCHAR(100) | NOT NULL | Nama lengkap pengguna |
| `email` | VARCHAR(150) | NOT NULL, UNIQUE | Alamat email (untuk login) |
| `password` | VARCHAR(255) | NOT NULL | Kata sandi terenkripsi (bcrypt) |
| `created_at` | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Waktu pendaftaran |
| `updated_at` | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP | Waktu pembaruan |

### Tabel `lamaran`
Menyimpan data lamaran magang milik pengguna.
| Kolom | Tipe Data | Atribut | Keterangan |
|---|---|---|---|
| `id` | INT | PRIMARY KEY, AUTO_INCREMENT | ID unik lamaran |
| `user_id` | INT | NOT NULL, FK -> `users(id)` ON DELETE CASCADE | Pemilik lamaran |
| `nama_perusahaan` | VARCHAR(150) | NOT NULL | Nama perusahaan yang dilamar |
| `posisi` | VARCHAR(150) | NOT NULL | Posisi/jabatan magang |
| `tanggal_lamar` | DATE | NOT NULL | Tanggal pengiriman lamaran |
| `tenggat` | DATE | NOT NULL | Batas akhir seleksi/pengumuman |
| `tautan_lowongan` | VARCHAR(500) | NULL | Tautan URL info lowongan |
| `nama_kontak_hrd` | VARCHAR(100) | NULL | Nama penanggung jawab/HRD |
| `email_kontak_hrd` | VARCHAR(150) | NULL | Email penanggung jawab/HRD |
| `tahap` | ENUM | NOT NULL DEFAULT 'kirim_berkas' | 'kirim_berkas', 'tes', 'wawancara', 'hasil' |
| `status` | ENUM | NOT NULL DEFAULT 'menunggu' | 'menunggu', 'lolos', 'ditolak' |
| `is_prioritas` | BOOLEAN | NOT NULL DEFAULT FALSE | Penanda lamaran impian |
| `catatan_hasil` | TEXT | NULL | Catatan evaluasi/alasan diterima/ditolak |
| `created_at` | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Waktu pembuatan data |
| `updated_at` | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP | Waktu pembaruan |

### Tabel `riwayat_tahap`
Mencatat garis waktu (timeline) perjalanan tahapan lamaran.
| Kolom | Tipe Data | Atribut | Keterangan |
|---|---|---|---|
| `id` | INT | PRIMARY KEY, AUTO_INCREMENT | ID entri riwayat |
| `lamaran_id` | INT | NOT NULL, FK -> `lamaran(id)` ON DELETE CASCADE | Relasi ke lamaran |
| `tahap` | ENUM | NOT NULL | Tahap baru saat perubahan |
| `tanggal` | DATE | NOT NULL | Tanggal perpindahan tahap |
| `keterangan` | VARCHAR(255) | NULL | Catatan tambahan perpindahan |
| `created_at` | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Waktu pencatatan |

### Tabel `catatan_wawancara`
Menyimpan daftar persiapan wawancara per lamaran.
| Kolom | Tipe Data | Atribut | Keterangan |
|---|---|---|---|
| `id` | INT | PRIMARY KEY, AUTO_INCREMENT | ID catatan wawancara |
| `lamaran_id` | INT | NOT NULL, FK -> `lamaran(id)` ON DELETE CASCADE | Relasi ke lamaran |
| `pertanyaan` | TEXT | NOT NULL | Pertanyaan yang mungkin muncul |
| `jawaban` | TEXT | NULL | Jawaban yang telah disiapkan |
| `hal_dipelajari` | TEXT | NULL | Hal-hal penting yang perlu dipelajari |
| `created_at` | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Waktu pembuatan |
| `updated_at` | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP | Waktu pembaruan |

### Tabel `berkas_lamaran`
Menyimpan daftar centang kelengkapan berkas persyaratan untuk setiap lamaran (CV, Surat Lamaran, Portofolio, Transkrip).
| Kolom | Tipe Data | Atribut | Keterangan |
|---|---|---|---|
| `id` | INT | PRIMARY KEY, AUTO_INCREMENT | ID entri berkas |
| `lamaran_id` | INT | NOT NULL, FK -> `lamaran(id)` ON DELETE CASCADE | Relasi ke lamaran |
| `nama_berkas` | VARCHAR(100) | NOT NULL | Contoh: 'CV', 'Surat Lamaran', 'Portofolio', 'Transkrip' |
| `sudah_siap` | BOOLEAN | NOT NULL DEFAULT FALSE | Status kelengkapan berkas |
| `updated_at` | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP | Waktu pembaruan status |

---

## 3. Daftar Endpoint API (REST)

Semua endpoint dilindungi dengan otentikasi JWT (header `Authorization: Bearer <token>`), kecuali endpoint otentikasi (`/api/auth/*`).

### Autentikasi (`/api/auth`)
1. `POST /api/auth/register`
   - Body: `{ "nama": "...", "email": "...", "password": "..." }`
   - Respons: Data pengguna baru + JWT Token.
2. `POST /api/auth/login`
   - Body: `{ "email": "...", "password": "..." }`
   - Respons: Data pengguna + JWT Token.
3. `GET /api/auth/me`
   - Header: `Bearer <token>`
   - Respons: Profil pengguna saat ini.

### Lamaran (`/api/lamaran`)
1. `GET /api/lamaran`
   - Query: `tahap` (opsional), `status` (opsional), `search` (opsional).
   - Respons: Daftar lamaran dengan kelengkapan berkas (% siap) dan status tenggat, terurut berdasarkan `is_prioritas DESC`, `tenggat ASC`.
2. `POST /api/lamaran`
   - Body: `{ "nama_perusahaan", "posisi", "tanggal_lamar", "tenggat", "tautan_lowongan", "nama_kontak_hrd", "email_kontak_hrd", "is_prioritas", "tahap", "status" }`
   - Keterangan: Otomatis memasukkan 4 berkas default (CV, Surat Lamaran, Portofolio, Transkrip) dan 1 entri riwayat tahap awal.
3. `GET /api/lamaran/:id`
   - Respons: Detail lamaran lengkap beserta berkas, riwayat tahap (timeline), dan catatan wawancara.
4. `PUT /api/lamaran/:id`
   - Body: Pembaruan data pokok lamaran.
5. `DELETE /api/lamaran/:id`
   - Menghapus lamaran beserta seluruh relasi datanya.
6. `PATCH /api/lamaran/:id/tahap`
   - Body: `{ "tahap": "...", "status": "...", "tanggal": "...", "keterangan": "..." }`
   - Memperbarui tahap dan status lamaran, serta mencatat ke tabel `riwayat_tahap`.
7. `PATCH /api/lamaran/:id/prioritas`
   - Body: `{ "is_prioritas": true/false }`
   - Mengubah status prioritas lamaran.
8. `PATCH /api/lamaran/:id/catatan-hasil`
   - Body: `{ "catatan_hasil": "..." }`
   - Menyimpan evaluasi akhir saat tahap mencapai 'hasil'.

### Catatan Persiapan Wawancara (`/api/lamaran/:id/wawancara`)
1. `GET /api/lamaran/:id/wawancara` - Daftar pertanyaan wawancara.
2. `POST /api/lamaran/:id/wawancara` - Tambah pertanyaan & persiapan.
3. `PUT /api/lamaran/:id/wawancara/:catatanId` - Perbarui catatan wawancara.
4. `DELETE /api/lamaran/:id/wawancara/:catatanId` - Hapus catatan wawancara.

### Daftar Berkas Persyaratan (`/api/lamaran/:id/berkas`)
1. `GET /api/lamaran/:id/berkas` - Daftar 4 berkas persyaratan dan status centang.
2. `PATCH /api/lamaran/:id/berkas/:berkasId`
   - Body: `{ "sudah_siap": true/false }`
   - Mengubah status kesiapan berkas.

### Ringkasan Statistik (`/api/statistik`)
1. `GET /api/statistik`
   - Respons:
     - `total_lamaran`: Jumlah total lamaran aktif.
     - `menunggu`: Jumlah lamaran berstatus 'menunggu'.
     - `lolos`: Jumlah lamaran berstatus 'lolos'.
     - `ditolak`: Jumlah lamaran berstatus 'ditolak'.
     - `sebaran_tahap`: Jumlah lamaran per tahap ('kirim_berkas', 'tes', 'wawancara', 'hasil').

---

## 4. Struktur Folder Proyek

```text
JejakMagang/
├── docs/
│   └── rancangan.md
├── db/
│   ├── schema.sql
│   ├── seed.sql
│   └── README.md
├── api/
│   ├── src/
│   │   ├── config/
│   │   │   └── database.js
│   │   ├── middlewares/
│   │   │   └── auth.js
│   │   ├── controllers/
│   │   │   ├── authController.js
│   │   │   ├── lamaranController.js
│   │   │   ├── wawancaraController.js
│   │   │   ├── berkasController.js
│   │   │   └── statistikController.js
│   │   ├── routes/
│   │   │   ├── authRoutes.js
│   │   │   ├── lamaranRoutes.js
│   │   │   └── statistikRoutes.js
│   │   └── app.js
│   ├── index.js
│   ├── .env.example
│   ├── package.json
│   └── README.md
├── frontend/
│   ├── lib/
│   │   ├── config/
│   │   │   ├── api_config.dart
│   │   │   └── theme.dart
│   │   ├── models/
│   │   │   ├── user_model.dart
│   │   │   ├── lamaran_model.dart
│   │   │   ├── riwayat_tahap_model.dart
│   │   │   ├── wawancara_model.dart
│   │   │   ├── berkas_model.dart
│   │   │   └── statistik_model.dart
│   │   ├── services/
│   │   │   ├── api_service.dart
│   │   │   ├── auth_service.dart
│   │   │   ├── notification_service.dart
│   │   │   └── storage_service.dart
│   │   ├── providers/
│   │   │   ├── auth_provider.dart
│   │   │   ├── lamaran_provider.dart
│   │   │   ├── statistik_provider.dart
│   │   │   └── theme_provider.dart
│   │   ├── screens/
│   │   │   ├── auth/
│   │   │   │   ├── login_screen.dart
│   │   │   │   └── register_screen.dart
│   │   │   ├── lamaran/
│   │   │   │   ├── lamaran_list_screen.dart
│   │   │   │   ├── lamaran_detail_screen.dart
│   │   │   │   └── lamaran_form_screen.dart
│   │   │   ├── statistik/
│   │   │   │   └── statistik_screen.dart
│   │   │   └── splash_screen.dart
│   │   ├── widgets/
│   │   │   ├── application_card.dart
│   │   │   ├── timeline_widget.dart
│   │   │   ├── interview_notes_widget.dart
│   │   │   ├── document_checklist_widget.dart
│   │   │   ├── stage_status_badge.dart
│   │   │   ├── priority_badge.dart
│   │   │   ├── stat_card.dart
│   │   │   ├── empty_state_widget.dart
│   │   │   └── custom_text_field.dart
│   │   ├── routes.dart
│   │   └── main.dart
│   ├── pubspec.yaml
│   └── README.md
├── .gitignore
└── README.md
```

---

## 5. Keputusan Desain Tambahan
1. **Aturan Status vs Tahap**:
   - Jika `tahap` bukan `'hasil'`, maka nilai status selalu dikunci menjadi `'menunggu'`.
   - Hanya saat `tahap == 'hasil'`, pengguna dapat memilih status `'lolos'` atau `'ditolak'`, serta melampirkan `catatan_hasil` evaluasi.
2. **Pengingat Tenggat**:
   - Notifikasi lokal dijadwalkan pada H-3 dan H-1 sebelum tanggal tenggat pukul 08:00 WIB/lokal menggunakan `flutter_local_notifications`. Jika tanggal H-3 atau H-1 sudah lewat, jadwal diabaikan.
3. **Validasi Formulir**:
   - Kolom `nama_perusahaan`, `posisi`, `tanggal_lamar`, `tenggat` adalah wajib.
   - `tenggat` tidak boleh mendahului `tanggal_lamar`.
   - Format email diverifikasi menggunakan regex standar pada frontend dan backend.


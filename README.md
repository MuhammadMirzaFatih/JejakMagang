# JejakMagang 📱🚀

**JejakMagang** adalah aplikasi mobile yang dirancang untuk membantu mahasiswa mencatat, mengelola, dan memantau seluruh proses lamaran magang dalam satu tempat yang rapi dan terorganisir.

Aplikasi ini mencakup pencatatan data perusahaan, posisi, tanggal lamar, tenggat, kontak HRD, tahapan seleksi, garis waktu riwayat (*timeline*), pengingat tenggat terjadwal, checklist 4 berkas persyaratan (CV, surat lamaran, portofolio, transkrip), catatan persiapan wawancara, label prioritas, catatan evaluasi hasil akhir, dan visualisasi grafik statistik.

---

## 🌟 13 Fitur Wajib yang Tersedia

1. **Daftar Akun dan Masuk (Autentikasi)**: Registrasi, masuk dengan JWT token, kata sandi dienkripsi dengan `bcrypt`, sesi tersimpan di `flutter_secure_storage`, dan data antar pengguna terisolasi penuh.
2. **Tambah, Ubah, dan Hapus Lamaran (CRUD)**: Kelola nama perusahaan, posisi, tanggal lamar, tenggat, tautan lowongan, nama dan email kontak HRD, serta konfirmasi saat hapus.
3. **Tahapan Seleksi per Lamaran**: Tahapan: *Kirim Berkas*, *Tes*, *Wawancara*, dan *Hasil*. Status otomatis *Menunggu* sebelum tahap hasil; dapat dipilih *Lolos* atau *Ditolak* saat mencapai tahap hasil.
4. **Filter Berdasarkan Tahap**: Filter instan berdasarkan tahapan seleksi dan pencarian teks judul perusahaan/posisi.
5. **Pengingat Tenggat**: Notifikasi lokal otomatis terjadwal pada **H-3** dan **H-1** pukul **08.00** sebelum tenggat waktu lamaran (`flutter_local_notifications`), serta badge penanda *Lewat Tenggat*.
6. **Ringkasan Statistik**: Penghitungan total lamaran, status menunggu, lolos, ditolak, prioritas impian, dan lewat tenggat.
7. **Garis Waktu per Lamaran (Signature Feature)**: Tampilan visual vertikal riwayat perjalanan tahapan lamaran magang dari awal hingga akhir beserta tanggal dan catatan keterangannya.
8. **Catatan Persiapan Wawancara**: Daftar pertanyaan yang mungkin muncul, jawaban yang disiapkan, dan hal yang perlu dipelajari per lamaran (CRUD lengkap).
9. **Daftar Berkas Persyaratan**: Checklist 4 berkas utama (CV, Surat Lamaran, Portofolio, Transkrip) dengan progress bar persentase yang tampil di kartu daftar utama.
10. **Mode Gelap (Dark Mode)**: Pengalihan tema gelap dan terang secara instan, tersimpan persisten melalui `shared_preferences`.
11. **Grafik Statistik (`fl_chart`)**: Diagram lingkaran (*Pie Chart*) sebaran status dan diagram batang (*Bar Chart*) sebaran tahapan seleksi.
12. **Label Prioritas**: Penanda bintang emas untuk lamaran impian; lamaran berprioritas selalu ditampilkan di paling atas daftar.
13. **Catatan Hasil Akhir**: Kolom evaluasi alasan diterima/ditolak dan refleksi diri saat lamaran mencapai tahap hasil.

---

## 🛠️ Tumpukan Teknologi (Tech Stack)

| Bagian | Teknologi | Keterangan |
|---|---|---|
| **Mobile Frontend** | Flutter 3.47+ (Dart) | Antarmuka mobile modern (iOS/Android/Web/Desktop) |
| **State Management**| `provider` | Pengelolaan status reaktif dan modular |
| **Navigasi** | `go_router` | Rute deklaratif |
| **HTTP Client** | `http` | Pemanggilan RESTful API dengan header token |
| **Grafik Data** | `fl_chart` | Visualisasi Pie Chart & Bar Chart interaktif |
| **Notifikasi** | `flutter_local_notifications` | Notifikasi pengingat tenggat lokal terjadwal H-3 & H-1 |
| **Penyimpanan Aman**| `flutter_secure_storage` | Penyimpanan JWT Token otentikasi pengguna |
| **Preferensi** | `shared_preferences` | Penyimpanan pilihan mode gelap & URL API kustom |
| **Backend API** | Node.js (Express.js) | Server API REST modular |
| **Basis Data** | MySQL 8.x / MariaDB | Relasional database dengan driver `mysql2` |
| **Kueri SQL** | Raw SQL Queries | Kueri langsung tanpa ORM agar mudah dijelaskan di video |
| **Keamanan** | `bcryptjs` & `jsonwebtoken` | Hashing kata sandi dan otentikasi sesi JWT |

---

## 📁 Struktur Repositori

```text
JejakMagang/
├── docs/
│   └── rancangan.md               # Dokumen rancangan database, endpoint, & arsitektur
├── db/
│   ├── schema.sql                 # DDL skrip pembuatan basis data & tabel
│   ├── seed.sql                   # Data awal contoh untuk pengujian
│   └── README.md                  # Panduan menjalankan MySQL
├── api/
│   ├── src/
│   │   ├── config/database.js     # Pool koneksi MySQL raw queries
│   │   ├── middlewares/auth.js    # Verifikasi token JWT
│   │   ├── controllers/           # Logika bisnis endpoint
│   │   ├── routes/                # Pemetaan rute REST API
│   │   ├── scripts/               # Skrip migrasi seed & uji otomatis 17 endpoint
│   │   └── app.js                 # Konfigurasi Express & error handling
│   ├── index.js                   # Entry point server API
│   ├── package.json
│   ├── .env.example
│   └── README.md                  # Panduan API backend
├── frontend/
│   ├── lib/
│   │   ├── config/                # URL API dinamis & tema terang/gelap
│   │   ├── models/                # Model data (User, Lamaran, Timeline, Berkas, dll)
│   │   ├── services/              # API Client, Notifikasi, & Penyimpanan
│   │   ├── providers/             # State Management Provider
│   │   ├── screens/               # Layar antarmuka per fitur
│   │   ├── widgets/               # Komponen UI modular
│   │   ├── routes.dart            # Navigasi go_router
│   │   └── main.dart              # Entry point aplikasi Flutter
│   ├── test/                      # Pengujian unit & parsing
│   ├── pubspec.yaml
│   └── README.md                  # Panduan aplikasi Flutter
├── .gitignore
└── README.md
```

---

## 🚀 Panduan Menjalankan dari Nol

### 1. Prasyarat
- **Node.js** v18+ atau v20+
- **MySQL** aktif di port 3306 (Laragon, XAMPP, atau MySQL Server mandiri)
- **Flutter SDK** versi 3.19+

---

### 2. Menyiapkan Basis Data & Menjalankan API

1. Buka terminal pada folder proyek:
   ```bash
   cd api
   ```
2. Buat berkas konfigurasi `.env` (salin dari `.env.example`):
   ```bash
   cp .env.example .env
   ```
   *(Secara default host adalah `127.0.0.1`, port `3306`, user `root`, password kosong, dan database `jejakmagang`)*.
3. Pasang paket dependensi API:
   ```bash
   npm install
   ```
4. Jalankan migrasi tabel dan data seed otomatis:
   ```bash
   npm run seed
   ```
5. *(Opsional)* Jalankan pengujian otomatis untuk memverifikasi 17 endpoint API:
   ```bash
   npm test
   ```
6. Jalankan server API:
   ```bash
   npm start
   ```
   Server API akan aktif di `http://localhost:3000` (Healthcheck: `http://localhost:3000/api/health`).

---

### 3. Menjalankan Aplikasi Mobile Frontend

Buka jendela terminal baru:

1. Masuk ke folder frontend:
   ```bash
   cd frontend
   ```
2. Ambil paket Flutter:
   ```bash
   flutter pub get
   ```
3. Verifikasi kode:
   ```bash
   flutter analyze
   flutter test
   ```
4. Jalankan aplikasi:
   ```bash
   # Jalankan di Chrome (Web):
   flutter run -d chrome

# Atau di Desktop Windows:
   flutter run -d windows

# Atau di Android Emulator / HP Fisik:
   flutter run
   ```

> **Catatan Alamat API:**
> - Di Android Emulator, aplikasi otomatis mengarah ke `http://10.0.2.2:3000/api`.
> - Di Web atau Desktop Windows, aplikasi otomatis mengarah ke `http://localhost:3000/api`.
> - Jika menggunakan **HP Fisik**, buka menu **Pengaturan** (ikon gerigi di pojok kanan atas aplikasi) lalu ubah URL dasar ke IP lokal komputer Anda (contoh: `http://192.168.1.10:3000/api`) dan klik tombol **Tes Koneksi**.

---

## 👤 Akun Contoh untuk Mencoba

| Keterangan | Email | Kata Sandi |
|---|---|---|
| **Akun Demo (Budi Santoso)** | `budi@mahasiswa.id` | `Password123!` |

*(Tersedia tombol satu-klik **Gunakan Akun Contoh (Budi)** pada layar login untuk pengujian instan).*


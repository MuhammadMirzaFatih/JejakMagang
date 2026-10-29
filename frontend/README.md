# Frontend Mobile JejakMagang (Flutter)

Aplikasi mobile **JejakMagang** dibangun menggunakan **Flutter (Dart)** dengan antarmuka modern, bersih, responsif, dan seluruh teks dalam **Bahasa Indonesia**.

---

## Fitur Aplikasi yang Tersedia

1. **Daftar Akun & Masuk (Otentikasi)**:
   - Registrasi pengguna (Nama, Email, Kata Sandi).
   - Masuk akun dengan token JWT tersimpan aman di `flutter_secure_storage`.
   - Tombol instan *Isi Akun Contoh (Budi)* untuk kemudahan demo pengujian.
   - Isolasi data pengguna: Pengguna hanya melihat lamarannya sendiri.

2. **Manajemen Lamaran Magang (CRUD)**:
   - Formulir tambah dan ubah lamaran (Perusahaan, Posisi, Tanggal Lamar, Tenggat, Tautan, Kontak HRD, Prioritas).
   - Validasi formulir lengkap (format email, kolom wajib, tanggal tenggat tidak boleh sebelum tanggal lamar).
   - Hapus lamaran dengan dialog konfirmasi keamanan.

3. **Tahapan Seleksi per Lamaran**:
   - 4 tahap seleksi: **Kirim Berkas**, **Tes Seleksi**, **Wawancara**, dan **Hasil Akhir**.
   - Pengguna dapat memindahkan tahap kapan saja.
   - Status otomatis dikunci menjadi *Menunggu* sebelum tahap hasil, dan dapat dipilih *Lolos* / *Ditolak* saat mencapai tahap hasil.

4. **Filter Berdasarkan Tahap**:
   - Filter chips di bagian atas: *Semua*, *Kirim Berkas*, *Tes*, *Wawancara*, *Hasil*.
   - Fitur pencarian instan nama perusahaan dan posisi magang.

5. **Pengingat Tenggat & Penanda Lewat Tenggat**:
   - Notifikasi lokal otomatis dijadwalkan pada **H-3** dan **H-1** pukul **08.00** sebelum tenggat waktu lamaran menggunakan `flutter_local_notifications`.
   - Penanda visual khusus (*Lewat Tenggat*) untuk lamaran yang tanggalnya telah terlewati.

6. **Ringkasan Statistik**:
   - Kartu metrik total lamaran, jumlah menunggu, lolos, ditolak, prioritas impian, dan lewat tenggat.

7. **Garis Waktu (Timeline) yang Menonjol**:
   - Tampilan garis waktu vertikal di halaman detail sebagai ciri khas aplikasi, mencatat setiap perpindahan tahapan beserta tanggal dan keterangannya.

8. **Catatan Persiapan Wawancara**:
   - Tambah, ubah, dan hapus pertanyaan wawancara yang diprediksi, jawaban yang disiapkan, dan hal yang perlu dipelajari.

9. **Daftar Centang Berkas Persyaratan**:
   - Checklist 4 berkas wajib: **CV**, **Surat Lamaran**, **Portofolio**, dan **Transkrip**.
   - Indikator persentase kelengkapan berkas ditampilkan langsung pada kartu daftar lamaran.

10. **Mode Gelap (Dark Mode)**:
    - Beralih instan antara mode terang dan gelap dari AppBar atau Pengaturan.
    - Pilihan tersimpan persisten melalui `shared_preferences`.

11. **Grafik Statistik (`fl_chart`)**:
    - Diagram lingkaran (*Pie Chart*) interaktif untuk sebaran status (Menunggu, Lolos, Ditolak).
    - Diagram batang (*Bar Chart*) untuk distribusi jumlah lamaran per tahapan seleksi.

12. **Label Prioritas (Impian)**:
    - Tandai lamaran favorit/impian dengan ikon bintang prioritas emas.
    - Lamaran prioritas otomatis tampil paling atas di daftar utama.

13. **Catatan Evaluasi Hasil Akhir**:
    - Saat mencapai tahap hasil, pengguna dapat mengisi catatan evaluasi (alasan diterima/ditolak dan refleksi diri).

---

## Struktur Folder Frontend

```text
frontend/
├── lib/
│   ├── config/
│   │   ├── api_config.dart          # Konfigurasi URL API & rute
│   │   └── theme.dart               # Palet tema terang & gelap
│   ├── models/
│   │   ├── user_model.dart          # Model pengguna
│   │   ├── lamaran_model.dart       # Model lamaran & helper hari
│   │   ├── riwayat_tahap_model.dart # Model riwayat garis waktu
│   │   ├── wawancara_model.dart     # Model catatan wawancara
│   │   ├── berkas_model.dart        # Model berkas persyaratan
│   │   └── statistik_model.dart     # Model ringkasan statistik
│   ├── services/
│   │   ├── api_service.dart         # Klien HTTP terpadu & header JWT
│   │   ├── storage_service.dart     # Secure storage & Shared preferences
│   │   └── notification_service.dart# Penjadwal notifikasi H-3 & H-1
│   ├── providers/
│   │   ├── theme_provider.dart      # Provider mode gelap/terang
│   │   ├── auth_provider.dart       # Provider otentikasi sesi
│   │   ├── lamaran_provider.dart    # Provider data lamaran & aksi
│   │   └── statistik_provider.dart  # Provider metrik & grafik
│   ├── screens/
│   │   ├── splash_screen.dart       # Cek sesi saat startup
│   │   ├── auth/
│   │   │   ├── login_screen.dart    # Masuk akun & tombol demo
│   │   │   └── register_screen.dart # Pendaftaran akun baru
│   │   ├── lamaran/
│   │   │   ├── lamaran_list_screen.dart   # Daftar utama, filter, pencarian
│   │   │   ├── lamaran_form_screen.dart   # Formulir tambah & ubah
│   │   │   └── lamaran_detail_screen.dart # Detail, timeline, berkas, wawancara
│   │   ├── statistik/
│   │   │   └── statistik_screen.dart      # Kartu metrik & grafik fl_chart
│   │   └── settings/
│   │       └── settings_screen.dart       # Konfigurasi API, tema, profil
│   ├── widgets/
│   │   ├── application_card.dart    # Kartu item lamaran di daftar
│   │   ├── custom_text_field.dart   # Input teks dengan validasi
│   │   ├── document_checklist_widget.dart # Checklist 4 berkas
│   │   ├── empty_state_widget.dart  # Tampilan kondisi data kosong
│   │   ├── interview_notes_widget.dart    # CRUD catatan wawancara
│   │   ├── priority_badge.dart      # Badge bintang prioritas
│   │   ├── stage_status_badge.dart  # Badge tahap & status
│   │   ├── stat_card.dart           # Kartu metrik statistik
│   │   └── timeline_widget.dart     # Garis waktu seleksi
│   ├── routes.dart                  # Konfigurasi navigasi go_router
│   └── main.dart                    # Entry point aplikasi Flutter
├── pubspec.yaml
└── README.md
```

---

## Prasyarat Menjalankan
- Flutter SDK versi 3.19+ atau 3.24+ (tersedia versi 3.47 di environment ini).
- Perangkat fisik (Android/iOS) atau Emulator Android / Chrome Browser / Desktop Windows.

---

## Langkah Menjalankan

### 1. Masuk ke Folder Frontend
```bash
cd frontend
```

### 2. Pasang Dependensi
```bash
flutter pub get
```

### 3. Konfigurasi Alamat API
Secara default, aplikasi telah dikonfigurasi:
- **Emulator Android**: Menggunakan `http://10.0.2.2:3000/api`
- **Windows / Web / iOS Simulator**: Menggunakan `http://localhost:3000/api`

Jika menggunakan **HP Fisik**, Anda dapat mengubah URL di dalam aplikasi melalui menu **Pengaturan (Ikon Roda Gigi di kanan atas)** atau mengubah berkas [api_config.dart](file:///c:/Users/ASUS/JejakMagang/frontend/lib/config/api_config.dart) menjadi IP komputer lokal Anda (misal `http://192.168.1.10:3000/api`).

Tersedia tombol **Tes Koneksi** pada layar Pengaturan untuk memverifikasi sambungan ke server backend secara instan.

### 4. Jalankan Aplikasi
```bash
# Jalankan di emulator / device default:
flutter run

# Atau jalankan di Chrome:
flutter run -d chrome

# Atau jalankan di Windows Desktop:
flutter run -d windows
```

### 5. Menjalankan Analisis Kode
```bash
flutter analyze
```
*(Hasil: `No issues found!`)*

### 6. Menjalankan Pengujian Otomatis
```bash
flutter test
```
*(Hasil: `All tests passed!`)*

# Panduan Basis Data JejakMagang (MySQL)

Direktori ini berisi skrip DDL skema dan data awal (seeding) untuk basis data aplikasi **JejakMagang**.

## Prasyarat
- Server MySQL versi 8.0+ atau MariaDB 10.4+ yang sedang aktif di port 3306.
- Kredensial pengguna (default Laragon / XAMPP: user `root`, password kosong `""`).

## Berkas yang Tersedia
1. `schema.sql`: Membuat basis data `jejakmagang` beserta tabel `users`, `lamaran`, `riwayat_tahap`, `catatan_wawancara`, dan `berkas_lamaran` dengan constraint dan indeks.
2. `seed.sql`: Berisi data awal realistis untuk pengujian, termasuk akun demo, contoh lamaran pada berbagai tahap, riwayat garis waktu, catatan wawancara, dan kelengkapan berkas.

## Langkah Menjalankan Skrip

### Opsi A: Menggunakan Perintah MySQL CLI
Buka terminal dan jalankan perintah berikut:

```bash
# 1. Eksekusi skema basis data
mysql -u root -p < schema.sql

# 2. Eksekusi data seed
mysql -u root -p < seed.sql
```

*(Jika tidak menggunakan password, hilangkan opsi `-p` atau tekan Enter saat diminta password).*

### Opsi B: Menggunakan phpMyAdmin / DBeaver / HeidiSQL
1. Buka antarmuka manajemen MySQL favorit Anda (seperti HeidiSQL bawaan Laragon atau phpMyAdmin).
2. Buat query baru, salin isi `schema.sql`, lalu jalankan.
3. Buka query baru lagi, salin isi `seed.sql`, lalu jalankan.

### Opsi C: Menggunakan Skrip API (Node.js)
Dari folder `api/`, Anda juga dapat menjalankan:
```bash
npm run seed
```

## Akun Demo
Setelah skrip dijalankan, akun demo berikut siap digunakan:
- **Email**: `budi@mahasiswa.id`
- **Kata Sandi**: `Password123!`


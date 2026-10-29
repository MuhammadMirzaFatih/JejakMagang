-- Skrip Data Contoh (Seed) JejakMagang
-- Akun contoh: budi@mahasiswa.id / Password123!

USE jejakmagang;

-- Hapus data contoh sebelumnya jika ada
DELETE FROM users WHERE email = 'budi@mahasiswa.id';

-- 1. Tambah Akun Pengguna Contoh
-- Password hash untuk 'Password123!'
INSERT INTO users (id, nama, email, password) VALUES
(1, 'Budi Santoso', 'budi@mahasiswa.id', '$2a$10$pp9uyEw0GQ3Y6XP/m7mb2OeHlXFdI7gqLC8vGScQnCT.QfFx3RoWi');

-- 2. Tambah Data Lamaran Contoh
INSERT INTO lamaran (id, user_id, nama_perusahaan, posisi, tanggal_lamar, tenggat, tautan_lowongan, nama_kontak_hrd, email_kontak_hrd, tahap, status, is_prioritas, catatan_hasil) VALUES
(1, 1, 'PT GoTo Gojek Tokopedia', 'Mobile Developer Intern (Flutter)', '2026-10-10', '2026-11-05', 'https://career.goto.com/jobs/mobile-dev-intern', 'Sarah Wijaya', 'sarah.hrd@goto.com', 'wawancara', 'menunggu', TRUE, NULL),
(2, 1, 'PT Bank Central Asia Tbk', 'IT Trainee Intern', '2026-09-15', '2026-10-20', 'https://karir.bca.co.id/internship', 'Hendra Setiawan', 'hendra_hrd@bca.co.id', 'hasil', 'lolos', FALSE, 'Diterima magang periode 6 bulan dengan uang saku dan bimbingan mentor senior. Mulai onboarding Desember 2026.'),
(3, 1, 'Shopee Indonesia', 'Software Engineering Intern', '2026-09-01', '2026-09-25', 'https://careers.shopee.co.id', 'Tim Rekrutmen', 'recruitment@shopee.com', 'hasil', 'ditolak', FALSE, 'Belum lolos seleksi technical test algoritma dynamic programming. Perlu lebih banyak latihan LeetCode medium/hard.'),
(4, 1, 'PT Telkom Indonesia (Persero) Tbk', 'Frontend & Mobile Intern', '2026-10-15', '2026-11-02', 'https://rekrutmen.telkom.co.id', 'Rian Pratama', 'recruitment@telkom.co.id', 'tes', 'menunggu', TRUE, NULL),
(5, 1, 'Traveloka', 'Mobile Engineer Intern', '2026-10-24', '2026-11-10', 'https://traveloka.com/careers', 'Lisa Amanda', 'lisa@traveloka.com', 'kirim_berkas', 'menunggu', FALSE, NULL);

-- 3. Tambah Riwayat Garis Waktu (Timeline)
INSERT INTO riwayat_tahap (lamaran_id, tahap, tanggal, keterangan) VALUES
-- Lamaran 1 (GoTo)
(1, 'kirim_berkas', '2026-10-10', 'Berkas CV dan portofolio dikirim via website karir resmi.'),
(1, 'tes', '2026-10-18', 'Menyelesaikan online coding test Flutter & Dart 90 menit.'),
(1, 'wawancara', '2026-10-25', 'Diundang sesi user interview via Google Meet bersama Tech Lead.'),

-- Lamaran 2 (BCA)
(2, 'kirim_berkas', '2026-09-15', 'Kirim berkas via portal karir BCA IT.'),
(2, 'tes', '2026-09-28', 'Tes psikotes online dan logika pemrograman.'),
(2, 'wawancara', '2026-10-10', 'Wawancara HR dan wawancara user panel di Wisma BCA.'),
(2, 'hasil', '2026-10-20', 'Menerima surat penawaran resmi (Offering Letter) magang 6 bulan.'),

-- Lamaran 3 (Shopee)
(3, 'kirim_berkas', '2026-09-01', 'Submit resume via portal Shopee Careers.'),
(3, 'tes', '2026-09-12', 'Shopee Online Assessment HackerRank.'),
(3, 'hasil', '2026-09-25', 'Menerima email penolakan setelah tahap tes teknis.'),

-- Lamaran 4 (Telkom)
(4, 'kirim_berkas', '2026-10-15', 'Pendaftaran program magang bersertifikat Telkom.'),
(4, 'tes', '2026-10-26', 'Menerima link tes wawasan teknologi dan coding online.'),

-- Lamaran 5 (Traveloka)
(5, 'kirim_berkas', '2026-10-24', 'Aplikasi dikirimkan, menunggu konfirmasi berkas HRD.');

-- 4. Tambah Catatan Persiapan Wawancara
INSERT INTO catatan_wawancara (lamaran_id, pertanyaan, jawaban, hal_dipelajari) VALUES
(1, 'Bagaimana cara kerja State Management Provider pada Flutter?', 'Provider membungkus InheritedWidget untuk membagi state secara reaktif ke widget turunan tanpa perlu prop drilling, serta meminimalkan rebuild yang tidak perlu melalui Consumer atau context.watch/read.', 'Arsitektur Provider, ChangeNotifier, dan perbedaannya dengan Riverpod/Bloc.'),
(1, 'Ceritakan proyek Flutter paling menantang yang pernah Anda buat!', 'Membangun aplikasi e-commerce dengan offline cache, sinkronisasi REST API, dan integrasi payment gateway.', 'Cara menyampaikan dengan metode STAR (Situation, Task, Action, Result).'),
(2, 'Mengapa tertarik magang di industri perbankan (BCA)?', 'Ingin memahami implementasi arsitektur sistem perbankan skala besar dengan standar keamanan tinggi dan reliabilitas 99.99%.', 'Profil inovasi digital BCA seperti myBCA dan Blu.');

-- 5. Tambah Daftar Berkas Persyaratan (Checklist)
INSERT INTO berkas_lamaran (lamaran_id, nama_berkas, sudah_siap) VALUES
-- Lamaran 1 (GoTo) - Semua siap (100%)
(1, 'CV', TRUE),
(1, 'Surat Lamaran', TRUE),
(1, 'Portofolio', TRUE),
(1, 'Transkrip', TRUE),

-- Lamaran 2 (BCA) - Semua siap (100%)
(2, 'CV', TRUE),
(2, 'Surat Lamaran', TRUE),
(2, 'Portofolio', TRUE),
(2, 'Transkrip', TRUE),

-- Lamaran 3 (Shopee) - 3 siap (75%)
(3, 'CV', TRUE),
(3, 'Surat Lamaran', TRUE),
(3, 'Portofolio', FALSE),
(3, 'Transkrip', TRUE),

-- Lamaran 4 (Telkom) - 3 siap (75%)
(4, 'CV', TRUE),
(4, 'Surat Lamaran', TRUE),
(4, 'Portofolio', TRUE),
(4, 'Transkrip', FALSE),

-- Lamaran 5 (Traveloka) - 2 siap (50%)
(5, 'CV', TRUE),
(5, 'Surat Lamaran', TRUE),
(5, 'Portofolio', FALSE),
(5, 'Transkrip', FALSE);


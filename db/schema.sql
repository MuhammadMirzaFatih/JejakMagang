-- Skrip Pembuatan Basis Data JejakMagang
-- MySQL 8.x / MariaDB

CREATE DATABASE IF NOT EXISTS jejakmagang
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE jejakmagang;

-- Hapus tabel jika sudah ada sebelumnya (urutan foreign key)
DROP TABLE IF EXISTS berkas_lamaran;
DROP TABLE IF EXISTS catatan_wawancara;
DROP TABLE IF EXISTS riwayat_tahap;
DROP TABLE IF EXISTS lamaran;
DROP TABLE IF EXISTS users;

-- 1. Tabel Pengguna (Users)
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nama VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 2. Tabel Lamaran Magang
CREATE TABLE lamaran (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    nama_perusahaan VARCHAR(150) NOT NULL,
    posisi VARCHAR(150) NOT NULL,
    tanggal_lamar DATE NOT NULL,
    tenggat DATE NOT NULL,
    tautan_lowongan VARCHAR(500) NULL,
    nama_kontak_hrd VARCHAR(100) NULL,
    email_kontak_hrd VARCHAR(150) NULL,
    tahap ENUM('kirim_berkas', 'tes', 'wawancara', 'hasil') NOT NULL DEFAULT 'kirim_berkas',
    status ENUM('menunggu', 'lolos', 'ditolak') NOT NULL DEFAULT 'menunggu',
    is_prioritas BOOLEAN NOT NULL DEFAULT FALSE,
    catatan_hasil TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_lamaran_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_status (user_id, status),
    INDEX idx_user_tahap (user_id, tahap),
    INDEX idx_tenggat (tenggat)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 3. Tabel Riwayat Tahap (Garis Waktu / Timeline)
CREATE TABLE riwayat_tahap (
    id INT AUTO_INCREMENT PRIMARY KEY,
    lamaran_id INT NOT NULL,
    tahap ENUM('kirim_berkas', 'tes', 'wawancara', 'hasil') NOT NULL,
    tanggal DATE NOT NULL,
    keterangan VARCHAR(255) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_riwayat_lamaran FOREIGN KEY (lamaran_id) REFERENCES lamaran(id) ON DELETE CASCADE,
    INDEX idx_riwayat_lamaran (lamaran_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 4. Tabel Catatan Persiapan Wawancara
CREATE TABLE catatan_wawancara (
    id INT AUTO_INCREMENT PRIMARY KEY,
    lamaran_id INT NOT NULL,
    pertanyaan TEXT NOT NULL,
    jawaban TEXT NULL,
    hal_dipelajari TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_wawancara_lamaran FOREIGN KEY (lamaran_id) REFERENCES lamaran(id) ON DELETE CASCADE,
    INDEX idx_wawancara_lamaran (lamaran_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 5. Tabel Daftar Berkas Persyaratan (Checklist)
CREATE TABLE berkas_lamaran (
    id INT AUTO_INCREMENT PRIMARY KEY,
    lamaran_id INT NOT NULL,
    nama_berkas VARCHAR(100) NOT NULL,
    sudah_siap BOOLEAN NOT NULL DEFAULT FALSE,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_berkas_lamaran FOREIGN KEY (lamaran_id) REFERENCES lamaran(id) ON DELETE CASCADE,
    INDEX idx_berkas_lamaran (lamaran_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


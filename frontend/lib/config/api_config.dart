import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

/// Konfigurasi URL dasar API backend
class ApiConfig {
  // Alamat default berdasarkan platform
  static String get defaultBaseUrl {
    if (kIsWeb) {
      return 'http://localhost:3000/api';
    }
    try {
      if (Platform.isAndroid) {
        // 10.0.2.2 adalah alias localhost dari emulator Android ke host machine
        return 'http://10.0.2.2:3000/api';
      }
    } catch (_) {}
    return 'http://localhost:3000/api';
  }

  // URL aktif saat runtime (dapat diubah di halaman Pengaturan)
  static String baseUrl = defaultBaseUrl;

  // Endpoint Autentikasi
  static String get register => '$baseUrl/auth/register';
  static String get login => '$baseUrl/auth/login';
  static String get me => '$baseUrl/auth/me';

  // Endpoint Lamaran
  static String get lamaran => '$baseUrl/lamaran';
  static String lamaranDetail(int id) => '$baseUrl/lamaran/$id';
  static String lamaranTahap(int id) => '$baseUrl/lamaran/$id/tahap';
  static String lamaranPrioritas(int id) => '$baseUrl/lamaran/$id/prioritas';
  static String lamaranCatatanHasil(int id) => '$baseUrl/lamaran/$id/catatan-hasil';

  // Endpoint Wawancara
  static String wawancara(int lamaranId) => '$baseUrl/lamaran/$lamaranId/wawancara';
  static String wawancaraDetail(int lamaranId, int noteId) => '$baseUrl/lamaran/$lamaranId/wawancara/$noteId';

  // Endpoint Berkas
  static String berkas(int lamaranId) => '$baseUrl/lamaran/$lamaranId/berkas';
  static String berkasToggle(int lamaranId, int berkasId) => '$baseUrl/lamaran/$lamaranId/berkas/$berkasId';

  // Endpoint Statistik
  static String get statistik => '$baseUrl/statistik';
}


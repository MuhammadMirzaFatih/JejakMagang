import 'riwayat_tahap_model.dart';
import 'berkas_model.dart';
import 'wawancara_model.dart';

/// Model utama lamaran magang
class LamaranModel {
  final int id;
  final int userId;
  final String namaPerusahaan;
  final String posisi;
  final String tanggalLamar;
  final String tenggat;
  final String? tautanLowongan;
  final String? namaKontakHrd;
  final String? emailKontakHrd;
  final String tahap; // 'kirim_berkas', 'tes', 'wawancara', 'hasil'
  final String status; // 'menunggu', 'lolos', 'ditolak'
  final bool isPrioritas;
  final String? catatanHasil;
  final int totalBerkas;
  final int berkasSiap;
  final int persentaseBerkas;
  final bool isOverdue;

  // Detail lists
  final List<RiwayatTahapModel> riwayat;
  final List<BerkasModel> berkas;
  final List<WawancaraModel> catatanWawancara;

  LamaranModel({
    required this.id,
    required this.userId,
    required this.namaPerusahaan,
    required this.posisi,
    required this.tanggalLamar,
    required this.tenggat,
    this.tautanLowongan,
    this.namaKontakHrd,
    this.emailKontakHrd,
    required this.tahap,
    required this.status,
    required this.isPrioritas,
    this.catatanHasil,
    this.totalBerkas = 0,
    this.berkasSiap = 0,
    this.persentaseBerkas = 0,
    this.isOverdue = false,
    this.riwayat = const [],
    this.berkas = const [],
    this.catatanWawancara = const [],
  });

  factory LamaranModel.fromJson(Map<String, dynamic> json) {
    // Parse riwayat jika ada
    List<RiwayatTahapModel> riwayatList = [];
    if (json['riwayat'] != null && json['riwayat'] is List) {
      riwayatList = (json['riwayat'] as List)
          .map((item) => RiwayatTahapModel.fromJson(item))
          .toList();
    }

    // Parse berkas jika ada
    List<BerkasModel> berkasList = [];
    if (json['berkas'] != null && json['berkas'] is List) {
      berkasList = (json['berkas'] as List)
          .map((item) => BerkasModel.fromJson(item))
          .toList();
    }

    // Parse catatan wawancara jika ada
    List<WawancaraModel> wawancaraList = [];
    if (json['catatan_wawancara'] != null && json['catatan_wawancara'] is List) {
      wawancaraList = (json['catatan_wawancara'] as List)
          .map((item) => WawancaraModel.fromJson(item))
          .toList();
    }

    final totalB = json['total_berkas'] != null ? int.parse(json['total_berkas'].toString()) : berkasList.length;
    final siapB = json['berkas_siap'] != null ? int.parse(json['berkas_siap'].toString()) : berkasList.where((b) => b.sudahSiap).length;
    final pctB = json['persentase_berkas'] != null
        ? int.parse(json['persentase_berkas'].toString())
        : (totalB > 0 ? ((siapB / totalB) * 100).round() : 0);

    return LamaranModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      userId: json['user_id'] != null ? int.parse(json['user_id'].toString()) : 0,
      namaPerusahaan: json['nama_perusahaan'] ?? '',
      posisi: json['posisi'] ?? '',
      tanggalLamar: json['tanggal_lamar'] ?? '',
      tenggat: json['tenggat'] ?? '',
      tautanLowongan: json['tautan_lowongan'],
      namaKontakHrd: json['nama_kontak_hrd'],
      emailKontakHrd: json['email_kontak_hrd'],
      tahap: json['tahap'] ?? 'kirim_berkas',
      status: json['status'] ?? 'menunggu',
      isPrioritas: json['is_prioritas'] == true || json['is_prioritas'] == 1,
      catatanHasil: json['catatan_hasil'],
      totalBerkas: totalB,
      berkasSiap: siapB,
      persentaseBerkas: pctB,
      isOverdue: json['is_overdue'] == true || json['is_overdue'] == 1,
      riwayat: riwayatList,
      berkas: berkasList,
      catatanWawancara: wawancaraList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'nama_perusahaan': namaPerusahaan,
      'posisi': posisi,
      'tanggal_lamar': tanggalLamar,
      'tenggat': tenggat,
      'tautan_lowongan': tautanLowongan,
      'nama_kontak_hrd': namaKontakHrd,
      'email_kontak_hrd': emailKontakHrd,
      'tahap': tahap,
      'status': status,
      'is_prioritas': isPrioritas,
      'catatan_hasil': catatanHasil,
    };
  }

  /// Label tahap dalam bahasa Indonesia
  String get tahapLabel {
    switch (tahap) {
      case 'kirim_berkas':
        return 'Kirim Berkas';
      case 'tes':
        return 'Tes Seleksi';
      case 'wawancara':
        return 'Wawancara';
      case 'hasil':
        return 'Hasil Akhir';
      default:
        return tahap;
    }
  }

  /// Label status dalam bahasa Indonesia
  String get statusLabel {
    switch (status) {
      case 'menunggu':
        return 'Menunggu';
      case 'lolos':
        return 'Lolos';
      case 'ditolak':
        return 'Ditolak';
      default:
        return status;
    }
  }

  /// Hitung sisa hari sebelum tenggat
  int get sisaHari {
    try {
      final deadline = DateTime.parse(tenggat);
      final today = DateTime.now();
      final deadlineDate = DateTime(deadline.year, deadline.month, deadline.day);
      final todayDate = DateTime(today.year, today.month, today.day);
      return deadlineDate.difference(todayDate).inDays;
    } catch (_) {
      return 0;
    }
  }

  /// Apakah mendekati tenggat (H-3 atau H-1)
  bool get isMendekatiTenggat {
    if (status != 'menunggu') return false;
    final sisa = sisaHari;
    return sisa >= 0 && sisa <= 3;
  }
}


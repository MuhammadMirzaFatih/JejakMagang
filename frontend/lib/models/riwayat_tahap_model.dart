/// Model entri garis waktu (timeline) riwayat tahap lamaran
class RiwayatTahapModel {
  final int id;
  final int lamaranId;
  final String tahap;
  final String tanggal;
  final String? keterangan;
  final String? createdAt;

  RiwayatTahapModel({
    required this.id,
    required this.lamaranId,
    required this.tahap,
    required this.tanggal,
    this.keterangan,
    this.createdAt,
  });

  factory RiwayatTahapModel.fromJson(Map<String, dynamic> json) {
    return RiwayatTahapModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      lamaranId: json['lamaran_id'] is int ? json['lamaran_id'] : int.parse(json['lamaran_id'].toString()),
      tahap: json['tahap'] ?? 'kirim_berkas',
      tanggal: json['tanggal'] ?? '',
      keterangan: json['keterangan'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lamaran_id': lamaranId,
      'tahap': tahap,
      'tanggal': tanggal,
      'keterangan': keterangan,
      'created_at': createdAt,
    };
  }

  /// Label tahap dalam bahasa Indonesia
  String get tahapLabel {
    switch (tahap) {
      case 'kirim_berkas':
        return 'Kirim Berkas';
      case 'tes':
        return 'Tes';
      case 'wawancara':
        return 'Wawancara';
      case 'hasil':
        return 'Hasil';
      default:
        return tahap;
    }
  }
}


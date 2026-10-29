/// Model kelengkapan berkas persyaratan
class BerkasModel {
  final int id;
  final int lamaranId;
  final String namaBerkas;
  bool sudahSiap;
  final String? updatedAt;

  BerkasModel({
    required this.id,
    required this.lamaranId,
    required this.namaBerkas,
    required this.sudahSiap,
    this.updatedAt,
  });

  factory BerkasModel.fromJson(Map<String, dynamic> json) {
    return BerkasModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      lamaranId: json['lamaran_id'] is int ? json['lamaran_id'] : int.parse(json['lamaran_id'].toString()),
      namaBerkas: json['nama_berkas'] ?? '',
      sudahSiap: json['sudah_siap'] == true || json['sudah_siap'] == 1,
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lamaran_id': lamaranId,
      'nama_berkas': namaBerkas,
      'sudah_siap': sudahSiap,
      'updated_at': updatedAt,
    };
  }
}


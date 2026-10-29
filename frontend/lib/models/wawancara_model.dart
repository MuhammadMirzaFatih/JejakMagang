/// Model catatan persiapan wawancara
class WawancaraModel {
  final int id;
  final int lamaranId;
  final String pertanyaan;
  final String? jawaban;
  final String? halDipelajari;
  final String? createdAt;
  final String? updatedAt;

  WawancaraModel({
    required this.id,
    required this.lamaranId,
    required this.pertanyaan,
    this.jawaban,
    this.halDipelajari,
    this.createdAt,
    this.updatedAt,
  });

  factory WawancaraModel.fromJson(Map<String, dynamic> json) {
    return WawancaraModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      lamaranId: json['lamaran_id'] is int ? json['lamaran_id'] : int.parse(json['lamaran_id'].toString()),
      pertanyaan: json['pertanyaan'] ?? '',
      jawaban: json['jawaban'],
      halDipelajari: json['hal_dipelajari'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lamaran_id': lamaranId,
      'pertanyaan': pertanyaan,
      'jawaban': jawaban,
      'hal_dipelajari': halDipelajari,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}


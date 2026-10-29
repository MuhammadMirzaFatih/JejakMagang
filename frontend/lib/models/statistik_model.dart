/// Model ringkasan statistik lamaran
class StatistikModel {
  final int totalLamaran;
  final int menunggu;
  final int lolos;
  final int ditolak;
  final int kirimBerkas;
  final int tes;
  final int wawancara;
  final int hasil;
  final int prioritas;
  final int lewatTenggat;

  StatistikModel({
    required this.totalLamaran,
    required this.menunggu,
    required this.lolos,
    required this.ditolak,
    required this.kirimBerkas,
    required this.tes,
    required this.wawancara,
    required this.hasil,
    required this.prioritas,
    required this.lewatTenggat,
  });

  factory StatistikModel.fromJson(Map<String, dynamic> json) {
    final status = json['status'] ?? {};
    final tahap = json['tahap'] ?? {};

    return StatistikModel(
      totalLamaran: json['total_lamaran'] != null ? int.parse(json['total_lamaran'].toString()) : 0,
      menunggu: status['menunggu'] != null ? int.parse(status['menunggu'].toString()) : 0,
      lolos: status['lolos'] != null ? int.parse(status['lolos'].toString()) : 0,
      ditolak: status['ditolak'] != null ? int.parse(status['ditolak'].toString()) : 0,
      kirimBerkas: tahap['kirim_berkas'] != null ? int.parse(tahap['kirim_berkas'].toString()) : 0,
      tes: tahap['tes'] != null ? int.parse(tahap['tes'].toString()) : 0,
      wawancara: tahap['wawancara'] != null ? int.parse(tahap['wawancara'].toString()) : 0,
      hasil: tahap['hasil'] != null ? int.parse(tahap['hasil'].toString()) : 0,
      prioritas: json['prioritas'] != null ? int.parse(json['prioritas'].toString()) : 0,
      lewatTenggat: json['lewat_tenggat'] != null ? int.parse(json['lewat_tenggat'].toString()) : 0,
    );
  }

  factory StatistikModel.empty() {
    return StatistikModel(
      totalLamaran: 0,
      menunggu: 0,
      lolos: 0,
      ditolak: 0,
      kirimBerkas: 0,
      tes: 0,
      wawancara: 0,
      hasil: 0,
      prioritas: 0,
      lewatTenggat: 0,
    );
  }
}


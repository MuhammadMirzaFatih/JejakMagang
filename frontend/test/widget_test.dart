import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/models/lamaran_model.dart';
import 'package:frontend/models/user_model.dart';

void main() {
  test('UserModel json parsing smoke test', () {
    final json = {
      'id': 1,
      'nama': 'Budi Santoso',
      'email': 'budi@mahasiswa.id',
    };
    final user = UserModel.fromJson(json);
    expect(user.id, 1);
    expect(user.nama, 'Budi Santoso');
    expect(user.email, 'budi@mahasiswa.id');
  });

  test('LamaranModel json parsing and days calculation test', () {
    final json = {
      'id': 10,
      'user_id': 1,
      'nama_perusahaan': 'PT Inovasi Digital',
      'posisi': 'Flutter Developer',
      'tanggal_lamar': '2026-10-01',
      'tenggat': '2026-11-01',
      'tahap': 'wawancara',
      'status': 'menunggu',
      'is_prioritas': true,
      'total_berkas': 4,
      'berkas_siap': 4,
    };
    final lamaran = LamaranModel.fromJson(json);
    expect(lamaran.id, 10);
    expect(lamaran.namaPerusahaan, 'PT Inovasi Digital');
    expect(lamaran.tahapLabel, 'Wawancara');
    expect(lamaran.isPrioritas, true);
    expect(lamaran.persentaseBerkas, 100);
  });
}

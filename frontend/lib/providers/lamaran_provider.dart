import 'package:flutter/material.dart';
import '../config/api_config.dart';
import '../models/lamaran_model.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';

/// Provider pengelola data lamaran magang, tahapan seleksi, berkas, dan catatan wawancara
class LamaranProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final NotificationService _notificationService = NotificationService();

  List<LamaranModel> _lamaranList = [];
  LamaranModel? _selectedLamaran;
  bool _isLoading = false;
  String? _errorMessage;

  // Filter & Pencarian
  String _filterTahap = 'semua';
  String _filterStatus = 'semua';
  String _searchQuery = '';

  List<LamaranModel> get lamaranList => _lamaranList;
  LamaranModel? get selectedLamaran => _selectedLamaran;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String get filterTahap => _filterTahap;
  String get filterStatus => _filterStatus;
  String get searchQuery => _searchQuery;

  // Dapatkan daftar lamaran dengan filter aktif
  Future<void> fetchLamaranList() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final queryParams = <String, String>{};
      if (_filterTahap != 'semua') queryParams['tahap'] = _filterTahap;
      if (_filterStatus != 'semua') queryParams['status'] = _filterStatus;
      if (_searchQuery.trim().isNotEmpty) queryParams['search'] = _searchQuery.trim();

      final uri = Uri.parse(ApiConfig.lamaran).replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);
      final response = await _apiService.get(uri.toString());

      if (response['success'] == true && response['data'] != null) {
        final List data = response['data'];
        _lamaranList = data.map((item) => LamaranModel.fromJson(item)).toList();

        // Jadwalkan ulang notifikasi pengingat tenggat (H-3 dan H-1)
        _notificationService.rescheduleAllReminders(_lamaranList);
      } else {
        _errorMessage = response['message'] ?? 'Gagal memuat daftar lamaran.';
      }
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan tidak terduga: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Dapatkan detail satu lamaran lengkap
  Future<void> fetchLamaranDetail(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.get(ApiConfig.lamaranDetail(id));
      if (response['success'] == true && response['data'] != null) {
        _selectedLamaran = LamaranModel.fromJson(response['data']);
      } else {
        _errorMessage = response['message'] ?? 'Gagal memuat detail lamaran.';
      }
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Tambah lamaran baru
  Future<bool> createLamaran(Map<String, dynamic> data) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.post(ApiConfig.lamaran, body: data);
      if (response['success'] == true) {
        await fetchLamaranList();
        return true;
      } else {
        _errorMessage = response['message'] ?? 'Gagal menambahkan lamaran.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Ubah data pokok lamaran
  Future<bool> updateLamaran(int id, Map<String, dynamic> data) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.put(ApiConfig.lamaranDetail(id), body: data);
      if (response['success'] == true) {
        await fetchLamaranDetail(id);
        await fetchLamaranList();
        return true;
      } else {
        _errorMessage = response['message'] ?? 'Gagal memperbarui lamaran.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Hapus lamaran
  Future<bool> deleteLamaran(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.delete(ApiConfig.lamaranDetail(id));
      if (response['success'] == true) {
        if (_selectedLamaran?.id == id) {
          _selectedLamaran = null;
        }
        await fetchLamaranList();
        return true;
      } else {
        _errorMessage = response['message'] ?? 'Gagal menghapus lamaran.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Ubah tahap seleksi (otomatis mencatat garis waktu)
  Future<bool> updateTahap(int id, {
    required String tahap,
    String? status,
    String? tanggal,
    String? keterangan,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final Map<String, dynamic> body = {'tahap': tahap};
      if (status != null) body['status'] = status;
      if (tanggal != null) body['tanggal'] = tanggal;
      if (keterangan != null && keterangan.trim().isNotEmpty) {
        body['keterangan'] = keterangan.trim();
      }

      final response = await _apiService.patch(ApiConfig.lamaranTahap(id), body: body);
      if (response['success'] == true) {
        await fetchLamaranDetail(id);
        await fetchLamaranList();
        return true;
      } else {
        _errorMessage = response['message'] ?? 'Gagal memperbarui tahapan.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Ubah status prioritas
  Future<bool> togglePrioritas(int id, bool isPrioritas) async {
    try {
      final response = await _apiService.patch(
        ApiConfig.lamaranPrioritas(id),
        body: {'is_prioritas': isPrioritas},
      );

      if (response['success'] == true) {
        // Perbarui list lokal
        final index = _lamaranList.indexWhere((l) => l.id == id);
        if (index != -1) {
          final old = _lamaranList[index];
          _lamaranList[index] = LamaranModel(
            id: old.id,
            userId: old.userId,
            namaPerusahaan: old.namaPerusahaan,
            posisi: old.posisi,
            tanggalLamar: old.tanggalLamar,
            tenggat: old.tenggat,
            tautanLowongan: old.tautanLowongan,
            namaKontakHrd: old.namaKontakHrd,
            emailKontakHrd: old.emailKontakHrd,
            tahap: old.tahap,
            status: old.status,
            isPrioritas: isPrioritas,
            catatanHasil: old.catatanHasil,
            totalBerkas: old.totalBerkas,
            berkasSiap: old.berkasSiap,
            persentaseBerkas: old.persentaseBerkas,
            isOverdue: old.isOverdue,
            riwayat: old.riwayat,
            berkas: old.berkas,
            catatanWawancara: old.catatanWawancara,
          );
          // Urutkan ulang: prioritas di atas
          _lamaranList.sort((a, b) {
            if (a.isPrioritas != b.isPrioritas) {
              return b.isPrioritas ? 1 : -1;
            }
            return a.tenggat.compareTo(b.tenggat);
          });
        }

        if (_selectedLamaran?.id == id) {
          await fetchLamaranDetail(id);
        } else {
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  // Simpan catatan evaluasi hasil akhir
  Future<bool> updateCatatanHasil(int id, {required String catatanHasil, String? status}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final Map<String, dynamic> body = {
        'catatan_hasil': catatanHasil.trim(),
      };
      if (status != null) body['status'] = status;

      final response = await _apiService.patch(ApiConfig.lamaranCatatanHasil(id), body: body);
      if (response['success'] == true) {
        await fetchLamaranDetail(id);
        await fetchLamaranList();
        return true;
      } else {
        _errorMessage = response['message'] ?? 'Gagal menyimpan catatan evaluasi.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Centang kelengkapan berkas
  Future<bool> toggleBerkas(int lamaranId, int berkasId, bool sudahSiap) async {
    try {
      final response = await _apiService.patch(
        ApiConfig.berkasToggle(lamaranId, berkasId),
        body: {'sudah_siap': sudahSiap},
      );

      if (response['success'] == true) {
        if (_selectedLamaran != null && _selectedLamaran!.id == lamaranId) {
          final updatedBerkas = _selectedLamaran!.berkas.map((b) {
            if (b.id == berkasId) {
              b.sudahSiap = sudahSiap;
            }
            return b;
          }).toList();

          final total = updatedBerkas.length;
          final siap = updatedBerkas.filter((b) => b.sudahSiap).length;
          final pct = total > 0 ? ((siap / total) * 100).round() : 0;

          _selectedLamaran = LamaranModel(
            id: _selectedLamaran!.id,
            userId: _selectedLamaran!.userId,
            namaPerusahaan: _selectedLamaran!.namaPerusahaan,
            posisi: _selectedLamaran!.posisi,
            tanggalLamar: _selectedLamaran!.tanggalLamar,
            tenggat: _selectedLamaran!.tenggat,
            tautanLowongan: _selectedLamaran!.tautanLowongan,
            namaKontakHrd: _selectedLamaran!.namaKontakHrd,
            emailKontakHrd: _selectedLamaran!.emailKontakHrd,
            tahap: _selectedLamaran!.tahap,
            status: _selectedLamaran!.status,
            isPrioritas: _selectedLamaran!.isPrioritas,
            catatanHasil: _selectedLamaran!.catatanHasil,
            totalBerkas: total,
            berkasSiap: siap,
            persentaseBerkas: pct,
            isOverdue: _selectedLamaran!.isOverdue,
            riwayat: _selectedLamaran!.riwayat,
            berkas: updatedBerkas,
            catatanWawancara: _selectedLamaran!.catatanWawancara,
          );
        }

        // Perbarui list juga
        await fetchLamaranList();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error toggle berkas: $e');
      return false;
    }
  }

  // Tambah catatan persiapan wawancara
  Future<bool> addCatatanWawancara(int lamaranId, {
    required String pertanyaan,
    String? jawaban,
    String? halDipelajari,
  }) async {
    try {
      final Map<String, dynamic> body = {
        'pertanyaan': pertanyaan.trim(),
      };
      if (jawaban != null && jawaban.trim().isNotEmpty) body['jawaban'] = jawaban.trim();
      if (halDipelajari != null && halDipelajari.trim().isNotEmpty) body['hal_dipelajari'] = halDipelajari.trim();

      final response = await _apiService.post(
        ApiConfig.wawancara(lamaranId),
        body: body,
      );

      if (response['success'] == true) {
        await fetchLamaranDetail(lamaranId);
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Ubah catatan persiapan wawancara
  Future<bool> updateCatatanWawancara(int lamaranId, int noteId, {
    required String pertanyaan,
    String? jawaban,
    String? halDipelajari,
  }) async {
    try {
      final Map<String, dynamic> body = {
        'pertanyaan': pertanyaan.trim(),
      };
      if (jawaban != null && jawaban.trim().isNotEmpty) body['jawaban'] = jawaban.trim();
      if (halDipelajari != null && halDipelajari.trim().isNotEmpty) body['hal_dipelajari'] = halDipelajari.trim();

      final response = await _apiService.put(
        ApiConfig.wawancaraDetail(lamaranId, noteId),
        body: body,
      );

      if (response['success'] == true) {
        await fetchLamaranDetail(lamaranId);
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Hapus catatan persiapan wawancara
  Future<bool> deleteCatatanWawancara(int lamaranId, int noteId) async {
    try {
      final response = await _apiService.delete(ApiConfig.wawancaraDetail(lamaranId, noteId));
      if (response['success'] == true) {
        await fetchLamaranDetail(lamaranId);
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Pengaturan Filter
  void setFilterTahap(String tahap) {
    if (_filterTahap != tahap) {
      _filterTahap = tahap;
      fetchLamaranList();
    }
  }

  void setFilterStatus(String status) {
    if (_filterStatus != status) {
      _filterStatus = status;
      fetchLamaranList();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    fetchLamaranList();
  }

  void clearFilters() {
    _filterTahap = 'semua';
    _filterStatus = 'semua';
    _searchQuery = '';
    fetchLamaranList();
  }
}

extension WhereExtension<T> on Iterable<T> {
  Iterable<T> filter(bool Function(T) test) => where(test);
}

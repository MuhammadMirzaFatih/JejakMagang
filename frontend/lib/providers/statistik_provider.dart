import 'package:flutter/material.dart';
import '../config/api_config.dart';
import '../models/statistik_model.dart';
import '../services/api_service.dart';

/// Provider pengelola data agregasi statistik dan grafik
class StatistikProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  StatistikModel _statistik = StatistikModel.empty();
  bool _isLoading = false;
  String? _errorMessage;

  StatistikModel get statistik => _statistik;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchStatistik() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.get(ApiConfig.statistik);
      if (response['success'] == true && response['data'] != null) {
        _statistik = StatistikModel.fromJson(response['data']);
      } else {
        _errorMessage = response['message'] ?? 'Gagal memuat statistik.';
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
}


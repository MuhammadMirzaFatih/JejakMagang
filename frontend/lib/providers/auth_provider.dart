import 'package:flutter/material.dart';
import '../config/api_config.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

/// Provider pengelola status otentikasi pengguna
class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();

  UserModel? _currentUser;
  String? _token;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  String? get token => _token;
  bool get isAuthenticated => _token != null && _token!.isNotEmpty;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Inisialisasi status autentikasi dari penyimpanan lokal
  Future<bool> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Muat alamat API kustom jika ada
      final customUrl = await _storageService.getCustomApiUrl();
      if (customUrl != null && customUrl.isNotEmpty) {
        ApiConfig.baseUrl = customUrl;
      }

      final savedToken = await _storageService.getToken();
      if (savedToken == null || savedToken.isEmpty) {
        _token = null;
        _currentUser = null;
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _token = savedToken;

      // Ambil data profil terkini dari backend
      final response = await _apiService.get(ApiConfig.me);
      if (response['success'] == true && response['user'] != null) {
        _currentUser = UserModel.fromJson(response['user']);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        await logout();
        return false;
      }
    } catch (_) {
      // Jika token kedaluwarsa atau server offline, bersihkan sesi
      _token = null;
      _currentUser = null;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Masuk (Login)
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.post(
        ApiConfig.login,
        body: {
          'email': email.trim(),
          'password': password,
        },
        requireAuth: false,
      );

      if (response['success'] == true) {
        _token = response['token'];
        _currentUser = UserModel.fromJson(response['user']);
        await _storageService.saveToken(_token!);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response['message'] ?? 'Gagal masuk ke aplikasi.';
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
      _errorMessage = 'Terjadi kesalahan tidak terduga: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Daftar Akun Baru (Register)
  Future<bool> register(String nama, String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.post(
        ApiConfig.register,
        body: {
          'nama': nama.trim(),
          'email': email.trim(),
          'password': password,
        },
        requireAuth: false,
      );

      if (response['success'] == true) {
        _token = response['token'];
        _currentUser = UserModel.fromJson(response['user']);
        await _storageService.saveToken(_token!);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response['message'] ?? 'Pendaftaran akun gagal.';
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
      _errorMessage = 'Terjadi kesalahan tidak terduga: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Keluar (Logout)
  Future<void> logout() async {
    _token = null;
    _currentUser = null;
    _errorMessage = null;
    await _storageService.clearToken();
    notifyListeners();
  }

  // Ubah alamat API kustom
  Future<void> updateApiBaseUrl(String newUrl) async {
    ApiConfig.baseUrl = newUrl;
    await _storageService.setCustomApiUrl(newUrl);
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}


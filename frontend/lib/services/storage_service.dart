import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Layanan penyimpanan lokal:
/// - flutter_secure_storage untuk token kredensial
/// - shared_preferences untuk preferensi umum (tema gelap & alamat API)
class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  final _secureStorage = const FlutterSecureStorage();
  SharedPreferences? _prefs;

  static const String _keyToken = 'auth_token';
  static const String _keyDarkMode = 'is_dark_mode';
  static const String _keyCustomApiUrl = 'custom_api_url';

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // --- TOKEN OTENTIKASI (Secure Storage) ---
  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: _keyToken, value: token);
  }

  Future<String?> getToken() async {
    try {
      return await _secureStorage.read(key: _keyToken);
    } catch (_) {
      return null;
    }
  }

  Future<void> clearToken() async {
    await _secureStorage.delete(key: _keyToken);
  }

  // --- PREFERENSI TEMA GELAP (Shared Preferences) ---
  Future<void> setDarkMode(bool isDark) async {
    await init();
    await _prefs?.setBool(_keyDarkMode, isDark);
  }

  Future<bool> getDarkMode() async {
    await init();
    return _prefs?.getBool(_keyDarkMode) ?? false;
  }

  // --- ALAMAT API DINAMIS (Shared Preferences) ---
  Future<void> setCustomApiUrl(String url) async {
    await init();
    await _prefs?.setString(_keyCustomApiUrl, url);
  }

  Future<String?> getCustomApiUrl() async {
    await init();
    return _prefs?.getString(_keyCustomApiUrl);
  }
}


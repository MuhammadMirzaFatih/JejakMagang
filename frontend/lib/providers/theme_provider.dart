import 'package:flutter/material.dart';
import '../services/storage_service.dart';

/// Provider pengelola mode gelap / terang
class ThemeProvider with ChangeNotifier {
  final StorageService _storageService = StorageService();
  bool _isDarkMode = false;
  bool _isLoaded = false;

  bool get isDarkMode => _isDarkMode;
  bool get isLoaded => _isLoaded;
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  ThemeProvider() {
    loadThemePreference();
  }

  Future<void> loadThemePreference() async {
    _isDarkMode = await _storageService.getDarkMode();
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    await _storageService.setDarkMode(_isDarkMode);
  }

  Future<void> setDarkMode(bool value) async {
    if (_isDarkMode == value) return;
    _isDarkMode = value;
    notifyListeners();
    await _storageService.setDarkMode(value);
  }
}


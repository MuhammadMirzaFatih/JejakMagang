import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'storage_service.dart';

/// Pengecualian khusus untuk pesan galat API
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

/// Layanan HTTP terpadu untuk memanggil endpoint API
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final StorageService _storageService = StorageService();
  final Duration _timeout = const Duration(seconds: 15);

  Future<Map<String, String>> _getHeaders({bool requireAuth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requireAuth) {
      final token = await _storageService.getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  dynamic _processResponse(http.Response response) {
    dynamic body;
    try {
      body = jsonDecode(response.body);
    } catch (_) {
      body = {'message': response.body};
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    } else {
      String errorMessage = 'Terjadi kesalahan pada server (${response.statusCode})';
      if (body is Map && body['message'] != null) {
        errorMessage = body['message'].toString();
      }
      throw ApiException(errorMessage, response.statusCode);
    }
  }

  Future<dynamic> get(String url, {bool requireAuth = true}) async {
    try {
      final headers = await _getHeaders(requireAuth: requireAuth);
      final response = await http
          .get(Uri.parse(url), headers: headers)
          .timeout(_timeout);
      return _processResponse(response);
    } on SocketException {
      throw ApiException('Tidak dapat terhubung ke server. Periksa koneksi internet atau alamat API Anda.');
    } on TimeoutException {
      throw ApiException('Koneksi ke server terputus karena batas waktu habis (timeout).');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Terjadi kegagalan komunikasi dengan server: ${e.toString()}');
    }
  }

  Future<dynamic> post(String url, {Map<String, dynamic>? body, bool requireAuth = true}) async {
    try {
      final headers = await _getHeaders(requireAuth: requireAuth);
      final response = await http
          .post(
            Uri.parse(url),
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(_timeout);
      return _processResponse(response);
    } on SocketException {
      throw ApiException('Tidak dapat terhubung ke server. Periksa koneksi internet atau alamat API Anda.');
    } on TimeoutException {
      throw ApiException('Koneksi ke server terputus karena batas waktu habis (timeout).');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Terjadi kegagalan komunikasi dengan server: ${e.toString()}');
    }
  }

  Future<dynamic> put(String url, {Map<String, dynamic>? body, bool requireAuth = true}) async {
    try {
      final headers = await _getHeaders(requireAuth: requireAuth);
      final response = await http
          .put(
            Uri.parse(url),
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(_timeout);
      return _processResponse(response);
    } on SocketException {
      throw ApiException('Tidak dapat terhubung ke server. Periksa koneksi internet atau alamat API Anda.');
    } on TimeoutException {
      throw ApiException('Koneksi ke server terputus karena batas waktu habis (timeout).');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Terjadi kegagalan komunikasi dengan server: ${e.toString()}');
    }
  }

  Future<dynamic> patch(String url, {Map<String, dynamic>? body, bool requireAuth = true}) async {
    try {
      final headers = await _getHeaders(requireAuth: requireAuth);
      final response = await http
          .patch(
            Uri.parse(url),
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(_timeout);
      return _processResponse(response);
    } on SocketException {
      throw ApiException('Tidak dapat terhubung ke server. Periksa koneksi internet atau alamat API Anda.');
    } on TimeoutException {
      throw ApiException('Koneksi ke server terputus karena batas waktu habis (timeout).');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Terjadi kegagalan komunikasi dengan server: ${e.toString()}');
    }
  }

  Future<dynamic> delete(String url, {bool requireAuth = true}) async {
    try {
      final headers = await _getHeaders(requireAuth: requireAuth);
      final response = await http
          .delete(Uri.parse(url), headers: headers)
          .timeout(_timeout);
      return _processResponse(response);
    } on SocketException {
      throw ApiException('Tidak dapat terhubung ke server. Periksa koneksi internet atau alamat API Anda.');
    } on TimeoutException {
      throw ApiException('Koneksi ke server terputus karena batas waktu habis (timeout).');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Terjadi kegagalan komunikasi dengan server: ${e.toString()}');
    }
  }
}


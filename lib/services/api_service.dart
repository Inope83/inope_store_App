import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static String get baseUrl {
    const envUrl = String.fromEnvironment('API_URL');
    if (envUrl.isNotEmpty) return envUrl;

    if (kIsWeb) {
      return 'http://127.0.0.1:8000/api';
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      // 10.0.2.2 is for emulator; use your computer's LAN IP for physical phone.
      return 'http://192.168.68.118:8000/api';
    }

    // For iOS simulator, macOS, Linux, Windows
    return 'http://127.0.0.1:8000/api';
  }

  static final ApiService _instance = ApiService._();
  factory ApiService() => _instance;
  ApiService._();

  final _storage = const FlutterSecureStorage();
  String? _accessToken;
  String? _refreshToken;

  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;

  Future<void> init() async {
    try {
      _accessToken = await _storage.read(key: 'access_token');
      _refreshToken = await _storage.read(key: 'refresh_token');
    } catch (e) {
      // Stale/corrupted encrypted storage (e.g. after reinstall with a
      // different keystore key) causes decryption to fail. Wipe and continue.
      debugPrint('Secure storage read failed, clearing: $e');
      try {
        await _storage.deleteAll();
      } catch (_) {}
      _accessToken = null;
      _refreshToken = null;
    }
  }

  Map<String, String> get _headers {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
    };
  }

  Future<void> _saveTokens(String access, String refresh) async {
    _accessToken = access;
    _refreshToken = refresh;
    await _storage.write(key: 'access_token', value: access);
    await _storage.write(key: 'refresh_token', value: refresh);
  }

  Future<void> clearTokens() async {
    _accessToken = null;
    _refreshToken = null;
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
  }

  Future<bool> _tryRefresh() async {
    if (_refreshToken == null) return false;
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/auth/token/refresh/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh': _refreshToken}),
      );
      if (res.statusCode == 200 && res.body.isNotEmpty) {
        final data = jsonDecode(res.body);
        await _saveTokens(data['access'], data['refresh'] ?? _refreshToken!);
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<http.Response> get(
    String path, {
    Map<String, String>? queryParams,
  }) async {
    final uri = Uri.parse(
      '$baseUrl$path',
    ).replace(queryParameters: queryParams);
    var res = await http.get(uri, headers: _headers);
    if (res.statusCode == 401 && await _tryRefresh()) {
      res = await http.get(uri, headers: _headers);
    }
    return res;
  }

  Future<http.Response> post(String path, {Map<String, dynamic>? body}) async {
    final uri = Uri.parse('$baseUrl$path');
    var res = await http.post(
      uri,
      headers: _headers,
      body: body != null ? jsonEncode(body) : null,
    );
    if (res.statusCode == 401 && await _tryRefresh()) {
      res = await http.post(
        uri,
        headers: _headers,
        body: body != null ? jsonEncode(body) : null,
      );
    }
    return res;
  }

  Future<http.Response> put(String path, {Map<String, dynamic>? body}) async {
    final uri = Uri.parse('$baseUrl$path');
    var res = await http.put(
      uri,
      headers: _headers,
      body: body != null ? jsonEncode(body) : null,
    );
    if (res.statusCode == 401 && await _tryRefresh()) {
      res = await http.put(
        uri,
        headers: _headers,
        body: body != null ? jsonEncode(body) : null,
      );
    }
    return res;
  }

  Future<http.Response> delete(String path) async {
    final uri = Uri.parse('$baseUrl$path');
    var res = await http.delete(uri, headers: _headers);
    if (res.statusCode == 401 && await _tryRefresh()) {
      res = await http.delete(uri, headers: _headers);
    }
    return res;
  }

  Future<http.Response> uploadFiles(
    String path,
    List<http.MultipartFile> files, {
    Map<String, String>? fields,
    String method = 'POST',
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    var req = http.MultipartRequest(method, uri);
    if (_accessToken != null) {
      req.headers['Authorization'] = 'Bearer $_accessToken';
    }
    req.files.addAll(files);
    if (fields != null) req.fields.addAll(fields);
    var streamed = await req.send();
    var res = await http.Response.fromStream(streamed);
    if (res.statusCode == 401 && await _tryRefresh()) {
      req = http.MultipartRequest(method, uri);
      if (_accessToken != null) {
        req.headers['Authorization'] = 'Bearer $_accessToken';
      }
      req.files.addAll(files);
      if (fields != null) req.fields.addAll(fields);
      streamed = await req.send();
      res = await http.Response.fromStream(streamed);
    }
    return res;
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/auth/login/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (res.body.isEmpty) {
        return {
          'error': 'Server returned empty response (Status ${res.statusCode})'
        };
      }

      final data = jsonDecode(res.body);
      if (data is! Map<String, dynamic>) {
        return {'error': 'Invalid response format from server'};
      }

      if (res.statusCode == 200) {
        await _saveTokens(data['access'], data['refresh']);
      }
      return data;
    } catch (e) {
      return {'error': 'Connection error: $e'};
    }
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> body) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/auth/register/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (res.body.isEmpty) {
        return {
          'error': 'Server returned empty response (Status ${res.statusCode})'
        };
      }

      final data = jsonDecode(res.body);
      if (data is! Map<String, dynamic>) {
        return {'error': 'Invalid response format from server'};
      }

      if (res.statusCode == 201) {
        await _saveTokens(data['access'], data['refresh']);
      }
      return data;
    } catch (e) {
      return {'error': 'Connection error: $e'};
    }
  }
}

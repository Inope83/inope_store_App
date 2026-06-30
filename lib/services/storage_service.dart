import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static final StorageService _instance = StorageService._();
  factory StorageService() => _instance;
  StorageService._();

  final FlutterSecureStorage? _secureStorage =
      kIsWeb ? null : const FlutterSecureStorage();

  Future<String?> read(String key) async {
    if (_secureStorage != null) {
      try {
        return await _secureStorage!.read(key: key);
      } catch (e) {
        debugPrint('Secure storage read failed, trying shared prefs: $e');
      }
    }
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  Future<void> write(String key, String value) async {
    if (_secureStorage != null) {
      try {
        await _secureStorage!.write(key: key, value: value);
        return;
      } catch (e) {
        debugPrint('Secure storage write failed, using shared prefs: $e');
      }
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  Future<void> delete(String key) async {
    if (_secureStorage != null) {
      try {
        await _secureStorage!.delete(key: key);
        return;
      } catch (e) {
        debugPrint('Secure storage delete failed, using shared prefs: $e');
      }
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  Future<void> deleteAll() async {
    if (_secureStorage != null) {
      try {
        await _secureStorage!.deleteAll();
        return;
      } catch (e) {
        debugPrint('Secure storage deleteAll failed, using shared prefs: $e');
      }
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}

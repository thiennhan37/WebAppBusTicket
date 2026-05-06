import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  final _secureStorage = const FlutterSecureStorage();
  SharedPreferences? _prefs;

  // Khởi tạo (Gọi ở main.dart)
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ==========================================
  // 1. SECURE STORAGE (Dùng cho dữ liệu nhạy cảm)
  // ==========================================
  Future<void> writeSecure(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
  }

  Future<String?> readSecure(String key) async {
    return await _secureStorage.read(key: key);
  }

  Future<void> deleteSecure(String key) async {
    await _secureStorage.delete(key: key);
  }

  // ==========================================
  // 2. SHARED PREFERENCES (Dùng cho dữ liệu thường)
  // ==========================================
  Future<void> writeString(String key, String value) async {
    await _prefs?.setString(key, value);
  }

  String? readString(String key) {
    return _prefs?.getString(key);
  }

  Future<void> delete(String key) async {
    await _prefs?.remove(key);
  }
}
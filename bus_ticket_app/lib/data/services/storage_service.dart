import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StorageService {
  final _secureStorage = const FlutterSecureStorage();
  SharedPreferences? _prefs;

  // Khởi tạo SharedPreferences (gọi hàm này ở main.dart trước khi chạy app)
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // --- 1. XỬ LÝ TOKEN (BẢO MẬT CAO) ---
  Future<void> saveTokens(String accessToken, String refreshToken) async {
    await _secureStorage.write(key: 'access_token', value: accessToken);
    await _secureStorage.write(key: 'refresh_token', value: refreshToken);
  }

  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: 'access_token');
  }

  Future<void> clearTokens() async {
    await _secureStorage.delete(key: 'access_token');
    await _secureStorage.delete(key: 'refresh_token');
  }

  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: 'refresh_token');
  }

  // --- 2. XỬ LÝ THÔNG TIN USER (TỐC ĐỘ CAO) ---
  // Ví dụ lưu trữ dạng chuỗi JSON
  Future<void> saveUserInfo(Map<String, dynamic> userInfo) async {
    final jsonString = jsonEncode(userInfo);
    await _prefs?.setString('user_info', jsonString);
  }

  Map<String, dynamic>? getUserInfo() {
    final jsonString = _prefs?.getString('user_info');
    if (jsonString != null) {
      return jsonDecode(jsonString);
    }
    return null;
  }

  Future<void> clearUserInfo() async {
    await _prefs?.remove('user_info');
  }

  Future<void> clearAll() async {
    await clearTokens();
    await clearUserInfo();
  }
}

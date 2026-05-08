import 'dart:convert';

import '../../../core/storage/storage_service.dart';


class AuthStorage {
  final StorageService _storage;

  AuthStorage(this._storage);

  // --- TOKENS ---
  Future<void> saveTokens(String accessToken, String refreshToken) async {
    await _storage.writeSecure('access_token', accessToken);
    await _storage.writeSecure('refresh_token', refreshToken);
  }

  Future<String?> getAccessToken() async => await _storage.readSecure('access_token');
  Future<String?> getRefreshToken() async => await _storage.readSecure('refresh_token');

  Future<void> clearTokens() async {
    await _storage.deleteSecure('access_token');
    await _storage.deleteSecure('refresh_token');
  }

  // --- USER INFO ---
  Future<void> saveUserInfo(Map<String, dynamic> userInfo) async {
    await _storage.writeString('user_info', jsonEncode(userInfo));
  }

  Map<String, dynamic>? getUserInfo() {
    final data = _storage.readString('user_info');
    return data != null ? jsonDecode(data) : null;
  }

  Future<void> clearUserInfo() async => await _storage.delete('user_info');

  // --- CLEAR ALL (Dùng cho Logout) ---
  Future<void> clearAll() async {
    await clearTokens();
    await clearUserInfo();
  }
}
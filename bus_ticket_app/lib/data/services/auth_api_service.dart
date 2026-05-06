// lib/data/services/auth_api_service.dart
import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/constants/api_constants.dart';

class AuthApiService {
  final ApiClient _apiClient;

  AuthApiService(this._apiClient);

  Future<Response> sendOtp(Map<String, dynamic> data) async {
    return await _apiClient.post(
      ApiConstants.sendOtp,
      data: data,
      options: Options(extra: {'requiresToken': false}),
    );
  }

  Future<Response> verifyOtp(Map<String, dynamic> data) async {
    return await _apiClient.post(
      ApiConstants.verifyOtp,
      data: data,
      options: Options(extra: {'requiresToken': false}),
    );
  }

  Future<Response> logout(Map<String, dynamic> data) async {
    return await _apiClient.post(
      ApiConstants.logOut,
      data: data,
      // Logout thường cần truyền kèm Token để xác thực huỷ phiên
      options: Options(extra: {'requiresToken': true}),
    );
  }

  Future<Response> sendRegistrationOtp(Map<String, dynamic> data) async {
    return await _apiClient.post(
      ApiConstants.sendOtpRegister,
      data: data,
      options: Options(extra: {'requiresToken': false}),
    );
  }

  Future<Response> verifyRegistrationOtp(Map<String, dynamic> data) async {
    return await _apiClient.post(
      ApiConstants.verifyOtpRegister,
      data: data,
      options: Options(extra: {'requiresToken': false}),
    );
  }
}
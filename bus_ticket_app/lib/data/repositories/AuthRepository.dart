import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../models/customer_register_request_model.dart';
import '../services/auth_api_service.dart'; // Thay ApiService bằng AuthApiService
import '../models/otp_request_model.dart';
import '../models/otp_response_model.dart';
import '../models/otp_verify_model.dart';
import '../models/auth_response_model.dart';

class AuthRepository {
  final AuthApiService _authApiService;

  AuthRepository(this._authApiService);

  // Send OTP (Login)
  Future<OtpResponseModel> sendOtp(String email) async {
    try {
      final request = OtpRequestModel(email: email);
      final response = await _authApiService.sendOtp(request.toJson());

      return OtpResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        return OtpResponseModel.fromJson(e.response!.data);
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      rethrow;
    }
  }

  // Verify OTP (Login)
  Future<AuthResponseModel> verifyOtp(String email, String otp) async {
    try {
      final request = OtpVerifyModel(email: email, otp: otp);
      final response = await _authApiService.verifyOtp(request.toJson());

      return AuthResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        return AuthResponseModel.fromJson(e.response!.data);
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      rethrow;
    }
  }

  // Logout
  Future<void> logout({required String accessToken, required String refreshToken}) async {
    try {
      await _authApiService.logout({
        "accessToken": accessToken,
        "refreshToken": refreshToken,
      });
    } catch (e) {
      print('Lỗi gọi API Logout từ Server: $e');
      rethrow;
    }
  }

  // Send OTP (Register)
  Future<OtpResponseModel> sendRegistrationOtp(CustomerRegisterRequestModel request) async {
    try {
      final response = await _authApiService.sendRegistrationOtp(request.toJson());

      return OtpResponseModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response != null) {
        return OtpResponseModel.fromJson(e.response!.data);
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      print('Lỗi gọi API sendRegistrationOtp: $e');
      rethrow;
    }
  }

  // Verify OTP (Register)
  Future<AuthResponseModel> verifyRegistrationOtp(String email, String otp) async {
    try {
      final response = await _authApiService.verifyRegistrationOtp({
        "email": email,
        "otp": otp,
      });

      return AuthResponseModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response != null) {
        return AuthResponseModel.fromJson(e.response!.data);
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      print('Lỗi gọi API verifyRegistrationOtp: $e');
      rethrow;
    }
  }
}
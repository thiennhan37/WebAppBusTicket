import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../models/otp_request_model.dart';
import '../models/otp_response_model.dart';
import '../models/otp_verify_model.dart';
import '../models/auth_response_model.dart';

class ApiService {
  final Dio _dio;

  ApiService()
      : _dio = Dio(BaseOptions(
          baseUrl: ApiConstants.baseUrl,
          headers: ApiConstants.headers,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        )) {
    // Add logging interceptor
    _dio.interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
      error: true,
    ));
  }

  // Send OTP
  Future<OtpResponseModel> sendOtp(OtpRequestModel request) async {
    try {
      final response = await _dio.post(
        ApiConstants.sendOtp,
        data: request.toJson(),
      );
      return OtpResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        // API returned error response
        return OtpResponseModel.fromJson(e.response!.data);
      } else {
        // Network error
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // Verify OTP
  Future<AuthResponseModel> verifyOtp(OtpVerifyModel request) async {
    try {
      final response = await _dio.post(
        ApiConstants.verifyOtp,
        data: request.toJson(),
      );
      return AuthResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        // API returned error response
        return AuthResponseModel.fromJson(e.response!.data);
      } else {
        // Network error
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}

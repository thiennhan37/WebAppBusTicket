import '../../core/constants/api_constants.dart';
import '../services/api_service.dart';
import '../models/otp_request_model.dart';
import '../models/otp_response_model.dart';
import '../models/otp_verify_model.dart';
import '../models/auth_response_model.dart';

class AuthRepository {
  final ApiService _apiService;

  AuthRepository(this._apiService);

  // Send OTP
  Future<OtpResponseModel> sendOtp(String email) async {
    final request = OtpRequestModel(email: email);
    return await _apiService.sendOtp(request);
  }

  // Verify OTP
  Future<AuthResponseModel> verifyOtp(String email, String otp) async {
    final request = OtpVerifyModel(email: email, otp: otp);
    return await _apiService.verifyOtp(request);
  }

  Future<void> logout(
      {required String accessToken, required String refreshToken}) async {
    try {
      // Gửi POST request với body là JSON map chứa 2 key khớp với class LogoutRequest của Java
      await _apiService.post(
        ApiConstants.logOut,
        data: {
          "accessToken": accessToken,
          "refreshToken": refreshToken,
        },
      );
    } catch (e) {
      print('Lỗi gọi API Logout từ Server: $e');
    }
  }
}

class ApiConstants {
  // Base URL
  static const String baseUrl = 'http://172.28.96.1:8080/vexedat';

  // Auth endpoints
  static const String sendOtp = '$baseUrl/auth/send-otp';
  static const String verifyOtp = '$baseUrl/auth/verify-otp';
  static const String logOut = '$baseUrl/auth/log-out';
  static const String sendOtpRegister = '$baseUrl/register/init';
  static const String verifyOtpRegister = '$baseUrl/register/verify';

  // HTTP Headers
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Timeouts
  static const int connectionTimeout = 10; // seconds
  static const int receiveTimeout = 10; // seconds
}

class ApiConstants {
  // Base URL
  static const String baseUrl = 'http://172.28.96.1:8080/vexedat';

  // Auth endpoints
  static const String sendOtp = '$baseUrl/auth/send-otp';
  static const String verifyOtp = '$baseUrl/auth/verify-otp';
  static const String logOut = '$baseUrl/auth/log-out';
  static const String sendOtpRegister = '$baseUrl/register/init';
  static const String verifyOtpRegister = '$baseUrl/register/verify';
  static const String refreshToken = '$baseUrl/auth/refresh-token';
  static const String getProvinces = '$baseUrl/provinces';
  static const String getStop = '$baseUrl/stops';
  static const String searchTrip = '$baseUrl/trips/search';
  static const String busDiagram = '$baseUrl/trips/bus-diagram';

  // HTTP Headers
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Timeouts
  static const int connectionTimeout = 10; // seconds
  static const int receiveTimeout = 10; // seconds
}

class ApiConstants {
  // Base URL
  static const String baseUrl = 'http://localhost:8080/vexedat';

  static const String sendOtp = '$baseUrl/auth/send-otp';
  static const String verifyOtp = '$baseUrl/auth/verify-otp';
  static const String logOut = '$baseUrl/auth/log-out';
  static const String sendOtpRegister = '$baseUrl/register/init';
  static const String verifyOtpRegister = '$baseUrl/register/verify';
  static const String refreshToken = '$baseUrl/auth/refresh-token';
  static const String getProvinces = '$baseUrl/provinces';
  static const String getStop = '$baseUrl/trips/stops';
  static const String searchTrip = '$baseUrl/trips/search';
  static const String busDiagram = '$baseUrl/trips/bus-diagram';
  static const String holdSeats = '$baseUrl/customer/orders/hold-seats/';
  static const String momoPayment = '$baseUrl/customer/orders/payment/';
  static const String checkPaymentStatus = '$baseUrl/customer/orders/payment-status';
  static const String getRecentOrders = '$baseUrl/customer/orders/recent';
  static const String updateProfile = '$baseUrl/customer/profile';
  static const String orderDetail = '$baseUrl/customer/order/detail/';
  static const String unholdSeats = '$baseUrl/customer/orders/unhold-seats/';

  // HTTP Headers
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Timeouts
  static const int connectionTimeout = 10; // seconds
  static const int receiveTimeout = 10; // seconds
}

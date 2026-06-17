class ApiConstants {
  // Base URL
  static const String baseUrl = 'http://47.129.116.239:8080/vexedat';
  static const String notificationSocketUrl = '$baseUrl/ws/notifications';

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
  static const String vnpayPayment = '$baseUrl/vnpay/payment-url/';
  static const String checkPaymentStatus = '$baseUrl/customer/orders/payment-status';
  static const String getRecentOrders = '$baseUrl/customer/orders/recent';
  static const String updateProfile = '$baseUrl/customer/profile';
  static const String orderDetail = '$baseUrl/customer/order/detail/';
  static const String unholdSeats = '$baseUrl/customer/orders/unhold-seats/';
  static const String rateOrder = '$baseUrl/customer/orders/';
  static const String getCompaniesInfo = '$baseUrl/trips/get-companies-info';
  static String getPickupStops(String provinceId) => '$baseUrl/provinces/$provinceId/pickup-stops';
  static String getDropoffStops(String provinceId) => '$baseUrl/provinces/$provinceId/dropoff-stops';
  static const String googleMobileLogin = '$baseUrl/auth/google/mobile';
  static const String googleMobileRegister = '$baseUrl/auth/google/mobile/register';
  static const String deviceTokens = '$baseUrl/api/device-tokens';
  static const String chatConversations = '$baseUrl/api/chat/conversations';
  static const String chatMessages = '$baseUrl/api/chat/messages';
  static const String chatSocketUrl = '$baseUrl/ws';
  static const String companiesForChat = '$baseUrl/customer/companies-list';
  // HTTP Headers
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Timeouts
  static const int connectionTimeout = 10; // seconds
  static const int receiveTimeout = 10; // seconds
}

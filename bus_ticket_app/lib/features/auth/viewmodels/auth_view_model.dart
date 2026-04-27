import 'package:bus_ticket_app/data/models/customer_register_request_model.dart';
import 'package:bus_ticket_app/data/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:bus_ticket_app/data/repositories/AuthRepository.dart';
import 'package:get_it/get_it.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  AuthViewModel(this._authRepository);

  // --- State Variables (Trạng thái giao diện) ---
  bool _isLoading = false;
  String? _errorMessage;

  // --- Getters cho View ---
  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  // Hàm xóa lỗi (Dùng khi user bắt đầu gõ lại text)
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // --- 1. Xử lý Gửi OTP ---
  // Trả về bool để View biết có thành công hay không (chuyển qua trang nhập OTP)
  Future<bool> sendOtp(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authRepository.sendOtp(email);

      if (response.isSuccess) {
        // code == 0
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        // Dùng message từ API (VD: "Không tìm thấy gmail này trong hệ thống" - Code 4021)
        _errorMessage = response.message ?? 'Lỗi không xác định khi gửi OTP';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Lỗi kết nối: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // --- 2. Xử lý Xác thực OTP ---
  Future<bool> verifyOtp(String otp, String email) async {
    if (email.isEmpty) {
      _errorMessage = 'Lỗi hệ thống: Không tìm thấy email cần xác thực.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authRepository.verifyOtp(email, otp);

      if (response.isSuccess && response.result != null) {
        // code == 0

        // 1. Lấy Token từ Result
        final accessToken = response.accessToken;
        final refreshToken = response.refreshToken;
        final userInfo = response.customerInfo;
        // 2. LƯU TOKEN VÀO BỘ NHỚ BẢO MẬT (Keychain/Keystore)
        final storage = GetIt.I<StorageService>();
        await storage.saveTokens(accessToken!, refreshToken!);
        if (userInfo != null) await storage.saveUserInfo(userInfo.toJson());
        _isLoading = false;
        notifyListeners();
        return true; // Báo cho View biết Đăng nhập thành công
      } else {
        // Xử lý lỗi sai OTP (Code 4022 - "Sai OTP hoặc OTP đã hết hạn")
        _errorMessage = response.message ?? 'Mã OTP không hợp lệ';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Lỗi kết nối: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    final storage = GetIt.I<StorageService>();

    try {
      // 1. LẤY TOKEN TRƯỚC (Bắt buộc phải lấy trước khi gọi clearAll)
      final String? accessToken = await storage.getAccessToken();
      final String? refreshToken = await storage.getRefreshToken();

      // 2. GỌI API LOGOUT (Chỉ gọi khi có đủ 2 token)
      if (accessToken != null && refreshToken != null) {
        await _authRepository.logout(
          accessToken: accessToken,
          refreshToken: refreshToken,
        );
      }
    } catch (e) {
      print('Lỗi quá trình đăng xuất: $e');
    } finally {
      await storage.clearAll();
    }
  }
  
  Future<bool> sendRegistrationOtp(
      CustomerRegisterRequestModel registerData) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Gọi qua Repository
      final response = await _authRepository.sendRegistrationOtp(registerData);

      if (response.isSuccess) {
        // Trả về code == 0 hoặc 200 OK
        _isLoading = false;
        notifyListeners();
        return true; // Báo cho View chuyển sang màn hình nhập OTP
      } else {
        // Lỗi từ backend (VD: 4002 - Email đã sử dụng, 4025 - Số điện thoại đã sử dụng)
        _errorMessage =
            response.message ?? 'Đã xảy ra lỗi khi đăng ký. Vui lòng thử lại.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Lỗi kết nối mạng: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> verifyRegistrationOtp(String email, String otp) async {
    if (email.isEmpty) {
      _errorMessage = 'Lỗi hệ thống: Không tìm thấy email cần xác thực.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authRepository.verifyRegistrationOtp(email, otp);

      if (response.isSuccess && response.result != null) {
        // code == 0

        // 1. Lấy Token & Thông tin User từ Result (Giống hệt luồng Login)
        final accessToken = response.accessToken;
        final refreshToken = response.refreshToken;
        final userInfo = response.customerInfo;

        // 2. LƯU TOKEN VÀO BỘ NHỚ
        final storage = GetIt.I<StorageService>();
        await storage.saveTokens(accessToken!, refreshToken!);
        if (userInfo != null) {
          await storage.saveUserInfo(userInfo.toJson());
        }

        _isLoading = false;
        notifyListeners();
        return true; // Báo cho View biết tạo tài khoản & đăng nhập thành công -> Chuyển vào màn Home
      } else {
        // Lỗi sai OTP hoặc Phiên đăng ký hết hạn (Code 4022, 4026)
        _errorMessage =
            response.message ?? 'Mã OTP không hợp lệ hoặc đã hết hạn.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Lỗi kết nối: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}

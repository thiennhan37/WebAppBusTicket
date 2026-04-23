import 'package:flutter/material.dart';
import 'package:bus_ticket_app/data/repositories/AuthRepository.dart';

// Import Secure Storage của bạn vào đây (như đã bàn ở câu hỏi trước)
// import '../services/secure_storage_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  AuthViewModel(this._authRepository);

  // --- State Variables (Trạng thái giao diện) ---
  bool _isLoading = false;
  String? _errorMessage;
  String _savedEmail = ''; // Lưu lại email sau khi gửi OTP thành công

  // --- Getters cho View ---
  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  String get savedEmail => _savedEmail;

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
        _savedEmail = email; // Cất email lại dùng cho bước sau
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
  Future<bool> verifyOtp(String otp) async {
    if (_savedEmail.isEmpty) {
      _errorMessage = 'Lỗi hệ thống: Không tìm thấy email cần xác thực.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authRepository.verifyOtp(_savedEmail, otp);

      if (response.isSuccess && response.result != null) {
        // code == 0

        // 1. Lấy Token từ Result
        final accessToken = response.accessToken;
        final refreshToken = response.refreshToken;

        // 2. LƯU TOKEN VÀO BỘ NHỚ BẢO MẬT (Keychain/Keystore)
        // Ví dụ: await SecureStorageService.saveTokens(accessToken!, refreshToken!);

        // 3. Lấy thông tin user nếu cần (lưu vào local database hoặc state manager khác)
        // final userInfo = response.customerInfo;

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
}

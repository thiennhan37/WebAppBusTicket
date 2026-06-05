import 'package:bus_ticket_app/core/network/api_client.dart';
import 'package:bus_ticket_app/data/models/customer_info_model.dart';
import 'package:bus_ticket_app/data/models/customer_register_request_model.dart';
import 'package:bus_ticket_app/data/services/local/auth_storage.dart';
import 'package:bus_ticket_app/features/notification/viewmodels/notification_view_model.dart';
import 'package:flutter/material.dart';
import 'package:bus_ticket_app/data/repositories/AuthRepository.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/constants/google_auth_constants.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  final ApiClient _apiClient;

  AuthViewModel(this._authRepository, this._apiClient);

  bool _isLoading = false;
  String? _errorMessage;
  bool _isTemporarilyBlocked = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isTemporarilyBlocked => _isTemporarilyBlocked;


  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearTemporaryBlock() {
    _isTemporarilyBlocked = false;
    notifyListeners();
  }

  Future<bool> sendOtp(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authRepository.sendOtp(email);
      if (response.isSuccess) {
        _isLoading = false;
        _isTemporarilyBlocked = false;
        notifyListeners();
        return true;
      } else {
        _isTemporarilyBlocked = response.isTooManyFailedAttempts;
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
        _isTemporarilyBlocked = false;
        final storage = GetIt.I<AuthStorage>();
        await storage.saveTokens(response.accessToken!, response.refreshToken!);
        if (response.customerInfo != null) await storage.saveUserInfo(response.customerInfo!.toJson());
        await GetIt.I<NotificationViewModel>().initializeForCurrentCustomer();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isTemporarilyBlocked = response.isTooManyFailedAttempts;
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

  Future<bool> loginWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
        serverClientId: GoogleAuthConstants.hasServerClientId ? GoogleAuthConstants.serverClientId : null,
      );
      await googleSignIn.signOut();
      final account = await googleSignIn.signIn();
      if (account == null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final auth = await account.authentication;
      final idToken = auth.idToken;
      if (idToken == null || idToken.isEmpty) {
        _errorMessage = 'Không lấy được Google ID token.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final response = await _authRepository.googleMobileLogin(idToken);
      if (response.isSuccess && response.result != null) {
        _isTemporarilyBlocked = false;
        final storage = GetIt.I<AuthStorage>();
        await storage.saveTokens(response.accessToken!, response.refreshToken!);
        if (response.customerInfo != null) {
          await storage.saveUserInfo(response.customerInfo!.toJson());
        }
        await GetIt.I<NotificationViewModel>().initializeForCurrentCustomer();
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _errorMessage = response.message ?? 'Đăng nhập Google thất bại';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Lỗi đăng nhập Google: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Bước 1 của Đăng ký Google: Chỉ lấy info
  Future<Map<String, String>?> signInWithGoogleForRegister() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
        serverClientId: GoogleAuthConstants.hasServerClientId ? GoogleAuthConstants.serverClientId : null,
      );
      await googleSignIn.signOut();
      final account = await googleSignIn.signIn();
      if (account == null) {
        _isLoading = false;
        notifyListeners();
        return null;
      }

      final auth = await account.authentication;
      final idToken = auth.idToken;
      if (idToken == null || idToken.isEmpty) {
        _errorMessage = 'Không lấy được Google ID token.';
        _isLoading = false;
        notifyListeners();
        return null;
      }

      _isLoading = false;
      notifyListeners();
      return {
        'idToken': idToken,
        'email': account.email,
        'fullName': account.displayName ?? '',
      };
    } catch (e) {
      _errorMessage = 'Lỗi Google Auth: $e';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // Bước 2: Thực hiện đăng ký thực sự
  Future<bool> completeGoogleRegister(String idToken, CustomerInfoModel customerInfo) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authRepository.googleMobileRegister(idToken, customerInfo);
      if (response.isSuccess && response.result != null) {
        final storage = GetIt.I<AuthStorage>();
        await storage.saveTokens(response.accessToken!, response.refreshToken!);
        if (response.customerInfo != null) {
          await storage.saveUserInfo(response.customerInfo!.toJson());
        }
        await GetIt.I<NotificationViewModel>().initializeForCurrentCustomer();
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _errorMessage = response.message ?? 'Đăng ký Google thất bại';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Lỗi đăng ký Google: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    final storage = GetIt.I<AuthStorage>();
    try {
      final String? accessToken = await storage.getAccessToken();
      final String? refreshToken = await storage.getRefreshToken();
      if (accessToken != null && refreshToken != null) {
        await _authRepository.logout(accessToken: accessToken, refreshToken: refreshToken);
      }
    } catch (e) {
      print('Lỗi quá trình đăng xuất: $e');
    } finally {
      GetIt.I<NotificationViewModel>().disconnect();
      await storage.clearAll();
    }
  }

  Future<bool> sendRegistrationOtp(CustomerRegisterRequestModel registerData) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final response = await _authRepository.sendRegistrationOtp(registerData);
      if (response.isSuccess) {
        _isTemporarilyBlocked = false;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isTemporarilyBlocked = response.isTooManyFailedAttempts;
        _errorMessage = response.message ?? 'Đã xảy ra lỗi khi đăng ký.';
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
        _isTemporarilyBlocked = false;
        final storage = GetIt.I<AuthStorage>();
        await storage.saveTokens(response.accessToken!, response.refreshToken!);
        if (response.customerInfo != null) await storage.saveUserInfo(response.customerInfo!.toJson());
        await GetIt.I<NotificationViewModel>().initializeForCurrentCustomer();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isTemporarilyBlocked = response.isTooManyFailedAttempts;
        _errorMessage = response.message ?? 'Mã OTP không hợp lệ hoặc đã hết hạn.';
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

  Future<bool> tryAutoLogin() async {
    try {
      final refreshToken = await GetIt.I<AuthStorage>().getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) return false;
      final success = await _apiClient.refreshToken();
      if (success) {
        await GetIt.I<NotificationViewModel>().initializeForCurrentCustomer();
      }
      return success;
    } catch (e) {
      return false;
    }
  }
}

// lib/features/profile/viewmodels/profile_viewmodel.dart
import 'package:flutter/material.dart';
import '../../../data/models/update_customer_profile_request_model.dart';
import '../../../data/repositories/customer_repository.dart';

class ProfileViewModel extends ChangeNotifier {
  final CustomerRepository _repository;

  ProfileViewModel(this._repository);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<bool> saveProfile(UpdateCustomerProfileRequestModel data) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.updateProfile(data);
      _isLoading = false;
      notifyListeners();
      return true; // Lưu thành công
    } catch (e) {
      _isLoading = false;
      // Cắt bỏ chữ "Exception: " nếu có
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false; // Lưu thất bại
    }
  }
}
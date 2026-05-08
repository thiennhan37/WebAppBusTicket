import 'dart:async';
import 'package:flutter/material.dart';
import '../../../data/models/province_model.dart';
import '../../../data/repositories/location_repository.dart';

class LocationViewModel extends ChangeNotifier {
  final LocationRepository _repository;

  LocationViewModel(this._repository) {
    fetchProvinces('');
  }

  List<ProvinceModel> _provinces = [];
  List<ProvinceModel> get provinces => _provinces;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Timer? _debounceTimer;

  // Hàm xử lý khi người dùng gõ phím
  void onSearchChanged(String query) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();

    // Đợi người dùng ngừng gõ 500ms thì mới gọi API
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      fetchProvinces(query.trim());
    });
  }

  Future<void> fetchProvinces(String keyword) async {
    _isLoading = true;
    notifyListeners();

    try {
      _provinces = await _repository.searchProvinces(keyword);
    } catch (e) {
      print('Lỗi fetch provinces: $e');
      // Nếu API lỗi, có thể gán danh sách phổ biến mặc định vào đây
      _provinces = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
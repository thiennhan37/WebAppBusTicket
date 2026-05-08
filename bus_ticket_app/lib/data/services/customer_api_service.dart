// lib/data/services/customer_api_service.dart
import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';

class CustomerApiService {
  final ApiClient _apiClient;

  CustomerApiService(this._apiClient);

  // Thường update profile sẽ dùng PUT hoặc PATCH. Nếu backend của bạn dùng POST thì sửa lại _apiClient.post nhé
  Future<Response> updateProfile(Map<String, dynamic> data) async {
    return await _apiClient.put(
      '/customer/profile', // Thay bằng ApiConstants.updateProfile nếu bạn có khai báo
      data: data,
      // Endpoint này chắc chắn cần Token, mặc định trong ApiClient đã là true nên không cần thêm options
    );
  }
}
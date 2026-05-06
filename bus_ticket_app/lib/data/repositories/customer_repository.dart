// lib/data/repositories/customer_repository.dart
import 'package:dio/dio.dart';
import '../models/update_customer_profile_request_model.dart';
import '../services/customer_api_service.dart';

class CustomerRepository {
  final CustomerApiService _customerApiService;

  CustomerRepository(this._customerApiService);

  Future<void> updateProfile(UpdateCustomerProfileRequestModel request) async {
    try {
      await _customerApiService.updateProfile(request.toJson());
    } on DioException catch (e) {
      if (e.response != null) {
        // Trích xuất câu thông báo lỗi từ backend (ví dụ: "Số điện thoại không hợp lệ")
        final errorMessage = e.response?.data['message'] ?? 'Có lỗi xảy ra từ máy chủ';
        throw Exception(errorMessage);
      }
      throw Exception('Lỗi kết nối mạng: ${e.message}');
    } catch (e) {
      throw Exception('Lỗi không xác định: $e');
    }
  }
}
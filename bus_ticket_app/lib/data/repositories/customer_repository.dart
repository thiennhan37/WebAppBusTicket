// lib/data/repositories/customer_repository.dart
import 'package:bus_ticket_app/data/models/order_model.dart';
import 'package:bus_ticket_app/data/models/order_detail_model.dart';
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
        final errorMessage = e.response?.data['message'] ?? 'Có lỗi xảy ra từ máy chủ';
        throw Exception(errorMessage);
      }
      throw Exception('Lỗi kết nối mạng: ${e.message}');
    } catch (e) {
      throw Exception('Lỗi không xác định: $e');
    }
  }

  Future<List<OrderModel>> getRecentOrders() async {
    try {
      final response = await _customerApiService.getRecentOrders();
      final List<dynamic> data = response.data['result'] ?? [];
      return data.map((json) => OrderModel.fromJson(json)).toList();
    } on DioException catch (e) {
      if (e.response != null) {
        final errorMessage = e.response?.data['message'] ?? 'Không thể tải danh sách vé';
        throw Exception(errorMessage);
      }
      throw Exception('Lỗi kết nối mạng: ${e.message}');
    } catch (e) {
      throw Exception('Lỗi không xác định: $e');
    }
  }

  Future<bool> unholdSeats(String orderId) async {
    try {
      final response = await _customerApiService.unholdSeats(orderId);
      return response.data['result'] == true;
    } on DioException catch (e) {
      if (e.response != null) {
        final errorMessage = e.response?.data['message'] ?? 'Không thể hủy đơn hàng';
        throw Exception(errorMessage);
      }
      throw Exception('Lỗi kết nối mạng: ${e.message}');
    } catch (e) {
      throw Exception('Lỗi không xác định: $e');
    }
  }

  Future<OrderDetailModel> getOrderDetail(String orderId) async {
    try {
      final response = await _customerApiService.getOrderDetail(orderId);
      return OrderDetailModel.fromJson(response.data['result']);
    } on DioException catch (e) {
      if (e.response != null) {
        final errorMessage = e.response?.data['message'] ?? 'Không thể tải chi tiết đơn hàng';
        throw Exception(errorMessage);
      }
      throw Exception('Lỗi kết nối mạng: ${e.message}');
    } catch (e) {
      throw Exception('Lỗi không xác định: $e');
    }
  }

  Future<Map<String, dynamic>> rateOrder(String orderId, Map<String, dynamic> ratingData) async {
    try {
      final response = await _customerApiService.rateOrder(orderId, ratingData);
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        return e.response?.data ?? {'code': -1, 'message': 'Có lỗi xảy ra'};
      }
      throw Exception('Lỗi kết nối mạng: ${e.message}');
    } catch (e) {
      throw Exception('Lỗi không xác định: $e');
    }
  }
}

// lib/data/services/customer_api_service.dart
import 'package:bus_ticket_app/core/constants/api_constants.dart';
import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';

class CustomerApiService {
  final ApiClient _apiClient;

  CustomerApiService(this._apiClient);

  Future<Response> updateProfile(Map<String, dynamic> data) async {
    return await _apiClient.put(
      ApiConstants.updateProfile,
      data: data,
    );
  }

  Future<Response> getRecentOrders() async {
    return await _apiClient.get(ApiConstants.getRecentOrders);
  }
}
import 'package:bus_ticket_app/core/constants/api_constants.dart';
import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
class LocationApiService {
  final ApiClient _apiClient;

  LocationApiService(this._apiClient);

  // Gọi API: GET /provinces
  Future<Response> searchProvinces(String keyword) async {
    return await _apiClient.get(
      ApiConstants.getProvinces,
      queryParameters: {
        if (keyword.isNotEmpty) 'keyword': keyword,
        // 'page': 0, 'size': 20 // Nếu bạn muốn truyền thêm pageable
      },
    );
  }

  // Gọi API: GET /stops
  Future<Response> findAllStops(String province, String keyword) async {
    return await _apiClient.get(
      ApiConstants.getStop,
      queryParameters: {
        'province': province,
        if (keyword.isNotEmpty) 'keyword': keyword,
      },
    );
  }
}
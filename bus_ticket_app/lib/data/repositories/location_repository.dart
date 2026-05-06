import 'package:dio/dio.dart';
import '../models/province_model.dart';
import '../services/location_api_service.dart';

class LocationRepository {
  final LocationApiService _locationApiService;

  LocationRepository(this._locationApiService);

  // Parse dữ liệu tỉnh thành
  Future<List<ProvinceModel>> searchProvinces(String keyword) async {
    try {
      final response = await _locationApiService.searchProvinces(keyword);

      final List data = response.data['result'] ?? response.data['data'] ?? [];

      return data.map((json) => ProvinceModel.fromJson(json)).toList();

    } on DioException catch (e) {
      if (e.response != null) {
        final errorMessage = e.response?.data['message'] ?? 'Có lỗi xảy ra khi lấy danh sách tỉnh thành';
        throw Exception(errorMessage);
      }
      throw Exception('Lỗi kết nối mạng: ${e.message}');
    } catch (e) {
      throw Exception('Lỗi không xác định: $e');
    }
  }

  // Parse dữ liệu điểm dừng
  Future<List<dynamic>> findAllStops(String province, String keyword) async {
    try {
      final response = await _locationApiService.findAllStops(province, keyword);

      // Bạn có thể tạo thêm StopModel và map() giống như trên nếu cần
      return response.data['result'] ?? response.data['data'] ?? [];

    } on DioException catch (e) {
      if (e.response != null) {
        final errorMessage = e.response?.data['message'] ?? 'Có lỗi xảy ra khi lấy điểm dừng';
        throw Exception(errorMessage);
      }
      throw Exception('Lỗi kết nối mạng: ${e.message}');
    } catch (e) {
      throw Exception('Lỗi không xác định: $e');
    }
  }
}
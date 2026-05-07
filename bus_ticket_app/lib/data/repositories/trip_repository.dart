import 'package:bus_ticket_app/data/models/trip_model.dart';
import 'package:bus_ticket_app/data/services/trip_api_service.dart';
import 'package:dio/dio.dart';

class TripRepository{
  final TripApiService _tripApiService;
  TripRepository(this._tripApiService);


  Future<List<TripModel>> searchTrip(String startProvince, String endProvince, String date) async {
    try {
      final response = await _tripApiService.searchTrip(startProvince, endProvince, date);

      final List data = response.data['result'] ?? response.data['data'] ?? [];

      return data.map((json) => TripModel.fromJson(json)).toList();

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
}
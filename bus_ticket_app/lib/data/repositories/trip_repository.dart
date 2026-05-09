import 'package:bus_ticket_app/data/models/bus_diagram_model.dart';
import 'package:bus_ticket_app/data/models/stop_model.dart';
import 'package:bus_ticket_app/data/models/trip_model.dart';
import 'package:bus_ticket_app/data/services/trip_api_service.dart';
import 'package:dio/dio.dart';

class TripRepository{
  final TripApiService _tripApiService;
  TripRepository(this._tripApiService);


  Future<List<TripModel>> searchTrip(String startProvince, String endProvince, String date) async {
    try {
      final response = await _tripApiService.searchTrip(startProvince, endProvince, date);
      final data = response.data['result'] ?? response.data['data'] ?? [];
      return (data as List).map<TripModel>((json) => TripModel.fromJson(json)).toList();
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

  Future<BusDiagramData> getBusDiagram(String tripId) async {
    try {
      final response = await _tripApiService.getBusDiagram(tripId);
      final result = response.data['result'];
      if (result != null) {
        return BusDiagramData.fromJson(result);
      }
      throw Exception('Không tìm thấy sơ đồ xe');
    } on DioException catch (e) {
      if (e.response != null) {
        final errorMessage = e.response?.data['message'] ?? 'Có lỗi xảy ra khi lấy sơ đồ xe';
        throw Exception(errorMessage);
      }
      throw Exception('Lỗi kết nối mạng: ${e.message}');
    } catch (e) {
      throw Exception('Lỗi không xác định: $e');
    }
  }

  Future<List<StopModel>> getStops(String provinceId) async {
    try {
      final response = await _tripApiService.getStops(provinceId);
      final data = response.data['result'] as List?;
      if (data != null) {
        return data.map((json) => StopModel.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      if (e.response != null) {
        final errorMessage = e.response?.data['message'] ?? 'Có lỗi xảy ra khi lấy danh sách điểm đón/trả';
        throw Exception(errorMessage);
      }
      throw Exception('Lỗi kết nối mạng: ${e.message}');
    } catch (e) {
      throw Exception('Lỗi không xác định: $e');
    }
  }
}
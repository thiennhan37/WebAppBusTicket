import 'package:bus_ticket_app/data/models/bus_company_model.dart';
import 'package:bus_ticket_app/data/models/bus_diagram_model.dart';
import 'package:bus_ticket_app/data/models/paginated_trip_result.dart';
import 'package:bus_ticket_app/data/models/stop_model.dart';
import 'package:bus_ticket_app/data/models/trip_model.dart';
import 'package:bus_ticket_app/data/services/trip_api_service.dart';
import 'package:dio/dio.dart';

class TripRepository {
  final TripApiService _tripApiService;
  TripRepository(this._tripApiService);

  Future<PaginatedTripResult> searchTrip({
    required String startProvince,
    required String endProvince,
    required String date,
    int? minPrice,
    int? maxPrice,
    List<String>? busCompanyIds,
    String? departureTimeFrom,
    String? departureTimeTo,
    List<int>? pickupStopIds,
    List<int>? dropoffStopIds,
    String? busType,
    double? minRating,
    String? sortBy,
    int page = 0,
  }) async {
    try {
      final response = await _tripApiService.searchTrip(
        startProvince: startProvince,
        endProvince: endProvince,
        date: date,
        minPrice: minPrice,
        maxPrice: maxPrice,
        busCompanyIds: busCompanyIds,
        departureTimeFrom: departureTimeFrom,
        departureTimeTo: departureTimeTo,
        pickupStopIds: pickupStopIds,
        dropoffStopIds: dropoffStopIds,
        busType: busType,
        minRating: minRating,
        sortBy: sortBy,
        page: page,
      );
      final result = response.data['result'] ?? response.data['data'] ?? [];
      final content = _extractTripContent(result);
      final pageInfo = result is Map<String, dynamic> ? result['page'] as Map<String, dynamic>? : null;
      final currentPage = _readInt(pageInfo?['number']) ?? page;
      final totalPages = _readInt(pageInfo?['totalPages']);
      final totalElements = _readInt(pageInfo?['totalElements']);
      return PaginatedTripResult(
        trips: content.map((json) => TripModel.fromJson(json)).toList(),
        currentPage: currentPage,
        totalPages: totalPages,
        totalElements: totalElements,
      );
    } on DioException catch (e) {
      if (e.response != null) {
        final errorMessage = e.response?.data['message'] ?? 'Có lỗi xảy ra khi lấy danh sách chuyến xe';
        throw Exception(errorMessage);
      }
      throw Exception('Lỗi kết nối mạng: ${e.message}');
    } catch (e) {
      throw Exception('Lỗi không xác định: $e');
    }
  }

  List<dynamic> _extractTripContent(dynamic result) {
    if (result is List) {
      return result;
    }
    if (result is Map<String, dynamic>) {
      final content = result['content'];
      if (content is List) {
        return content;
      }
    }
    return [];
  }

  int? _readInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
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

  Future<List<StopModel>> getPickupStops(String provinceId) async {
    try {
      final response = await _tripApiService.getPickupStops(provinceId);
      final data = response.data['result'] as List?;
      if (data != null) {
        return data.map((json) => StopModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Lỗi lấy điểm đón: $e');
    }
  }

  Future<List<StopModel>> getDropoffStops(String provinceId) async {
    try {
      final response = await _tripApiService.getDropoffStops(provinceId);
      final data = response.data['result'] as List?;
      if (data != null) {
        return data.map((json) => StopModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Lỗi lấy điểm trả: $e');
    }
  }

  Future<List<BusCompanyModel>> getBusCompanies(String provinceId) async {
    try {
      final response = await _tripApiService.getCompaniesInfo(provinceId);
      final data = response.data['result'] as List?;
      if (data != null) {
        return data.map((json) => BusCompanyModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Lỗi lấy danh sách nhà xe: $e');
    }
  }

  Future<Response> holdSeats(String tripId, List<String> tripSeatIdList) async {
    try {
      return await _tripApiService.holdSeats(tripId, tripSeatIdList);
    } on DioException catch (e) {
      if (e.response != null) {
        return e.response!;
      }
      rethrow;
    }
  }

  Future<Response> payment({
    required String orderId,
    required String customerName,
    required String customerPhone,
    required String customerEmail,
  }) async {
    try {
      return await _tripApiService.payment(
        orderId: orderId,
        customerName: customerName,
        customerPhone: customerPhone,
        customerEmail: customerEmail,
      );
    } on DioException catch (e) {
      if (e.response != null) {
        return e.response!;
      }
      rethrow;
    }
  }

  Future<bool> checkPaymentStatus(String bookingOrderId) async {
    try {
      final response = await _tripApiService.checkPaymentStatus(bookingOrderId);
      return response.data['result'] == true;
    } catch (e) {
      return false;
    }
  }
}

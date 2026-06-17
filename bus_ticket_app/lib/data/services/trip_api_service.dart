import 'package:bus_ticket_app/core/network/api_client.dart';
import 'package:dio/dio.dart';

import '../../core/constants/api_constants.dart';

class TripApiService {
  final ApiClient _apiClient;
  TripApiService(this._apiClient);

  Future<Response> searchTrip({
    required String startProvince,
    required String endProvince,
    required String date,
    int? minPrice,
    int? maxPrice,
    String? busCompanyId,
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
    final queryParams = <String, dynamic>{
      'startProvince': startProvince,
      'endProvince': endProvince,
      'date': date,
      'page': page,
    };

    if (minPrice != null) queryParams['minPrice'] = minPrice;
    if (maxPrice != null) queryParams['maxPrice'] = maxPrice;
    if (busCompanyId != null) queryParams['busCompanyId'] = busCompanyId;
    if (departureTimeFrom != null) queryParams['departureTimeFrom'] = departureTimeFrom;
    if (departureTimeTo != null) queryParams['departureTimeTo'] = departureTimeTo;
    if (busType != null) queryParams['busType'] = busType;
    if (minRating != null) queryParams['minRating'] = minRating;
    if (sortBy != null) queryParams['sortBy'] = sortBy;

    // Chuyển sang chuỗi phân cách dấu phẩy để Backend (Spring Boot) map vào List dễ dàng hơn
    if (busCompanyIds != null && busCompanyIds.isNotEmpty) {
      queryParams['busCompanyIds'] = busCompanyIds.join(',');
    }
    if (pickupStopIds != null && pickupStopIds.isNotEmpty) {
      queryParams['pickupStopIds'] = pickupStopIds.join(',');
    }
    if (dropoffStopIds != null && dropoffStopIds.isNotEmpty) {
      queryParams['dropoffStopIds'] = dropoffStopIds.join(',');
    }

    return await _apiClient.get(
      ApiConstants.searchTrip,
      queryParameters: queryParams,
      requiresToken: false,
    );
  }

  Future<Response> getBusDiagram(String tripId) async {
    return await _apiClient.get(
      ApiConstants.busDiagram,
      queryParameters: {'tripId': tripId},
      requiresToken: false,
    );
  }

  Future<Response> getStops(String tripId) async {
    return await _apiClient.get(
      ApiConstants.getStop,
      queryParameters: {'tripId': tripId},
      requiresToken: false,
    );
  }

  Future<Response> getPickupStops(String provinceId) async {
    return await _apiClient.get(
      ApiConstants.getPickupStops(provinceId),
      requiresToken: false,
    );
  }

  Future<Response> getDropoffStops(String provinceId) async {
    return await _apiClient.get(
      ApiConstants.getDropoffStops(provinceId),
      requiresToken: false,
    );
  }

  Future<Response> getCompaniesInfo(String provinceId) async {
    return await _apiClient.get(
      '${ApiConstants.baseUrl}/trips/get-companies-info',
      queryParameters: {'provinceID': provinceId},
      requiresToken: false,
    );
  }

  Future<Response> holdSeats(String tripId, List<String> tripSeatIdList) async {
    return await _apiClient.post(
      '${ApiConstants.holdSeats}$tripId',
      data: {
        'tripSeatIdList': tripSeatIdList,
      },
      requiresToken: true,
    );
  }

  Future<Response> payment({
    required String orderId,
    required String customerName,
    required String customerPhone,
    required String customerEmail,
  }) async {
    return await _apiClient.post(
      '${ApiConstants.momoPayment}$orderId',
      data: {
        'customerName': customerName,
        'customerPhone': customerPhone,
        'customerEmail': customerEmail,
      },
      requiresToken: true,
    );
  }

  Future<Response> getVNPayUrl(String orderId) async {
    return await _apiClient.post(
      '${ApiConstants.vnpayPayment}$orderId',
      requiresToken: true,
    );
  }

  Future<Response> checkPaymentStatus(String bookingOrderId) async {
    return await _apiClient.get(
      ApiConstants.checkPaymentStatus,
      queryParameters: {'bookingOrderId': bookingOrderId},
      requiresToken: true,
    );
  }
}

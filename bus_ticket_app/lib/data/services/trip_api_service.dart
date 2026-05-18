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
    String? departureTimeFrom,
    String? departureTimeTo,
    int? pickupStopId,
    int? dropoffStopId,
    String? busType,
    double? minRating,
    String? sortBy,
  }) async {
    final queryParams = {
      'startProvince': startProvince,
      'endProvince': endProvince,
      'date': date,
    };

    if (minPrice != null) queryParams['minPrice'] = minPrice.toString();
    if (maxPrice != null) queryParams['maxPrice'] = maxPrice.toString();
    if (busCompanyId != null) queryParams['busCompanyId'] = busCompanyId;
    if (departureTimeFrom != null) queryParams['departureTimeFrom'] = departureTimeFrom;
    if (departureTimeTo != null) queryParams['departureTimeTo'] = departureTimeTo;
    if (pickupStopId != null) queryParams['pickupStopId'] = pickupStopId.toString();
    if (dropoffStopId != null) queryParams['dropoffStopId'] = dropoffStopId.toString();
    if (busType != null) queryParams['busType'] = busType;
    if (minRating != null) queryParams['minRating'] = minRating.toString();
    if (sortBy != null) queryParams['sortBy'] = sortBy;

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

  Future<Response> getStops(String provinceId) async {
    return await _apiClient.get(
      ApiConstants.getStop,
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

  Future<Response> checkPaymentStatus(String bookingOrderId) async {
    return await _apiClient.get(
      ApiConstants.checkPaymentStatus,
      queryParameters: {'bookingOrderId': bookingOrderId},
      requiresToken: true,
    );
  }
}

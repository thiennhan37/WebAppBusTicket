import 'package:bus_ticket_app/core/network/api_client.dart';
import 'package:dio/dio.dart';

import '../../core/constants/api_constants.dart';

class TripApiService{
  final ApiClient _apiClient;
  TripApiService(this._apiClient);
  
  Future<Response> searchTrip(String startProvince, String endProvince, String date) async{
    return await _apiClient.get(
      ApiConstants.searchTrip,
      queryParameters: {
        'startProvince': startProvince,
        'endProvince': endProvince,
        'date': date
      },
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
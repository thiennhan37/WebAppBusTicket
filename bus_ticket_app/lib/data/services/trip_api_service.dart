import 'package:bus_ticket_app/core/network/api_client.dart';
import 'package:bus_ticket_app/data/models/trip_model.dart';
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
    );
  }
}
import 'package:bus_ticket_app/data/models/trip_model.dart';
import 'package:bus_ticket_app/data/repositories/trip_repository.dart';
import 'package:flutter/cupertino.dart';

class SearchTripViewModel extends ChangeNotifier{
  final TripRepository _tripRepository;
  SearchTripViewModel(this._tripRepository);

  List<TripModel> _trips = [];
  List<TripModel> get trips => _trips;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  Future<void> searchTrip(String startProvince, String endProvince, String date) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
       _trips = await _tripRepository.searchTrip(startProvince, endProvince, date);
       _isLoading = false;
       notifyListeners();
    } catch (e) {
      _errorMessage = 'Lỗi kết nối: $e';
      _isLoading = false;
      notifyListeners();
    }
  }
}
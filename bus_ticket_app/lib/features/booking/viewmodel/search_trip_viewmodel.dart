import 'package:bus_ticket_app/data/models/bus_company_model.dart';
import 'package:bus_ticket_app/data/models/stop_model.dart';
import 'package:bus_ticket_app/data/models/trip_model.dart';
import 'package:bus_ticket_app/data/repositories/trip_repository.dart';
import 'package:flutter/cupertino.dart';

class SearchTripViewModel extends ChangeNotifier {
  final TripRepository _tripRepository;
  SearchTripViewModel(this._tripRepository);

  List<TripModel> _trips = [];
  List<TripModel> get trips => _trips;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Filter parameters
  String? _startProvince;
  String? _endProvince;
  String? _date;

  int? minPrice;
  int? maxPrice;
  List<String> busCompanyIds = [];
  String? departureTimeFrom;
  String? departureTimeTo;
  List<int> pickupStopIds = [];
  List<int> dropoffStopIds = [];
  String? busType;
  double? minRating;
  String _sortBy = 'departure_asc';

  String get sortBy => _sortBy;
  set sortBy(String value) {
    _sortBy = value;
    applyFilters();
  }

  String? get startProvinceId => _startProvince;
  String? get endProvinceId => _endProvince;

  void setBaseParams(String startProvince, String endProvince, String date) {
    _startProvince = startProvince;
    _endProvince = endProvince;
    _date = date;
  }

  Future<List<StopModel>> getPickupStops() async {
    if (_startProvince == null) return [];
    return await _tripRepository.getPickupStops(_startProvince!);
  }

  Future<List<StopModel>> getDropoffStops() async {
    if (_endProvince == null) return [];
    return await _tripRepository.getDropoffStops(_endProvince!);
  }

  Future<List<BusCompanyModel>> getBusCompanies() async {
    if (_startProvince == null) return [];
    return await _tripRepository.getBusCompanies(_startProvince!);
  }

  Future<void> searchTrip(String startProvince, String endProvince, String date) async {
    _startProvince = startProvince;
    _endProvince = endProvince;
    _date = date;

    // Reset filters
    minPrice = null;
    maxPrice = null;
    busCompanyIds = [];
    departureTimeFrom = null;
    departureTimeTo = null;
    pickupStopIds = [];
    dropoffStopIds = [];
    busType = null;
    minRating = null;
    _sortBy = 'departure_asc';

    await _fetchTrips();
  }

  Future<void> applyFilters() async {
    if (_startProvince == null || _endProvince == null || _date == null) return;
    await _fetchTrips();
  }

  void clearFilters() {
    minPrice = null;
    maxPrice = null;
    busCompanyIds = [];
    departureTimeFrom = null;
    departureTimeTo = null;
    pickupStopIds = [];
    dropoffStopIds = [];
    busType = null;
    minRating = null;
    _sortBy = 'departure_asc';
    applyFilters();
  }

  Future<void> _fetchTrips() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _trips = await _tripRepository.searchTrip(
        startProvince: _startProvince!,
        endProvince: _endProvince!,
        date: _date!,
        minPrice: minPrice,
        maxPrice: maxPrice,
        busCompanyIds: busCompanyIds.isEmpty ? null : busCompanyIds,
        departureTimeFrom: departureTimeFrom,
        departureTimeTo: departureTimeTo,
        pickupStopIds: pickupStopIds.isEmpty ? null : pickupStopIds,
        dropoffStopIds: dropoffStopIds.isEmpty ? null : dropoffStopIds,
        busType: busType,
        minRating: minRating,
        sortBy: _sortBy,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Lỗi kết nối: $e';
      _isLoading = false;
      notifyListeners();
    }
  }
}

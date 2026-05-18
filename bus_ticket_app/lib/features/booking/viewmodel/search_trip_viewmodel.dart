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
  String? busCompanyId;
  String? departureTimeFrom;
  String? departureTimeTo;
  int? pickupStopId;
  int? dropoffStopId;
  String? busType;
  double? minRating;
  String _sortBy = 'departure_asc';

  String get sortBy => _sortBy;
  set sortBy(String value) {
    _sortBy = value;
    applyFilters();
  }

  void setBaseParams(String startProvince, String endProvince, String date) {
    _startProvince = startProvince;
    _endProvince = endProvince;
    _date = date;
  }

  Future<void> searchTrip(String startProvince, String endProvince, String date) async {
    _startProvince = startProvince;
    _endProvince = endProvince;
    _date = date;

    // QUAN TRỌNG: Xóa toàn bộ bộ lọc cũ khi thực hiện tìm kiếm mới từ trang chủ
    minPrice = null;
    maxPrice = null;
    busCompanyId = null;
    departureTimeFrom = null;
    departureTimeTo = null;
    pickupStopId = null;
    dropoffStopId = null;
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
    busCompanyId = null;
    departureTimeFrom = null;
    departureTimeTo = null;
    pickupStopId = null;
    dropoffStopId = null;
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
      // Debug log để kiểm tra tham số (có thể xóa sau)
      print("Fetching trips with: date=$_date, departureTimeTo=$departureTimeTo");

      _trips = await _tripRepository.searchTrip(
        startProvince: _startProvince!,
        endProvince: _endProvince!,
        date: _date!,
        minPrice: minPrice,
        maxPrice: maxPrice,
        busCompanyId: busCompanyId,
        departureTimeFrom: departureTimeFrom,
        departureTimeTo: departureTimeTo,
        pickupStopId: pickupStopId,
        dropoffStopId: dropoffStopId,
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

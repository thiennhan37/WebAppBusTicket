import 'package:bus_ticket_app/data/models/bus_diagram_model.dart';
import 'package:bus_ticket_app/data/models/stop_model.dart';
import 'package:bus_ticket_app/data/repositories/trip_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:string_normalizer/string_normalizer.dart';

class SeatSelectionViewModel extends ChangeNotifier {
  final TripRepository _tripRepository;
  SeatSelectionViewModel(this._tripRepository);

  // --- Thông tin chuyến đi cơ bản (truyền từ trang search) ---
  String? _departureTime;
  String? _arrivalTime;
  String? _departureStation;
  String? _arrivalStation;
  String? _date;

  void setTripInfo({
    required String departureTime,
    required String arrivalTime,
    required String departureStation,
    required String arrivalStation,
    required String date,
  }) {
    _departureTime = departureTime;
    _arrivalTime = arrivalTime;
    _departureStation = departureStation;
    _arrivalStation = arrivalStation;
    _date = date;
  }

  String get departureTime => _departureTime ?? '--:--';
  String get arrivalTime => _arrivalTime ?? '--:--';
  String get departureStation => _departureStation ?? '';
  String get arrivalStation => _arrivalStation ?? '';
  String get date => _date ?? '';

  // --- Sơ đồ ghế ---
  BusDiagramData? _busDiagramData;
  BusDiagramData? get busDiagramData => _busDiagramData;

  final Set<String> _selectedSeats = {};
  Set<String> get selectedSeats => _selectedSeats;

  // --- Điểm đón/trả ---
  List<StopModel> _departureStops = [];
  List<StopModel> _arrivalStops = [];

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  List<StopModel> get filteredDepartureStops {
    final query = normalize(_searchQuery);

    if (query.isEmpty) return _departureStops;

    return _departureStops.where((stop) {
      final name = normalize(stop.name);
      final address = normalize(stop.address);

      return name.contains(query) ||
          address.contains(query);
    }).toList();
  }

  List<StopModel> get filteredArrivalStops {
    final query = normalize(_searchQuery);

    if (query.isEmpty) return _arrivalStops;

    return _arrivalStops.where((stop) {
      final name = normalize(stop.name);
      final address = normalize(stop.address);

      return name.contains(query) ||
          address.contains(query);
    }).toList();
  }

  StopModel? _selectedDepartureStop;
  StopModel? get selectedDepartureStop => _selectedDepartureStop;

  StopModel? _selectedArrivalStop;
  StopModel? get selectedArrivalStop => _selectedArrivalStop;

  // --- Thông tin liên hệ ---
  String _contactName = '';
  String get contactName => _contactName;
  
  String _contactPhone = '';
  String get contactPhone => _contactPhone;
  
  String _contactEmail = '';
  String get contactEmail => _contactEmail;

  // --- Trạng thái UI ---
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  int _currentStep = 1;
  int get currentStep => _currentStep;

  // --- Methods ---

  void updateContactInfo({String? name, String? phone, String? email}) {
    if (name != null) _contactName = name;
    if (phone != null) _contactPhone = phone;
    if (email != null) _contactEmail = email;
    notifyListeners();
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> fetchBusDiagram(String tripId) async {
    _isLoading = true;
    _errorMessage = null;
    _selectedSeats.clear();
    _currentStep = 1;
    _searchQuery = '';
    notifyListeners();

    try {
      _busDiagramData = await _tripRepository.getBusDiagram(tripId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchDepartureStops(String provinceId) async {
    _isLoading = true;
    _errorMessage = null;
    _searchQuery = '';
    notifyListeners();

    try {
      _departureStops = await _tripRepository.getStops(provinceId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchArrivalStops(String provinceId) async {
    _isLoading = true;
    _errorMessage = null;
    _searchQuery = '';
    notifyListeners();

    try {
      _arrivalStops = await _tripRepository.getStops(provinceId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void toggleSeatSelection(String seatCode) {
    final seat = _busDiagramData?.seats.firstWhere((s) => s.seatCode == seatCode);
    if (seat == null || seat.status != 'AVAILABLE') return;

    if (_selectedSeats.contains(seatCode)) {
      _selectedSeats.remove(seatCode);
    } else {
      _selectedSeats.add(seatCode);
    }
    notifyListeners();
  }

  void selectDepartureStop(StopModel stop) {
    _selectedDepartureStop = stop;
    notifyListeners();
  }

  void selectArrivalStop(StopModel stop) {
    _selectedArrivalStop = stop;
    notifyListeners();
  }

  void nextStep() {
    if (_currentStep < 5) {
      _currentStep++;
      _searchQuery = '';
      notifyListeners();
    }
  }

  void previousStep() {
    if (_currentStep > 1) {
      _currentStep--;
      _searchQuery = '';
      notifyListeners();
    }
  }

  void goToStep(int step) {
    _currentStep = step;
    notifyListeners();
  }

  bool isSelected(String seatCode) => _selectedSeats.contains(seatCode);

  String getSeatStatus(String seatCode) {
    final seat = _busDiagramData?.seats.firstWhere(
      (s) => s.seatCode == seatCode,
      orElse: () => SeatStatus(seatCode: '', status: 'NONE', price: 0),
    );
    return seat?.status ?? 'NONE';
  }

  int get totalPrice {
    if (_busDiagramData == null) return 0;
    int total = 0;
    for (var seatCode in _selectedSeats) {
      final seat = _busDiagramData!.seats.firstWhere((s) => s.seatCode == seatCode);
      total += seat.price;
    }
    return total;
  }

  String normalize(String text) {
    return StringNormalizer.normalize(text)
        .replaceAll('đ', 'd')
        .replaceAll('Đ', 'D')
        .toLowerCase()
        .trim();
  }
}

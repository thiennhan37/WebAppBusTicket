import 'package:bus_ticket_app/data/models/bus_diagram_model.dart';
import 'package:bus_ticket_app/data/models/stop_model.dart';
import 'package:bus_ticket_app/data/repositories/trip_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:string_normalizer/string_normalizer.dart';

class SeatSelectionViewModel extends ChangeNotifier {
  final TripRepository _tripRepository;
  SeatSelectionViewModel(this._tripRepository);

  // --- Thông tin chuyến đi cơ bản ---
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
      return name.contains(query) || address.contains(query);
    }).toList();
  }

  List<StopModel> get filteredArrivalStops {
    final query = normalize(_searchQuery);
    if (query.isEmpty) return _arrivalStops;
    return _arrivalStops.where((stop) {
      final name = normalize(stop.name);
      final address = normalize(stop.address);
      return name.contains(query) || address.contains(query);
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

  // --- Thanh toán ---
  String? _selectedPaymentMethod;
  String? get selectedPaymentMethod => _selectedPaymentMethod;

  String? _orderCode;
  String? get orderCode => _orderCode;

  void selectPaymentMethod(String method) {
    _selectedPaymentMethod = method;
    notifyListeners();
  }

  // --- Trạng thái UI ---
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  int? _lastErrorCode;
  int? get lastErrorCode => _lastErrorCode;

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
    _lastErrorCode = null;
    _selectedSeats.clear();
    _currentStep = 1;
    _searchQuery = '';
    _selectedPaymentMethod = null;
    _orderCode = null;
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

  Future<void> refreshBusDiagram(String tripId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newData = await _tripRepository.getBusDiagram(tripId);
      _busDiagramData = newData;
      
      // Lọc lại danh sách ghế đã chọn
      final validSeats = <String>{};
      for (var seatCode in _selectedSeats) {
        try {
          final seat = newData.seats.firstWhere((s) => s.seatCode == seatCode);
          if (seat.status == 'AVAILABLE') {
            validSeats.add(seatCode);
          }
        } catch (_) {}
      }
      
      _selectedSeats.clear();
      _selectedSeats.addAll(validSeats);
      
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

  Future<bool> holdSeats(String tripId) async {
    _isLoading = true;
    _errorMessage = null;
    _lastErrorCode = null;
    notifyListeners();

    try {
      final tripSeatIdList = _selectedSeats.map((seatCode) {
        return _busDiagramData!.seats.firstWhere((s) => s.seatCode == seatCode).seatId;
      }).toList();

      final response = await _tripRepository.holdSeats(tripId, tripSeatIdList);
      final data = response.data;
      final int code = data['code'];
      _lastErrorCode = code;

      if (code == 0) {
        _orderCode = data['result'];
        _isLoading = false;
        notifyListeners();
        return true;
      } else if (code == 4010) {
        // Lỗi 4010: Ghế đã có người đặt
        final newData = await _tripRepository.getBusDiagram(tripId);
        _busDiagramData = newData;
        
        final takenSeats = <String>[];
        final stillAvailable = <String>{};
        for (var seatCode in _selectedSeats) {
          try {
            final seat = newData.seats.firstWhere((s) => s.seatCode == seatCode);
            if (seat.status == 'AVAILABLE') {
              stillAvailable.add(seatCode);
            } else {
              takenSeats.add(seatCode);
            }
          } catch (_) {}
        }
        
        _selectedSeats.clear();
        _selectedSeats.addAll(stillAvailable);
        
        if (takenSeats.isNotEmpty) {
          _errorMessage = "Các ghế sau đã có người đặt: ${takenSeats.join(', ')}";
        } else {
          _errorMessage = data['message'] ?? 'Một trong những ghế đã có người đặt';
        }
      } else if (code == 4013) {
        _errorMessage = 'Bạn phải thanh toán đơn hàng đang tồn tại';
      } else {
        _errorMessage = 'Lỗi đặt vé';
      }
      
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Lỗi đặt vé';
      _isLoading = false;
      notifyListeners();
      return false;
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
    if (_currentStep < 6) {
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
      orElse: () => SeatStatus(seatId: '', seatCode: '', status: 'NONE', price: 0),
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

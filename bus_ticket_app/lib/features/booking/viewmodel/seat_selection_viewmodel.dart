import 'dart:async';

import 'package:bus_ticket_app/data/models/bus_diagram_model.dart';
import 'package:bus_ticket_app/data/models/stop_model.dart';
import 'package:bus_ticket_app/data/repositories/trip_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:string_normalizer/string_normalizer.dart';
import 'package:url_launcher/url_launcher.dart';

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

  Map<String, dynamic>? _paymentData;
  Map<String, dynamic>? get paymentData => _paymentData;

  bool _isPaymentSuccessful = false;
  bool get isPaymentSuccessful => _isPaymentSuccessful;

  int? _manualTotalPrice;

  // --- Timers ---
  Timer? _paymentTimer;
  Timer? _statusCheckTimer;
  int _remainingSeconds = 600; // 10 phút
  bool _isTimerExpired = false;

  int get remainingSeconds => _remainingSeconds;
  bool get isTimerExpired => _isTimerExpired;

  String get remainingTimeFormatted {
    int minutes = _remainingSeconds ~/ 60;
    int seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void startPaymentTimer({int? initialSeconds}) {
    _paymentTimer?.cancel();
    if (initialSeconds != null) {
      _remainingSeconds = initialSeconds;
    } else {
      _remainingSeconds = 600;
    }
    _isTimerExpired = false;
    _paymentTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        notifyListeners();
      } else {
        _isTimerExpired = true;
        _paymentTimer?.cancel();
        stopStatusCheck();
        notifyListeners();
      }
    });
  }

  void stopPaymentTimer() {
    _paymentTimer?.cancel();
    _remainingSeconds = 600;
    _isTimerExpired = false;
    _paymentData = null;
    _orderCode = null;
    _manualTotalPrice = null;
    stopStatusCheck();
  }

  void startStatusCheck() {
    _statusCheckTimer?.cancel();
    if ((_selectedPaymentMethod != 'momo' && _selectedPaymentMethod != 'vnpay') || _orderCode == null) return;

    _statusCheckTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      if (_currentStep == 6 && (_selectedPaymentMethod == 'momo' || _selectedPaymentMethod == 'vnpay') && _orderCode != null && !_isPaymentSuccessful) {
        final isPaid = await _tripRepository.checkPaymentStatus(_orderCode!);
        if (isPaid) {
          _isPaymentSuccessful = true;
          _statusCheckTimer?.cancel();
          _paymentTimer?.cancel();
          notifyListeners();
        }
      } else {
        timer.cancel();
      }
    });
  }

  void stopStatusCheck() {
    _statusCheckTimer?.cancel();
    _statusCheckTimer = null;
  }

  void selectPaymentMethod(String method) {
    _selectedPaymentMethod = method;
    if (method == 'momo' || method == 'vnpay') {
      startStatusCheck();
      if (method == 'vnpay') {
        processPayment();
      }
    } else {
      stopStatusCheck();
    }
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

  /// Lấy danh sách điểm dừng của chuyến xe (Gồm cả đón và trả)
  Future<void> fetchTripStops(String tripId) async {
    try {
      final stopsData = await _tripRepository.getStopsForTrip(tripId);

      _departureStops = stopsData
          .where((item) => item['type'] == 'UP')
          .map((item) => item['stop'] as StopModel)
          .toList();

      _arrivalStops = stopsData
          .where((item) => item['type'] == 'DOWN')
          .map((item) => item['stop'] as StopModel)
          .toList();
    } catch (e) {
      debugPrint('Error fetching trip stops: $e');
      rethrow;
    }
  }

  Future<void> fetchBusDiagram(String tripId) async {
    if (tripId.isEmpty) return;
    _isLoading = true;
    _errorMessage = null;
    _lastErrorCode = null;
    _selectedSeats.clear();
    _currentStep = 1;
    _searchQuery = '';
    _selectedPaymentMethod = null;
    _orderCode = null;
    _paymentData = null;
    _isPaymentSuccessful = false;
    _manualTotalPrice = null;
    _selectedDepartureStop = null;
    _selectedArrivalStop = null;
    stopPaymentTimer();
    notifyListeners();

    try {
      // Gọi song song cả sơ đồ và điểm dừng để tối ưu thời gian
      final results = await Future.wait([
        _tripRepository.getBusDiagram(tripId),
        fetchTripStops(tripId),
      ]);
      
      _busDiagramData = results[0] as BusDiagramData;
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void resumeBooking(String orderId, int totalPrice, {int? remainingSeconds}) {
    _orderCode = orderId;
    _manualTotalPrice = totalPrice;
    _currentStep = 6;
    _isPaymentSuccessful = false;
    _paymentData = null;
    _selectedPaymentMethod = null;
    startPaymentTimer(initialSeconds: remainingSeconds ?? 600);
    notifyListeners();
  }

  Future<void> refreshBusDiagram(String tripId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newData = await _tripRepository.getBusDiagram(tripId);
      _busDiagramData = newData;
      
      final validSeats = <String>{};
      for (var seatCode in _selectedSeats) {
        try {
          final seat = newData.seats.firstWhere((s) => s.seatCode == seatCode);
          if (seat.status.toUpperCase() == 'AVAILABLE') {
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

  Future<bool> holdSeats(String tripId) async {
    _isLoading = true;
    _errorMessage = null;
    _lastErrorCode = null;
    notifyListeners();

    try {
      final List<String> tripSeatIdList = [];
      for (var seatCode in _selectedSeats) {
        try {
          final seat = _busDiagramData!.seats.firstWhere((s) => s.seatCode == seatCode);
          tripSeatIdList.add(seat.seatId);
        } catch (_) {}
      }

      if (tripSeatIdList.isEmpty) {
        _errorMessage = "Vui lòng chọn ghế";
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final response = await _tripRepository.holdSeats(tripId, tripSeatIdList);
      final data = response.data;
      final int code = data['code'];
      _lastErrorCode = code;

      if (code == 1000 || code == 0) {
        _orderCode = data['data'] ?? data['result'];
        _isLoading = false;
        _paymentData = null;
        _isPaymentSuccessful = false;
        startPaymentTimer();
        notifyListeners();
        return true;
      } else if (code == 4010) {
        final newData = await _tripRepository.getBusDiagram(tripId);
        _busDiagramData = newData;
        
        final takenSeats = <String>[];
        final stillAvailable = <String>{};
        for (var seatCode in _selectedSeats) {
          try {
            final seat = newData.seats.firstWhere((s) => s.seatCode == seatCode);
            if (seat.status.toUpperCase() == 'AVAILABLE') {
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

  Future<bool> processPayment() async {
    if (_orderCode == null) {
      _errorMessage = "Không tìm thấy mã đơn hàng";
      notifyListeners();
      return false;
    }

    if (_selectedPaymentMethod == 'vnpay') {
      return await _processVNPay();
    }

    if (_paymentData != null) {
      startStatusCheck();
      return true;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _tripRepository.payment(
        orderId: _orderCode!,
        customerName: _contactName,
        customerPhone: _contactPhone,
        customerEmail: _contactEmail,
      );

      final data = response.data;
      if (data['code'] == 0 || data['code'] == 1000) {
        _paymentData = data['result'] ?? data['data'];
        _isLoading = false;
        startStatusCheck();
        notifyListeners();
        return true;
      } else {
        _errorMessage = data['message'] ?? "Lỗi thanh toán";
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = "Lỗi kết nối thanh toán";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> _processVNPay() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _tripRepository.getVNPayUrl(_orderCode!);
      final data = response.data;
      if (data['code'] == 0 || data['code'] == 1000) {
        final result = data['result'] ?? data['data'];
        final payUrl = result['payUrl'];
        if (payUrl != null) {
          final uri = Uri.parse(payUrl);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
            _isLoading = false;
            startStatusCheck();
            notifyListeners();
            return true;
          } else {
            _errorMessage = "Không thể mở liên kết thanh toán";
          }
        } else {
          _errorMessage = "Không tìm thấy liên kết thanh toán";
        }
      } else {
        _errorMessage = data['message'] ?? "Lỗi lấy liên kết thanh toán VNPay";
      }
    } catch (e) {
      _errorMessage = "Lỗi kết nối VNPay";
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  void toggleSeatSelection(String seatCode) {
    if (_busDiagramData == null) return;

    final hasSeat = _busDiagramData!.seats.any((s) => s.seatCode == seatCode);
    if (!hasSeat) return;

    final seat = _busDiagramData!.seats.firstWhere((s) => s.seatCode == seatCode);
    if (seat.status.toUpperCase() != 'AVAILABLE') return;

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
      if (_currentStep != 6) {
        stopStatusCheck();
      }
      notifyListeners();
    }
  }

  void goToStep(int step) {
    _currentStep = step;
    if (_currentStep != 6) {
      stopStatusCheck();
    }
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
    if (_manualTotalPrice != null) return _manualTotalPrice!;
    if (_busDiagramData == null) return 0;
    int total = 0;
    for (var seatCode in _selectedSeats) {
      try {
        final seat = _busDiagramData!.seats.firstWhere((s) => s.seatCode == seatCode);
        total += seat.price;
      } catch (_) {}
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

  @override
  void dispose() {
    _paymentTimer?.cancel();
    _statusCheckTimer?.cancel();
    super.dispose();
  }
}

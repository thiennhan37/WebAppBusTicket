import 'package:bus_ticket_app/data/models/bus_diagram_model.dart';
import 'package:bus_ticket_app/data/repositories/trip_repository.dart';
import 'package:flutter/foundation.dart';

class SeatSelectionViewModel extends ChangeNotifier {
  final TripRepository _tripRepository;
  SeatSelectionViewModel(this._tripRepository);

  BusDiagramData? _busDiagramData;
  BusDiagramData? get busDiagramData => _busDiagramData;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  final Set<String> _selectedSeats = {};
  Set<String> get selectedSeats => _selectedSeats;

  Future<void> fetchBusDiagram(String tripId) async {
    _isLoading = true;
    _errorMessage = null;
    _selectedSeats.clear();
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
}

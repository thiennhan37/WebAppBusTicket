import 'package:flutter/material.dart';
import '../../../data/models/order_model.dart';
import '../../../data/repositories/customer_repository.dart';

class MyTicketsViewModel extends ChangeNotifier {
  final CustomerRepository _repository;

  MyTicketsViewModel(this._repository);

  List<OrderModel> _orders = [];
  List<OrderModel> get orders => _orders;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Lọc đơn hàng hiện tại: Đang giữ chỗ hoặc Đã thanh toán nhưng chưa khởi hành
  List<OrderModel> get currentOrders {
    final now = DateTime.now();
    return _orders.where((o) {
      final isUpcoming = DateTime.parse(o.departureTime).isAfter(now);
      return o.orderStatus == 'HOLDING' || (o.orderStatus == 'PAID' && isUpcoming);
    }).toList();
  }
  
  // Lọc đơn hàng đã đi: Đã thanh toán và đã quá giờ khởi hành
  List<OrderModel> get pastOrders {
    final now = DateTime.now();
    return _orders.where((o) {
      final isPast = DateTime.parse(o.departureTime).isBefore(now);
      return o.orderStatus == 'PAID' && isPast;
    }).toList();
  }

  // Lọc đơn hàng đã hủy hoặc hết hạn
  List<OrderModel> get cancelledOrders => _orders.where((o) => 
    o.orderStatus == 'CANCELLED' || o.orderStatus == 'EXPIRED'
  ).toList();

  Future<void> fetchOrders() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _orders = await _repository.getRecentOrders();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }

  Future<bool> cancelOrder(String orderId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _repository.unholdSeats(orderId);
      if (success) {
        await fetchOrders(); // Tải lại danh sách sau khi hủy thành công
        return true;
      }
      _isLoading = false;
      _errorMessage = "Hủy đơn hàng thất bại";
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
}

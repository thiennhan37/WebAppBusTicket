import 'dart:async';

import 'package:bus_ticket_app/data/models/notification_payload_model.dart';
import 'package:bus_ticket_app/data/services/local/auth_storage.dart';
import 'package:bus_ticket_app/data/services/local/notification_storage.dart';
import 'package:bus_ticket_app/data/services/notification_socket_service.dart';
import 'package:bus_ticket_app/global_varible.dart';
import 'package:flutter/material.dart';

class NotificationViewModel extends ChangeNotifier {
  final AuthStorage _authStorage;
  final NotificationStorage _notificationStorage;
  final NotificationSocketService _socketService;

  StreamSubscription<NotificationPayloadModel>? _subscription;
  String? _customerId;
  List<NotificationPayloadModel> _notifications = [];

  NotificationViewModel(
    this._authStorage,
    this._notificationStorage,
    this._socketService,
  ) {
    _subscription = _socketService.notifications.listen(_onNotificationReceived);
  }

  List<NotificationPayloadModel> get notifications => List.unmodifiable(_notifications);

  int get unreadCount => _notifications.where((item) => !item.read).length;

  Future<void> initializeForCurrentCustomer() async {
    final userInfo = _authStorage.getUserInfo();
    final customerId = userInfo?['id']?.toString();
    if (customerId == null || customerId.isEmpty) {
      disconnect();
      return;
    }

    _customerId = customerId;
    _notifications = _notificationStorage.getNotifications(customerId);
    notifyListeners();
    _socketService.connect(customerId);
  }

  Future<void> markAllAsRead() async {
    _notifications = _notifications.map((item) => item.copyWith(read: true)).toList();
    await _persist();
    notifyListeners();
  }

  void disconnect() {
    _socketService.disconnect();
    _customerId = null;
    _notifications = [];
    notifyListeners();
  }

  Future<void> _onNotificationReceived(NotificationPayloadModel notification) async {
    if (_notifications.any((item) => item.eventId == notification.eventId)) {
      return;
    }

    _notifications = [notification, ..._notifications].take(100).toList();
    await _persist();
    notifyListeners();
    _showInAppMessage(notification);
  }

  Future<void> _persist() async {
    final customerId = _customerId;
    if (customerId == null || customerId.isEmpty) {
      return;
    }
    await _notificationStorage.saveNotifications(customerId, _notifications);
  }

  void _showInAppMessage(NotificationPayloadModel notification) {
    final context = navigatorKey.currentContext;
    if (context == null) {
      return;
    }

    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(
        content: Text(notification.title),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Xem',
          onPressed: () {},
        ),
      ),
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _socketService.dispose();
    super.dispose();
  }
}

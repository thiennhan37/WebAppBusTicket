import 'package:bus_ticket_app/core/network/api_client.dart';
import 'package:bus_ticket_app/data/models/notification_payload_model.dart';
import 'package:bus_ticket_app/data/services/local/auth_storage.dart';
import 'package:bus_ticket_app/data/services/local/notification_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../core/constants/api_constants.dart';

class FirebaseMessagingService {
  final ApiClient _apiClient;
  final AuthStorage _authStorage;
  final NotificationStorage _notificationStorage;

  FirebaseMessagingService(
      this._apiClient,
      this._authStorage,
      this._notificationStorage,
      );

  Future<void> initialize() async {
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen(_saveRemoteMessageForCurrentCustomer);
    FirebaseMessaging.onMessageOpenedApp.listen(_saveRemoteMessageForCurrentCustomer);

    FirebaseMessaging.instance.onTokenRefresh.listen((token) async {
      try {
        await registerCurrentDeviceToken(token: token);
      } catch (_) {
        // Token refresh will be retried on the next successful login/app start.
      }
    });
  }

  Future<void> registerCurrentDeviceToken({String? token}) async {
    final userInfo = _authStorage.getUserInfo();
    final customerId = userInfo?['id']?.toString();
    if (customerId == null || customerId.isEmpty) {
      return;
    }

    final fcmToken = token ?? await FirebaseMessaging.instance.getToken();
    if (fcmToken == null || fcmToken.isEmpty) {
      return;
    }

    await _apiClient.post(
      ApiConstants.deviceTokens,
      data: {'token': fcmToken},
    );
  }

  Future<void> _saveRemoteMessageForCurrentCustomer(RemoteMessage message) async {
    final userInfo = _authStorage.getUserInfo();
    final customerId = userInfo?['id']?.toString();
    if (customerId == null || customerId.isEmpty) {
      return;
    }

    final notification = _payloadFromRemoteMessage(message);
    final current = _notificationStorage.getNotifications(customerId);
    if (current.any((item) => item.eventId == notification.eventId)) {
      return;
    }

    await _notificationStorage.saveNotifications(
      customerId,
      [notification, ...current].take(100).toList(),
    );
  }
}

NotificationPayloadModel _payloadFromRemoteMessage(RemoteMessage message) {
  final data = Map<String, dynamic>.from(message.data);
  final nestedData = Map<String, dynamic>.from(data)
    ..remove('eventId')
    ..remove('type')
    ..remove('title')
    ..remove('message')
    ..remove('createdAt')
    ..remove('read');

  return NotificationPayloadModel.fromJson({
    'eventId': data['eventId']?.toString() ?? message.messageId,
    'type': data['type']?.toString() ?? 'GENERAL',
    'title': data['title']?.toString() ?? message.notification?.title ?? 'Thông báo',
    'message': data['message']?.toString() ?? message.notification?.body ?? '',
    'createdAt': data['createdAt']?.toString() ?? DateTime.now().toIso8601String(),
    'data': nestedData,
    'read': false,
  });
}
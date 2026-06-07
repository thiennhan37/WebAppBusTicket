import 'dart:async';
import 'dart:convert';

import 'package:bus_ticket_app/core/constants/api_constants.dart';
import 'package:bus_ticket_app/data/models/notification_payload_model.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

class NotificationSocketService {
  StompClient? _client;
  String? _customerId;
  final _notificationController = StreamController<NotificationPayloadModel>.broadcast();

  Stream<NotificationPayloadModel> get notifications => _notificationController.stream;

  bool get isConnected => _client?.connected == true;

  void connect(String customerId, String? token) {
    if (_customerId == customerId && isConnected) {
      return;
    }

    disconnect();
    _customerId = customerId;
    final url = token != null && token.isNotEmpty
        ? '${ApiConstants.notificationSocketUrl}?token=$token'
        : ApiConstants.notificationSocketUrl;

    _client = StompClient(
      config: StompConfig.sockJS(
        url: url,
        onConnect: _onConnect,
        onWebSocketError: (error) => print('Notification socket error: $error'),
        onStompError: (frame) => print('Notification STOMP error: ${frame.body}'),
        reconnectDelay: const Duration(seconds: 5),
      ),
    );
    _client?.activate();
  }

  void _onConnect(StompFrame frame) {
    final customerId = _customerId;
    if (customerId == null || customerId.isEmpty) {
      return;
    }

    _client?.subscribe(
      destination: '/topic/customers/$customerId',
      callback: _handleFrame,
    );

    _client?.subscribe(
      destination: '/topic/customers',
      callback: _handleFrame,
    );
  }

  void _handleFrame(StompFrame frame) {
    final body = frame.body;
    if (body == null || body.isEmpty) {
      return;
    }

    final json = jsonDecode(body);
    if (json is Map) {
      _notificationController.add(
        NotificationPayloadModel.fromJson(Map<String, dynamic>.from(json)),
      );
    }
  }

  void disconnect() {
    _client?.deactivate();
    _client = null;
    _customerId = null;
  }

  void dispose() {
    disconnect();
    _notificationController.close();
  }
}

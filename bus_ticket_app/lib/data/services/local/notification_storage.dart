import 'dart:convert';

import 'package:bus_ticket_app/core/storage/storage_service.dart';
import 'package:bus_ticket_app/data/models/notification_payload_model.dart';

class NotificationStorage {
  final StorageService _storage;

  NotificationStorage(this._storage);

  String _key(String customerId) => 'notifications_$customerId';

  List<NotificationPayloadModel> getNotifications(String customerId) {
    final data = _storage.readString(_key(customerId));
    if (data == null || data.isEmpty) {
      return [];
    }

    final decoded = jsonDecode(data);
    if (decoded is! List) {
      return [];
    }

    return decoded
        .whereType<Map>()
        .map((item) => NotificationPayloadModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<void> saveNotifications(String customerId, List<NotificationPayloadModel> notifications) async {
    final data = notifications.map((item) => item.toJson()).toList();
    await _storage.writeString(_key(customerId), jsonEncode(data));
  }
}

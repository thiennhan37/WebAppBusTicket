import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationPayloadModel {
  final String eventId;
  final String type;
  final String title;
  final String message;
  final DateTime createdAt;
  final Map<String, dynamic> data;
  final bool read;

  const NotificationPayloadModel({
    required this.eventId,
    required this.type,
    required this.title,
    required this.message,
    required this.createdAt,
    this.data = const {},
    this.read = false,
  });

  factory NotificationPayloadModel.fromJson(Map<String, dynamic> json) {
    return NotificationPayloadModel(
      eventId: json['eventId']?.toString() ?? DateTime.now().microsecondsSinceEpoch.toString(),
      type: json['type']?.toString() ?? 'GENERAL',
      title: json['title']?.toString() ?? 'Thông báo',
      message: json['message']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      data: json['data'] is Map
          ? Map<String, dynamic>.from(json['data'] as Map)
          : const {},
      read: json['read'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'eventId': eventId,
      'type': type,
      'title': title,
      'message': message,
      'createdAt': createdAt.toIso8601String(),
      'data': data,
      'read': read,
    };
  }

  NotificationPayloadModel copyWith({bool? read}) {
    return NotificationPayloadModel(
      eventId: eventId,
      type: type,
      title: title,
      message: message,
      createdAt: createdAt,
      data: data,
      read: read ?? this.read,
    );
  }

  String get displayTime {
    return DateFormat('HH:mm - dd/MM/yyyy').format(createdAt.toLocal());
  }

  IconData get icon {
    switch (type) {
      case 'PAYMENT_SUCCESS':
        return Icons.check_circle;
      case 'TRIP_DEPARTURE_REMINDER':
        return Icons.directions_bus;
      default:
        return Icons.notifications;
    }
  }

  Color get iconColor {
    switch (type) {
      case 'PAYMENT_SUCCESS':
        return const Color(0xFF2E7D32);
      case 'TRIP_DEPARTURE_REMINDER':
        return const Color(0xFF1E88E5);
      default:
        return const Color(0xFFF57C00);
    }
  }

  Color get iconBackgroundColor {
    switch (type) {
      case 'PAYMENT_SUCCESS':
        return const Color(0xFFE8F5E9);
      case 'TRIP_DEPARTURE_REMINDER':
        return const Color(0xFFE3F2FD);
      default:
        return const Color(0xFFFFF3E0);
    }
  }
}

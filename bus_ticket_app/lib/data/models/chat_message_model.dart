class ChatMessageModel {
  final int? id;
  final int conversationId;
  final String? senderId;
  final String? senderRole;
  final String content;
  final DateTime? sentAt;
  final int unreadCustomerCount;
  final int unreadCompanyCount;

  const ChatMessageModel({
    this.id,
    required this.conversationId,
    this.senderId,
    this.senderRole,
    required this.content,
    this.sentAt,
    this.unreadCustomerCount = 0,
    this.unreadCompanyCount = 0,
  });

  bool get isFromCustomer => senderRole?.toUpperCase() == 'CUSTOMER';

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: _readInt(json['id']),
      conversationId: _readInt(json['conversationId']) ?? 0,
      senderId: json['senderId']?.toString(),
      senderRole: json['senderRole']?.toString(),
      content: json['content']?.toString() ?? '',
      sentAt: _parseDateTime(json['sentAt']),
      unreadCustomerCount: _readInt(json['unreadCustomerCount']) ?? 0,
      unreadCompanyCount: _readInt(json['unreadCompanyCount']) ?? 0,
    );
  }

  static int? _readInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }
}

import 'chat_message_model.dart';

class ChatConversationModel {
  final int id;
  final String status;
  final DateTime? createdAt;
  final DateTime? lastMessageAt;
  final String busCompanyId;
  final String busCompanyName;
  final ChatMessageModel? lastMessage;

  const ChatConversationModel({
    required this.id,
    required this.status,
    this.createdAt,
    this.lastMessageAt,
    required this.busCompanyId,
    required this.busCompanyName,
    this.lastMessage,
  });

  int get unreadCount => lastMessage?.unreadCustomerCount ?? 0;

  factory ChatConversationModel.fromJson(Map<String, dynamic> json) {
    final lastMessageJson = json['lastMessage'];
    return ChatConversationModel(
      id: _readInt(json['id']) ?? 0,
      status: json['status']?.toString() ?? 'OPEN',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      lastMessageAt: DateTime.tryParse(json['lastMessageAt']?.toString() ?? ''),
      busCompanyId: json['busCompanyId']?.toString() ?? '',
      busCompanyName: json['busCompanyName']?.toString() ?? 'Nhà xe',
      lastMessage: lastMessageJson is Map<String, dynamic>
          ? ChatMessageModel.fromJson(lastMessageJson)
          : null,
    );
  }

  ChatConversationModel copyWith({
    ChatMessageModel? lastMessage,
    DateTime? lastMessageAt,
    int? unreadCustomerCount,
  }) {
    final updatedLastMessage = lastMessage ??
        (this.lastMessage != null && unreadCustomerCount != null
            ? ChatMessageModel(
                id: this.lastMessage!.id,
                conversationId: this.lastMessage!.conversationId,
                senderId: this.lastMessage!.senderId,
                senderRole: this.lastMessage!.senderRole,
                content: this.lastMessage!.content,
                sentAt: this.lastMessage!.sentAt,
                unreadCustomerCount: unreadCustomerCount,
                unreadCompanyCount: this.lastMessage!.unreadCompanyCount,
              )
            : this.lastMessage);

    return ChatConversationModel(
      id: id,
      status: status,
      createdAt: createdAt,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      busCompanyId: busCompanyId,
      busCompanyName: busCompanyName,
      lastMessage: updatedLastMessage,
    );
  }

  static int? _readInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}

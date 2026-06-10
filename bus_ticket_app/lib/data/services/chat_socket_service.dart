import 'dart:async';
import 'dart:convert';

import 'package:bus_ticket_app/core/constants/api_constants.dart';
import 'package:bus_ticket_app/data/models/chat_message_model.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

enum ChatConnectionStatus { disconnected, connecting, connected, error }

class ChatSocketService {
  StompClient? _client;
  String? _token;

  /// Conversations that should stay subscribed (survives STOMP auto-reconnect).
  final Set<int> _trackedConversationIds = {};
  final Map<int, StompUnsubscribe> _activeSubscriptions = {};

  final _messageController = StreamController<ChatMessageModel>.broadcast();
  final _statusController = StreamController<ChatConnectionStatus>.broadcast();

  Stream<ChatMessageModel> get messages => _messageController.stream;
  Stream<ChatConnectionStatus> get status => _statusController.stream;

  bool get isConnected => _client?.connected == true;

  void connect(String? token) {
    if (token == null || token.isEmpty) {
      _statusController.add(ChatConnectionStatus.error);
      return;
    }

    if (_token == token && isConnected) {
      return;
    }

    disconnect();
    _token = token;

    final socketUrl = '${ApiConstants.chatSocketUrl}?token=${Uri.encodeComponent(token)}';
    _statusController.add(ChatConnectionStatus.connecting);

    _client = StompClient(
      config: StompConfig(
        url: socketUrl.replaceFirst('http', 'ws'),
        onConnect: _onConnect,
        onWebSocketError: (_) => _statusController.add(ChatConnectionStatus.error),
        onStompError: (_) => _statusController.add(ChatConnectionStatus.error),
        onDisconnect: (_) {
          _clearActiveSubscriptions();
          _statusController.add(ChatConnectionStatus.disconnected);
        },
        reconnectDelay: const Duration(seconds: 5),
        heartbeatIncoming: const Duration(seconds: 10),
        heartbeatOutgoing: const Duration(seconds: 10),
      ),
    );
    _client?.activate();
  }

  void _onConnect(StompFrame frame) {
    _statusController.add(ChatConnectionStatus.connected);
    _clearActiveSubscriptions();
    for (final conversationId in _trackedConversationIds) {
      _doSubscribe(conversationId);
    }
  }

  void subscribeToConversation(int conversationId) {
    _trackedConversationIds.add(conversationId);
    if (isConnected && !_activeSubscriptions.containsKey(conversationId)) {
      _doSubscribe(conversationId);
    }
  }

  void unsubscribeFromConversation(int conversationId) {
    _trackedConversationIds.remove(conversationId);
    _activeSubscriptions.remove(conversationId)?.call();
  }

  /// Keep subscriptions in sync with the currently visible conversation list.
  void syncConversationSubscriptions(Set<int> conversationIds) {
    final removed = _trackedConversationIds.difference(conversationIds);
    for (final id in removed) {
      unsubscribeFromConversation(id);
    }
    for (final id in conversationIds) {
      subscribeToConversation(id);
    }
  }

  void _doSubscribe(int conversationId) {
    if (!isConnected || _activeSubscriptions.containsKey(conversationId)) {
      return;
    }

    final unsubscribe = _client?.subscribe(
      destination: '/topic/conversation/$conversationId',
      callback: _handleFrame,
    );
    if (unsubscribe != null) {
      _activeSubscriptions[conversationId] = unsubscribe;
    }
  }

  void _handleFrame(StompFrame frame) {
    final body = frame.body;
    if (body == null || body.isEmpty) {
      return;
    }

    final json = jsonDecode(body);
    if (json is Map) {
      _messageController.add(
        ChatMessageModel.fromJson(Map<String, dynamic>.from(json)),
      );
    }
  }

  void sendMessage(int conversationId, String content) {
    _client?.send(
      destination: '/app/chat.send',
      body: jsonEncode({
        'conversationId': conversationId,
        'content': content,
      }),
    );
  }

  void _clearActiveSubscriptions() {
    for (final unsubscribe in _activeSubscriptions.values) {
      unsubscribe();
    }
    _activeSubscriptions.clear();
  }

  void disconnect() {
    _clearActiveSubscriptions();
    _trackedConversationIds.clear();
    _client?.deactivate();
    _client = null;
    _token = null;
  }

  void dispose() {
    disconnect();
    _messageController.close();
    _statusController.close();
  }
}

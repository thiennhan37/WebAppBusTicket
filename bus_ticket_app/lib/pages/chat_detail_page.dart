import 'dart:async';

import 'package:bus_ticket_app/data/models/chat_message_model.dart';
import 'package:bus_ticket_app/data/repositories/chat_repository.dart';
import 'package:bus_ticket_app/data/services/chat_socket_service.dart';
import 'package:bus_ticket_app/data/services/local/auth_storage.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

class ChatDetailPage extends StatefulWidget {
  final int conversationId;
  final String companyName;

  const ChatDetailPage({
    super.key,
    required this.conversationId,
    required this.companyName,
  });

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final _chatRepository = GetIt.I<ChatRepository>();
  final _socketService = GetIt.I<ChatSocketService>();
  final _authStorage = GetIt.I<AuthStorage>();
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  final List<ChatMessageModel> _messages = [];
  StreamSubscription<ChatMessageModel>? _messageSubscription;
  StreamSubscription<ChatConnectionStatus>? _statusSubscription;

  ChatConnectionStatus _connectionStatus = ChatConnectionStatus.disconnected;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _isSending = false;
  int _currentPage = 0;
  bool _hasMore = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _initChat();
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    _statusSubscription?.cancel();
    _scrollController.dispose();
    _messageController.dispose();
    // _socketService.disconnect();
    super.dispose();
  }

  Future<void> _initChat() async {
    _messageSubscription = _socketService.messages.listen(_onIncomingMessage);
    // Listen for connection status and subscribe when connected so we don't try to
    // subscribe before the socket is ready.
    _statusSubscription = _socketService.status.listen((status) {
      if (mounted) {
        setState(() => _connectionStatus = status);
      }

      if (status == ChatConnectionStatus.connected) {
        // Subscribe to the conversation only when the socket is connected.
        _socketService.subscribeToConversation(widget.conversationId);
      }
    });

    final token = await _authStorage.getAccessToken();
    // Trigger connect. If connect is asynchronous inside the service it will update
    // the status stream which will handle subscribing for us. If it's already
    // connected, the status listener above will also get the connected event and
    // subscribe.
    _socketService.connect(token);

    await _loadMessages(refresh: true);
  }

  void _onIncomingMessage(ChatMessageModel message) {
    if (message.conversationId != widget.conversationId) return;
    if (message.id != null && _messages.any((item) => item.id == message.id)) return;

    final shouldScroll = message.isFromCustomer || _isNearBottom();
    setState(() => _messages.add(message));
    if (shouldScroll) {
      _scrollToBottom();
    }
  }

  bool _isNearBottom() {
    if (!_scrollController.hasClients) return true;
    final position = _scrollController.position;
    if (!position.hasContentDimensions) return true;
    return position.maxScrollExtent - position.pixels <= 120;
  }

  Future<void> _loadMessages({bool refresh = true}) async {
    if (!refresh) {
      if (_isLoadingMore || !_hasMore) return;
      _isLoadingMore = true;
      if (mounted) setState(() {});
    } else {
      setState(() {
        _isLoading = true;
        _error = null;
        _currentPage = 0;
      });
    }

    final previousScrollExtent = _scrollController.hasClients
        ? _scrollController.position.maxScrollExtent
        : 0.0;
    final previousScrollOffset = _scrollController.hasClients
        ? _scrollController.offset
        : 0.0;

    try {
      final result = await _chatRepository.getMessages(
        conversationId: widget.conversationId,
        page: refresh ? 0 : _currentPage + 1,
      );

      if (!mounted) return;

      setState(() {
        if (refresh) {
          _messages
            ..clear()
            ..addAll(result.content);
        } else {
          final existingIds = _messages.map((item) => item.id).toSet();
          final olderMessages = result.content
              .where((item) => item.id == null || !existingIds.contains(item.id))
              .toList();
          _messages.insertAll(0, olderMessages);
        }
        _currentPage = result.currentPage;
        _hasMore = result.hasMore(loadedCount: _messages.length);
        _isLoading = false;
        _isLoadingMore = false;
      });

      if (refresh) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      } else {
        _restoreScrollAfterPrepend(previousScrollExtent, previousScrollOffset);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  void _restoreScrollAfterPrepend(double previousScrollExtent, double previousScrollOffset) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      final newScrollExtent = _scrollController.position.maxScrollExtent;
      final extentDelta = newScrollExtent - previousScrollExtent;
      if (extentDelta > 0) {
        _scrollController.jumpTo(previousScrollOffset + extentDelta);
      }
    });
  }

  void _onScroll() {
    if (!_hasMore || _isLoadingMore || _isLoading || !_scrollController.hasClients) {
      return;
    }

    final position = _scrollController.position;
    if (!position.hasContentDimensions || position.maxScrollExtent <= 0) {
      return;
    }

    if (position.pixels <= 120) {
      _loadMessages(refresh: false);
    }
  }

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty || _isSending) return;

    setState(() => _isSending = true);
    _messageController.clear();

    try {
      if (_socketService.isConnected) {
        _socketService.sendMessage(widget.conversationId, content);
      } else {
        final message = await _chatRepository.sendMessage(
          conversationId: widget.conversationId,
          content: content,
        );
        _onIncomingMessage(message);
      }
    } catch (e) {
      _messageController.text = content;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _jumpToBottom();
      WidgetsBinding.instance.addPostFrameCallback((_) => _jumpToBottom());
    });
  }

  void _jumpToBottom() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (!position.hasContentDimensions) return;
    position.jumpTo(position.maxScrollExtent);
  }

  Future<void> _reconnect() async {
    final token = await _authStorage.getAccessToken();
    _socketService.connect(token);
    // If already connected immediately, ensure subscription; otherwise the status
    // listener in _initChat will subscribe when connected.
    if (_socketService.isConnected) {
      _socketService.subscribeToConversation(widget.conversationId);
    }
  }

  String _formatTime(DateTime? value) {
    if (value == null) return '';
    return DateFormat('HH:mm dd/MM').format(value);
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.companyName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(
              _statusLabel,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _reconnect,
            icon: const Icon(Icons.refresh),
            tooltip: 'Kết nối lại',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: _buildMessageList(primary)),
          _buildInputBar(primary),
        ],
      ),
    );
  }

  String get _statusLabel {
    switch (_connectionStatus) {
      case ChatConnectionStatus.connected:
        return 'Đang kết nối';
      case ChatConnectionStatus.connecting:
        return 'Đang mở kết nối...';
      case ChatConnectionStatus.error:
        return 'Lỗi kết nối - dùng HTTP gửi tin';
      case ChatConnectionStatus.disconnected:
        return 'Mất kết nối';
    }
  }

  Widget _buildMessageList(Color primary) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null && _messages.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => _loadMessages(),
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    if (_messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.forum_outlined, size: 56, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              'Gửi tin nhắn đầu tiên cho ${widget.companyName}',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: _messages.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == 0) {
          if (_isLoadingMore) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          }
          if (_hasMore) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Center(
                child: Text(
                  'Lướt lên để xem tin nhắn cũ hơn',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ),
            );
          }
        }

        final messageIndex = _hasMore ? index - 1 : index;
        if (messageIndex < 0 || messageIndex >= _messages.length) {
          return const SizedBox.shrink();
        }
        final message = _messages[messageIndex];
        final isMine = message.isFromCustomer;

        return Align(
          alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.78,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isMine ? primary : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isMine ? 16 : 4),
                bottomRight: Radius.circular(isMine ? 4 : 16),
              ),
              border: isMine ? null : Border.all(color: Colors.grey.shade200),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.content,
                  style: TextStyle(
                    color: isMine ? Colors.white : Colors.black87,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTime(message.sentAt),
                  style: TextStyle(
                    fontSize: 11,
                    color: isMine ? Colors.white70 : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInputBar(Color primary) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
                decoration: InputDecoration(
                  hintText: 'Nhập tin nhắn...',
                  filled: true,
                  fillColor: const Color(0xFFF5F7FB),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Material(
              color: primary,
              shape: const CircleBorder(),
              child: IconButton(
                onPressed: _isSending ? null : _sendMessage,
                icon: _isSending
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send_rounded, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

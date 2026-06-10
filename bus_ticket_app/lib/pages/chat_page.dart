import 'package:bus_ticket_app/data/models/chat_conversation_model.dart';
import 'package:bus_ticket_app/data/models/chat_message_model.dart';
import 'package:bus_ticket_app/data/repositories/chat_repository.dart';
import 'package:bus_ticket_app/data/services/chat_socket_service.dart';
import 'package:bus_ticket_app/data/services/local/auth_storage.dart';
import 'package:bus_ticket_app/pages/chat_detail_page.dart';
import 'package:bus_ticket_app/pages/find_company_chat_page.dart';
import 'package:bus_ticket_app/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _chatRepository = GetIt.I<ChatRepository>();
  final _authStorage = GetIt.I<AuthStorage>();
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  final _socketService = GetIt.I<ChatSocketService>();
  StreamSubscription<ChatMessageModel>? _messageSubscription;
  StreamSubscription<ChatConnectionStatus>? _statusSubscription;
  Timer? _searchDebounce;

  List<ChatConversationModel> _conversations = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _error;
  int _currentPage = 0;
  bool _hasMore = false;
  String _appliedCompanyInfo = '';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(() {
      if (mounted) setState(() {});
    });
    _loadConversations();

    _authStorage.getAccessToken().then((token) {
      _socketService.connect(token);
    });

    _messageSubscription = _socketService.messages.listen(_onSocketMessage);

    _statusSubscription = _socketService.status.listen((status) {
      if (status == ChatConnectionStatus.connected) {
        _syncConversationSubscriptions();
      }
    });
  }

  void _syncConversationSubscriptions() {
    final loadedIds = _conversations.map((conv) => conv.id).toSet();
    _socketService.syncConversationSubscriptions(loadedIds);
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _messageSubscription?.cancel();
    _statusSubscription?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      _loadConversations(refresh: true);
    });
  }

  void _clearSearch() {
    _searchDebounce?.cancel();
    _searchController.clear();
    _loadConversations(refresh: true);
  }

  void _onScroll() {
    if (!_hasMore || _isLoadingMore || _isLoading || !_scrollController.hasClients) {
      return;
    }
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 120) {
      _loadConversations(refresh: false);
    }
  }

  Future<void> _loadConversations({bool refresh = true}) async {
    final companyInfo = _searchController.text.trim();

    if (refresh) {
      setState(() {
        _isLoading = true;
        _error = null;
        _currentPage = 0;
      });
    } else {
      if (_isLoadingMore || !_hasMore) return;
      setState(() => _isLoadingMore = true);
    }

    try {
      final result = await _chatRepository.getConversations(
        companyInfo: companyInfo,
        page: refresh ? 0 : _currentPage + 1,
      );

      if (!mounted) return;

      setState(() {
        if (refresh) {
          _conversations = result.content;
          _appliedCompanyInfo = companyInfo;
        } else {
          final existingIds = _conversations.map((item) => item.id).toSet();
          _conversations.addAll(
            result.content.where((item) => !existingIds.contains(item.id)),
          );
        }
        _currentPage = result.currentPage;
        _hasMore = result.hasMore(loadedCount: _conversations.length);
        _isLoading = false;
        _isLoadingMore = false;
      });
      _syncConversationSubscriptions();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  void _openFindCompanyPage() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const FindCompanyChatPage()),
    ).then((_) {
      if (mounted) _loadConversations();
    });
  }

  Future<void> _navigateToChat(ChatConversationModel conversation) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatDetailPage(
          conversationId: conversation.id,
          companyName: conversation.busCompanyName,
        ),
      ),
    ).then((_) {
      if (mounted) _loadConversations();
    });
  }

  String _formatTime(DateTime? value) {
    if (value == null) return '';
    return DateFormat('dd/MM HH:mm').format(value);
  }

  void _onSocketMessage(ChatMessageModel message) {
    if (!mounted) return;

    final idx = _conversations.indexWhere((c) => c.id == message.conversationId);
    if (idx >= 0) {
      final conv = _conversations[idx];

      final unreadCustomerCount = !message.isFromCustomer
          ? (message.unreadCustomerCount > 0
              ? message.unreadCustomerCount
              : conv.unreadCount + 1)
          : conv.unreadCount;

      final updated = conv.copyWith(
        lastMessage: message,
        lastMessageAt: message.sentAt,
        unreadCustomerCount: unreadCustomerCount,
      );

      setState(() {
        _conversations.removeAt(idx);
        _conversations.insert(0, updated);
      });
    } else if (_appliedCompanyInfo.isEmpty) {
      _loadConversations();
    }
  }

  @override
  Widget build(BuildContext context) {
    final userInfo = _authStorage.getUserInfo();
    if (userInfo == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Chat với nhà xe'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, size: 56, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('Vui lòng đăng nhập để chat với nhà xe'),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  );
                },
                child: const Text('Đăng nhập'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text('Chat với nhà xe'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openFindCompanyPage,
        backgroundColor: Theme.of(context).colorScheme.primary,
        icon: const Icon(Icons.add_comment_outlined, color: Colors.white),
        label: const Text('Nhắn tin mới', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Tìm theo tên nhà xe...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _clearSearch,
                      )
                    : IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: () => _loadConversations(),
                      ),
                filled: true,
                fillColor: const Color(0xFFF5F7FB),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (_) {
                _searchDebounce?.cancel();
                _loadConversations(refresh: true);
              },
            ),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null && _conversations.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
              const SizedBox(height: 12),
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => _loadConversations(),
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    if (_conversations.isEmpty) {
      final isSearching = _appliedCompanyInfo.isNotEmpty;
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSearching ? Icons.search_off : Icons.chat_bubble_outline,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                isSearching ? 'Không tìm thấy hội thoại' : 'Chưa có hội thoại nào',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                isSearching
                    ? 'Không có hội thoại nào với nhà xe "$_appliedCompanyInfo"'
                    : 'Bấm "Nhắn tin mới" để bắt đầu trò chuyện với nhà xe',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
              if (isSearching) ...[
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _clearSearch,
                  child: const Text('Xóa bộ lọc'),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadConversations(),
      child: ListView.separated(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: _conversations.length + (_isLoadingMore ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          if (index == _conversations.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          }

          final conversation = _conversations[index];
          return _ConversationTile(
            conversation: conversation,
            timeLabel: _formatTime(conversation.lastMessageAt),
            onTap: () => _navigateToChat(conversation),
          );
        },
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final ChatConversationModel conversation;
  final String timeLabel;
  final VoidCallback onTap;

  const _ConversationTile({
    required this.conversation,
    required this.timeLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final initials = _getInitials(conversation.busCompanyName);
    final preview = conversation.lastMessage?.content ?? 'Bắt đầu trò chuyện';
    final unread = conversation.unreadCount;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: const Color(0xFFE3F2FD),
                child: Text(
                  initials,
                  style: const TextStyle(
                    color: Color(0xFF1E88E5),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            conversation.busCompanyName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (timeLabel.isNotEmpty)
                          Text(
                            timeLabel,
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      preview,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ],
                ),
              ),
              if (unread > 0) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E88E5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$unread',
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'NX';
    final words = name.trim().split(RegExp(r'\s+'));
    return words.take(2).map((word) => word.isNotEmpty ? word[0] : '').join().toUpperCase();
  }
}

import 'dart:async';

import 'package:bus_ticket_app/data/models/company_for_chat_model.dart';
import 'package:bus_ticket_app/data/repositories/chat_repository.dart';
import 'package:bus_ticket_app/pages/chat_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class FindCompanyChatPage extends StatefulWidget {
  const FindCompanyChatPage({super.key});

  @override
  State<FindCompanyChatPage> createState() => _FindCompanyChatPageState();
}

class _FindCompanyChatPageState extends State<FindCompanyChatPage> {
  final _chatRepository = GetIt.I<ChatRepository>();
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  final List<CompanyForChatModel> _companies = [];
  Timer? _debounce;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _isStartingChat = false;
  String? _error;
  int _currentPage = 0;
  bool _hasMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(() {
      if (mounted) setState(() {});
    });
    _loadCompanies();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _loadCompanies(refresh: true);
    });
  }

  void _onScroll() {
    if (!_hasMore || _isLoadingMore || _isLoading || !_scrollController.hasClients) {
      return;
    }
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 120) {
      _loadCompanies(refresh: false);
    }
  }

  Future<void> _loadCompanies({bool refresh = true}) async {
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
      final result = await _chatRepository.searchCompaniesForChat(
        name: _searchController.text.trim(),
        page: refresh ? 0 : _currentPage + 1,
      );

      if (!mounted) return;

      setState(() {
        if (refresh) {
          _companies
            ..clear()
            ..addAll(result.content);
        } else {
          final existingIds = _companies.map((item) => item.id).toSet();
          _companies.addAll(
            result.content.where((item) => !existingIds.contains(item.id)),
          );
        }
        _currentPage = result.currentPage;
        _hasMore = result.hasMore(loadedCount: _companies.length);
        _isLoading = false;
        _isLoadingMore = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _startChat(CompanyForChatModel company) async {
    if (_isStartingChat) return;

    setState(() => _isStartingChat = true);

    try {
      final conversation = await _chatRepository.createOrGetConversation(
        busCompanyId: company.id,
      );
      if (!mounted) return;

      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ChatDetailPage(
            conversationId: conversation.id,
            companyName: conversation.busCompanyName.isNotEmpty
                ? conversation.busCompanyName
                : company.companyName,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) {
        setState(() => _isStartingChat = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text('Tìm nhà xe'),
        backgroundColor: primary,
        foregroundColor: Colors.white,
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
                hintText: 'Nhập tên nhà xe...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _loadCompanies(refresh: true);
                        },
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFFF5F7FB),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (_) => _loadCompanies(refresh: true),
            ),
          ),
          Expanded(child: _buildBody(primary)),
        ],
      ),
    );
  }

  Widget _buildBody(Color primary) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null && _companies.isEmpty) {
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
                onPressed: () => _loadCompanies(),
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    if (_companies.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.directions_bus_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text(
              'Không tìm thấy nhà xe',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Thử tìm với từ khóa khác',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: () => _loadCompanies(),
          child: ListView.separated(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: _companies.length + (_isLoadingMore ? 1 : 0),
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              if (index == _companies.length) {
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

              final company = _companies[index];
              return _CompanyTile(
                company: company,
                primary: primary,
                onTap: _isStartingChat ? null : () => _startChat(company),
              );
            },
          ),
        ),
        if (_isStartingChat)
          Container(
            color: Colors.black26,
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }
}

class _CompanyTile extends StatelessWidget {
  final CompanyForChatModel company;
  final Color primary;
  final VoidCallback? onTap;

  const _CompanyTile({
    required this.company,
    required this.primary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
                child: Icon(Icons.directions_bus, color: primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      company.companyName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (company.hotline != null && company.hotline!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Hotline: ${company.hotline}',
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                      ),
                    ],
                    if (company.email != null && company.email!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        company.email!,
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              Icon(Icons.chat_bubble_outline, color: primary),
            ],
          ),
        ),
      ),
    );
  }
}

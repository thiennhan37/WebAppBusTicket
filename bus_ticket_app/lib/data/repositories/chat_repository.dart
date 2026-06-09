import 'package:bus_ticket_app/data/models/chat_conversation_model.dart';
import 'package:bus_ticket_app/data/models/chat_message_model.dart';
import 'package:bus_ticket_app/data/models/company_for_chat_model.dart';
import 'package:bus_ticket_app/data/models/paginated_chat_result.dart';
import 'package:bus_ticket_app/data/services/chat_api_service.dart';
import 'package:dio/dio.dart';

class ChatRepository {
  final ChatApiService _chatApiService;

  ChatRepository(this._chatApiService);

  Future<PaginatedChatResult<ChatConversationModel>> getConversations({
    String companyInfo = '',
    int page = 0,
    int size = 10,
  }) async {
    try {
      final response = await _chatApiService.getConversations(
        companyInfo: companyInfo,
        page: page,
        size: size,
      );
      return _parsePagedResult(
        response.data,
        (json) => ChatConversationModel.fromJson(json),
        page,
      );
    } on DioException catch (e) {
      throw _mapError(e, 'Không thể tải danh sách hội thoại');
    }
  }

  Future<PaginatedChatResult<ChatMessageModel>> getMessages({
    required int conversationId,
    int page = 0,
    int size = 20,
  }) async {
    try {
      final response = await _chatApiService.getMessages(
        conversationId: conversationId,
        page: page,
        size: size,
      );
      return _parsePagedResult(
        response.data,
        (json) => ChatMessageModel.fromJson(json),
        page,
      );
    } on DioException catch (e) {
      throw _mapError(e, 'Không thể tải tin nhắn');
    }
  }

  Future<PaginatedChatResult<CompanyForChatModel>> searchCompaniesForChat({
    String name = '',
    int page = 0,
    int size = 10,
  }) async {
    try {
      final response = await _chatApiService.searchCompaniesForChat(
        name: name,
        page: page,
        size: size,
      );
      return _parsePagedResult(
        response.data,
        (json) => CompanyForChatModel.fromJson(json),
        page,
      );
    } on DioException catch (e) {
      throw _mapError(e, 'Không thể tìm nhà xe');
    }
  }

  Future<ChatConversationModel> createOrGetConversation({
    required String busCompanyId,
  }) async {
    try {
      final response = await _chatApiService.createOrGetConversation(
        busCompanyId: busCompanyId,
      );
      final result = response.data['result'] ?? response.data['data'];
      if (result is Map<String, dynamic>) {
        return ChatConversationModel.fromJson(result);
      }
      throw Exception('Phản hồi không hợp lệ từ máy chủ');
    } on DioException catch (e) {
      throw _mapError(e, 'Không thể tạo hội thoại');
    }
  }

  Future<ChatMessageModel> sendMessage({
    required int conversationId,
    required String content,
  }) async {
    try {
      final response = await _chatApiService.sendMessage(
        conversationId: conversationId,
        content: content,
      );
      final result = response.data['result'] ?? response.data['data'];
      if (result is Map<String, dynamic>) {
        return ChatMessageModel.fromJson(result);
      }
      throw Exception('Phản hồi không hợp lệ từ máy chủ');
    } on DioException catch (e) {
      throw _mapError(e, 'Không thể gửi tin nhắn');
    }
  }

  PaginatedChatResult<T> _parsePagedResult<T>(
    dynamic data,
    T Function(Map<String, dynamic>) mapper,
    int fallbackPage,
  ) {
    final result = data is Map ? (data['result'] ?? data['data'] ?? data) : data;
    final content = _extractContent(result);
    final resultMap = result is Map<String, dynamic> ? result : null;
    final pageInfo = resultMap?['page'] as Map<String, dynamic>?;

    final currentPage = _readInt(pageInfo?['number']) ??
        _readInt(resultMap?['number']) ??
        fallbackPage;
    final totalPages = _readInt(pageInfo?['totalPages']) ??
        _readInt(resultMap?['totalPages']);
    final totalElements = _readInt(pageInfo?['totalElements']) ??
        _readInt(resultMap?['totalElements']);
    final pageSize = _readInt(pageInfo?['size']) ??
        _readInt(resultMap?['size']) ??
        content.length;

    return PaginatedChatResult<T>(
      content: content.map((item) => mapper(Map<String, dynamic>.from(item))).toList(),
      currentPage: currentPage,
      totalPages: totalPages,
      totalElements: totalElements,
      pageSize: pageSize > 0 ? pageSize : 10,
    );
  }

  List<dynamic> _extractContent(dynamic result) {
    if (result is List) return result;
    if (result is Map<String, dynamic>) {
      final content = result['content'];
      if (content is List) return content;
    }
    return [];
  }

  int? _readInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  Exception _mapError(DioException e, String fallback) {
    if (e.response != null) {
      final message = e.response?.data['message'] ?? fallback;
      return Exception(message);
    }
    return Exception('Lỗi kết nối mạng: ${e.message}');
  }
}

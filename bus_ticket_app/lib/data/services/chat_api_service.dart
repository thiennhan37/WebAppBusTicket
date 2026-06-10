import 'package:bus_ticket_app/core/constants/api_constants.dart';
import 'package:bus_ticket_app/core/network/api_client.dart';
import 'package:dio/dio.dart';

class ChatApiService {
  final ApiClient _apiClient;

  ChatApiService(this._apiClient);

  Future<Response> getConversations({
    String companyInfo = '',
    int page = 0,
    int size = 10,
  }) {
    return _apiClient.get(
      ApiConstants.chatConversations,
      queryParameters: {
        if (companyInfo.isNotEmpty) 'companyInfo': companyInfo,
        'page': page,
        'size': size,
      },
    );
  }

  Future<Response> getMessages({
    required int conversationId,
    int page = 0,
    int size = 20,
  }) {
    return _apiClient.get(
      '${ApiConstants.chatConversations}/$conversationId/messages',
      queryParameters: {
        'page': page,
        'size': size,
      },
    );
  }

  Future<Response> createOrGetConversation({required String busCompanyId}) {
    return _apiClient.post(
      ApiConstants.chatConversations,
      data: {'busCompanyId': busCompanyId},
    );
  }

  Future<Response> sendMessage({
    required int conversationId,
    required String content,
  }) {
    return _apiClient.post(
      ApiConstants.chatMessages,
      data: {
        'conversationId': conversationId,
        'content': content,
      },
    );
  }

  Future<Response> searchCompaniesForChat({
    String name = '',
    int page = 0,
    int size = 10,
  }) {
    return _apiClient.get(
      ApiConstants.companiesForChat,
      queryParameters: {
        if (name.isNotEmpty) 'name': name,
        'page': page,
        'size': size,
      },
    );
  }
}

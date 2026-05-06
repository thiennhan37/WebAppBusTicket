import 'package:bus_ticket_app/pages/login_page.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../data/services/storage_service.dart';
import '../constants/api_constants.dart';
import '../../global_varible.dart';

class ApiClient {
  late Dio dio;
  final StorageService _storageService;

  ApiClient(this._storageService) {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    dio.interceptors.add(
      QueuedInterceptorsWrapper(
        // 1. Gắn Access Token trước khi gửi Request

        onRequest: (options, handler) async {
          final bool requiresToken = options.extra['requiresToken'] ?? true;
          if (requiresToken) {
            String? accessToken = await _storageService.getAccessToken();
            if (accessToken != null && accessToken.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $accessToken';
            }
          }
          return handler.next(options);
        },

        onError: (DioException error, handler) async {
          if (error.response?.statusCode == 401) {
            bool isRefreshed = await _refreshToken();
            if (isRefreshed) {
              String? newAccessToken = await _storageService.getAccessToken();
              final options = error.requestOptions;
              options.headers['Authorization'] = 'Bearer $newAccessToken';
              try {
                // Gửi lại chính request bị lỗi đó với token mới
                final response = await dio.fetch(options);
                return handler.resolve(response);
              } on DioException catch (retryError) {
                return handler.next(retryError);
              }
            } else {
              // Refresh Token thất bại (có thể do Refresh Token cũng đã hết hạn)
              // -> Đăng xuất người dùng, xóa dữ liệu storage và đẩy về màn Login
              await _forceLogout();
              return handler.next(error);
            }
          }
          return handler.next(error);
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          print("========== REQUEST ==========");
          print("URL: ${options.method} ${options.uri}");

          if (options.headers.isNotEmpty) {
            print("Headers:");
            options.headers.forEach((k, v) => print("$k: $v"));
          }

          if (options.queryParameters.isNotEmpty) {
            print("Query Params:");
            print(options.queryParameters);
          }

          if (options.data != null) {
            print("Body (DTO):");
            print(options.data);
          }

          print("=============================");

          return handler.next(options);
        },
      ),
    );
  }

  Future<bool> _refreshToken() async {
    try {
      // Lấy Refresh Token từ Local Storage
      String? refreshToken = await _storageService.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        return false;
      }

      final tokenDio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));

      final response = await tokenDio.post(
        ApiConstants.refreshToken,
        options: Options(
          headers: {
            "Cookie": "refreshToken=$refreshToken",
          },
        )
      );

      if (response.statusCode == 200) {
        final newAccessToken = response.data['accessToken'];
        final newRefreshToken = response.data['refreshToken'];

        await _storageService.saveTokens(newAccessToken, newRefreshToken);

        return true;
      }
      return false;
    } catch (e) {
      print('Lỗi khi Refresh Token: $e');
      return false;
    }
  }

  Future<void> _forceLogout() async {
    await _storageService.clearTokens();
    Fluttertoast.showToast(
      msg: "Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
    navigatorKey.currentState?.pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }


  Future<Response> get(String path, {Options? options}) async {
    return await dio.get(path, options: options);
  }

  Future<Response> post(String path, {dynamic data, Options? options}) async {
    return await dio.post(path, data: data, options: options);
  }

  Future<Response> put(String path, {dynamic data, Options? options}) async {
    return await dio.put(path, data: data, options: options);
  }

  Future<Response> delete(String path, {Options? options}) async {
    return await dio.delete(path, options: options);
  }
}

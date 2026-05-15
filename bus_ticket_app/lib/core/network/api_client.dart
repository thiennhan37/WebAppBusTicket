import 'package:bus_ticket_app/data/services/local/auth_storage.dart';
import 'package:bus_ticket_app/pages/login_page.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../constants/api_constants.dart';
import '../../global_varible.dart';

class ApiClient {
  late Dio dio;
  final AuthStorage _authStorage;

  ApiClient(this._authStorage) {
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
            String? accessToken = await _authStorage.getAccessToken();
            if (accessToken != null && accessToken.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $accessToken';
            }
          }
          return handler.next(options);
        },

        onError: (DioException error, handler) async {
          if (error.response?.statusCode == 401) {
            bool isRefreshed = await refreshToken();
            if (isRefreshed) {
              String? newAccessToken = await _authStorage.getAccessToken();
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
        }
        ,
        onResponse: (response, handler) {
          print("========== RESPONSE ==========");
          print("Status Code: ${response.statusCode}");
          print("URL: ${response.requestOptions.method} ${response.requestOptions.uri}");

          if (!response.headers.isEmpty) {
            print("Headers:");
            response.headers.forEach((k, v) => print("$k: $v"));
          }

          if (response.data != null) {
            print("Response Data:");
            print(response.data);
          }

          print("==============================");

          return handler.next(response);
        },
        onError: (DioException error, handler) {
          print("========== ERROR ==========");
          print("Error Type: ${error.type}");
          print("Status Code: ${error.response?.statusCode}");
          print("URL: ${error.requestOptions.method} ${error.requestOptions.uri}");
          print("Error Message: ${error.message}");

          if (error.response?.data != null) {
            print("Error Response Data:");
            print(error.response?.data);
          }

          print("===========================");

          return handler.next(error);
        },
      ),
    );

  }

  Future<bool> refreshToken() async {
    try {
      // Lấy Refresh Token từ Local Storage
      String? refreshToken = await _authStorage.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        return false;
      }
      print(refreshToken);
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
        final newAccessToken = response.data['result']['accessToken'];
        final newRefreshToken = response.data['result']['refreshToken'];
        print("accesstoken: ${newAccessToken}");
        await _authStorage.saveTokens(newAccessToken, newRefreshToken);
        return true;
      }
      return false;
    } catch (e) {
      print('Lỗi khi Refresh Token: $e');
      return false;
    }
  }

  Future<void> _forceLogout() async {
    await _authStorage.clearTokens();
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


  Future<Response> get(
      String path, {
        Map<String, dynamic>? queryParameters,
        bool requiresToken = true,
        Options? options,
      }) async {
    return await dio.get(
      path,
      queryParameters: queryParameters,
      options: (options ?? Options()).copyWith(
        extra: {
          'requiresToken': requiresToken,
        },
      ),
    );
  }

  Future<Response> post(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        bool requiresToken = true,
        Options? options,
      }) async {
    return await dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: (options ?? Options()).copyWith(
        extra: {
          'requiresToken': requiresToken,
        },
      ),
    );
  }

  Future<Response> put(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        bool requiresToken = true,
        Options? options,
      }) async {
    return await dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
      options: (options ?? Options()).copyWith(
        extra: {
          'requiresToken': requiresToken,
        },
      ),
    );
  }

  Future<Response> delete(
      String path, {
        Map<String, dynamic>? queryParameters,
        dynamic data,
        bool requiresToken = true,
        Options? options,
      }) async {
    return await dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
      options: (options ?? Options()).copyWith(
        extra: {
          'requiresToken': requiresToken,
        },
      ),
    );
  }
}

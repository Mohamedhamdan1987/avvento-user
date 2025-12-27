import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../constants/api_constants.dart';

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      print('REQUEST[${options.method}] => PATH: ${options.path}');
      if (options.queryParameters.isNotEmpty) {
        print('QueryParameters: ${options.queryParameters}');
      }
      if (options.data != null) {
        print('Data: ${options.data}');
      }
      if (options.headers.containsKey(ApiConstants.authorizationHeader)) {
        print('Headers: ${options.headers[ApiConstants.authorizationHeader]}');
      }
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      print(
        'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}',
      );
      print('Data: ${response.data}');
    }
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      print(
        'ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}',
      );
      print('Error: ${err.message}');
      if (err.response != null) {
        print('Response: ${err.response?.data}');
      }
    }
    super.onError(err, handler);
  }
}

class AuthInterceptor extends Interceptor {
  final String? Function()? getToken;

  AuthInterceptor({this.getToken});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = getToken?.call();
    if (token != null && token.isNotEmpty) {
      options.headers[ApiConstants.authorizationHeader] =
          '${ApiConstants.bearerPrefix}$token';
    }
    super.onRequest(options, handler);
  }
}


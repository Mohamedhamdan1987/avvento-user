import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';

class ConnectivityInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final connectivityResult = await Connectivity().checkConnectivity();
    
    if (connectivityResult.contains(ConnectivityResult.none)) {
      return _reject(options, handler, 'No network connection');
    }

    // Even if connected to Wifi/Mobile, verify actual internet reachability
    try {
      final result = await InternetAddress.lookup('google.com').timeout(const Duration(seconds: 3));
      if (result.isEmpty || result[0].rawAddress.isEmpty) {
        return _reject(options, handler, 'No internet access');
      }
    } catch (_) {
      return _reject(options, handler, 'No internet access');
    }

    return handler.next(options);
  }

  void _reject(RequestOptions options, RequestInterceptorHandler handler, String message) {
    return handler.reject(
      DioException(
        requestOptions: options,
        error: message,
        type: DioExceptionType.connectionError,
      ),
    );
  }
}

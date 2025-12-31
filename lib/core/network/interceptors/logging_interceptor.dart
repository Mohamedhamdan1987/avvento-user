import 'package:dio/dio.dart';
import '../../utils/logger.dart';

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    AppLogger.debug(
      'REQUEST[${options.method}] => PATH: ${options.path}',
      'Dio',
    );
    AppLogger.debug(
      'Headers: ${options.headers}',
      'Dio',
    );
    if (options.data != null) {
      AppLogger.debug(
        'Data: ${options.data}',
        'Dio',
      );
    }
    if (options.queryParameters.isNotEmpty) {
      AppLogger.debug(
        'QueryParameters: ${options.queryParameters}',
        'Dio',
      );
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    AppLogger.debug(
      'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}',
      'Dio',
    );
    AppLogger.debug(
      'Data: ${response.data}',
      'Dio',
    );
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final statusCode = err.response?.statusCode;
    
    // 400 and 404 are expected validation errors, log as debug not error
    if (statusCode == 400 || statusCode == 404) {
      AppLogger.debug(
        'RESPONSE[${statusCode}] => PATH: ${err.requestOptions.path}',
        'Dio',
      );
      if (err.response?.data != null) {
        AppLogger.debug(
          'Response Data: ${err.response?.data}',
          'Dio',
        );
      }
    } else {
      // Real errors (500, network issues, etc.) should be logged as errors
      AppLogger.error(
        'ERROR[${statusCode}] => PATH: ${err.requestOptions.path}',
        err,
        err.stackTrace,
        'Dio',
      );
      if (err.response?.data != null) {
        AppLogger.debug(
          'Error Data: ${err.response?.data}',
          'Dio',
        );
      }
    }
    super.onError(err, handler);
  }
}


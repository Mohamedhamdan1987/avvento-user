import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import 'failures.dart';

class ApiException {
  static Failure handleException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutFailure(
          AppConstants.timeoutErrorMessage,
          code: 'TIMEOUT',
        );

      case DioExceptionType.badResponse:
        return _handleResponseError(error.response);

      case DioExceptionType.cancel:
        return NetworkFailure(
          'تم إلغاء الطلب',
          code: 'CANCELLED',
        );

      case DioExceptionType.connectionError:
        final errorMsg = error.error.toString();
        if (errorMsg.contains('No network connection') || 
            errorMsg.contains('No internet access')) {
          return NetworkFailure(
            AppConstants.networkErrorMessage,
            code: 'NO_INTERNET',
          );
        }
        if (error.message?.contains('Connection refused') == true || 
            errorMsg.contains('Connection refused')) {
          return ServerFailure(
            'لا يمكن الاتصال بالسيرفر، تأكد من تشغيل السيرفر المحلي',
            code: 'CONNECTION_REFUSED',
          );
        }
        return NetworkFailure(
          AppConstants.networkErrorMessage,
          code: 'CONNECTION_ERROR',
        );

      case DioExceptionType.badCertificate:
        return NetworkFailure(
          'خطأ في شهادة الاتصال',
          code: 'BAD_CERTIFICATE',
        );

      case DioExceptionType.unknown:
        if (error.message?.contains('SocketException') == true ||
            error.message?.contains('Network is unreachable') == true) {
          return NetworkFailure(
            AppConstants.networkErrorMessage,
            code: 'NO_INTERNET',
          );
        }
        return UnknownFailure(
          error.message ?? AppConstants.unknownErrorMessage,
          code: 'UNKNOWN',
        );
    }
  }

  static Failure _handleResponseError(Response? response) {
    if (response == null) {
      return UnknownFailure(
        AppConstants.unknownErrorMessage,
        code: 'NULL_RESPONSE',
      );
    }

    final statusCode = response.statusCode;
    final data = response.data;

    String message = AppConstants.serverErrorMessage;
    String code = statusCode.toString();

    // Try to extract error message from response
    if (data is Map<String, dynamic>) {
      message = data['message'] as String? ??
          data['error'] as String? ??
          data['errors']?.toString() ??
          message;
      code = data['code'] as String? ?? statusCode.toString();
    } else if (data is String) {
      message = data;
    }

    switch (statusCode) {
      case 400:
        return ValidationFailure(
          message,
          code: code,
        );
      case 401:
        return UnauthorizedFailure(
          message,
          code: code,
        );
      case 403:
        return UnauthorizedFailure(
          'غير مصرح لك بالوصول إلى هذا المورد',
          code: code,
        );
      case 404:
        return NotFoundFailure(
          'المورد المطلوب غير موجود',
          code: code,
        );
      case 422:
        return ValidationFailure(
          message,
          code: code,
        );
      case 500:
      case 502:
      case 503:
      case 504:
        return ServerFailure(
          AppConstants.serverErrorMessage,
          code: code,
        );
      default:
        return ServerFailure(
          message,
          code: code,
        );
    }
  }
}


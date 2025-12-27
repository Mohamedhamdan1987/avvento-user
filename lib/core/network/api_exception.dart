import 'package:dio/dio.dart';
import '../error/exceptions.dart';

class ApiException {
  ApiException._();

  static Exception handleDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException('انتهت مهلة الاتصال. يرجى المحاولة مرة أخرى');

      case DioExceptionType.badResponse:
        return _handleResponseError(error.response);

      case DioExceptionType.cancel:
        return NetworkException('تم إلغاء الطلب');

      case DioExceptionType.badCertificate:
        return NetworkException('شهادة SSL غير صالحة');

      case DioExceptionType.connectionError:
        return NetworkException('خطأ في الاتصال. يرجى التحقق من الاتصال بالإنترنت');

      case DioExceptionType.unknown:
        return NetworkException('حدث خطأ غير متوقع');
    }
  }

  static Exception _handleResponseError(Response? response) {
    if (response == null) {
      return ServerException(message: 'لا توجد استجابة من الخادم');
    }

    final statusCode = response.statusCode;
    final data = response.data;

    String message = 'حدث خطأ في الخادم';
    Map<String, dynamic>? errors;

    if (data is Map<String, dynamic>) {
      message = data['message'] as String? ?? 
                data['error'] as String? ?? 
                message;
      errors = data['errors'] as Map<String, dynamic>?;
    } else if (data is String) {
      message = data;
    }

    switch (statusCode) {
      case 400:
        return ValidationException(message: message, errors: errors);
      case 401:
        return UnauthorizedException(message: message);
      case 403:
        return UnauthorizedException(message: 'غير مصرح به');
      case 404:
        return NotFoundException(message: message);
      case 500:
      case 502:
      case 503:
        return ServerException(
          message: 'خطأ في الخادم. يرجى المحاولة لاحقاً',
          statusCode: statusCode,
          data: data,
        );
      default:
        return ServerException(
          message: message,
          statusCode: statusCode,
          data: data,
        );
    }
  }
}


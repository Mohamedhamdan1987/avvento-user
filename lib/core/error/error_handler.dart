import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import '../utils/show_snackbar.dart';
import 'api_exception.dart';
import 'failures.dart';
import '../utils/logger.dart';

class ErrorHandler {
  static void handleError(Failure failure) {
    AppLogger.error('Error occurred', failure, null, 'ErrorHandler');

    final userMessage = getErrorMessage(failure);

    showSnackBar(
      title: 'خطأ',
      message: userMessage,
    );
  }

  static Failure handleDioError(DioException error) {
    return ApiException.handleException(error);
  }

  static String getErrorMessage(Failure failure) {
    if (failure is NetworkFailure) {
      return 'تحقق من اتصالك بالإنترنت';
    } else if (failure is TimeoutFailure) {
      return 'انتهت مهلة الاتصال، يرجى المحاولة مرة أخرى';
    } else if (failure is ServerFailure) {
      return 'حدث خطأ في الخادم، يرجى المحاولة لاحقاً';
    } else if (failure is UnauthorizedFailure) {
      if (failure.message == 'Invalid credentials') {
        return AppConstants.invalidCredentialsErrorMessage;
      }
      return 'غير مصرح لك بالوصول';
    } else if (failure is NotFoundFailure) {
      return 'المورد المطلوب غير موجود';
    } else if (failure is ValidationFailure) {
      return 'يرجى التحقق من البيانات المدخلة';
    }
    return 'حدث خطأ غير متوقع، يرجى المحاولة مرة أخرى';
  }
}


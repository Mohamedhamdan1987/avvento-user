import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../constants/app_constants.dart';
import '../utils/show_snackbar.dart';
import 'api_exception.dart';
import 'failures.dart';
import '../utils/logger.dart';

class ErrorHandler {
  static void handleError(Failure failure) {
    AppLogger.error('Error occurred', failure, null, 'ErrorHandler');

    String userMessage = failure.message;

    // Customize user-friendly messages based on failure type
    if (failure is NetworkFailure) {
      userMessage = 'تحقق من اتصالك بالإنترنت';
    } else if (failure is TimeoutFailure) {
      userMessage = 'انتهت مهلة الاتصال، يرجى المحاولة مرة أخرى';
    } else if (failure is ServerFailure) {
      userMessage = 'حدث خطأ في الخادم، يرجى المحاولة لاحقاً';
    } else if (failure is UnauthorizedFailure) {
      if (failure.message == 'Invalid credentials') {
        userMessage = AppConstants.invalidCredentialsErrorMessage;
      } else {
        userMessage = failure.message.isNotEmpty 
            ? failure.message 
            : 'غير مصرح لك بالوصول';
      }
      // Optionally handle logout here
      // Get.find<AuthController>().logout();
    } else if (failure is ValidationFailure) {
      // Use the actual validation message
      userMessage = failure.message;
    }

    // Show error message to user
    showSnackBar(
      title: 'خطأ', message:  userMessage,
      // 
      // duration: const Duration(seconds: 3),
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
      return failure.message.isNotEmpty 
          ? failure.message 
          : 'غير مصرح لك بالوصول';
    } else if (failure is NotFoundFailure) {
      return 'المورد المطلوب غير موجود';
    } else if (failure is ValidationFailure) {
      return failure.message;
    }
    return failure.message;
  }
}


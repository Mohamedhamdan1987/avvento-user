import 'exceptions.dart';
import 'failures.dart';

class ErrorHandler {
  ErrorHandler._();

  static Failure handleException(Exception exception) {
    if (exception is ServerException) {
      return ServerFailure(exception.message);
    } else if (exception is CacheException) {
      return CacheFailure(exception.message);
    } else if (exception is NetworkException) {
      return NetworkFailure(exception.message);
    } else if (exception is UnauthorizedException) {
      return UnauthorizedFailure(exception.message);
    } else if (exception is NotFoundException) {
      return NotFoundFailure(exception.message);
    } else if (exception is ValidationException) {
      return ValidationFailure(exception.message);
    } else {
      return UnknownFailure('حدث خطأ غير متوقع');
    }
  }

  static String getFailureMessage(Failure failure) {
    return failure.message;
  }

  static String getErrorMessage(Exception exception) {
    final failure = handleException(exception);
    return getFailureMessage(failure);
  }
}


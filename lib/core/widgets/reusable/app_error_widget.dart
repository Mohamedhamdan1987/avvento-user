import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../constants/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../error/failures.dart';

enum ErrorType { server, network, timeout, notFound, unauthorized, unknown }

class AppErrorWidget extends StatefulWidget {
  final String? title;
  final String? message;
  final VoidCallback? onRetry;
  final ErrorType errorType;
  final Failure? failure;
  final double? iconSize;

  const AppErrorWidget({
    super.key,
    this.title,
    this.message,
    this.onRetry,
    this.errorType = ErrorType.server,
    this.failure,
    this.iconSize,
  });

  factory AppErrorWidget.fromFailure({
    Key? key,
    required Failure failure,
    VoidCallback? onRetry,
    double? iconSize,
  }) {
    return AppErrorWidget(
      key: key,
      failure: failure,
      errorType: _mapFailureToType(failure),
      onRetry: onRetry,
      iconSize: iconSize,
    );
  }

  static ErrorType _mapFailureToType(Failure failure) {
    if (failure is NetworkFailure) return ErrorType.network;
    if (failure is TimeoutFailure) return ErrorType.timeout;
    if (failure is ServerFailure) return ErrorType.server;
    if (failure is NotFoundFailure) return ErrorType.notFound;
    if (failure is UnauthorizedFailure) return ErrorType.unauthorized;
    return ErrorType.unknown;
  }

  @override
  State<AppErrorWidget> createState() => _AppErrorWidgetState();
}

class _AppErrorWidgetState extends State<AppErrorWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isLight = theme.brightness == Brightness.light;
    final errorConfig = _getErrorConfig();

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 24.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: (widget.iconSize ?? 100).w,
                  height: (widget.iconSize ?? 100).w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        errorConfig.color.withOpacity(0.12),
                        errorConfig.color.withOpacity(0.05),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      errorConfig.icon,
                      size: (widget.iconSize ?? 100).w * 0.48,
                      color: errorConfig.color,
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                Text(
                  widget.title ?? errorConfig.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle().textColorBold(
                    fontSize: 20.sp,
                    color: isLight ? AppColors.textDark : Colors.white,
                  ),
                ),
                SizedBox(height: 8.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Text(
                    widget.message ?? errorConfig.message,
                    textAlign: TextAlign.center,
                    style: const TextStyle().textColorMedium(
                      fontSize: 14.sp,
                      color: isLight ? AppColors.textLight : Colors.grey[400],
                    ),
                  ),
                ),
                if (widget.onRetry != null) ...[
                  SizedBox(height: 32.h),
                  _RetryButton(
                    onTap: widget.onRetry!,
                    isLight: isLight,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  _ErrorConfig _getErrorConfig() {
    switch (widget.errorType) {
      case ErrorType.network:
        return _ErrorConfig(
          icon: Icons.wifi_off_rounded,
          title: 'لا يوجد اتصال بالإنترنت',
          message: 'تحقق من اتصالك بالشبكة وحاول مرة أخرى',
          color: AppColors.warning,
        );
      case ErrorType.timeout:
        return _ErrorConfig(
          icon: Icons.timer_off_rounded,
          title: 'انتهت مهلة الاتصال',
          message: 'الخادم يستغرق وقتاً أطول من المتوقع، حاول مرة أخرى',
          color: AppColors.warning,
        );
      case ErrorType.server:
        return _ErrorConfig(
          icon: Icons.cloud_off_rounded,
          title: 'خطأ في الخادم',
          message: 'نواجه مشكلة مؤقتة، يرجى المحاولة لاحقاً',
          color: AppColors.error,
        );
      case ErrorType.notFound:
        return _ErrorConfig(
          icon: Icons.search_off_rounded,
          title: 'غير موجود',
          message: 'لم نتمكن من العثور على ما تبحث عنه',
          color: AppColors.info,
        );
      case ErrorType.unauthorized:
        return _ErrorConfig(
          icon: Icons.lock_outline_rounded,
          title: 'غير مصرح',
          message: 'يرجى تسجيل الدخول مرة أخرى',
          color: AppColors.purpleDark,
        );
      case ErrorType.unknown:
        return _ErrorConfig(
          icon: Icons.error_outline_rounded,
          title: 'حدث خطأ غير متوقع',
          message: 'حدث خطأ ما، يرجى المحاولة مرة أخرى',
          color: AppColors.error,
        );
    }
  }
}

class _RetryButton extends StatefulWidget {
  final VoidCallback onTap;
  final bool isLight;

  const _RetryButton({required this.onTap, required this.isLight});

  @override
  State<_RetryButton> createState() => _RetryButtonState();
}

class _RetryButtonState extends State<_RetryButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;
  bool _isRetrying = false;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (_isRetrying) return;
    setState(() => _isRetrying = true);
    _rotationController.forward(from: 0).then((_) {
      setState(() => _isRetrying = false);
    });
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _handleTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 14.h),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.purple, AppColors.purpleDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.purple.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              RotationTransition(
                turns: _rotationController,
                child: Icon(
                  Icons.refresh_rounded,
                  color: Colors.white,
                  size: 20.w,
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                'إعادة المحاولة',
                style: const TextStyle().textColorBold(
                  fontSize: 15.sp,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorConfig {
  final IconData icon;
  final String title;
  final String message;
  final Color color;

  const _ErrorConfig({
    required this.icon,
    required this.title,
    required this.message,
    required this.color,
  });
}

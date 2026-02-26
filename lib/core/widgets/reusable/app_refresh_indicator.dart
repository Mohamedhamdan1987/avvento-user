import 'dart:async';

import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:vibration/vibration.dart';

import '../../constants/app_colors.dart';

/// A shared pull-to-refresh widget with the Avvento branded experience:
/// - Logo in a purple circle slides down from the top
/// - Progress ring shows pull progress / loading spinner
///
/// Optionally exposes the refresh progress (0..~1.5) via [onProgressChanged]
/// so the parent can react (e.g. zoom a cover image).
///
/// Usage:
/// ```dart
/// AppRefreshIndicator(
///   onRefresh: () async { await controller.refreshData(); },
///   child: SingleChildScrollView(...),
/// )
/// ```
class AppRefreshIndicator extends StatelessWidget {
  /// Called when the user completes the pull gesture.
  final Future<void> Function() onRefresh;

  /// The scrollable child.
  final Widget child;

  /// Optional callback that streams the current pull progress (0 → ~1.5).
  /// Use this to drive effects like cover-image zoom.
  final ValueChanged<double>? onProgressChanged;

  /// Distance the user must drag before the refresh is armed.
  final double offsetToArmed;

  const AppRefreshIndicator({
    super.key,
    required this.onRefresh,
    required this.child,
    this.onProgressChanged,
    this.offsetToArmed = 140.0,
  });

  Future<void> _vibratePulse({required int durationMs}) async {
    final bool hasSupport = await Vibration.hasVibrator();
    if (!hasSupport) return;
    await Vibration.vibrate(duration: durationMs);
  }

  @override
  Widget build(BuildContext context) {
    return CustomRefreshIndicator(
      onRefresh: () async {
        await _vibratePulse(durationMs: 60);
        await onRefresh();
      },
      onStateChanged: (IndicatorStateChange change) {
        // Fire haptics exactly on refresh threshold crossing and loading start.
        if (change.didChange(to: IndicatorState.armed)) {
          unawaited(_vibratePulse(durationMs: 40));
        } else if (change.didChange(to: IndicatorState.loading)) {
          unawaited(_vibratePulse(durationMs: 70));
        }
      },
      offsetToArmed: offsetToArmed,
      builder: (BuildContext context, Widget child, IndicatorController controller) {
        return AnimatedBuilder(
          animation: controller,
          builder: (BuildContext context, _) {
            final double progress = controller.value.clamp(0.0, 1.5);

            // Notify parent of progress changes (e.g. for cover zoom)
            if (onProgressChanged != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                onProgressChanged!(progress);
              });
            }

            return Stack(
              children: [
                // Page content — stays in place, no shift
                child,
                // Logo overlay sliding down from top
                if (progress > 0.0)
                  _LogoOverlay(
                    progress: progress,
                    isLoading: controller.isLoading,
                  ),
              ],
            );
          },
        );
      },
      child: child,
    );
  }
}

/// The animated logo circle that appears during pull-to-refresh.
class _LogoOverlay extends StatelessWidget {
  final double progress;
  final bool isLoading;

  const _LogoOverlay({
    required this.progress,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(top: 10.h),
          child: Align(
            alignment: Alignment.topCenter,
            child: Opacity(
              opacity: progress.clamp(0.0, 1.0),
              child: Transform.translate(
                offset: Offset(0, (-30 + progress * 30).clamp(-30.0, 0.0)),
                child: Container(
                  width: 50.w,
                  height: 50.w,
                  decoration: BoxDecoration(
                    color: AppColors.purple.withOpacity(0.92),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.purple.withOpacity(0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Progress ring
                      if (isLoading)
                        SizedBox(
                          width: 50.w,
                          height: 50.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white.withOpacity(0.8),
                            ),
                          ),
                        )
                      else
                        SizedBox(
                          width: 50.w,
                          height: 50.w,
                          child: CircularProgressIndicator(
                            value: progress.clamp(0.0, 1.0),
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white.withOpacity(0.6),
                            ),
                            backgroundColor: Colors.white.withOpacity(0.15),
                          ),
                        ),
                      // Logo icon
                      SvgPicture.asset(
                        'assets/svg/logo.svg',
                        width: 24.w,
                        height: 24.h,
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

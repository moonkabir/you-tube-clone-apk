import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../state/player_lock_provider.dart';

/// The core Touch Lock Overlay widget
/// When locked:
/// 1. Intercepts all toddler taps and swipes across the entire screen via [AbsorbPointer]
/// 2. Displays a subtle, semi-transparent unlock target in the corner
/// 3. Requires a sustained 3-second long-press with real-time visual progress ring to unlock
class TouchLockOverlay extends ConsumerStatefulWidget {
  const TouchLockOverlay({super.key});

  @override
  ConsumerState<TouchLockOverlay> createState() => _TouchLockOverlayState();
}

class _TouchLockOverlayState extends ConsumerState<TouchLockOverlay>
    with SingleTickerProviderStateMixin {
  Timer? _holdTimer;
  static const int _holdDurationMs = 3000; // 3 seconds requirement
  static const int _tickIntervalMs = 50;   // Update every 50ms
  int _elapsedMs = 0;
  bool _isHolding = false;

  void _startHolding() {
    setState(() {
      _isHolding = true;
      _elapsedMs = 0;
    });
    HapticFeedback.lightImpact();

    _holdTimer?.cancel();
    _holdTimer = Timer.periodic(const Duration(milliseconds: _tickIntervalMs), (timer) {
      _elapsedMs += _tickIntervalMs;
      final progress = (_elapsedMs / _holdDurationMs).clamp(0.0, 1.0);
      ref.read(playerLockProvider.notifier).setUnlockProgress(progress);

      if (_elapsedMs >= _holdDurationMs) {
        _completeUnlock();
      }
    });
  }

  void _cancelHolding() {
    _holdTimer?.cancel();
    if (_isHolding) {
      setState(() {
        _isHolding = false;
        _elapsedMs = 0;
      });
      ref.read(playerLockProvider.notifier).cancelUnlock();
    }
  }

  void _completeUnlock() {
    _holdTimer?.cancel();
    HapticFeedback.heavyImpact();
    setState(() {
      _isHolding = false;
      _elapsedMs = 0;
    });
    ref.read(playerLockProvider.notifier).unlockScreen();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Screen Unlocked'),
        duration: Duration(seconds: 1),
        backgroundColor: AppColors.lockSuccess,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lockState = ref.watch(playerLockProvider);

    if (!lockState.isLocked) {
      return const SizedBox.shrink();
    }

    return Stack(
      children: [
        // 1. Transparent full-screen touch interceptor that blocks all toddler gestures
        Positioned.fill(
          child: AbsorbPointer(
            absorbing: true,
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ),

        // 2. Subtle translucent unlock target positioned at top right corner
        Positioned(
          top: 20,
          right: 20,
          child: SafeArea(
            child: Listener(
              onPointerDown: (_) => _startHolding(),
              onPointerUp: (_) => _cancelHolding(),
              onPointerCancel: (_) => _cancelHolding(),
              behavior: HitTestBehavior.opaque,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: _isHolding ? 0.95 : 0.45,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: _isHolding ? AppColors.sunnyYellow : Colors.white24,
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Radial countdown progress circle
                      SizedBox(
                        width: 28,
                        height: 28,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircularProgressIndicator(
                              value: lockState.unlockProgress,
                              strokeWidth: 3,
                              backgroundColor: Colors.white24,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.sunnyYellow,
                              ),
                            ),
                            const Icon(
                              Icons.lock_rounded,
                              size: 16,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _isHolding
                            ? 'Hold ${(3 - (_elapsedMs / 1000)).toStringAsFixed(1)}s...'
                            : 'Hold to unlock',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

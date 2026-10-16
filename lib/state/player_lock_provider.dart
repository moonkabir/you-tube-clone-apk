import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/utils/system_ui_helper.dart';

class PlayerLockState {
  final bool isLocked;
  final double unlockProgress; // 0.0 to 1.0

  const PlayerLockState({
    this.isLocked = false,
    this.unlockProgress = 0.0,
  });

  PlayerLockState copyWith({
    bool? isLocked,
    double? unlockProgress,
  }) {
    return PlayerLockState(
      isLocked: isLocked ?? this.isLocked,
      unlockProgress: unlockProgress ?? this.unlockProgress,
    );
  }
}

class PlayerLockNotifier extends StateNotifier<PlayerLockState> {
  PlayerLockNotifier() : super(const PlayerLockState());

  /// Activate screen lock mode
  /// Switches device to landscape and sticky immersive mode to block OnePlus 8T nav gestures
  Future<void> lockScreen() async {
    state = state.copyWith(isLocked: true, unlockProgress: 0.0);
    await SystemUiHelper.setLandscapeMode();
    await SystemUiHelper.enableStickyImmersiveMode();
  }

  /// Deactivate screen lock mode
  /// Restores UI controls while preserving player orientation
  Future<void> unlockScreen() async {
    state = state.copyWith(isLocked: false, unlockProgress: 0.0);
    await SystemUiHelper.setLandscapeMode();
  }

  /// Update unlock hold progress (from 0.0 to 1.0)
  void setUnlockProgress(double progress) {
    state = state.copyWith(unlockProgress: progress.clamp(0.0, 1.0));
  }

  /// Reset unlock progress when user lifts finger early
  void cancelUnlock() {
    state = state.copyWith(unlockProgress: 0.0);
  }
}

final playerLockProvider = StateNotifierProvider<PlayerLockNotifier, PlayerLockState>((ref) {
  return PlayerLockNotifier();
});

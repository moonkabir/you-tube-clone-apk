import 'package:flutter/services.dart';

/// Helper to handle immersive sticky mode and orientation switching for OnePlus 8T
class SystemUiHelper {
  /// Hide status and navigation bars using sticky immersive mode
  /// Perfect for OnePlus 8T to prevent toddler status bar pull-downs
  static Future<void> enableStickyImmersiveMode() async {
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
      overlays: [],
    );
  }

  /// Restore standard system UI bars (e.g. inside parental admin dashboard)
  static Future<void> restoreNormalSystemUI() async {
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: SystemUiOverlay.values,
    );
  }

  /// Lock orientation to landscape (used for locked playback)
  static Future<void> setLandscapeMode() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  /// Lock orientation to portrait
  static Future<void> setPortraitMode() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  /// Unlock orientations to support both portrait and landscape
  static Future<void> setFlexibleOrientation() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }
}

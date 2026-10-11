import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/system_ui_helper.dart';
import 'state/storage_provider.dart';
import 'ui/screens/kids_home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize offline-first shared_preferences storage
  final prefs = await SharedPreferences.getInstance();

  // Enable sticky immersive mode by default for distraction-free toddler use (OnePlus 8T)
  await SystemUiHelper.enableStickyImmersiveMode();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const KidsTubeApp(),
    ),
  );
}

class KidsTubeApp extends StatelessWidget {
  const KidsTubeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kids Tube',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const KidsHomeScreen(),
    );
  }
}

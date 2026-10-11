import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kids_youtube_clone/main.dart';
import 'package:kids_youtube_clone/state/storage_provider.dart';

void main() {
  testWidgets('App basic smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const KidsTubeApp(),
      ),
    );

    expect(find.byType(KidsTubeApp), findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:whisky_hikes/main_web.dart';

void main() {
  // WhiskyHikesWebApp constructs an AuthService, which reads the global
  // Supabase singleton. Without this the whole group dies on
  // "You must initialize the supabase instance". The URL and key are
  // deliberately fake and token refresh is off, so nothing hits the network.
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    // Supabase.initialize builds a SharedPreferences-backed auth store before
    // it looks at `localStorage`, so the plugin needs a mock backend.
    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(
      url: 'http://localhost:54321',
      anonKey: 'test-anon-key',
      authOptions: const FlutterAuthClientOptions(
        autoRefreshToken: false,
        localStorage: EmptyLocalStorage(),
      ),
    );
  });

  group('WhiskyHikesWebApp Tests', () {
    testWidgets('App lädt ohne Fehler', (WidgetTester tester) async {
      await tester.pumpWidget(const WhiskyHikesWebApp());

      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('App hat korrekten Titel', (WidgetTester tester) async {
      await tester.pumpWidget(const WhiskyHikesWebApp());

      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.title, equals('Whisky Hikes - Web Admin'));
    });

    testWidgets('App verwendet korrekte Theme-Farben', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const WhiskyHikesWebApp());

      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.theme?.colorScheme.primary, equals(Colors.amber));
      expect(app.theme?.useMaterial3, isTrue);
    });
  });
}

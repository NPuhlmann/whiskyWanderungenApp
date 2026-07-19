import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:whisky_hikes/main_web.dart';

void main() {
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

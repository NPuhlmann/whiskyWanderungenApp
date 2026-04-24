import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:whisky_hikes/main_web.dart';
import 'package:whisky_hikes/UI/shared/responsive_layout.dart';

void main() {
  group('WhiskyHikesWebApp Tests', () {
    testWidgets('App lädt ohne Fehler', (WidgetTester tester) async {
      await tester.pumpWidget(const WhiskyHikesWebApp());

      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(WebHomePage), findsOneWidget);
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

  group('WebHomePage Tests', () {
    testWidgets('WebHomePage zeigt ResponsiveLayout', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: WebHomePage()));

      expect(find.byType(ResponsiveLayout), findsOneWidget);
    });

    testWidgets('WebHomePage funktioniert bei kleiner Bildschirmgröße', (
      WidgetTester tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(400, 800)); // Mobile Größe

      await tester.pumpWidget(const MaterialApp(home: WebHomePage()));

      // Sollte mobile Layout zeigen
      expect(find.text('Whisky Hikes Web'), findsOneWidget);
      expect(find.text('Mobile Layout'), findsOneWidget);
      expect(find.text('Web-App läuft erfolgreich! 🎉'), findsOneWidget);
    });

    testWidgets('WebHomePage funktioniert bei großer Bildschirmgröße', (
      WidgetTester tester,
    ) async {
      await tester.binding.setSurfaceSize(
        const Size(1400, 800),
      ); // Desktop Größe

      await tester.pumpWidget(const MaterialApp(home: WebHomePage()));

      // Sollte desktop Layout zeigen
      expect(find.text('Willkommen bei Whisky Hikes'), findsOneWidget);
      expect(
        find.text('Desktop Layout - Web-App läuft erfolgreich! 🎉'),
        findsOneWidget,
      );
      expect(find.text('✅ Flutter Web aktiviert'), findsOneWidget);
    });

    testWidgets('Desktop Layout zeigt Sidebar', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(
        const Size(1400, 800),
      ); // Desktop Größe

      await tester.pumpWidget(const MaterialApp(home: WebHomePage()));

      // Sidebar sollte sichtbar sein
      expect(find.text('Whisky Hikes'), findsOneWidget);
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Wanderrouten'), findsOneWidget);
      expect(find.text('Bestellungen'), findsOneWidget);
    });

    testWidgets('Mobile Layout zeigt AppBar', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 800)); // Mobile Größe

      await tester.pumpWidget(const MaterialApp(home: WebHomePage()));

      // AppBar sollte sichtbar sein
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Whisky Hikes Web'), findsOneWidget);
    });

    testWidgets('Features werden korrekt angezeigt', (
      WidgetTester tester,
    ) async {
      await tester.binding.setSurfaceSize(
        const Size(1400, 800),
      ); // Desktop Größe

      await tester.pumpWidget(const MaterialApp(home: WebHomePage()));

      // Alle Features sollten sichtbar sein
      expect(find.text('✅ Flutter Web aktiviert'), findsOneWidget);
      expect(find.text('✅ Responsive Layout implementiert'), findsOneWidget);
      expect(find.text('✅ Admin-Dashboard erstellt'), findsOneWidget);
      expect(find.text('✅ Navigation implementiert'), findsOneWidget);
      expect(
        find.text('✅ Web-spezifische Dependencies hinzugefügt'),
        findsOneWidget,
      );
    });
  });

  group('Responsive Behavior Tests', () {
    testWidgets('Layout wechselt korrekt zwischen Mobile und Desktop', (
      WidgetTester tester,
    ) async {
      // Starte mit Mobile
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pumpWidget(const MaterialApp(home: WebHomePage()));

      expect(find.text('Mobile Layout'), findsOneWidget);
      expect(
        find.text('Desktop Layout - Web-App läuft erfolgreich! 🎉'),
        findsNothing,
      );

      // Wechsle zu Desktop
      await tester.binding.setSurfaceSize(const Size(1400, 800));
      await tester.pumpWidget(const MaterialApp(home: WebHomePage()));

      expect(
        find.text('Desktop Layout - Web-App läuft erfolgreich! 🎉'),
        findsOneWidget,
      );
      expect(find.text('Mobile Layout'), findsNothing);
    });

    testWidgets(
      'Tablet-Größe zeigt Mobile-Layout (da kein Tablet-Widget definiert)',
      (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(
          const Size(1000, 800),
        ); // Tablet Größe

        await tester.pumpWidget(const MaterialApp(home: WebHomePage()));

        // Sollte Mobile-Layout zeigen, da kein Tablet-Widget definiert ist
        expect(find.text('Mobile Layout'), findsOneWidget);
      },
    );
  });
}

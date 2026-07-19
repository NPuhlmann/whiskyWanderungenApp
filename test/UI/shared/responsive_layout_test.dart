import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:whisky_hikes/UI/shared/responsive_layout.dart';

/// Sets the logical viewport for a widget test.
///
/// `tester.view.physicalSize` is in *physical* pixels, so it only equals the
/// logical size the widgets see once `devicePixelRatio` is pinned to 1.0 —
/// the test default of 3.0 otherwise divides the requested width by three and
/// silently lands in the wrong breakpoint. `tester.view.reset()` in the
/// teardown stops sizes leaking into the next test.
Future<void> setViewport(WidgetTester tester, Size size) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);
}

void main() {
  group('ResponsiveLayout Tests', () {
    testWidgets(
      'ResponsiveLayout zeigt mobile Layout bei kleiner Bildschirmbreite',
      (WidgetTester tester) async {
        await setViewport(tester, const Size(400, 800)); // Mobile Größe

        await tester.pumpWidget(
          MaterialApp(
            home: ResponsiveLayout(
              mobile: const Text('Mobile Layout'),
              desktop: const Text('Desktop Layout'),
            ),
          ),
        );

        expect(find.text('Mobile Layout'), findsOneWidget);
        expect(find.text('Desktop Layout'), findsNothing);
      },
    );

    testWidgets(
      'ResponsiveLayout zeigt desktop Layout bei großer Bildschirmbreite',
      (WidgetTester tester) async {
        await setViewport(tester, const Size(1400, 800)); // Desktop Größe

        await tester.pumpWidget(
          MaterialApp(
            home: ResponsiveLayout(
              mobile: const Text('Mobile Layout'),
              desktop: const Text('Desktop Layout'),
            ),
          ),
        );

        expect(find.text('Desktop Layout'), findsOneWidget);
        expect(find.text('Mobile Layout'), findsNothing);
      },
    );

    testWidgets(
      'ResponsiveLayout zeigt mobile Layout bei Tablet-Größe ohne tablet Widget',
      (WidgetTester tester) async {
        await setViewport(tester, const Size(1000, 800)); // Tablet Größe

        await tester.pumpWidget(
          MaterialApp(
            home: ResponsiveLayout(
              mobile: const Text('Mobile Layout'),
              desktop: const Text('Desktop Layout'),
            ),
          ),
        );

        expect(find.text('Mobile Layout'), findsOneWidget);
        expect(find.text('Desktop Layout'), findsNothing);
      },
    );

    testWidgets(
      'ResponsiveLayout zeigt tablet Layout bei Tablet-Größe mit tablet Widget',
      (WidgetTester tester) async {
        await setViewport(tester, const Size(1000, 800)); // Tablet Größe

        await tester.pumpWidget(
          MaterialApp(
            home: ResponsiveLayout(
              mobile: const Text('Mobile Layout'),
              tablet: const Text('Tablet Layout'),
              desktop: const Text('Desktop Layout'),
            ),
          ),
        );

        expect(find.text('Tablet Layout'), findsOneWidget);
        expect(find.text('Mobile Layout'), findsNothing);
        expect(find.text('Desktop Layout'), findsNothing);
      },
    );
  });

  group('ResponsiveLayoutUtils Tests', () {
    testWidgets('isMobile erkennt mobile Bildschirmgröße korrekt', (
      WidgetTester tester,
    ) async {
      await setViewport(tester, const Size(400, 800));

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final isMobile = ResponsiveLayoutUtils.isMobile(context);
              return Text('Mobile: $isMobile');
            },
          ),
        ),
      );

      expect(find.text('Mobile: true'), findsOneWidget);
    });

    testWidgets('isDesktop erkennt desktop Bildschirmgröße korrekt', (
      WidgetTester tester,
    ) async {
      await setViewport(tester, const Size(1400, 800));

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final isDesktop = ResponsiveLayoutUtils.isDesktop(context);
              return Text('Desktop: $isDesktop');
            },
          ),
        ),
      );

      expect(find.text('Desktop: true'), findsOneWidget);
    });

    testWidgets('isTablet erkennt tablet Bildschirmgröße korrekt', (
      WidgetTester tester,
    ) async {
      await setViewport(tester, const Size(1000, 800));

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final isTablet = ResponsiveLayoutUtils.isTablet(context);
              return Text('Tablet: $isTablet');
            },
          ),
        ),
      );

      expect(find.text('Tablet: true'), findsOneWidget);
    });
  });

  group('ResponsiveBuilder Tests', () {
    testWidgets(
      'ResponsiveBuilder funktioniert mit verschiedenen Bildschirmgrößen',
      (WidgetTester tester) async {
        await setViewport(tester, const Size(400, 800)); // Mobile Größe

        await tester.pumpWidget(
          MaterialApp(
            home: ResponsiveBuilder(
              builder: (context, isMobile, isTablet, isDesktop) {
                if (isMobile) return const Text('Mobile Builder');
                if (isTablet) return const Text('Tablet Builder');
                if (isDesktop) return const Text('Desktop Builder');
                return const Text('Unknown');
              },
            ),
          ),
        );

        expect(find.text('Mobile Builder'), findsOneWidget);
      },
    );

    testWidgets('ResponsiveBuilder funktioniert bei Desktop-Größe', (
      WidgetTester tester,
    ) async {
      await setViewport(tester, const Size(1400, 800)); // Desktop Größe

      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveBuilder(
            builder: (context, isMobile, isTablet, isDesktop) {
              if (isMobile) return const Text('Mobile Builder');
              if (isTablet) return const Text('Tablet Builder');
              if (isDesktop) return const Text('Desktop Builder');
              return const Text('Unknown');
            },
          ),
        ),
      );

      expect(find.text('Desktop Builder'), findsOneWidget);
    });
  });

  group('PlatformUtils Tests', () {
    test('isWeb gibt korrekten Wert zurück', () {
      // In Flutter Test-Umgebung sollte isWeb false sein
      expect(PlatformUtils.isWeb, isFalse);
    });

    test('isMobile gibt korrekten Wert zurück', () {
      // In Flutter Test-Umgebung sollte isMobile true sein
      expect(PlatformUtils.isMobile, isTrue);
    });

    test('platform gibt korrekten Wert zurück', () {
      expect(PlatformUtils.platform, equals('mobile'));
    });
  });
}

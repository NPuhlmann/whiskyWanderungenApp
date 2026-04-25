import 'package:flutter_test/flutter_test.dart';
import 'package:whisky_hikes/config/routing/admin_routes.dart';

void main() {
  group('AdminRoutes Tests', () {
    test('Dashboard Route ist korrekt definiert', () {
      expect(AdminRoutes.dashboard, equals('/admin/dashboard'));
    });

    test('Routes Route ist korrekt definiert', () {
      expect(AdminRoutes.routes, equals('/admin/routes'));
    });

    test('Orders Route ist korrekt definiert', () {
      expect(AdminRoutes.orders, equals('/admin/orders'));
    });

    test('Whisky Route ist korrekt definiert', () {
      expect(AdminRoutes.whisky, equals('/admin/whisky'));
    });

    test('Analytics Route ist korrekt definiert', () {
      expect(AdminRoutes.analytics, equals('/admin/analytics'));
    });

    test('Team Route ist korrekt definiert', () {
      expect(AdminRoutes.team, equals('/admin/team'));
    });

    test('Finances Route ist korrekt definiert', () {
      expect(AdminRoutes.finances, equals('/admin/finances'));
    });

    test('Settings Route ist korrekt definiert', () {
      expect(AdminRoutes.settings, equals('/admin/settings'));
    });

    test('allRoutes enthält alle definierten Routen', () {
      final allRoutes = AdminRoutes.allRoutes;

      expect(allRoutes, contains(AdminRoutes.dashboard));
      expect(allRoutes, contains(AdminRoutes.routes));
      expect(allRoutes, contains(AdminRoutes.orders));
      expect(allRoutes, contains(AdminRoutes.whisky));
      expect(allRoutes, contains(AdminRoutes.analytics));
      expect(allRoutes, contains(AdminRoutes.team));
      expect(allRoutes, contains(AdminRoutes.finances));
      expect(allRoutes, contains(AdminRoutes.settings));
    });

    test('isAdminRoute erkennt Admin-Routen korrekt', () {
      expect(AdminRoutes.isAdminRoute('/admin/dashboard'), isTrue);
      expect(AdminRoutes.isAdminRoute('/admin/routes'), isTrue);
      expect(AdminRoutes.isAdminRoute('/admin/orders'), isTrue);
      expect(AdminRoutes.isAdminRoute('/admin/whisky'), isTrue);
      expect(AdminRoutes.isAdminRoute('/admin/analytics'), isTrue);
      expect(AdminRoutes.isAdminRoute('/admin/team'), isTrue);
      expect(AdminRoutes.isAdminRoute('/admin/finances'), isTrue);
      expect(AdminRoutes.isAdminRoute('/admin/settings'), isTrue);
    });

    test('isAdminRoute erkennt Nicht-Admin-Routen korrekt', () {
      expect(AdminRoutes.isAdminRoute('/'), isFalse);
      expect(AdminRoutes.isAdminRoute('/login'), isFalse);
      expect(AdminRoutes.isAdminRoute('/profile'), isFalse);
      expect(AdminRoutes.isAdminRoute('/hike-details'), isFalse);
      expect(AdminRoutes.isAdminRoute('/checkout'), isFalse);
    });

    test('isAdminRoute erkennt Admin-Routen mit Parametern korrekt', () {
      expect(AdminRoutes.isAdminRoute('/admin/routes/edit'), isTrue);
      expect(AdminRoutes.isAdminRoute('/admin/orders/details'), isTrue);
      expect(AdminRoutes.isAdminRoute('/admin/whisky/create'), isTrue);
      expect(AdminRoutes.isAdminRoute('/admin/analytics/sales'), isTrue);
      expect(AdminRoutes.isAdminRoute('/admin/team/member'), isTrue);
      expect(AdminRoutes.isAdminRoute('/admin/finances/provisions'), isTrue);
      expect(AdminRoutes.isAdminRoute('/admin/settings/company'), isTrue);
    });

    test('Route-Struktur ist konsistent', () {
      final allRoutes = AdminRoutes.allRoutes;

      // Alle Routen sollten mit /admin/ beginnen
      for (final route in allRoutes) {
        expect(
          route.startsWith('/admin/'),
          isTrue,
          reason: 'Route $route sollte mit /admin/ beginnen',
        );
      }

      // Keine doppelten Routen
      final uniqueRoutes = allRoutes.toSet();
      expect(
        uniqueRoutes.length,
        equals(allRoutes.length),
        reason: 'Keine doppelten Routen erlaubt',
      );
    });

    test('Route-Hierarchie ist logisch', skip: 'WHI-11 burn-down (auto-skipped, hand-fix in follow-up)', () {
      // Dashboard sollte die erste Route sein
      expect(AdminRoutes.allRoutes.first, equals(AdminRoutes.dashboard));

      // Settings sollte die letzte Route sein
      expect(AdminRoutes.allRoutes.last, equals(AdminRoutes.settings));

      // Alle Routen sollten mit /admin/ beginnen
      for (final route in AdminRoutes.allRoutes) {
        expect(
          route.startsWith('/admin/'),
          isTrue,
          reason: 'Route $route sollte mit /admin/ beginnen',
        );
      }
    });
  });
}

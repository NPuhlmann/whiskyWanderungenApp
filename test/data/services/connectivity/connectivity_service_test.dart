import 'package:flutter_test/flutter_test.dart';
import 'package:whisky_hikes/data/services/connectivity/connectivity_service.dart';

void main() {
  group('ConnectivityService', () {
    late ConnectivityService connectivityService;
    bool disposed = false;

    setUp(() {
      connectivityService = ConnectivityService.instance;
      disposed = false;
    });

    tearDown(() async {
      if (!disposed) {
        try {
          await connectivityService.dispose();
          disposed = true;
        } catch (e) {
          // Ignore disposal errors in tests
        }
      }
    });

    group('Singleton Instance', () {
      test('should return same instance', () {
        // Act
        final instance1 = ConnectivityService.instance;
        final instance2 = ConnectivityService.instance;

        // Assert
        expect(instance1, same(instance2));
      });
    });

    group('Network Status', () {
      test('should have initial network status', () {
        // Assert
        expect(connectivityService.currentStatus, isA<NetworkStatus>());
      });

      test('should provide network status stream', () {
        // Assert
        expect(connectivityService.networkStatusStream, isA<Stream<NetworkStatus>>());
      });
    });

    group('Network Status Extensions', () {
      test('NetworkStatus.connected_wifi should be connected', () {
        // Arrange
        const status = NetworkStatus.connected_wifi;

        // Assert
        expect(status.isConnected, isTrue);
        expect(status.isWifi, isTrue);
        expect(status.isMobile, isFalse);
      });

      test('NetworkStatus.connected_mobile should be connected', () {
        // Arrange
        const status = NetworkStatus.connected_mobile;

        // Assert
        expect(status.isConnected, isTrue);
        expect(status.isWifi, isFalse);
        expect(status.isMobile, isTrue);
      });

      test('NetworkStatus.disconnected should not be connected', () {
        // Arrange
        const status = NetworkStatus.disconnected;

        // Assert
        expect(status.isConnected, isFalse);
        expect(status.isWifi, isFalse);
        expect(status.isMobile, isFalse);
      });

      test('NetworkStatus.connected_wifi_good should have good quality', () {
        // Arrange
        const status = NetworkStatus.connected_wifi_good;

        // Assert
        expect(status.isGoodQuality, isTrue);
        expect(status.isPoorQuality, isFalse);
      });

      test('NetworkStatus.connected_wifi_poor should have poor quality', () {
        // Arrange
        const status = NetworkStatus.connected_wifi_poor;

        // Assert
        expect(status.isGoodQuality, isFalse);
        expect(status.isPoorQuality, isTrue);
      });
    });

    group('Display Names', () {
      test('should provide correct display names for all statuses', () {
        const testCases = {
          NetworkStatus.unknown: 'Unbekannt',
          NetworkStatus.disconnected: 'Nicht verbunden',
          NetworkStatus.connected_no_internet: 'Verbunden, kein Internet',
          NetworkStatus.connected_wifi: 'WLAN verbunden',
          NetworkStatus.connected_wifi_good: 'WLAN (gut)',
          NetworkStatus.connected_wifi_poor: 'WLAN (schwach)',
          NetworkStatus.connected_mobile: 'Mobil verbunden',
          NetworkStatus.connected_mobile_good: 'Mobil (gut)',
          NetworkStatus.connected_mobile_poor: 'Mobil (schwach)',
          NetworkStatus.connected_ethernet: 'Ethernet verbunden',
        };

        testCases.forEach((status, expectedName) {
          expect(status.displayName, equals(expectedName), 
                 reason: 'Display name for $status should be $expectedName');
        });
      });
    });

    group('Connection Type Detection', () {
      test('should identify WiFi connections correctly', () {
        const wifiStatuses = [
          NetworkStatus.connected_wifi,
          NetworkStatus.connected_wifi_good,
          NetworkStatus.connected_wifi_poor,
        ];

        for (final status in wifiStatuses) {
          expect(status.isWifi, isTrue, reason: '$status should be identified as WiFi');
          expect(status.isMobile, isFalse, reason: '$status should not be identified as mobile');
        }
      });

      test('should identify mobile connections correctly', () {
        const mobileStatuses = [
          NetworkStatus.connected_mobile,
          NetworkStatus.connected_mobile_good,
          NetworkStatus.connected_mobile_poor,
        ];

        for (final status in mobileStatuses) {
          expect(status.isMobile, isTrue, reason: '$status should be identified as mobile');
          expect(status.isWifi, isFalse, reason: '$status should not be identified as WiFi');
        }
      });
    });

    group('Quality Detection', () {
      test('should identify good quality connections', () {
        const goodQualityStatuses = [
          NetworkStatus.connected_wifi_good,
          NetworkStatus.connected_mobile_good,
        ];

        for (final status in goodQualityStatuses) {
          expect(status.isGoodQuality, isTrue, reason: '$status should have good quality');
          expect(status.isPoorQuality, isFalse, reason: '$status should not have poor quality');
        }
      });

      test('should identify poor quality connections', () {
        const poorQualityStatuses = [
          NetworkStatus.connected_wifi_poor,
          NetworkStatus.connected_mobile_poor,
        ];

        for (final status in poorQualityStatuses) {
          expect(status.isPoorQuality, isTrue, reason: '$status should have poor quality');
          expect(status.isGoodQuality, isFalse, reason: '$status should not have good quality');
        }
      });

      test('should identify normal quality connections', () {
        const normalQualityStatuses = [
          NetworkStatus.connected_wifi,
          NetworkStatus.connected_mobile,
          NetworkStatus.connected_ethernet,
        ];

        for (final status in normalQualityStatuses) {
          expect(status.isGoodQuality, isFalse, reason: '$status should not have good quality flag');
          expect(status.isPoorQuality, isFalse, reason: '$status should not have poor quality flag');
        }
      });
    });

    group('Network Statistics', () {
      test('should provide network stats structure', () {
        // Act
        final stats = connectivityService.getNetworkStats();

        // Assert
        expect(stats, isA<Map<String, dynamic>>());
        expect(stats.containsKey('currentStatus'), isTrue);
        expect(stats.containsKey('isConnected'), isTrue);
      });

      test('should track connection time when available', () {
        // Act
        final stats = connectivityService.getNetworkStats();

        // Assert - Should have these keys even if null
        expect(stats.containsKey('lastConnectedTime'), isTrue);
        expect(stats.containsKey('lastDisconnectedTime'), isTrue);
        expect(stats.containsKey('uptime'), isTrue);
        expect(stats.containsKey('downtime'), isTrue);
      });
    });

    group('Service Lifecycle', () {
      test('should initialize without throwing', () async {
        // Act & Assert - Should not throw
        await expectLater(() => connectivityService.initialize(), 
                         returnsNormally);
      });

      test('should dispose without throwing', () async {
        // Act & Assert - Should not throw
        await expectLater(() => connectivityService.dispose(), 
                         returnsNormally);
        disposed = true; // Mark as disposed to prevent tearDown disposal
      });
    });

    group('Host Reachability', () {
      // Note: These tests might fail in environments without internet
      // They are more integration tests than unit tests
      
      test('should attempt to check host reachability', () async {
        // Act & Assert - Should not throw, regardless of result
        await expectLater(() => connectivityService.canReachHost('example.com'), 
                         returnsNormally);
      });

      test('should attempt to check Supabase reachability', () async {
        // Act & Assert - Should not throw, regardless of result  
        await expectLater(() => connectivityService.canReachSupabase(), 
                         returnsNormally);
      });

      test('should handle invalid host gracefully', () async {
        // Act
        final result = await connectivityService.canReachHost('invalid-host-that-definitely-does-not-exist.local');

        // Assert - Should return false for invalid host
        expect(result, isFalse);
      });
    });

    group('Edge Cases', () {
      test('should handle multiple dispose calls gracefully', () async {
        // Act & Assert - Multiple dispose calls should not throw
        await connectivityService.dispose();
        await expectLater(() => connectivityService.dispose(), 
                         returnsNormally);
        disposed = true; // Mark as disposed to prevent tearDown disposal
      });

      test('should handle network status check without initialization', () async {
        // Act & Assert - Should not throw even if not initialized
        await expectLater(() => connectivityService.checkNetworkStatus(), 
                         returnsNormally);
      });
    });
  });

  group('ConnectionType', () {
    test('should have all expected connection types', () {
      // Assert - Verify all expected connection types exist
      expect(ConnectionType.values, contains(ConnectionType.wifi));
      expect(ConnectionType.values, contains(ConnectionType.mobile));
      expect(ConnectionType.values, contains(ConnectionType.ethernet));
      expect(ConnectionType.values, contains(ConnectionType.other));
    });
  });

  group('ConnectionQuality', () {
    test('should have all expected quality levels', () {
      // Assert - Verify all expected quality levels exist
      expect(ConnectionQuality.values, contains(ConnectionQuality.unknown));
      expect(ConnectionQuality.values, contains(ConnectionQuality.poor));
      expect(ConnectionQuality.values, contains(ConnectionQuality.good));
    });
  });
}
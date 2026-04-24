import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:whisky_hikes/data/services/auth/auth_service.dart';

// Generate mocks
@GenerateMocks([SupabaseClient])
import 'auth_service_simple_test.mocks.dart';

void main() {
  group('AuthService Basic Tests', () {
    late AuthService authService;
    late MockSupabaseClient mockClient;

    setUp(() {
      mockClient = MockSupabaseClient();
      // Pass isDevMode explicitly to avoid dotenv dependency
      authService = AuthService(client: mockClient, isDevMode: true);
    });

    test('should instantiate service', () {
      expect(authService, isNotNull);
      expect(authService, isA<AuthService>());
    });

    test('should have client property', () {
      expect(authService.client, isNotNull);
      expect(authService.client, equals(mockClient));
    });

    test('should have dev mode property', () {
      expect(authService.isDevMode, isA<bool>());
      expect(authService.isDevMode, isTrue);
    });
  });
}

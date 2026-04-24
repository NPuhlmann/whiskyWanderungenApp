import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:whisky_hikes/data/services/database/backend_api.dart';

// Generate mocks
@GenerateMocks([SupabaseClient])
import 'backend_api_simple_test.mocks.dart';

void main() {
  group('BackendApiService Basic Tests', () {
    late BackendApiService backendApiService;
    late MockSupabaseClient mockClient;

    setUp(() {
      mockClient = MockSupabaseClient();
      backendApiService = BackendApiService(client: mockClient);
    });

    test('should instantiate service', () {
      expect(backendApiService, isNotNull);
      expect(backendApiService, isA<BackendApiService>());
    });

    test('should have client property', () {
      expect(backendApiService.client, isNotNull);
      expect(backendApiService.client, equals(mockClient));
    });
  });
}

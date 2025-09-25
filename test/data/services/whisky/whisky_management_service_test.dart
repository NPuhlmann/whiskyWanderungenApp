import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:whisky_hikes/data/services/whisky/whisky_management_service.dart';
import 'package:whisky_hikes/domain/models/tasting_set.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../test_helpers.dart';
import '../../../mocks/mock_supabase.mocks.dart';

void main() {
  group('WhiskyManagementService', () {
    late WhiskyManagementService service;
    late MockSupabaseClient mockClient;
    late MockSupabaseQueryBuilder mockQueryBuilder;
    late MockPostgrestFilterBuilder mockFilterBuilder;
    late MockStorageFileApi mockStorage;

    setUp(() {
      mockClient = MockSupabaseClient();
      mockQueryBuilder = MockSupabaseQueryBuilder();
      mockFilterBuilder = MockPostgrestFilterBuilder();
      mockStorage = MockStorageFileApi();

      // Setup storage mocking
      when(mockClient.storage).thenReturn(MockStorageBucket());
      when(mockClient.storage.from(any)).thenReturn(mockStorage);

      service = WhiskyManagementService(mockClient);
    });

    group('TastingSet Operations', () {
      test('should get all tasting sets successfully', () async {
        // Arrange
        final testTastingSets = [
          TestHelpers.createTestTastingSet(id: 1, name: 'Highland Collection'),
          TestHelpers.createTestTastingSet(id: 2, name: 'Islay Selection'),
        ];

        when(mockClient.from('tasting_sets')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select(any)).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.order('name')).thenReturn(mockFilterBuilder);

        when(mockFilterBuilder.then()).thenAnswer((_) async => [
          testTastingSets[0].toJson(),
          testTastingSets[1].toJson(),
        ]);

        // Act
        final result = await service.getAllTastingSets();

        // Assert
        expect(result, hasLength(2));
        expect(result[0].name, equals('Highland Collection'));
        expect(result[1].name, equals('Islay Selection'));

        verify(mockClient.from('tasting_sets')).called(1);
        verify(mockQueryBuilder.select('*, samples:whisky_samples(*)')).called(1);
      });

      test('should get tasting sets by hike ID successfully', () async {
        // Arrange
        final testTastingSet = TestHelpers.createTestTastingSet(
          id: 1,
          hikeId: 100,
          name: 'Mountain Trail Set'
        );

        when(mockClient.from('tasting_sets')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select(any)).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.eq('hike_id', 100)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.single()).thenAnswer((_) async => testTastingSet.toJson());

        // Act
        final result = await service.getTastingSetByHikeId(100);

        // Assert
        expect(result, isNotNull);
        expect(result!.name, equals('Mountain Trail Set'));
        expect(result.hikeId, equals(100));

        verify(mockClient.from('tasting_sets')).called(1);
        verify(mockQueryBuilder.eq('hike_id', 100)).called(1);
      });

      test('should return null when tasting set not found for hike', () async {
        // Arrange
        when(mockClient.from('tasting_sets')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select(any)).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.eq('hike_id', 999)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.single()).thenThrow(
          PostgrestException(message: 'No rows returned', details: null, hint: null, code: null)
        );

        // Act
        final result = await service.getTastingSetByHikeId(999);

        // Assert
        expect(result, isNull);
      });

      test('should create tasting set successfully', () async {
        // Arrange
        final newTastingSet = TestHelpers.createTestTastingSet(
          name: 'New Collection',
          hikeId: 200,
        );

        final createdData = newTastingSet.copyWith(id: 123).toJson();

        when(mockClient.from('tasting_sets')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.insert(any)).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select()).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.single()).thenAnswer((_) async => createdData);

        // Act
        final result = await service.createTastingSet(newTastingSet);

        // Assert
        expect(result.id, equals(123));
        expect(result.name, equals('New Collection'));
        expect(result.hikeId, equals(200));

        verify(mockClient.from('tasting_sets')).called(1);
        verify(mockQueryBuilder.insert(any)).called(1);
      });

      test('should update tasting set successfully', () async {
        // Arrange
        final updatedTastingSet = TestHelpers.createTestTastingSet(
          id: 1,
          name: 'Updated Collection',
          description: 'Updated description',
        );

        when(mockClient.from('tasting_sets')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.update(any)).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.eq('id', 1)).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select()).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.single()).thenAnswer((_) async => updatedTastingSet.toJson());

        // Act
        final result = await service.updateTastingSet(updatedTastingSet);

        // Assert
        expect(result.name, equals('Updated Collection'));
        expect(result.description, equals('Updated description'));

        verify(mockClient.from('tasting_sets')).called(1);
        verify(mockQueryBuilder.update(any)).called(1);
        verify(mockQueryBuilder.eq('id', 1)).called(1);
      });

      test('should delete tasting set successfully', () async {
        // Arrange
        when(mockClient.from('tasting_sets')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.delete()).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.eq('id', 1)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.then()).thenAnswer((_) async => []);

        // Act
        await service.deleteTastingSet(1);

        // Assert
        verify(mockClient.from('tasting_sets')).called(1);
        verify(mockQueryBuilder.delete()).called(1);
        verify(mockQueryBuilder.eq('id', 1)).called(1);
      });
    });

    group('WhiskySample Operations', () {
      test('should get whisky samples by tasting set ID', () async {
        // Arrange
        final testSamples = [
          TestHelpers.createTestWhiskySample(id: 1, name: 'Glenfiddich 12'),
          TestHelpers.createTestWhiskySample(id: 2, name: 'Macallan 15'),
        ];

        when(mockClient.from('whisky_samples')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select()).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.eq('tasting_set_id', 1)).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.order('order_index')).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.then()).thenAnswer((_) async => [
          testSamples[0].toJson(),
          testSamples[1].toJson(),
        ]);

        // Act
        final result = await service.getWhiskySamplesByTastingSetId(1);

        // Assert
        expect(result, hasLength(2));
        expect(result[0].name, equals('Glenfiddich 12'));
        expect(result[1].name, equals('Macallan 15'));

        verify(mockClient.from('whisky_samples')).called(1);
        verify(mockQueryBuilder.eq('tasting_set_id', 1)).called(1);
      });

      test('should create whisky sample successfully', () async {
        // Arrange
        final newSample = TestHelpers.createTestWhiskySample(
          name: 'New Whisky',
          distillery: 'New Distillery',
        );

        final createdData = newSample.copyWith(id: 456).toJson();

        when(mockClient.from('whisky_samples')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.insert(any)).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select()).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.single()).thenAnswer((_) async => createdData);

        // Act
        final result = await service.createWhiskySample(newSample);

        // Assert
        expect(result.id, equals(456));
        expect(result.name, equals('New Whisky'));
        expect(result.distillery, equals('New Distillery'));

        verify(mockClient.from('whisky_samples')).called(1);
        verify(mockQueryBuilder.insert(any)).called(1);
      });

      test('should update whisky sample successfully', () async {
        // Arrange
        final updatedSample = TestHelpers.createTestWhiskySample(
          id: 1,
          name: 'Updated Whisky',
          age: 25,
        );

        when(mockClient.from('whisky_samples')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.update(any)).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.eq('id', 1)).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select()).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.single()).thenAnswer((_) async => updatedSample.toJson());

        // Act
        final result = await service.updateWhiskySample(updatedSample);

        // Assert
        expect(result.name, equals('Updated Whisky'));
        expect(result.age, equals(25));

        verify(mockClient.from('whisky_samples')).called(1);
        verify(mockQueryBuilder.update(any)).called(1);
      });

      test('should delete whisky sample successfully', () async {
        // Arrange
        when(mockClient.from('whisky_samples')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.delete()).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.eq('id', 1)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.then()).thenAnswer((_) async => []);

        // Act
        await service.deleteWhiskySample(1);

        // Assert
        verify(mockClient.from('whisky_samples')).called(1);
        verify(mockQueryBuilder.delete()).called(1);
        verify(mockQueryBuilder.eq('id', 1)).called(1);
      });

      test('should update sample order successfully', () async {
        // Arrange
        final reorderedSamples = [
          TestHelpers.createTestWhiskySample(id: 2, orderIndex: 0),
          TestHelpers.createTestWhiskySample(id: 1, orderIndex: 1),
        ];

        when(mockClient.from('whisky_samples')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.update(any)).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.eq('id', any)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.then()).thenAnswer((_) async => []);

        // Act
        await service.updateSampleOrder(reorderedSamples);

        // Assert
        verify(mockClient.from('whisky_samples')).called(2);
        verify(mockQueryBuilder.update(any)).called(2);
      });
    });

    group('Image Management', () {
      test('should upload whisky image successfully', () async {
        // Arrange
        final imageBytes = List.generate(100, (index) => index % 256);
        const sampleId = 123;
        const fileName = 'whisky_123.jpg';

        when(mockStorage.uploadBinary(any, any, fileOptions: anyNamed('fileOptions')))
            .thenAnswer((_) async => fileName);
        when(mockStorage.getPublicUrl(fileName))
            .thenReturn('https://storage.example.com/whisky_123.jpg');

        // Act
        final result = await service.uploadWhiskyImage(sampleId, imageBytes, 'jpg');

        // Assert
        expect(result, equals('https://storage.example.com/whisky_123.jpg'));
        verify(mockStorage.uploadBinary(any, imageBytes, fileOptions: anyNamed('fileOptions'))).called(1);
        verify(mockStorage.getPublicUrl(fileName)).called(1);
      });

      test('should handle image upload error gracefully', () async {
        // Arrange
        final imageBytes = List.generate(100, (index) => index % 256);
        const sampleId = 123;

        when(mockStorage.uploadBinary(any, any, fileOptions: anyNamed('fileOptions')))
            .thenThrow(StorageException('Upload failed', statusCode: '500'));

        // Act & Assert
        expect(
          () => service.uploadWhiskyImage(sampleId, imageBytes, 'jpg'),
          throwsA(isA<StorageException>()),
        );
      });

      test('should delete whisky image successfully', () async {
        // Arrange
        const fileName = 'whisky_123.jpg';

        when(mockStorage.remove([fileName]))
            .thenAnswer((_) async => []);

        // Act
        await service.deleteWhiskyImage(fileName);

        // Assert
        verify(mockStorage.remove([fileName])).called(1);
      });
    });

    group('Search and Filter Operations', () {
      test('should search tasting sets by name', () async {
        // Arrange
        final searchResults = [
          TestHelpers.createTestTastingSet(id: 1, name: 'Highland Collection'),
        ];

        when(mockClient.from('tasting_sets')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select(any)).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.ilike('name', '%highland%')).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.then()).thenAnswer((_) async => [
          searchResults[0].toJson(),
        ]);

        // Act
        final result = await service.searchTastingSets('highland');

        // Assert
        expect(result, hasLength(1));
        expect(result[0].name, equals('Highland Collection'));

        verify(mockQueryBuilder.ilike('name', '%highland%')).called(1);
      });

      test('should filter whisky samples by region', () async {
        // Arrange
        final filteredSamples = [
          TestHelpers.createTestWhiskySample(id: 1, region: 'Speyside'),
          TestHelpers.createTestWhiskySample(id: 2, region: 'Speyside'),
        ];

        when(mockClient.from('whisky_samples')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select()).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.eq('region', 'Speyside')).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.then()).thenAnswer((_) async => [
          filteredSamples[0].toJson(),
          filteredSamples[1].toJson(),
        ]);

        // Act
        final result = await service.getWhiskySamplesByRegion('Speyside');

        // Assert
        expect(result, hasLength(2));
        expect(result.every((sample) => sample.region == 'Speyside'), isTrue);

        verify(mockQueryBuilder.eq('region', 'Speyside')).called(1);
      });
    });

    group('Error Handling', () {
      test('should handle database connection errors', () async {
        // Arrange
        when(mockClient.from('tasting_sets')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select(any)).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.order('name')).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.then()).thenThrow(
          PostgrestException(message: 'Connection failed', details: null, hint: null, code: null)
        );

        // Act & Assert
        expect(
          () => service.getAllTastingSets(),
          throwsA(isA<PostgrestException>()),
        );
      });

      test('should handle invalid data gracefully', () async {
        // Arrange
        when(mockClient.from('tasting_sets')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select(any)).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.order('name')).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.then()).thenAnswer((_) async => [
          {'invalid': 'data'}, // Invalid TastingSet data
        ]);

        // Act & Assert
        expect(
          () => service.getAllTastingSets(),
          throwsA(isA<TypeError>()),
        );
      });
    });
  });
}
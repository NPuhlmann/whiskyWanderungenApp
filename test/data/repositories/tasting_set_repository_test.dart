import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:whisky_hikes/data/repositories/tasting_set_repository.dart';
import 'package:whisky_hikes/data/services/database/backend_api.dart';
import 'package:whisky_hikes/domain/models/tasting_set.dart';

import '../../mocks/mock_backend_api_service.dart';

void main() {
  group('TastingSetRepository Tests', () {
    late MockBackendApiService mockBackendApiService;
    late TastingSetRepository repository;

    setUp(() {
      mockBackendApiService = MockBackendApiService();
      repository = TastingSetRepository(mockBackendApiService);
    });

    group('getTastingSetForHike', () {
      const int hikeId = 1;

      test('should return tasting set when found', () async {
        // Arrange
        final expectedTastingSet = TastingSet(
          id: 1,
          hikeId: hikeId,
          name: 'Highland Collection',
          description: 'A curated selection of Highland whiskies',
          samples: [
            const WhiskySample(
              id: 1,
              name: 'Glenlivet 12',
              region: 'Speyside',
              distillery: 'Glenlivet',
              sampleSizeMl: 30.0,
              age: 12,
              abv: 40.0,
              notes: 'Fruity and floral with honey notes',
            ),
            const WhiskySample(
              id: 2,
              name: 'Macallan 18',
              region: 'Speyside', 
              distillery: 'Macallan',
              sampleSizeMl: 25.0,
              age: 18,
              abv: 43.0,
              notes: 'Rich sherry influence with dried fruits',
            ),
          ],
        );

        when(mockBackendApiService.getTastingSetForHike(hikeId))
            .thenAnswer((_) async => expectedTastingSet);

        // Act
        final result = await repository.getTastingSetForHike(hikeId);

        // Assert
        expect(result, equals(expectedTastingSet));
        expect(result!.id, equals(1));
        expect(result.hikeId, equals(hikeId));
        expect(result.name, equals('Highland Collection'));
        expect(result.samples.length, equals(2));
        expect(result.samples[0].name, equals('Glenlivet 12'));
        expect(result.samples[1].name, equals('Macallan 18'));
        verify(mockBackendApiService.getTastingSetForHike(hikeId)).called(1);
      });

      test('should return null when no tasting set found', () async {
        // Arrange
        when(mockBackendApiService.getTastingSetForHike(hikeId))
            .thenAnswer((_) async => null);

        // Act
        final result = await repository.getTastingSetForHike(hikeId);

        // Assert
        expect(result, isNull);
        verify(mockBackendApiService.getTastingSetForHike(hikeId)).called(1);
      });

      test('should throw exception when backend service fails', () async {
        // Arrange
        const errorMessage = 'Database connection failed';
        when(mockBackendApiService.getTastingSetForHike(hikeId))
            .thenThrow(Exception(errorMessage));

        // Act & Assert
        expect(
          () => repository.getTastingSetForHike(hikeId),
          throwsA(isA<Exception>()),
        );
        verify(mockBackendApiService.getTastingSetForHike(hikeId)).called(1);
      });

      test('should handle invalid hikeId gracefully', () async {
        // Arrange
        const invalidHikeId = -1;
        when(mockBackendApiService.getTastingSetForHike(invalidHikeId))
            .thenAnswer((_) async => null);

        // Act
        final result = await repository.getTastingSetForHike(invalidHikeId);

        // Assert
        expect(result, isNull);
        verify(mockBackendApiService.getTastingSetForHike(invalidHikeId)).called(1);
      });
    });

    group('createTastingSet', () {
      test('should create tasting set successfully', () async {
        // Arrange
        final tastingSetToCreate = TastingSet(
          id: 0, // ID will be assigned by backend
          hikeId: 2,
          name: 'Islay Explorer',
          description: 'Peated whiskies from Islay',
          samples: [
            const WhiskySample(
              id: 0,
              name: 'Ardbeg 10',
              region: 'Islay',
              distillery: 'Ardbeg',
              sampleSizeMl: 25.0,
              age: 10,
              abv: 46.0,
              notes: 'Heavily peated with smoky intensity',
            ),
          ],
        );

        final createdTastingSet = tastingSetToCreate.copyWith(id: 5);

        when(mockBackendApiService.createTastingSet(tastingSetToCreate))
            .thenAnswer((_) async => createdTastingSet);

        // Act
        final result = await repository.createTastingSet(tastingSetToCreate);

        // Assert
        expect(result, equals(createdTastingSet));
        expect(result.id, equals(5));
        expect(result.hikeId, equals(2));
        expect(result.name, equals('Islay Explorer'));
        verify(mockBackendApiService.createTastingSet(tastingSetToCreate)).called(1);
      });

      test('should throw exception when creation fails', () async {
        // Arrange
        final tastingSetToCreate = TastingSet(
          id: 0,
          hikeId: 1,
          name: 'Test Set',
          description: 'Test description',
          samples: const [],
        );

        when(mockBackendApiService.createTastingSet(tastingSetToCreate))
            .thenThrow(Exception('Creation failed'));

        // Act & Assert
        expect(
          () => repository.createTastingSet(tastingSetToCreate),
          throwsA(isA<Exception>()),
        );
        verify(mockBackendApiService.createTastingSet(tastingSetToCreate)).called(1);
      });
    });

    group('updateTastingSet', () {
      test('should update tasting set successfully', () async {
        // Arrange
        final tastingSetToUpdate = TastingSet(
          id: 3,
          hikeId: 1,
          name: 'Updated Highland Collection',
          description: 'Updated description with more samples',
          samples: [
            const WhiskySample(
              id: 1,
              name: 'Glenlivet 12',
              region: 'Speyside',
              distillery: 'Glenlivet',
              sampleSizeMl: 30.0,
            ),
            const WhiskySample(
              id: 2,
              name: 'Glenfiddich 15',
              region: 'Speyside',
              distillery: 'Glenfiddich',
              sampleSizeMl: 25.0,
            ),
          ],
        );

        when(mockBackendApiService.updateTastingSet(tastingSetToUpdate))
            .thenAnswer((_) async => tastingSetToUpdate);

        // Act
        final result = await repository.updateTastingSet(tastingSetToUpdate);

        // Assert
        expect(result, equals(tastingSetToUpdate));
        expect(result.name, equals('Updated Highland Collection'));
        expect(result.samples.length, equals(2));
        verify(mockBackendApiService.updateTastingSet(tastingSetToUpdate)).called(1);
      });

      test('should throw exception when update fails', () async {
        // Arrange
        final tastingSetToUpdate = TastingSet(
          id: 1,
          hikeId: 1,
          name: 'Test Set',
          description: 'Test',
          samples: const [],
        );

        when(mockBackendApiService.updateTastingSet(tastingSetToUpdate))
            .thenThrow(Exception('Update failed'));

        // Act & Assert
        expect(
          () => repository.updateTastingSet(tastingSetToUpdate),
          throwsA(isA<Exception>()),
        );
        verify(mockBackendApiService.updateTastingSet(tastingSetToUpdate)).called(1);
      });
    });

    group('deleteTastingSet', () {
      test('should delete tasting set successfully', () async {
        // Arrange
        const tastingSetId = 1;
        when(mockBackendApiService.deleteTastingSet(tastingSetId))
            .thenAnswer((_) async => true);

        // Act
        final result = await repository.deleteTastingSet(tastingSetId);

        // Assert
        expect(result, isTrue);
        verify(mockBackendApiService.deleteTastingSet(tastingSetId)).called(1);
      });

      test('should return false when deletion fails', () async {
        // Arrange
        const tastingSetId = 1;
        when(mockBackendApiService.deleteTastingSet(tastingSetId))
            .thenAnswer((_) async => false);

        // Act
        final result = await repository.deleteTastingSet(tastingSetId);

        // Assert
        expect(result, isFalse);
        verify(mockBackendApiService.deleteTastingSet(tastingSetId)).called(1);
      });

      test('should throw exception when backend service fails', () async {
        // Arrange
        const tastingSetId = 1;
        when(mockBackendApiService.deleteTastingSet(tastingSetId))
            .thenThrow(Exception('Delete operation failed'));

        // Act & Assert
        expect(
          () => repository.deleteTastingSet(tastingSetId),
          throwsA(isA<Exception>()),
        );
        verify(mockBackendApiService.deleteTastingSet(tastingSetId)).called(1);
      });
    });

    group('getAllTastingSets', () {
      test('should return list of all tasting sets', () async {
        // Arrange
        final expectedTastingSets = [
          TastingSet(
            id: 1,
            hikeId: 1,
            name: 'Highland Collection',
            description: 'Highland whiskies',
            samples: const [],
          ),
          TastingSet(
            id: 2,
            hikeId: 2,
            name: 'Islay Collection',
            description: 'Peated whiskies from Islay',
            samples: const [],
          ),
        ];

        when(mockBackendApiService.getAllTastingSets())
            .thenAnswer((_) async => expectedTastingSets);

        // Act
        final result = await repository.getAllTastingSets();

        // Assert
        expect(result, equals(expectedTastingSets));
        expect(result.length, equals(2));
        expect(result[0].name, equals('Highland Collection'));
        expect(result[1].name, equals('Islay Collection'));
        verify(mockBackendApiService.getAllTastingSets()).called(1);
      });

      test('should return empty list when no tasting sets found', () async {
        // Arrange
        when(mockBackendApiService.getAllTastingSets())
            .thenAnswer((_) async => []);

        // Act
        final result = await repository.getAllTastingSets();

        // Assert
        expect(result, isEmpty);
        verify(mockBackendApiService.getAllTastingSets()).called(1);
      });

      test('should throw exception when backend service fails', () async {
        // Arrange
        when(mockBackendApiService.getAllTastingSets())
            .thenThrow(Exception('Network error'));

        // Act & Assert
        expect(
          () => repository.getAllTastingSets(),
          throwsA(isA<Exception>()),
        );
        verify(mockBackendApiService.getAllTastingSets()).called(1);
      });
    });

    group('Error Handling', () {
      test('should handle network timeout gracefully', () async {
        // Arrange
        when(mockBackendApiService.getTastingSetForHike(any))
            .thenThrow(Exception('Network timeout'));

        // Act & Assert
        expect(
          () => repository.getTastingSetForHike(1),
          throwsA(allOf(
            isA<Exception>(),
            predicate<Exception>((e) => e.toString().contains('Network timeout')),
          )),
        );
      });

      test('should propagate specific error messages from backend', () async {
        // Arrange
        const specificError = 'Tasting set not found for hike ID 999';
        when(mockBackendApiService.getTastingSetForHike(999))
            .thenThrow(Exception(specificError));

        // Act & Assert
        expect(
          () => repository.getTastingSetForHike(999),
          throwsA(allOf(
            isA<Exception>(),
            predicate<Exception>((e) => e.toString().contains(specificError)),
          )),
        );
      });
    });

    group('Business Logic Integration', () {
      test('should ensure tasting set belongs to correct hike', () async {
        // Arrange
        const hikeId = 5;
        final tastingSet = TastingSet(
          id: 1,
          hikeId: hikeId,
          name: 'Test Set',
          description: 'Test',
          samples: const [],
        );

        when(mockBackendApiService.getTastingSetForHike(hikeId))
            .thenAnswer((_) async => tastingSet);

        // Act
        final result = await repository.getTastingSetForHike(hikeId);

        // Assert
        expect(result!.hikeId, equals(hikeId));
        expect(result.hikeId, equals(tastingSet.hikeId));
      });

      test('should maintain sample order in tasting set', () async {
        // Arrange
        final tastingSet = TastingSet(
          id: 1,
          hikeId: 1,
          name: 'Ordered Set',
          description: 'Test ordering',
          samples: [
            const WhiskySample(id: 1, name: 'First', region: 'A', distillery: 'D1', sampleSizeMl: 25.0),
            const WhiskySample(id: 2, name: 'Second', region: 'B', distillery: 'D2', sampleSizeMl: 25.0),
            const WhiskySample(id: 3, name: 'Third', region: 'C', distillery: 'D3', sampleSizeMl: 25.0),
          ],
        );

        when(mockBackendApiService.getTastingSetForHike(1))
            .thenAnswer((_) async => tastingSet);

        // Act
        final result = await repository.getTastingSetForHike(1);

        // Assert
        expect(result!.samples[0].name, equals('First'));
        expect(result.samples[1].name, equals('Second'));
        expect(result.samples[2].name, equals('Third'));
      });
    });
  });
}
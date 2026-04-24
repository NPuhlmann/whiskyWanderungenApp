import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:whisky_hikes/data/providers/whisky_management_provider.dart';
import 'package:whisky_hikes/data/services/whisky/whisky_management_service.dart';
import 'package:whisky_hikes/domain/models/tasting_set.dart';

import '../../test_helpers.dart';
import '../../mocks/mock_services.mocks.dart';

void main() {
  group('WhiskyManagementProvider', () {
    late WhiskyManagementProvider provider;
    late MockWhiskyManagementService mockService;

    setUp(() {
      mockService = MockWhiskyManagementService();
      provider = WhiskyManagementProvider(mockService);
    });

    group('Initialization', () {
      test('should initialize with correct default values', () {
        expect(provider.tastingSets, isEmpty);
        expect(provider.whiskySamples, isEmpty);
        expect(provider.isLoading, false);
        expect(provider.error, isNull);
        expect(provider.searchQuery, equals(''));
        expect(provider.selectedRegion, isNull);
        expect(provider.selectedDistillery, isNull);
        expect(provider.sortBy, equals(TastingSetSortBy.name));
        expect(provider.sortAscending, true);
      });

      test('should load tasting sets on initialization', () async {
        final testSets = TestHelpers.createSampleTastingSets();

        when(mockService.getAllTastingSets()).thenAnswer((_) async => testSets);

        await provider.loadTastingSets();

        expect(provider.tastingSets, hasLength(3));
        expect(provider.tastingSets.first.name, equals('Highland Collection'));
        expect(provider.isLoading, false);
        expect(provider.error, isNull);
      });
    });

    group('Loading States', () {
      test('should set loading state during data fetching', () async {
        when(mockService.getAllTastingSets()).thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 100));
          return TestHelpers.createSampleTastingSets();
        });

        final loadingFuture = provider.loadTastingSets();

        expect(provider.isLoading, true);

        await loadingFuture;

        expect(provider.isLoading, false);
      });

      test('should handle loading errors gracefully', () async {
        const errorMessage = 'Database connection failed';

        when(
          mockService.getAllTastingSets(),
        ).thenThrow(Exception(errorMessage));

        await provider.loadTastingSets();

        expect(provider.isLoading, false);
        expect(provider.error, contains(errorMessage));
        expect(provider.tastingSets, isEmpty);
      });

      test('should clear error when loading succeeds after error', () async {
        // First call fails
        when(
          mockService.getAllTastingSets(),
        ).thenThrow(Exception('Network error'));

        await provider.loadTastingSets();
        expect(provider.error, isNotNull);

        // Second call succeeds
        when(
          mockService.getAllTastingSets(),
        ).thenAnswer((_) async => TestHelpers.createSampleTastingSets());

        await provider.loadTastingSets();
        expect(provider.error, isNull);
      });
    });

    group('Tasting Set Management', () {
      test('should create tasting set successfully', () async {
        final newSet = TestHelpers.createTestTastingSet(
          name: 'New Collection',
          hikeId: 100,
        );
        final createdSet = newSet.copyWith(id: 999);

        when(
          mockService.createTastingSet(newSet),
        ).thenAnswer((_) async => createdSet);
        when(
          mockService.getAllTastingSets(),
        ).thenAnswer((_) async => [createdSet]);

        await provider.createTastingSet(newSet);

        expect(provider.tastingSets, contains(createdSet));
        verify(mockService.createTastingSet(newSet)).called(1);
        verify(mockService.getAllTastingSets()).called(1);
      });

      test('should update tasting set successfully', () async {
        final initialSets = TestHelpers.createSampleTastingSets();
        final updatedSet = initialSets.first.copyWith(
          name: 'Updated Highland Collection',
          description: 'Updated description',
        );

        when(
          mockService.getAllTastingSets(),
        ).thenAnswer((_) async => initialSets);

        await provider.loadTastingSets();

        when(
          mockService.updateTastingSet(updatedSet),
        ).thenAnswer((_) async => updatedSet);
        when(
          mockService.getAllTastingSets(),
        ).thenAnswer((_) async => [updatedSet, ...initialSets.skip(1)]);

        await provider.updateTastingSet(updatedSet);

        expect(
          provider.tastingSets.first.name,
          equals('Updated Highland Collection'),
        );
        verify(mockService.updateTastingSet(updatedSet)).called(1);
      });

      test('should delete tasting set successfully', () async {
        final initialSets = TestHelpers.createSampleTastingSets();

        when(
          mockService.getAllTastingSets(),
        ).thenAnswer((_) async => initialSets);

        await provider.loadTastingSets();
        expect(provider.tastingSets, hasLength(3));

        when(mockService.deleteTastingSet(1)).thenAnswer((_) async {});
        when(
          mockService.getAllTastingSets(),
        ).thenAnswer((_) async => initialSets.skip(1).toList());

        await provider.deleteTastingSet(1);

        expect(provider.tastingSets, hasLength(2));
        expect(provider.tastingSets.every((set) => set.id != 1), true);
        verify(mockService.deleteTastingSet(1)).called(1);
      });

      test('should get tasting set by hike ID', () async {
        final testSet = TestHelpers.createTestTastingSet(hikeId: 100);

        when(
          mockService.getTastingSetByHikeId(100),
        ).thenAnswer((_) async => testSet);

        final result = await provider.getTastingSetByHikeId(100);

        expect(result, isNotNull);
        expect(result!.hikeId, equals(100));
        verify(mockService.getTastingSetByHikeId(100)).called(1);
      });
    });

    group('Whisky Sample Management', () {
      test('should load whisky samples for tasting set', () async {
        final testSamples = TestHelpers.createSampleWhiskySamples();

        when(
          mockService.getWhiskySamplesByTastingSetId(1),
        ).thenAnswer((_) async => testSamples);

        await provider.loadWhiskySamples(1);

        expect(provider.whiskySamples, hasLength(3));
        expect(provider.whiskySamples.first.name, equals('Glenfiddich 12'));
        verify(mockService.getWhiskySamplesByTastingSetId(1)).called(1);
      });

      test('should create whisky sample successfully', () async {
        final newSample = TestHelpers.createTestWhiskySample(
          name: 'New Whisky',
          distillery: 'New Distillery',
        );
        final createdSample = newSample.copyWith(id: 999);

        when(
          mockService.createWhiskySample(newSample),
        ).thenAnswer((_) async => createdSample);
        when(
          mockService.getWhiskySamplesByTastingSetId(1),
        ).thenAnswer((_) async => [createdSample]);

        await provider.createWhiskySample(newSample, tastingSetId: 1);

        expect(provider.whiskySamples, contains(createdSample));
        verify(mockService.createWhiskySample(newSample)).called(1);
      });

      test('should update whisky sample successfully', () async {
        final initialSamples = TestHelpers.createSampleWhiskySamples();
        final updatedSample = initialSamples.first.copyWith(
          name: 'Updated Glenfiddich 12',
          age: 15,
        );

        when(
          mockService.getWhiskySamplesByTastingSetId(1),
        ).thenAnswer((_) async => initialSamples);

        await provider.loadWhiskySamples(1);

        when(
          mockService.updateWhiskySample(updatedSample),
        ).thenAnswer((_) async => updatedSample);
        when(
          mockService.getWhiskySamplesByTastingSetId(1),
        ).thenAnswer((_) async => [updatedSample, ...initialSamples.skip(1)]);

        await provider.updateWhiskySample(updatedSample, tastingSetId: 1);

        expect(
          provider.whiskySamples.first.name,
          equals('Updated Glenfiddich 12'),
        );
        expect(provider.whiskySamples.first.age, equals(15));
      });

      test('should delete whisky sample successfully', () async {
        final initialSamples = TestHelpers.createSampleWhiskySamples();

        when(
          mockService.getWhiskySamplesByTastingSetId(1),
        ).thenAnswer((_) async => initialSamples);

        await provider.loadWhiskySamples(1);
        expect(provider.whiskySamples, hasLength(3));

        when(mockService.deleteWhiskySample(1)).thenAnswer((_) async {});
        when(
          mockService.getWhiskySamplesByTastingSetId(1),
        ).thenAnswer((_) async => initialSamples.skip(1).toList());

        await provider.deleteWhiskySample(1, tastingSetId: 1);

        expect(provider.whiskySamples, hasLength(2));
        expect(provider.whiskySamples.every((sample) => sample.id != 1), true);
      });

      test('should reorder whisky samples successfully', () async {
        final samples = TestHelpers.createSampleWhiskySamples();
        final reorderedSamples = [
          samples[2].copyWith(orderIndex: 0),
          samples[0].copyWith(orderIndex: 1),
          samples[1].copyWith(orderIndex: 2),
        ];

        when(
          mockService.updateSampleOrder(reorderedSamples),
        ).thenAnswer((_) async {});
        when(
          mockService.getWhiskySamplesByTastingSetId(1),
        ).thenAnswer((_) async => reorderedSamples);

        await provider.reorderWhiskySamples(reorderedSamples, tastingSetId: 1);

        expect(provider.whiskySamples.first.name, equals('Ardbeg 10'));
        expect(provider.whiskySamples.first.orderIndex, equals(0));
        verify(mockService.updateSampleOrder(reorderedSamples)).called(1);
      });
    });

    group('Search and Filtering', () {
      test('should update search query', () {
        expect(provider.searchQuery, equals(''));

        provider.updateSearchQuery('Highland');

        expect(provider.searchQuery, equals('Highland'));
      });

      test('should filter tasting sets by search query', () async {
        final allSets = TestHelpers.createSampleTastingSets();
        final filteredSets = [allSets.first]; // Highland Collection

        when(mockService.getAllTastingSets()).thenAnswer((_) async => allSets);
        when(
          mockService.searchTastingSets('Highland'),
        ).thenAnswer((_) async => filteredSets);

        await provider.loadTastingSets();
        provider.updateSearchQuery('Highland');
        await provider.applyFilters();

        expect(provider.filteredTastingSets, hasLength(1));
        expect(provider.filteredTastingSets.first.name, contains('Highland'));
      });

      test('should filter by region', () async {
        final allSets = TestHelpers.createSampleTastingSets();

        when(mockService.getAllTastingSets()).thenAnswer((_) async => allSets);

        await provider.loadTastingSets();
        provider.updateRegionFilter('Islay');

        expect(provider.selectedRegion, equals('Islay'));

        final filteredSets = provider.filteredTastingSets;
        final islaySet = filteredSets.firstWhere(
          (set) => set.name == 'Islay Experience',
          orElse: () => throw StateError('Islay set not found'),
        );
        expect(islaySet.mainRegion, equals('Islay'));
      });

      test('should filter by distillery', () async {
        final allSets = TestHelpers.createSampleTastingSets();

        when(mockService.getAllTastingSets()).thenAnswer((_) async => allSets);

        await provider.loadTastingSets();
        provider.updateDistilleryFilter('Ardbeg');

        expect(provider.selectedDistillery, equals('Ardbeg'));
      });

      test('should clear all filters', () async {
        final allSets = TestHelpers.createSampleTastingSets();

        when(mockService.getAllTastingSets()).thenAnswer((_) async => allSets);

        await provider.loadTastingSets();

        // Apply filters
        provider.updateSearchQuery('Highland');
        provider.updateRegionFilter('Speyside');
        provider.updateDistilleryFilter('Macallan');

        // Clear filters
        provider.clearFilters();

        expect(provider.searchQuery, equals(''));
        expect(provider.selectedRegion, isNull);
        expect(provider.selectedDistillery, isNull);
        expect(provider.filteredTastingSets, equals(provider.tastingSets));
      });
    });

    group('Sorting', () {
      test('should sort by name ascending by default', () async {
        final unsortedSets = [
          TestHelpers.createTestTastingSet(id: 1, name: 'Zebra Set'),
          TestHelpers.createTestTastingSet(id: 2, name: 'Alpha Set'),
          TestHelpers.createTestTastingSet(id: 3, name: 'Beta Set'),
        ];

        when(
          mockService.getAllTastingSets(),
        ).thenAnswer((_) async => unsortedSets);

        await provider.loadTastingSets();

        final sortedNames = provider.filteredTastingSets
            .map((set) => set.name)
            .toList();
        expect(sortedNames, equals(['Alpha Set', 'Beta Set', 'Zebra Set']));
      });

      test('should sort by name descending when toggled', () async {
        final unsortedSets = [
          TestHelpers.createTestTastingSet(id: 1, name: 'Alpha Set'),
          TestHelpers.createTestTastingSet(id: 2, name: 'Beta Set'),
          TestHelpers.createTestTastingSet(id: 3, name: 'Zebra Set'),
        ];

        when(
          mockService.getAllTastingSets(),
        ).thenAnswer((_) async => unsortedSets);

        await provider.loadTastingSets();

        // Toggle sort order to descending (starts ascending by default)
        provider.toggleSortOrder();

        final sortedNames = provider.filteredTastingSets
            .map((set) => set.name)
            .toList();
        expect(sortedNames, equals(['Zebra Set', 'Beta Set', 'Alpha Set']));
        expect(provider.sortAscending, false);
      });

      test('should sort by sample count', () async {
        final sets = [
          TestHelpers.createTestTastingSet(
            id: 1,
            name: 'Small Set',
            samples: [TestHelpers.createTestWhiskySample()],
          ),
          TestHelpers.createTestTastingSet(
            id: 2,
            name: 'Large Set',
            samples: TestHelpers.createSampleWhiskySamples(),
          ),
          TestHelpers.createTestTastingSet(
            id: 3,
            name: 'Medium Set',
            samples: TestHelpers.createSampleWhiskySamples().take(2).toList(),
          ),
        ];

        when(mockService.getAllTastingSets()).thenAnswer((_) async => sets);

        await provider.loadTastingSets();
        provider.updateSortBy(TastingSetSortBy.sampleCount);

        final sortedNames = provider.filteredTastingSets
            .map((set) => set.name)
            .toList();
        expect(sortedNames, equals(['Small Set', 'Medium Set', 'Large Set']));
      });

      test('should sort by average age', () async {
        final sets = [
          TestHelpers.createTestTastingSet(
            id: 1,
            name: 'Young Set',
            samples: [TestHelpers.createTestWhiskySample(age: 10)],
          ),
          TestHelpers.createTestTastingSet(
            id: 2,
            name: 'Old Set',
            samples: [TestHelpers.createTestWhiskySample(age: 25)],
          ),
          TestHelpers.createTestTastingSet(
            id: 3,
            name: 'Mixed Set',
            samples: [
              TestHelpers.createTestWhiskySample(age: 12),
              TestHelpers.createTestWhiskySample(age: 18),
            ],
          ),
        ];

        when(mockService.getAllTastingSets()).thenAnswer((_) async => sets);

        await provider.loadTastingSets();
        provider.updateSortBy(TastingSetSortBy.averageAge);

        final sortedNames = provider.filteredTastingSets
            .map((set) => set.name)
            .toList();
        expect(sortedNames, equals(['Young Set', 'Mixed Set', 'Old Set']));
      });
    });

    group('Image Management', () {
      test('should upload whisky image successfully', () async {
        final imageBytes = Uint8List.fromList(
          List.generate(100, (index) => index % 256),
        );
        const imageUrl = 'https://storage.example.com/whisky_123.jpg';

        when(
          mockService.uploadWhiskyImage(123, imageBytes, 'jpg'),
        ).thenAnswer((_) async => imageUrl);

        final result = await provider.uploadWhiskyImage(123, imageBytes, 'jpg');

        expect(result, equals(imageUrl));
        verify(mockService.uploadWhiskyImage(123, imageBytes, 'jpg')).called(1);
      });

      test('should upload tasting set image successfully', () async {
        final imageBytes = Uint8List.fromList(
          List.generate(100, (index) => index % 256),
        );
        const imageUrl = 'https://storage.example.com/tasting_set_456.jpg';

        when(
          mockService.uploadTastingSetImage(456, imageBytes, 'jpg'),
        ).thenAnswer((_) async => imageUrl);

        final result = await provider.uploadTastingSetImage(
          456,
          imageBytes,
          'jpg',
        );

        expect(result, equals(imageUrl));
        verify(
          mockService.uploadTastingSetImage(456, imageBytes, 'jpg'),
        ).called(1);
      });

      test('should handle image upload errors gracefully', () async {
        final imageBytes = Uint8List.fromList(
          List.generate(100, (index) => index % 256),
        );

        when(
          mockService.uploadWhiskyImage(123, imageBytes, 'jpg'),
        ).thenThrow(Exception('Upload failed'));

        expect(
          () => provider.uploadWhiskyImage(123, imageBytes, 'jpg'),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('Statistics', () {
      test('should load tasting set statistics', () async {
        final statsData = {
          'totalSets': 5,
          'availableSets': 4,
          'totalSamples': 15,
          'averageSamplesPerSet': 3.0,
          'regionDistribution': {'Speyside': 8, 'Islay': 4, 'Highlands': 3},
        };

        when(
          mockService.getTastingSetStatistics(),
        ).thenAnswer((_) async => statsData);

        await provider.loadStatistics();

        expect(provider.statistics, equals(statsData));
        expect(provider.statistics!['totalSets'], equals(5));
        expect(provider.statistics!['availableSets'], equals(4));
        verify(mockService.getTastingSetStatistics()).called(1);
      });

      test('should load popular distilleries', () async {
        final popularDistilleries = [
          {'distillery': 'Macallan', 'sampleCount': 8},
          {'distillery': 'Glenfiddich', 'sampleCount': 6},
          {'distillery': 'Ardbeg', 'sampleCount': 4},
        ];

        when(
          mockService.getPopularDistilleries(limit: 10),
        ).thenAnswer((_) async => popularDistilleries);

        await provider.loadPopularDistilleries();

        expect(provider.popularDistilleries, equals(popularDistilleries));
        expect(
          provider.popularDistilleries.first['distillery'],
          equals('Macallan'),
        );
        verify(mockService.getPopularDistilleries(limit: 10)).called(1);
      });
    });

    group('Validation', () {
      test('should validate tasting set data', () {
        final validSet = TestHelpers.createTestTastingSet(
          name: 'Valid Set',
          description: 'Valid description',
        );

        final invalidSet = TestHelpers.createTestTastingSet(
          name: '', // Invalid: empty name
          description: 'Valid description',
        );

        expect(provider.validateTastingSet(validSet), isNull);
        expect(provider.validateTastingSet(invalidSet), isNotNull);
      });

      test('should validate whisky sample data', () {
        final validSample = TestHelpers.createTestWhiskySample(
          name: 'Valid Whisky',
          distillery: 'Valid Distillery',
          age: 12,
          abv: 43.0,
          region: 'Speyside',
        );

        final invalidSample = TestHelpers.createTestWhiskySample(
          name: '', // Invalid: empty name
          distillery: 'Valid Distillery',
          age: -1, // Invalid: negative age
          abv: 101.0, // Invalid: ABV over 100%
          region: '',
        );

        expect(provider.validateWhiskySample(validSample), isNull);
        expect(provider.validateWhiskySample(invalidSample), isNotNull);
      });
    });

    group('Error Handling', () {
      test('should handle service errors during CRUD operations', () async {
        final testSet = TestHelpers.createTestTastingSet();

        when(
          mockService.createTastingSet(testSet),
        ).thenThrow(Exception('Database error'));

        await provider.createTastingSet(testSet);

        expect(provider.error, contains('Database error'));
        expect(provider.isLoading, false);
      });

      test('should reset error state on successful operations', () async {
        // First operation fails
        when(
          mockService.getAllTastingSets(),
        ).thenThrow(Exception('Network error'));

        await provider.loadTastingSets();
        expect(provider.error, isNotNull);

        // Second operation succeeds
        when(
          mockService.getAllTastingSets(),
        ).thenAnswer((_) async => TestHelpers.createSampleTastingSets());

        await provider.loadTastingSets();
        expect(provider.error, isNull);
      });
    });
  });
}

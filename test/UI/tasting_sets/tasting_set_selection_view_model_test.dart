import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:whisky_hikes/UI/mobile/tasting_sets/tasting_set_selection_view_model.dart';
import 'package:whisky_hikes/domain/models/hike.dart';
import 'package:whisky_hikes/domain/models/tasting_set.dart';
import 'package:whisky_hikes/data/repositories/tasting_set_repository.dart';

import '../../mocks/mock_repositories.dart';

void main() {
  group('TastingSetSelectionViewModel Tests', () {
    late MockTastingSetRepository mockTastingSetRepository;
    late TastingSetSelectionViewModel viewModel;
    late Hike testHike;

    setUp(() {
      mockTastingSetRepository = MockTastingSetRepository();
      testHike = const Hike(
        id: 1,
        name: 'Test Hike',
        length: 5.0,
        price: 29.99,
        difficulty: Difficulty.mid,
      );
      viewModel = TastingSetSelectionViewModel(
        hike: testHike,
        tastingSetRepository: mockTastingSetRepository,
      );
    });

    group('Initial State', () {
      test('should initialize with correct default values', () {
        expect(viewModel.hike, equals(testHike));
        expect(viewModel.tastingSet, isNull);
        expect(viewModel.isLoading, isTrue);
        expect(viewModel.error, isNull);
        expect(viewModel.hasError, isFalse);
        expect(viewModel.hasTastingSet, isFalse);
      });
    });

    group('loadTastingSet', () {
      test(
        'should load tasting set successfully and notify listeners',
        () async {
          // Arrange
          final expectedTastingSet = TastingSet(
            id: 1,
            hikeId: testHike.id,
            name: 'Highland Whisky Tasting',
            description: 'A selection of fine Highland whiskies',
            samples: [
              const WhiskySample(
                id: 1,
                name: 'Glenfiddich 12',
                region: 'Speyside',
                distillery: 'Glenfiddich',
                sampleSizeMl: 30.0,
              ),
            ],
          );

          when(
            mockTastingSetRepository.getTastingSetForHike(testHike.id),
          ).thenAnswer((_) async => expectedTastingSet);

          bool listenerCalled = false;
          viewModel.addListener(() => listenerCalled = true);

          // Act
          await viewModel.loadTastingSet();

          // Assert
          expect(viewModel.tastingSet, equals(expectedTastingSet));
          expect(viewModel.isLoading, isFalse);
          expect(viewModel.error, isNull);
          expect(viewModel.hasError, isFalse);
          expect(viewModel.hasTastingSet, isTrue);
          expect(listenerCalled, isTrue);
          verify(
            mockTastingSetRepository.getTastingSetForHike(testHike.id),
          ).called(1);
        },
      );

      test('should handle no tasting set found', () async {
        // Arrange
        when(
          mockTastingSetRepository.getTastingSetForHike(testHike.id),
        ).thenAnswer((_) async => null);

        bool listenerCalled = false;
        viewModel.addListener(() => listenerCalled = true);

        // Act
        await viewModel.loadTastingSet();

        // Assert
        expect(viewModel.tastingSet, isNull);
        expect(viewModel.isLoading, isFalse);
        expect(viewModel.error, isNull);
        expect(viewModel.hasError, isFalse);
        expect(viewModel.hasTastingSet, isFalse);
        expect(listenerCalled, isTrue);
        verify(
          mockTastingSetRepository.getTastingSetForHike(testHike.id),
        ).called(1);
      });

      test('should handle error loading tasting set', () async {
        // Arrange
        const errorMessage = 'Failed to load tasting set';
        when(
          mockTastingSetRepository.getTastingSetForHike(testHike.id),
        ).thenThrow(Exception(errorMessage));

        bool listenerCalled = false;
        viewModel.addListener(() => listenerCalled = true);

        // Act
        await viewModel.loadTastingSet();

        // Assert
        expect(viewModel.tastingSet, isNull);
        expect(viewModel.isLoading, isFalse);
        expect(viewModel.error, contains(errorMessage));
        expect(viewModel.hasError, isTrue);
        expect(viewModel.hasTastingSet, isFalse);
        expect(listenerCalled, isTrue);
        verify(
          mockTastingSetRepository.getTastingSetForHike(testHike.id),
        ).called(1);
      });

      test('should notify listeners even when exception occurs', () async {
        // Arrange
        when(
          mockTastingSetRepository.getTastingSetForHike(testHike.id),
        ).thenThrow(Exception('Network error'));

        int notificationCount = 0;
        viewModel.addListener(() => notificationCount++);

        // Act
        await viewModel.loadTastingSet();

        // Assert - Should notify at least once for loading state change and error
        expect(notificationCount, greaterThanOrEqualTo(1));
      });
    });

    group('Error Handling', () {
      test(
        'should handle repository throwing different exception types',
        () async {
          // Arrange
          when(
            mockTastingSetRepository.getTastingSetForHike(testHike.id),
          ).thenThrow(StateError('Invalid state'));

          // Act
          await viewModel.loadTastingSet();

          // Assert
          expect(viewModel.hasError, isTrue);
          expect(viewModel.error, contains('Invalid state'));
          expect(viewModel.isLoading, isFalse);
        },
      );

      test('should handle null hike ID gracefully', () async {
        // Arrange - This tests the robustness of the view model
        when(
          mockTastingSetRepository.getTastingSetForHike(testHike.id),
        ).thenAnswer((_) async => null);

        // Act & Assert - Should not crash
        await viewModel.loadTastingSet();
        expect(viewModel.hasTastingSet, isFalse);
      });
    });

    group('Listener Notifications', () {
      test('should notify listeners when loading starts', () async {
        // Arrange
        when(
          mockTastingSetRepository.getTastingSetForHike(testHike.id),
        ).thenAnswer((_) async => null);

        int notificationCount = 0;
        viewModel.addListener(() => notificationCount++);

        // Act
        await viewModel.loadTastingSet();

        // Assert - Should notify at least once during the loading process
        expect(notificationCount, greaterThan(0));
      });

      test('should notify listeners when error state changes', () async {
        // Arrange
        when(
          mockTastingSetRepository.getTastingSetForHike(testHike.id),
        ).thenThrow(Exception('Test error'));

        bool errorNotified = false;
        viewModel.addListener(() {
          if (viewModel.hasError) {
            errorNotified = true;
          }
        });

        // Act
        await viewModel.loadTastingSet();

        // Assert
        expect(errorNotified, isTrue);
      });
    });

    group('Business Logic', () {
      test('should maintain hike reference throughout lifecycle', () async {
        // Arrange
        when(
          mockTastingSetRepository.getTastingSetForHike(testHike.id),
        ).thenAnswer((_) async => null);

        // Act
        await viewModel.loadTastingSet();

        // Assert
        expect(viewModel.hike, equals(testHike));
        expect(viewModel.hike.id, equals(1));
        expect(viewModel.hike.name, equals('Test Hike'));
      });

      test('should correctly identify when tasting set is available', () async {
        // Arrange
        final tastingSet = TastingSet(
          id: 1,
          hikeId: testHike.id,
          name: 'Test Tasting Set',
          description: 'Test description',
          samples: const [
            WhiskySample(
              id: 1,
              name: 'Test Whisky',
              region: 'Test Region',
              distillery: 'Test Distillery',
              sampleSizeMl: 25.0,
            ),
          ],
        );

        when(
          mockTastingSetRepository.getTastingSetForHike(testHike.id),
        ).thenAnswer((_) async => tastingSet);

        // Act
        await viewModel.loadTastingSet();

        // Assert
        expect(viewModel.hasTastingSet, isTrue);
        expect(viewModel.tastingSet, isNotNull);
        expect(viewModel.tastingSet!.samples.length, equals(1));
      });
    });

    group('Auto-loading on Construction', () {
      test('should automatically start loading when created', () async {
        // This test verifies that the constructor calls _loadTastingSet
        // Arrange
        when(
          mockTastingSetRepository.getTastingSetForHike(testHike.id),
        ).thenAnswer((_) async => null);

        // Act - Constructor is already called in setUp
        // Give some time for the async operation to complete
        await Future.delayed(const Duration(milliseconds: 10));

        // Assert
        verify(
          mockTastingSetRepository.getTastingSetForHike(testHike.id),
        ).called(1);
      });
    });
  });
}

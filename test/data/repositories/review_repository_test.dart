import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:whisky_hikes/data/repositories/review_repository.dart';
import 'package:whisky_hikes/data/services/database/backend_api.dart';
import 'package:whisky_hikes/domain/models/review.dart';

import 'review_repository_test.mocks.dart';

@GenerateMocks([BackendApiService])
void main() {
  late ReviewRepository reviewRepository;
  late MockBackendApiService mockBackendApi;

  setUp(() {
    mockBackendApi = MockBackendApiService();
    reviewRepository = ReviewRepository(mockBackendApi);
  });

  group('ReviewRepository', () {
    final sampleReview = Review(
      id: 1,
      hikeId: 123,
      userId: 'user-123',
      rating: 4.5,
      comment: 'Fantastischer Whisky-Hike!',
      createdAt: DateTime(2024, 9, 2),
      userFirstName: 'Max',
      userLastName: 'Mustermann',
    );

    group('getReviewsForHike', () {
      test('should return list of reviews for hike', () async {
        when(mockBackendApi.getReviewsForHike(123))
            .thenAnswer((_) async => [sampleReview]);

        final result = await reviewRepository.getReviewsForHike(123);

        expect(result, isA<List<Review>>());
        expect(result.length, equals(1));
        expect(result.first.hikeId, equals(123));
        verify(mockBackendApi.getReviewsForHike(123)).called(1);
      });

      test('should throw exception on backend error', () async {
        when(mockBackendApi.getReviewsForHike(123))
            .thenThrow(Exception('Database error'));

        expect(
          () => reviewRepository.getReviewsForHike(123),
          throwsA(isA<Exception>()),
        );
        verify(mockBackendApi.getReviewsForHike(123)).called(1);
      });
    });

    group('createReview', () {
      test('should create review with valid parameters', () async {
        when(mockBackendApi.createReview(
          hikeId: 123,
          userId: 'user-123',
          rating: 4.5,
          comment: 'Fantastischer Hike!',
        )).thenAnswer((_) async => sampleReview);

        final result = await reviewRepository.createReview(
          hikeId: 123,
          userId: 'user-123',
          rating: 4.5,
          comment: 'Fantastischer Hike!',
        );

        expect(result, equals(sampleReview));
        verify(mockBackendApi.createReview(
          hikeId: 123,
          userId: 'user-123',
          rating: 4.5,
          comment: 'Fantastischer Hike!',
        )).called(1);
      });

      test('should throw ArgumentError for invalid rating', () async {
        expect(
          () => reviewRepository.createReview(
            hikeId: 123,
            userId: 'user-123',
            rating: 0.5, // Invalid rating < 1.0
            comment: 'Test',
          ),
          throwsA(isA<ArgumentError>()),
        );

        expect(
          () => reviewRepository.createReview(
            hikeId: 123,
            userId: 'user-123',
            rating: 5.5, // Invalid rating > 5.0
            comment: 'Test',
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should throw ArgumentError for invalid comment', () async {
        expect(
          () => reviewRepository.createReview(
            hikeId: 123,
            userId: 'user-123',
            rating: 4.0,
            comment: '', // Empty comment
          ),
          throwsA(isA<ArgumentError>()),
        );

        expect(
          () => reviewRepository.createReview(
            hikeId: 123,
            userId: 'user-123',
            rating: 4.0,
            comment: 'A' * 1001, // Too long comment
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should rethrow ArgumentError from validation', () async {
        expect(
          () => reviewRepository.createReview(
            hikeId: 123,
            userId: 'user-123',
            rating: 6.0, // Invalid
            comment: 'Test',
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should wrap other exceptions', () async {
        when(mockBackendApi.createReview(
          hikeId: any,
          userId: any,
          rating: any,
          comment: any,
        )).thenThrow(Exception('Database error'));

        expect(
          () => reviewRepository.createReview(
            hikeId: 123,
            userId: 'user-123',
            rating: 4.0,
            comment: 'Test',
          ),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('updateReview', () {
      test('should update review with valid parameters', () async {
        final updatedReview = sampleReview.copyWith(
          rating: 5.0,
          comment: 'Aktualisierter Kommentar',
        );

        when(mockBackendApi.updateReview(
          reviewId: 1,
          userId: 'user-123',
          rating: 5.0,
          comment: 'Aktualisierter Kommentar',
        )).thenAnswer((_) async => updatedReview);

        final result = await reviewRepository.updateReview(
          reviewId: 1,
          userId: 'user-123',
          rating: 5.0,
          comment: 'Aktualisierter Kommentar',
        );

        expect(result.rating, equals(5.0));
        expect(result.comment, equals('Aktualisierter Kommentar'));
        verify(mockBackendApi.updateReview(
          reviewId: 1,
          userId: 'user-123',
          rating: 5.0,
          comment: 'Aktualisierter Kommentar',
        )).called(1);
      });

      test('should validate rating range when provided', () async {
        expect(
          () => reviewRepository.updateReview(
            reviewId: 1,
            userId: 'user-123',
            rating: 0.5, // Invalid
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should validate comment when provided', () async {
        expect(
          () => reviewRepository.updateReview(
            reviewId: 1,
            userId: 'user-123',
            comment: '', // Empty
          ),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('deleteReview', () {
      test('should delete review successfully', () async {
        when(mockBackendApi.deleteReview(
          reviewId: 1,
          userId: 'user-123',
        )).thenAnswer((_) async {});

        await reviewRepository.deleteReview(
          reviewId: 1,
          userId: 'user-123',
        );

        verify(mockBackendApi.deleteReview(
          reviewId: 1,
          userId: 'user-123',
        )).called(1);
      });

      test('should throw exception on backend error', () async {
        when(mockBackendApi.deleteReview(
          reviewId: 1,
          userId: 'user-123',
        )).thenThrow(Exception('Delete failed'));

        expect(
          () => reviewRepository.deleteReview(
            reviewId: 1,
            userId: 'user-123',
          ),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('getReviewsByUser', () {
      test('should return user reviews', () async {
        when(mockBackendApi.getReviewsByUser('user-123'))
            .thenAnswer((_) async => [sampleReview]);

        final result = await reviewRepository.getReviewsByUser('user-123');

        expect(result, hasLength(1));
        expect(result.first.userId, equals('user-123'));
        verify(mockBackendApi.getReviewsByUser('user-123')).called(1);
      });

      test('should handle empty result', () async {
        when(mockBackendApi.getReviewsByUser('user-123'))
            .thenAnswer((_) async => []);

        final result = await reviewRepository.getReviewsByUser('user-123');

        expect(result, isEmpty);
        verify(mockBackendApi.getReviewsByUser('user-123')).called(1);
      });
    });

    group('getAverageRatingForHike', () {
      test('should return average rating', () async {
        when(mockBackendApi.getAverageRatingForHike(123))
            .thenAnswer((_) async => 4.2);

        final result = await reviewRepository.getAverageRatingForHike(123);

        expect(result, equals(4.2));
        verify(mockBackendApi.getAverageRatingForHike(123)).called(1);
      });

      test('should handle zero rating case', () async {
        when(mockBackendApi.getAverageRatingForHike(123))
            .thenAnswer((_) async => 0.0);

        final result = await reviewRepository.getAverageRatingForHike(123);

        expect(result, equals(0.0));
        verify(mockBackendApi.getAverageRatingForHike(123)).called(1);
      });
    });

    group('getUserReviewForHike', () {
      test('should return user review if exists', () async {
        when(mockBackendApi.getUserReviewForHike(
          hikeId: 123,
          userId: 'user-123',
        )).thenAnswer((_) async => sampleReview);

        final result = await reviewRepository.getUserReviewForHike(
          hikeId: 123,
          userId: 'user-123',
        );

        expect(result, equals(sampleReview));
        verify(mockBackendApi.getUserReviewForHike(
          hikeId: 123,
          userId: 'user-123',
        )).called(1);
      });

      test('should return null if no review exists', () async {
        when(mockBackendApi.getUserReviewForHike(
          hikeId: 123,
          userId: 'user-123',
        )).thenAnswer((_) async => null);

        final result = await reviewRepository.getUserReviewForHike(
          hikeId: 123,
          userId: 'user-123',
        );

        expect(result, isNull);
        verify(mockBackendApi.getUserReviewForHike(
          hikeId: 123,
          userId: 'user-123',
        )).called(1);
      });
    });

    group('getReviewStatsForHike', () {
      test('should return review statistics', () async {
        final stats = {
          'total_reviews': 10,
          'average_rating': 4.2,
          'rating_distribution': {
            '5_stars': 3,
            '4_stars': 4,
            '3_stars': 2,
            '2_stars': 1,
            '1_star': 0,
          }
        };

        when(mockBackendApi.getReviewStatsForHike(123))
            .thenAnswer((_) async => stats);

        final result = await reviewRepository.getReviewStatsForHike(123);

        expect(result['total_reviews'], equals(10));
        expect(result['average_rating'], equals(4.2));
        expect(result['rating_distribution'], isA<Map>());
        verify(mockBackendApi.getReviewStatsForHike(123)).called(1);
      });
    });

    group('getRecentReviews', () {
      test('should return recent reviews with default limit', () async {
        when(mockBackendApi.getRecentReviews(limit: 20))
            .thenAnswer((_) async => [sampleReview]);

        final result = await reviewRepository.getRecentReviews();

        expect(result, hasLength(1));
        expect(result.first, equals(sampleReview));
        verify(mockBackendApi.getRecentReviews(limit: 20)).called(1);
      });

      test('should return recent reviews with custom limit', () async {
        when(mockBackendApi.getRecentReviews(limit: 5))
            .thenAnswer((_) async => [sampleReview]);

        final result = await reviewRepository.getRecentReviews(limit: 5);

        expect(result, hasLength(1));
        verify(mockBackendApi.getRecentReviews(limit: 5)).called(1);
      });
    });
  });
}
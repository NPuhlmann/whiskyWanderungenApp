import 'dart:developer' as dev;

import '../../domain/models/review.dart';
import '../services/database/backend_api.dart';

/// Repository für das Management von Hike-Reviews
class ReviewRepository {
  final BackendApiService _backendApi;

  ReviewRepository(this._backendApi);

  /// Alle Reviews für einen bestimmten Hike abrufen
  Future<List<Review>> getReviewsForHike(int hikeId) async {
    try {
      dev.log('📖 Loading reviews for hike $hikeId');

      final reviews = await _backendApi.getReviewsForHike(hikeId);

      dev.log('✅ Loaded ${reviews.length} reviews for hike $hikeId');
      return reviews;
    } catch (e) {
      dev.log('❌ Error loading reviews for hike $hikeId: $e');
      throw Exception('Fehler beim Laden der Bewertungen: $e');
    }
  }

  /// Neues Review erstellen
  Future<Review> createReview({
    required int hikeId,
    required String userId,
    required double rating,
    required String comment,
  }) async {
    try {
      // Validierung
      if (rating < 1.0 || rating > 5.0) {
        throw ArgumentError('Bewertung muss zwischen 1.0 und 5.0 liegen');
      }

      if (comment.isEmpty || comment.length > 1000) {
        throw ArgumentError(
          'Kommentar darf nicht leer sein und maximal 1000 Zeichen haben',
        );
      }

      dev.log(
        '📝 Creating review for hike $hikeId by user $userId (rating: $rating)',
      );

      final review = await _backendApi.createReview(
        hikeId: hikeId,
        userId: userId,
        rating: rating,
        comment: comment,
      );

      dev.log('✅ Review created: ${review.id}');
      return review;
    } catch (e) {
      dev.log('❌ Error creating review: $e');
      if (e is ArgumentError) rethrow;
      throw Exception('Fehler beim Erstellen der Bewertung: $e');
    }
  }

  /// Review aktualisieren
  Future<Review> updateReview({
    required int reviewId,
    required String userId,
    double? rating,
    String? comment,
  }) async {
    try {
      // Validierung
      if (rating != null && (rating < 1.0 || rating > 5.0)) {
        throw ArgumentError('Bewertung muss zwischen 1.0 und 5.0 liegen');
      }

      if (comment != null && (comment.isEmpty || comment.length > 1000)) {
        throw ArgumentError(
          'Kommentar darf nicht leer sein und maximal 1000 Zeichen haben',
        );
      }

      dev.log('📝 Updating review $reviewId by user $userId');

      final review = await _backendApi.updateReview(
        reviewId: reviewId,
        userId: userId,
        rating: rating,
        comment: comment,
      );

      dev.log('✅ Review updated: ${review.id}');
      return review;
    } catch (e) {
      dev.log('❌ Error updating review: $e');
      if (e is ArgumentError) rethrow;
      throw Exception('Fehler beim Aktualisieren der Bewertung: $e');
    }
  }

  /// Review löschen
  Future<void> deleteReview({
    required int reviewId,
    required String userId,
  }) async {
    try {
      dev.log('🗑️ Deleting review $reviewId by user $userId');

      await _backendApi.deleteReview(reviewId: reviewId, userId: userId);

      dev.log('✅ Review deleted: $reviewId');
    } catch (e) {
      dev.log('❌ Error deleting review: $e');
      throw Exception('Fehler beim Löschen der Bewertung: $e');
    }
  }

  /// Reviews eines Benutzers abrufen
  Future<List<Review>> getReviewsByUser(String userId) async {
    try {
      dev.log('📖 Loading reviews by user $userId');

      final reviews = await _backendApi.getReviewsByUser(userId);

      dev.log('✅ Loaded ${reviews.length} reviews by user $userId');
      return reviews;
    } catch (e) {
      dev.log('❌ Error loading reviews by user $userId: $e');
      throw Exception('Fehler beim Laden der Bewertungen: $e');
    }
  }

  /// Durchschnittsbewertung für einen Hike abrufen
  Future<double> getAverageRatingForHike(int hikeId) async {
    try {
      dev.log('📊 Getting average rating for hike $hikeId');

      final averageRating = await _backendApi.getAverageRatingForHike(hikeId);

      dev.log('✅ Average rating for hike $hikeId: $averageRating');
      return averageRating;
    } catch (e) {
      dev.log('❌ Error getting average rating for hike $hikeId: $e');
      throw Exception('Fehler beim Abrufen der Durchschnittsbewertung: $e');
    }
  }

  /// Prüfen ob ein User bereits ein Review für einen Hike erstellt hat
  Future<Review?> getUserReviewForHike({
    required int hikeId,
    required String userId,
  }) async {
    try {
      dev.log('🔍 Checking user review for hike $hikeId by user $userId');

      final review = await _backendApi.getUserReviewForHike(
        hikeId: hikeId,
        userId: userId,
      );

      if (review != null) {
        dev.log('✅ Found user review: ${review.id}');
      } else {
        dev.log('ℹ️ No review found for user $userId on hike $hikeId');
      }
      return review;
    } catch (e) {
      dev.log('❌ Error checking user review: $e');
      throw Exception('Fehler beim Prüfen der Bewertung: $e');
    }
  }

  /// Bewertungsstatistiken für einen Hike abrufen
  Future<Map<String, dynamic>> getReviewStatsForHike(int hikeId) async {
    try {
      dev.log('📊 Getting review stats for hike $hikeId');

      final stats = await _backendApi.getReviewStatsForHike(hikeId);

      dev.log('✅ Review stats for hike $hikeId: $stats');
      return stats;
    } catch (e) {
      dev.log('❌ Error getting review stats for hike $hikeId: $e');
      throw Exception('Fehler beim Abrufen der Bewertungsstatistiken: $e');
    }
  }

  /// Die neuesten Reviews system-weit abrufen (für Admin/Übersicht)
  Future<List<Review>> getRecentReviews({int limit = 20}) async {
    try {
      dev.log('📖 Loading $limit recent reviews');

      final reviews = await _backendApi.getRecentReviews(limit: limit);

      dev.log('✅ Loaded ${reviews.length} recent reviews');
      return reviews;
    } catch (e) {
      dev.log('❌ Error loading recent reviews: $e');
      throw Exception('Fehler beim Laden der neuesten Bewertungen: $e');
    }
  }
}

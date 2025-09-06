import 'package:whisky_hikes/data/services/database/backend_api.dart';
import 'package:whisky_hikes/domain/models/tasting_set.dart';

/// Repository for managing tasting sets and whisky samples
/// Note: Tasting sets are now 1:1 with hikes and automatically included
class TastingSetRepository {
  final BackendApiService _backendApi;

  TastingSetRepository(this._backendApi);

  /// Get the tasting set for a specific hike (1:1 relationship)
  Future<TastingSet?> getTastingSetForHike(int hikeId) async {
    try {
      final response = await _backendApi.getTastingSetForHike(hikeId);
      return response;
    } catch (e) {
      throw Exception('Fehler beim Laden des Tasting Sets: $e');
    }
  }

  /// Get a specific tasting set by ID with all its samples
  Future<TastingSet?> getTastingSetById(int tastingSetId) async {
    try {
      final response = await _backendApi.getTastingSetById(tastingSetId);
      return response;
    } catch (e) {
      throw Exception('Fehler beim Laden des Tasting Sets: $e');
    }
    }

  /// Get all tasting sets (for admin/company management)
  Future<List<TastingSet>> getAllTastingSets() async {
    try {
      final response = await _backendApi.getAllTastingSets();
      return response;
    } catch (e) {
      throw Exception('Fehler beim Laden aller Tasting Sets: $e');
    }
  }

  /// Get whisky samples for a specific tasting set
  Future<List<WhiskySample>> getWhiskySamplesForTastingSet(int tastingSetId) async {
    try {
      final response = await _backendApi.getWhiskySamplesForTastingSet(tastingSetId);
      return response;
    } catch (e) {
      throw Exception('Fehler beim Laden der Whisky Samples: $e');
    }
  }

  /// Search tasting sets by name or description
  Future<List<TastingSet>> searchTastingSets(String query) async {
    try {
      final response = await _backendApi.searchTastingSets(query);
      return response;
    } catch (e) {
      throw Exception('Fehler bei der Suche nach Tasting Sets: $e');
    }
  }

  /// Get tasting sets by region
  Future<List<TastingSet>> getTastingSetsByRegion(String region) async {
    try {
      final response = await _backendApi.getTastingSetsByRegion(region);
      return response;
    } catch (e) {
      throw Exception('Fehler beim Laden der Tasting Sets nach Region: $e');
    }
  }

  /// Get tasting sets that are currently available (based on date constraints)
  Future<List<TastingSet>> getCurrentlyAvailableTastingSets() async {
    try {
      final response = await _backendApi.getCurrentlyAvailableTastingSets();
      return response;
    } catch (e) {
      throw Exception('Fehler beim Laden der aktuell verfügbaren Tasting Sets: $e');
    }
  }

  /// Update tasting set availability (for companies)
  Future<void> updateTastingSetAvailability({
    required int tastingSetId,
    required bool isAvailable,
    DateTime? availableFrom,
    DateTime? availableUntil,
  }) async {
    try {
      await _backendApi.updateTastingSetAvailability(
        tastingSetId, 
        isAvailable,
      );
    } catch (e) {
      throw Exception('Fehler beim Aktualisieren der Tasting Set Verfügbarkeit: $e');
    }
  }

  /// Get tasting sets with pagination (for admin/company management)
  Future<List<TastingSet>> getTastingSetsWithPagination({
    required int page,
    required int pageSize,
    String? searchQuery,
    String? region,
  }) async {
    try {
      final response = await _backendApi.getTastingSetsWithPagination(
        limit: pageSize,
        offset: page * pageSize,
      );
      return response;
    } catch (e) {
      throw Exception('Fehler beim Laden der Tasting Sets mit Paginierung: $e');
    }
  }

  /// Create a new tasting set for a hike (for companies)
  Future<TastingSet> createTastingSet({
    required int hikeId,
    required String name,
    required String description,
    String? imageUrl,
    DateTime? availableFrom,
    DateTime? availableUntil,
  }) async {
    try {
      final response = await _backendApi.createTastingSet(
        hikeId: hikeId,
        name: name,
        description: description,
        imageUrl: imageUrl,
        availableFrom: availableFrom,
        availableUntil: availableUntil,
      );
      return response;
    } catch (e) {
      throw Exception('Fehler beim Erstellen des Tasting Sets: $e');
    }
  }

  /// Update an existing tasting set (for companies)
  Future<TastingSet> updateTastingSet({
    required int tastingSetId,
    String? name,
    String? description,
    String? imageUrl,
    DateTime? availableFrom,
    DateTime? availableUntil,
  }) async {
    try {
      final response = await _backendApi.updateTastingSet(
        tastingSetId: tastingSetId,
        name: name,
        description: description,
        imageUrl: imageUrl,
        availableFrom: availableFrom,
        availableUntil: availableUntil,
      );
      return response;
    } catch (e) {
      throw Exception('Fehler beim Aktualisieren des Tasting Sets: $e');
    }
  }

  /// Delete a tasting set (for companies)
  Future<void> deleteTastingSet(int tastingSetId) async {
    try {
      await _backendApi.deleteTastingSet(tastingSetId);
    } catch (e) {
      throw Exception('Fehler beim Löschen des Tasting Sets: $e');
    }
  }
}

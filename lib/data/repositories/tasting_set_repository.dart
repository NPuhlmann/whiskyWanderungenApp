import 'dart:typed_data';

import 'package:whisky_hikes/data/services/database/backend_api.dart';
import 'package:whisky_hikes/data/services/whisky/whisky_management_service.dart';
import 'package:whisky_hikes/domain/models/tasting_set.dart';

/// Repository for managing tasting sets and whisky samples
/// Note: Tasting sets are now 1:1 with hikes and automatically included
class TastingSetRepository {
  final BackendApiService _backendApi;
  final WhiskyManagementService _whiskyService;

  TastingSetRepository(this._backendApi, this._whiskyService);

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

  /// Get whisky samples for a specific tasting set
  Future<List<WhiskySample>> getWhiskySamplesForTastingSet(
    int tastingSetId,
  ) async {
    try {
      final response = await _backendApi.getWhiskySamplesForTastingSet(
        tastingSetId,
      );
      return response;
    } catch (e) {
      throw Exception('Fehler beim Laden der Whisky Samples: $e');
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
      throw Exception(
        'Fehler beim Laden der aktuell verfügbaren Tasting Sets: $e',
      );
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
      await _backendApi.updateTastingSetAvailability(tastingSetId, isAvailable);
    } catch (e) {
      throw Exception(
        'Fehler beim Aktualisieren der Tasting Set Verfügbarkeit: $e',
      );
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

  // --- Admin-/Company-Verwaltung -------------------------------------------
  // Reine Pass-throughs auf WhiskyManagementService; die Query-Logik bleibt
  // dort. Das Repository verschiebt nur die Abhaengigkeitskante, damit
  // WhiskyManagementProvider keinen Supabase-Service mehr haelt (ADR-0004).

  Future<List<TastingSet>> getAllTastingSets() =>
      _whiskyService.getAllTastingSets();

  Future<TastingSet?> getTastingSetByHikeId(int hikeId) =>
      _whiskyService.getTastingSetByHikeId(hikeId);

  Future<TastingSet> createTastingSet(TastingSet tastingSet) =>
      _whiskyService.createTastingSet(tastingSet);

  Future<TastingSet> updateTastingSet(TastingSet tastingSet) =>
      _whiskyService.updateTastingSet(tastingSet);

  Future<void> deleteTastingSet(int tastingSetId) =>
      _whiskyService.deleteTastingSet(tastingSetId);

  Future<List<TastingSet>> searchTastingSets(String query) =>
      _whiskyService.searchTastingSets(query);

  Future<List<WhiskySample>> getWhiskySamplesByTastingSetId(int tastingSetId) =>
      _whiskyService.getWhiskySamplesByTastingSetId(tastingSetId);

  Future<WhiskySample> createWhiskySample(WhiskySample sample) =>
      _whiskyService.createWhiskySample(sample);

  Future<WhiskySample> updateWhiskySample(WhiskySample sample) =>
      _whiskyService.updateWhiskySample(sample);

  Future<void> deleteWhiskySample(int sampleId) =>
      _whiskyService.deleteWhiskySample(sampleId);

  Future<void> updateSampleOrder(List<WhiskySample> reorderedSamples) =>
      _whiskyService.updateSampleOrder(reorderedSamples);

  Future<String> uploadWhiskyImage(
    int sampleId,
    Uint8List imageBytes,
    String fileExtension,
  ) => _whiskyService.uploadWhiskyImage(sampleId, imageBytes, fileExtension);

  Future<String> uploadTastingSetImage(
    int tastingSetId,
    Uint8List imageBytes,
    String fileExtension,
  ) => _whiskyService.uploadTastingSetImage(
    tastingSetId,
    imageBytes,
    fileExtension,
  );

  Future<Map<String, dynamic>> getTastingSetStatistics() =>
      _whiskyService.getTastingSetStatistics();

  Future<List<Map<String, dynamic>>> getPopularDistilleries({int limit = 10}) =>
      _whiskyService.getPopularDistilleries(limit: limit);
}

import 'dart:typed_data';

import 'package:whisky_hikes/data/services/whisky/whisky_management_service.dart';
import 'package:whisky_hikes/domain/models/tasting_set.dart';

/// Repository for managing tasting sets and whisky samples
/// Note: Tasting sets are now 1:1 with hikes and automatically included
class TastingSetRepository {
  final WhiskyManagementService _whiskyService;

  TastingSetRepository(this._whiskyService);

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

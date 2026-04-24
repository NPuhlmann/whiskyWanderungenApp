import 'dart:developer';
import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:whisky_hikes/domain/models/tasting_set.dart';

/// Service for managing whisky-related data including tasting sets and whisky samples
class WhiskyManagementService {
  final SupabaseClient _client;

  WhiskyManagementService(this._client);

  // ==================== TastingSet Operations ====================

  /// Retrieves all tasting sets with their associated whisky samples
  Future<List<TastingSet>> getAllTastingSets() async {
    try {
      final response = await _client
          .from('tasting_sets')
          .select('*, samples:whisky_samples(*)')
          .order('name');

      return (response as List)
          .map((data) => TastingSet.fromJson(data as Map<String, dynamic>))
          .toList();
    } catch (e) {
      log('Error getting all tasting sets: $e');
      rethrow;
    }
  }

  /// Retrieves a tasting set by hike ID (1:1 relationship)
  Future<TastingSet?> getTastingSetByHikeId(int hikeId) async {
    try {
      final response = await _client
          .from('tasting_sets')
          .select('*, samples:whisky_samples(*)')
          .eq('hike_id', hikeId)
          .single();

      return TastingSet.fromJson(response);
    } catch (e) {
      if (e is PostgrestException) {
        log('No tasting set found for hike ID $hikeId');
        return null;
      }
      log('Error getting tasting set for hike $hikeId: $e');
      rethrow;
    }
  }

  /// Creates a new tasting set
  Future<TastingSet> createTastingSet(TastingSet tastingSet) async {
    try {
      final data = tastingSet.toJson();
      data.remove('id'); // Remove ID for creation
      data.remove('samples'); // Handle samples separately

      final response = await _client
          .from('tasting_sets')
          .insert(data)
          .select()
          .single();

      return TastingSet.fromJson(response);
    } catch (e) {
      log('Error creating tasting set: $e');
      rethrow;
    }
  }

  /// Updates an existing tasting set
  Future<TastingSet> updateTastingSet(TastingSet tastingSet) async {
    try {
      final data = tastingSet.toJson();
      data.remove('samples'); // Handle samples separately

      final response = await _client
          .from('tasting_sets')
          .update(data)
          .eq('id', tastingSet.id)
          .select()
          .single();

      return TastingSet.fromJson(response);
    } catch (e) {
      log('Error updating tasting set ${tastingSet.id}: $e');
      rethrow;
    }
  }

  /// Deletes a tasting set and all associated samples
  Future<void> deleteTastingSet(int tastingSetId) async {
    try {
      await _client.from('tasting_sets').delete().eq('id', tastingSetId);
    } catch (e) {
      log('Error deleting tasting set $tastingSetId: $e');
      rethrow;
    }
  }

  // ==================== WhiskySample Operations ====================

  /// Retrieves all whisky samples for a specific tasting set
  Future<List<WhiskySample>> getWhiskySamplesByTastingSetId(
    int tastingSetId,
  ) async {
    try {
      final response = await _client
          .from('whisky_samples')
          .select()
          .eq('tasting_set_id', tastingSetId)
          .order('order_index');

      return (response as List)
          .map((data) => WhiskySample.fromJson(data as Map<String, dynamic>))
          .toList();
    } catch (e) {
      log('Error getting whisky samples for tasting set $tastingSetId: $e');
      rethrow;
    }
  }

  /// Creates a new whisky sample
  Future<WhiskySample> createWhiskySample(WhiskySample sample) async {
    try {
      final data = sample.toJson();
      data.remove('id'); // Remove ID for creation

      final response = await _client
          .from('whisky_samples')
          .insert(data)
          .select()
          .single();

      return WhiskySample.fromJson(response);
    } catch (e) {
      log('Error creating whisky sample: $e');
      rethrow;
    }
  }

  /// Updates an existing whisky sample
  Future<WhiskySample> updateWhiskySample(WhiskySample sample) async {
    try {
      final data = sample.toJson();

      final response = await _client
          .from('whisky_samples')
          .update(data)
          .eq('id', sample.id)
          .select()
          .single();

      return WhiskySample.fromJson(response);
    } catch (e) {
      log('Error updating whisky sample ${sample.id}: $e');
      rethrow;
    }
  }

  /// Deletes a whisky sample
  Future<void> deleteWhiskySample(int sampleId) async {
    try {
      await _client.from('whisky_samples').delete().eq('id', sampleId);
    } catch (e) {
      log('Error deleting whisky sample $sampleId: $e');
      rethrow;
    }
  }

  /// Updates the order of multiple whisky samples
  Future<void> updateSampleOrder(List<WhiskySample> reorderedSamples) async {
    try {
      for (final sample in reorderedSamples) {
        await _client
            .from('whisky_samples')
            .update({'order_index': sample.orderIndex})
            .eq('id', sample.id);
      }
    } catch (e) {
      log('Error updating sample order: $e');
      rethrow;
    }
  }

  // ==================== Search and Filter Operations ====================

  /// Searches tasting sets by name (case-insensitive)
  Future<List<TastingSet>> searchTastingSets(String query) async {
    try {
      final response = await _client
          .from('tasting_sets')
          .select('*, samples:whisky_samples(*)')
          .ilike('name', '%${query.toLowerCase()}%');

      return (response as List)
          .map((data) => TastingSet.fromJson(data as Map<String, dynamic>))
          .toList();
    } catch (e) {
      log('Error searching tasting sets with query "$query": $e');
      rethrow;
    }
  }

  /// Retrieves whisky samples filtered by region
  Future<List<WhiskySample>> getWhiskySamplesByRegion(String region) async {
    try {
      final response = await _client
          .from('whisky_samples')
          .select()
          .eq('region', region);

      return (response as List)
          .map((data) => WhiskySample.fromJson(data as Map<String, dynamic>))
          .toList();
    } catch (e) {
      log('Error getting whisky samples for region "$region": $e');
      rethrow;
    }
  }

  /// Retrieves whisky samples filtered by distillery
  Future<List<WhiskySample>> getWhiskySamplesByDistillery(
    String distillery,
  ) async {
    try {
      final response = await _client
          .from('whisky_samples')
          .select()
          .eq('distillery', distillery);

      return (response as List)
          .map((data) => WhiskySample.fromJson(data as Map<String, dynamic>))
          .toList();
    } catch (e) {
      log('Error getting whisky samples for distillery "$distillery": $e');
      rethrow;
    }
  }

  /// Retrieves whisky samples filtered by age range
  Future<List<WhiskySample>> getWhiskySamplesByAgeRange(
    int minAge,
    int maxAge,
  ) async {
    try {
      final response = await _client
          .from('whisky_samples')
          .select()
          .gte('age', minAge)
          .lte('age', maxAge);

      return (response as List)
          .map((data) => WhiskySample.fromJson(data as Map<String, dynamic>))
          .toList();
    } catch (e) {
      log('Error getting whisky samples for age range $minAge-$maxAge: $e');
      rethrow;
    }
  }

  // ==================== Image Management ====================

  /// Uploads a whisky image to Supabase Storage
  Future<String> uploadWhiskyImage(
    int sampleId,
    Uint8List imageBytes,
    String fileExtension,
  ) async {
    try {
      final fileName = 'whisky_$sampleId.$fileExtension';

      await _client.storage
          .from('whisky-images')
          .uploadBinary(
            fileName,
            imageBytes,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );

      return _client.storage.from('whisky-images').getPublicUrl(fileName);
    } catch (e) {
      log('Error uploading whisky image for sample $sampleId: $e');
      rethrow;
    }
  }

  /// Uploads a tasting set image to Supabase Storage
  Future<String> uploadTastingSetImage(
    int tastingSetId,
    Uint8List imageBytes,
    String fileExtension,
  ) async {
    try {
      final fileName = 'tasting_set_$tastingSetId.$fileExtension';

      await _client.storage
          .from('tasting-set-images')
          .uploadBinary(
            fileName,
            imageBytes,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );

      return _client.storage.from('tasting-set-images').getPublicUrl(fileName);
    } catch (e) {
      log('Error uploading tasting set image for set $tastingSetId: $e');
      rethrow;
    }
  }

  /// Deletes a whisky image from Supabase Storage
  Future<void> deleteWhiskyImage(String fileName) async {
    try {
      await _client.storage.from('whisky-images').remove([fileName]);
    } catch (e) {
      log('Error deleting whisky image $fileName: $e');
      rethrow;
    }
  }

  /// Deletes a tasting set image from Supabase Storage
  Future<void> deleteTastingSetImage(String fileName) async {
    try {
      await _client.storage.from('tasting-set-images').remove([fileName]);
    } catch (e) {
      log('Error deleting tasting set image $fileName: $e');
      rethrow;
    }
  }

  // ==================== Statistics and Analytics ====================

  /// Gets statistics about tasting sets
  Future<Map<String, dynamic>> getTastingSetStatistics() async {
    try {
      final tastingSets = await getAllTastingSets();

      final totalSets = tastingSets.length;
      final availableSets = tastingSets
          .where((set) => set.isCurrentlyAvailable)
          .length;
      final totalSamples = tastingSets.fold<int>(
        0,
        (sum, set) => sum + set.sampleCount,
      );
      final averageSamplesPerSet = totalSets > 0
          ? totalSamples / totalSets
          : 0.0;

      final regionCounts = <String, int>{};
      for (final set in tastingSets) {
        for (final sample in set.samples) {
          regionCounts[sample.region] = (regionCounts[sample.region] ?? 0) + 1;
        }
      }

      return {
        'totalSets': totalSets,
        'availableSets': availableSets,
        'totalSamples': totalSamples,
        'averageSamplesPerSet': averageSamplesPerSet,
        'regionDistribution': regionCounts,
      };
    } catch (e) {
      log('Error getting tasting set statistics: $e');
      rethrow;
    }
  }

  /// Gets popular distilleries based on sample count
  Future<List<Map<String, dynamic>>> getPopularDistilleries({
    int limit = 10,
  }) async {
    try {
      final allSets = await getAllTastingSets();
      final distilleryCounts = <String, int>{};

      for (final set in allSets) {
        for (final sample in set.samples) {
          distilleryCounts[sample.distillery] =
              (distilleryCounts[sample.distillery] ?? 0) + 1;
        }
      }

      final sortedDistilleries = distilleryCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      return sortedDistilleries
          .take(limit)
          .map((entry) => {'distillery': entry.key, 'sampleCount': entry.value})
          .toList();
    } catch (e) {
      log('Error getting popular distilleries: $e');
      rethrow;
    }
  }
}

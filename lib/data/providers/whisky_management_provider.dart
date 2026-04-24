import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:whisky_hikes/data/services/whisky/whisky_management_service.dart';
import 'package:whisky_hikes/domain/models/tasting_set.dart';

/// Enumeration for tasting set sorting options
enum TastingSetSortBy { name, sampleCount, averageAge, averageAbv, region }

/// Provider for managing whisky-related data and state
class WhiskyManagementProvider with ChangeNotifier {
  final WhiskyManagementService _service;

  WhiskyManagementProvider(this._service);

  // ==================== State Variables ====================

  List<TastingSet> _tastingSets = [];
  List<WhiskySample> _whiskySamples = [];
  bool _isLoading = false;
  String? _error;

  // Filtering and sorting
  String _searchQuery = '';
  String? _selectedRegion;
  String? _selectedDistillery;
  TastingSetSortBy _sortBy = TastingSetSortBy.name;
  bool _sortAscending = true;

  // Statistics
  Map<String, dynamic>? _statistics;
  List<Map<String, dynamic>> _popularDistilleries = [];

  // ==================== Getters ====================

  List<TastingSet> get tastingSets => _tastingSets;
  List<WhiskySample> get whiskySamples => _whiskySamples;
  bool get isLoading => _isLoading;
  String? get error => _error;

  String get searchQuery => _searchQuery;
  String? get selectedRegion => _selectedRegion;
  String? get selectedDistillery => _selectedDistillery;
  TastingSetSortBy get sortBy => _sortBy;
  bool get sortAscending => _sortAscending;

  Map<String, dynamic>? get statistics => _statistics;
  List<Map<String, dynamic>> get popularDistilleries => _popularDistilleries;

  /// Get filtered and sorted tasting sets based on current filters
  List<TastingSet> get filteredTastingSets {
    var filtered = _tastingSets.where((set) {
      // Search query filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!set.name.toLowerCase().contains(query) &&
            !set.description.toLowerCase().contains(query)) {
          return false;
        }
      }

      // Region filter
      if (_selectedRegion != null) {
        final hasRegion = set.samples.any(
          (sample) => sample.region == _selectedRegion,
        );
        if (!hasRegion) return false;
      }

      // Distillery filter
      if (_selectedDistillery != null) {
        final hasDistillery = set.samples.any(
          (sample) => sample.distillery == _selectedDistillery,
        );
        if (!hasDistillery) return false;
      }

      return true;
    }).toList();

    // Apply sorting
    filtered.sort((a, b) {
      int comparison;
      switch (_sortBy) {
        case TastingSetSortBy.name:
          comparison = a.name.compareTo(b.name);
          break;
        case TastingSetSortBy.sampleCount:
          comparison = a.sampleCount.compareTo(b.sampleCount);
          break;
        case TastingSetSortBy.averageAge:
          comparison = a.averageAge.compareTo(b.averageAge);
          break;
        case TastingSetSortBy.averageAbv:
          comparison = a.averageAbv.compareTo(b.averageAbv);
          break;
        case TastingSetSortBy.region:
          comparison = a.mainRegion.compareTo(b.mainRegion);
          break;
      }

      return _sortAscending ? comparison : -comparison;
    });

    return filtered;
  }

  /// Get available regions from all tasting sets
  List<String> get availableRegions {
    final regions = <String>{};
    for (final set in _tastingSets) {
      for (final sample in set.samples) {
        regions.add(sample.region);
      }
    }
    return regions.toList()..sort();
  }

  /// Get available distilleries from all tasting sets
  List<String> get availableDistilleries {
    final distilleries = <String>{};
    for (final set in _tastingSets) {
      for (final sample in set.samples) {
        distilleries.add(sample.distillery);
      }
    }
    return distilleries.toList()..sort();
  }

  // ==================== Loading Operations ====================

  /// Load all tasting sets from the service
  Future<void> loadTastingSets() async {
    _setLoading(true);
    _clearError();

    try {
      _tastingSets = await _service.getAllTastingSets();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load tasting sets: $e');
      log('Error loading tasting sets: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Load whisky samples for a specific tasting set
  Future<void> loadWhiskySamples(int tastingSetId) async {
    _setLoading(true);
    _clearError();

    try {
      _whiskySamples = await _service.getWhiskySamplesByTastingSetId(
        tastingSetId,
      );
      notifyListeners();
    } catch (e) {
      _setError('Failed to load whisky samples: $e');
      log('Error loading whisky samples: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Get tasting set by hike ID
  Future<TastingSet?> getTastingSetByHikeId(int hikeId) async {
    try {
      return await _service.getTastingSetByHikeId(hikeId);
    } catch (e) {
      log('Error getting tasting set for hike $hikeId: $e');
      return null;
    }
  }

  // ==================== CRUD Operations - Tasting Sets ====================

  /// Create a new tasting set
  Future<void> createTastingSet(TastingSet tastingSet) async {
    _setLoading(true);
    _clearError();

    try {
      final validationError = validateTastingSet(tastingSet);
      if (validationError != null) {
        throw Exception('Validation failed: $validationError');
      }

      await _service.createTastingSet(tastingSet);
      await loadTastingSets(); // Reload to get updated list
    } catch (e) {
      _setError('Failed to create tasting set: $e');
      log('Error creating tasting set: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Update an existing tasting set
  Future<void> updateTastingSet(TastingSet tastingSet) async {
    _setLoading(true);
    _clearError();

    try {
      final validationError = validateTastingSet(tastingSet);
      if (validationError != null) {
        throw Exception('Validation failed: $validationError');
      }

      await _service.updateTastingSet(tastingSet);
      await loadTastingSets(); // Reload to get updated list
    } catch (e) {
      _setError('Failed to update tasting set: $e');
      log('Error updating tasting set: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Delete a tasting set
  Future<void> deleteTastingSet(int tastingSetId) async {
    _setLoading(true);
    _clearError();

    try {
      await _service.deleteTastingSet(tastingSetId);
      await loadTastingSets(); // Reload to get updated list
    } catch (e) {
      _setError('Failed to delete tasting set: $e');
      log('Error deleting tasting set: $e');
    } finally {
      _setLoading(false);
    }
  }

  // ==================== CRUD Operations - Whisky Samples ====================

  /// Create a new whisky sample
  Future<void> createWhiskySample(
    WhiskySample sample, {
    required int tastingSetId,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final validationError = validateWhiskySample(sample);
      if (validationError != null) {
        throw Exception('Validation failed: $validationError');
      }

      await _service.createWhiskySample(sample);
      await loadWhiskySamples(
        tastingSetId,
      ); // Reload samples for this tasting set
    } catch (e) {
      _setError('Failed to create whisky sample: $e');
      log('Error creating whisky sample: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Update an existing whisky sample
  Future<void> updateWhiskySample(
    WhiskySample sample, {
    required int tastingSetId,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final validationError = validateWhiskySample(sample);
      if (validationError != null) {
        throw Exception('Validation failed: $validationError');
      }

      await _service.updateWhiskySample(sample);
      await loadWhiskySamples(
        tastingSetId,
      ); // Reload samples for this tasting set
    } catch (e) {
      _setError('Failed to update whisky sample: $e');
      log('Error updating whisky sample: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Delete a whisky sample
  Future<void> deleteWhiskySample(
    int sampleId, {
    required int tastingSetId,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      await _service.deleteWhiskySample(sampleId);
      await loadWhiskySamples(
        tastingSetId,
      ); // Reload samples for this tasting set
    } catch (e) {
      _setError('Failed to delete whisky sample: $e');
      log('Error deleting whisky sample: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Reorder whisky samples
  Future<void> reorderWhiskySamples(
    List<WhiskySample> reorderedSamples, {
    required int tastingSetId,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      await _service.updateSampleOrder(reorderedSamples);
      await loadWhiskySamples(tastingSetId); // Reload to confirm order
    } catch (e) {
      _setError('Failed to reorder whisky samples: $e');
      log('Error reordering whisky samples: $e');
    } finally {
      _setLoading(false);
    }
  }

  // ==================== Search and Filtering ====================

  /// Update search query and apply filters
  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Update region filter
  void updateRegionFilter(String? region) {
    _selectedRegion = region;
    notifyListeners();
  }

  /// Update distillery filter
  void updateDistilleryFilter(String? distillery) {
    _selectedDistillery = distillery;
    notifyListeners();
  }

  /// Apply all current filters
  Future<void> applyFilters() async {
    if (_searchQuery.isNotEmpty) {
      try {
        _tastingSets = await _service.searchTastingSets(_searchQuery);
        notifyListeners();
      } catch (e) {
        log('Error applying search filter: $e');
      }
    }
  }

  /// Clear all filters
  void clearFilters() {
    _searchQuery = '';
    _selectedRegion = null;
    _selectedDistillery = null;
    notifyListeners();
  }

  // ==================== Sorting ====================

  /// Update sort criteria
  void updateSortBy(TastingSetSortBy sortBy) {
    if (_sortBy == sortBy) {
      _sortAscending = !_sortAscending;
    } else {
      _sortBy = sortBy;
      _sortAscending = true;
    }
    notifyListeners();
  }

  /// Toggle sort order
  void toggleSortOrder() {
    _sortAscending = !_sortAscending;
    notifyListeners();
  }

  // ==================== Image Management ====================

  /// Upload whisky image
  Future<String> uploadWhiskyImage(
    int sampleId,
    Uint8List imageBytes,
    String fileExtension,
  ) async {
    try {
      return await _service.uploadWhiskyImage(
        sampleId,
        imageBytes,
        fileExtension,
      );
    } catch (e) {
      log('Error uploading whisky image: $e');
      rethrow;
    }
  }

  /// Upload tasting set image
  Future<String> uploadTastingSetImage(
    int tastingSetId,
    Uint8List imageBytes,
    String fileExtension,
  ) async {
    try {
      return await _service.uploadTastingSetImage(
        tastingSetId,
        imageBytes,
        fileExtension,
      );
    } catch (e) {
      log('Error uploading tasting set image: $e');
      rethrow;
    }
  }

  // ==================== Statistics ====================

  /// Load tasting set statistics
  Future<void> loadStatistics() async {
    try {
      _statistics = await _service.getTastingSetStatistics();
      notifyListeners();
    } catch (e) {
      log('Error loading statistics: $e');
    }
  }

  /// Load popular distilleries
  Future<void> loadPopularDistilleries({int limit = 10}) async {
    try {
      _popularDistilleries = await _service.getPopularDistilleries(
        limit: limit,
      );
      notifyListeners();
    } catch (e) {
      log('Error loading popular distilleries: $e');
    }
  }

  // ==================== Validation ====================

  /// Validate tasting set data
  String? validateTastingSet(TastingSet tastingSet) {
    if (tastingSet.name.trim().isEmpty) {
      return 'Tasting set name cannot be empty';
    }

    if (tastingSet.name.length > 100) {
      return 'Tasting set name cannot exceed 100 characters';
    }

    if (tastingSet.description.trim().isEmpty) {
      return 'Description cannot be empty';
    }

    if (tastingSet.description.length > 1000) {
      return 'Description cannot exceed 1000 characters';
    }

    if (tastingSet.price < 0) {
      return 'Price cannot be negative';
    }

    return null;
  }

  /// Validate whisky sample data
  String? validateWhiskySample(WhiskySample sample) {
    if (sample.name.trim().isEmpty) {
      return 'Whisky name cannot be empty';
    }

    if (sample.name.length > 100) {
      return 'Whisky name cannot exceed 100 characters';
    }

    if (sample.distillery.trim().isEmpty) {
      return 'Distillery name cannot be empty';
    }

    if (sample.distillery.length > 100) {
      return 'Distillery name cannot exceed 100 characters';
    }

    if (sample.age < 0) {
      return 'Age cannot be negative';
    }

    if (sample.age > 100) {
      return 'Age cannot exceed 100 years';
    }

    if (sample.abv < 0 || sample.abv > 100) {
      return 'ABV must be between 0% and 100%';
    }

    if (sample.region.trim().isEmpty) {
      return 'Region cannot be empty';
    }

    if (sample.region.length > 50) {
      return 'Region cannot exceed 50 characters';
    }

    if (sample.tastingNotes.trim().isEmpty) {
      return 'Tasting notes cannot be empty';
    }

    if (sample.tastingNotes.length > 1000) {
      return 'Tasting notes cannot exceed 1000 characters';
    }

    if (sample.sampleSizeMl <= 0) {
      return 'Sample size must be greater than 0';
    }

    if (sample.sampleSizeMl > 100) {
      return 'Sample size cannot exceed 100ml';
    }

    if (sample.orderIndex < 0) {
      return 'Order index cannot be negative';
    }

    return null;
  }

  // ==================== Helper Methods ====================

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  /// Clear all data (useful for logout or reset)
  void clearData() {
    _tastingSets.clear();
    _whiskySamples.clear();
    _statistics = null;
    _popularDistilleries.clear();
    clearFilters();
    _clearError();
    notifyListeners();
  }

  /// Refresh all data
  Future<void> refreshData() async {
    await Future.wait([
      loadTastingSets(),
      loadStatistics(),
      loadPopularDistilleries(),
    ]);
  }
}

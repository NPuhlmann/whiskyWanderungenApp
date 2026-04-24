import 'package:flutter/foundation.dart';
import 'package:whisky_hikes/domain/models/tasting_set.dart';
import 'package:whisky_hikes/domain/models/hike.dart';
import 'package:whisky_hikes/data/repositories/tasting_set_repository.dart';
import 'package:whisky_hikes/data/services/database/backend_api.dart';

/// ViewModel for managing tasting set display (1:1 relationship with hikes)
class TastingSetSelectionViewModel extends ChangeNotifier {
  final Hike hike;
  final TastingSetRepository _tastingSetRepository;

  TastingSetSelectionViewModel({
    required this.hike,
    TastingSetRepository? tastingSetRepository,
  }) : _tastingSetRepository =
           tastingSetRepository ?? TastingSetRepository(BackendApiService()) {
    _loadTastingSet();
  }

  // State variables
  TastingSet? _tastingSet;
  bool _isLoading = true;
  String? _error;

  // Getters
  TastingSet? get tastingSet => _tastingSet;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasError => _error != null;
  bool get hasTastingSet => _tastingSet != null;

  /// Load the tasting set for the current hike (1:1 relationship)
  Future<void> _loadTastingSet() async {
    try {
      _setLoading(true);
      _clearError();

      // Load the single tasting set for the hike
      final tastingSet = await _tastingSetRepository.getTastingSetForHike(
        hike.id,
      );

      _tastingSet = tastingSet;
      _setLoading(false);
    } catch (e) {
      _setError('Fehler beim Laden des Tasting Sets: $e');
      _setLoading(false);
    }
  }

  /// Refresh tasting set data
  Future<void> refresh() async {
    await _loadTastingSet();
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Set error state
  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  /// Clear error state
  void _clearError() {
    _error = null;
    notifyListeners();
  }

  /// Get the total number of samples in the tasting set
  int get totalSampleCount {
    return _tastingSet?.sampleCount ?? 0;
  }

  /// Get the total volume of all samples in the tasting set
  double get totalVolumeMl {
    return _tastingSet?.totalVolumeMl ?? 0.0;
  }

  /// Get the main region of the tasting set
  String get mainRegion {
    return _tastingSet?.mainRegion ?? 'Unbekannt';
  }

  /// Get the average age of all samples
  double get averageAge {
    return _tastingSet?.averageAge ?? 0.0;
  }

  /// Get the average ABV of all samples
  double get averageAbv {
    return _tastingSet?.averageAbv ?? 0.0;
  }
}

import 'package:whisky_hikes/data/services/database/backend_api.dart';

import '../../domain/models/hike.dart';
import '../models/pagination_result.dart';

class HikeRepository {
  final BackendApiService _backendApiService;

  HikeRepository(this._backendApiService);

  Future<List<Hike>> getAllAvailableHikes() async {
    return await _backendApiService.fetchHikes();
  }

  Future<PaginationResult<Hike>> getHikesPaginated(
    PaginationParams params,
  ) async {
    return await _backendApiService.fetchHikesPaginated(params);
  }

  Future<List<Hike>> getUserHikes(String userId) async {
    return await _backendApiService.fetchUserHikes(userId);
  }

  /// Permanently delete a hike including its dependent records.
  Future<void> deleteHike(int hikeId) async {
    return await _backendApiService.deleteHike(hikeId);
  }
}

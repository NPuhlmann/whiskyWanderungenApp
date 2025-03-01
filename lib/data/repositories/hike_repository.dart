import 'package:whisky_hikes/data/services/database/backend_api.dart';

import '../../domain/models/hike.dart';

class HikeRepository {
  final BackendApiService _backendApiService;

  HikeRepository(this._backendApiService);

  Future<List<Hike>> getAllAvailableHikes() async {
    return await _backendApiService.fetchHikes();
  }

  Future<List<Hike>> getUserHikes(String userId) async {
    return await _backendApiService.fetchUserHikes(userId);
  }
}
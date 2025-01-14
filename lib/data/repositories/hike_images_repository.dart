// ein Repository das den Backendservice für die Hike Bilder kapselt

import 'package:whisky_hikes/domain/models/hike.dart';

import '../services/database/backend_api.dart';

class HikeImagesRepository {

  final BackendApiService _backendApiService;

  HikeImagesRepository(this._backendApiService);

  // upload von Bildern für einen Hike
  Future<void> uploadHikeImages(Hike hike, List<String> imagePaths) async {
    await _backendApiService.uploadHikeImages(hike.id, imagePaths);
  }

  // holen von Bildern für einen Hike
  Future<List<String>> getHikeImages(int hikeId) async {
    return await _backendApiService.getHikeImages(hikeId);
  }

}
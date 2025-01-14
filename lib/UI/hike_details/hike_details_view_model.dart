// in dieser Date wird die Logik für ein ViewModel in Flutter geschrieben.
// das viewmodel ist dafür zuständig, die Daten für die View zu verarbeiten und zu verwalten.
// in diesem Fall wird das ViewModel für die HikeDetailsPage geschrieben.
// das ViewModel bekommt Repositories übergeben, die es benutzt, um die Daten für die View zu holen.

import 'package:flutter/foundation.dart';

import '../../data/repositories/hike_images_repository.dart';

class HikeDetailsPageViewModel extends ChangeNotifier{

  HikeDetailsPageViewModel({required HikeImagesRepository hikeImagesRepository})
      : _hikeImagesRepository = hikeImagesRepository;

  final HikeImagesRepository _hikeImagesRepository;

  List<String> _hikeImages = [];
  List<String> get hikeImages => _hikeImages;
  set hikeImages(List<String> value) => _hikeImages = value;

  // eine Methode um aus dem HikeImage Repository die Bilder für das Hike anhand der Hike ID zu holen
  void getHikeImages(int hikeId) async {
    _hikeImages = await _hikeImagesRepository.getHikeImages(hikeId);
    notifyListeners();
  }
}

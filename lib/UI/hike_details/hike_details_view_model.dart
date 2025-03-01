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
  set hikeImages(List<String> value) {
    _hikeImages = value;
    // Wir rufen notifyListeners() nicht direkt auf, um Fehler zu vermeiden
    // wenn der Widget-Baum gesperrt ist
    Future.microtask(() => notifyListeners());
  }

  // Cache für die Bilder, um wiederholte Netzwerkanfragen zu vermeiden
  final Map<int, List<String>> _imageCache = {};

  // Methode zum Leeren der Bilder im UI, ohne den Cache zu beeinflussen
  void clearImagesForUI() {
    _hikeImages = [];
    // Wir rufen notifyListeners() nicht auf, da setState in der aufrufenden Methode verwendet wird
  }

  // eine Methode um aus dem HikeImage Repository die Bilder für das Hike anhand der Hike ID zu holen
  Future<void> getHikeImages(int hikeId) async {
    // Zuerst prüfen, ob die Bilder bereits im Cache sind
    if (_imageCache.containsKey(hikeId)) {
      _hikeImages = List<String>.from(_imageCache[hikeId]!); // Kopie erstellen, um Referenzprobleme zu vermeiden
      // Sicheres Aufrufen von notifyListeners()
      Future.microtask(() => notifyListeners());
      return;
    }
    
    // Wenn nicht im Cache, dann vom Repository holen
    final images = await _hikeImagesRepository.getHikeImages(hikeId);
    
    // Im Cache speichern
    _imageCache[hikeId] = List<String>.from(images); // Kopie erstellen, um Referenzprobleme zu vermeiden
    
    // Nur aktualisieren, wenn die Hike-ID noch aktuell ist (könnte sich während des Ladens geändert haben)
    _hikeImages = List<String>.from(images); // Kopie erstellen, um Referenzprobleme zu vermeiden
    
    // Sicheres Aufrufen von notifyListeners()
    Future.microtask(() => notifyListeners());
  }
  
  // Cache leeren, wenn nicht mehr benötigt
  void clearCache() {
    _imageCache.clear();
  }
}

// in dieser Date wird die Logik für ein ViewModel in Flutter geschrieben.
// das viewmodel ist dafür zuständig, die Daten für die View zu verarbeiten und zu verwalten.
// in diesem Fall wird das ViewModel für die HikeDetailsPage geschrieben.
// das ViewModel bekommt Repositories übergeben, die es benutzt, um die Daten für die View zu holen.

import 'dart:convert';
import 'dart:developer' as dev;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/repositories/hike_images_repository.dart';
import '../../data/repositories/waypoint_repository.dart';
import '../../domain/models/hike.dart';
import '../../domain/models/waypoint.dart';

class HikeDetailsPageViewModel extends ChangeNotifier{

  HikeDetailsPageViewModel({
    required HikeImagesRepository hikeImagesRepository,
    required WaypointRepository waypointRepository,
  }) : _hikeImagesRepository = hikeImagesRepository,
       _waypointRepository = waypointRepository;

  final HikeImagesRepository _hikeImagesRepository;
  final WaypointRepository _waypointRepository;

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

  // Methode zum Speichern einer Wanderung für die Offline-Nutzung
  Future<bool> saveHikeForOfflineUse(Hike hike) async {
    try {
      dev.log("Speichere Wanderung ${hike.id} für Offline-Nutzung");
      
      // 1. SharedPreferences-Instanz holen
      final prefs = await SharedPreferences.getInstance();
      
      // 2. Wanderungsdaten speichern
      final hikeJson = jsonEncode(hike.toJson());
      await prefs.setString('offline_hike_${hike.id}', hikeJson);
      dev.log("Wanderungsdaten gespeichert");
      
      // 3. Bilder der Wanderung speichern
      if (_imageCache.containsKey(hike.id)) {
        final imageUrls = _imageCache[hike.id]!;
        await prefs.setStringList('offline_hike_images_${hike.id}', imageUrls);
        dev.log("${imageUrls.length} Bilder für Wanderung gespeichert");
      } else {
        // Bilder laden, falls sie noch nicht im Cache sind
        final images = await _hikeImagesRepository.getHikeImages(hike.id);
        await prefs.setStringList('offline_hike_images_${hike.id}', images);
        dev.log("${images.length} Bilder für Wanderung geladen und gespeichert");
      }
      
      // 4. Wegpunkte der Wanderung laden und speichern
      final waypoints = await _waypointRepository.getWaypointsForHike(hike.id);
      final waypointsJsonList = waypoints.map((wp) => jsonEncode(wp.toJson())).toList();
      await prefs.setStringList('offline_hike_waypoints_${hike.id}', waypointsJsonList);
      dev.log("${waypoints.length} Wegpunkte für Wanderung gespeichert");
      
      // 5. Liste der offline verfügbaren Wanderungen aktualisieren
      final offlineHikes = prefs.getStringList('offline_hikes') ?? [];
      if (!offlineHikes.contains(hike.id.toString())) {
        offlineHikes.add(hike.id.toString());
        await prefs.setStringList('offline_hikes', offlineHikes);
      }
      
      dev.log("Wanderung ${hike.id} erfolgreich für Offline-Nutzung gespeichert");
      return true;
    } catch (e) {
      dev.log("Fehler beim Speichern der Wanderung für Offline-Nutzung: $e", error: e);
      return false;
    }
  }

  // Methode zum Prüfen, ob eine Wanderung offline verfügbar ist
  Future<bool> isHikeAvailableOffline(int hikeId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final offlineHikes = prefs.getStringList('offline_hikes') ?? [];
      return offlineHikes.contains(hikeId.toString());
    } catch (e) {
      dev.log("Fehler beim Prüfen der Offline-Verfügbarkeit: $e", error: e);
      return false;
    }
  }

  // Methode zum Löschen einer offline gespeicherten Wanderung
  Future<bool> removeOfflineHike(int hikeId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Alle zugehörigen Daten löschen
      await prefs.remove('offline_hike_$hikeId');
      await prefs.remove('offline_hike_images_$hikeId');
      await prefs.remove('offline_hike_waypoints_$hikeId');
      
      // Aus der Liste der offline verfügbaren Wanderungen entfernen
      final offlineHikes = prefs.getStringList('offline_hikes') ?? [];
      offlineHikes.remove(hikeId.toString());
      await prefs.setStringList('offline_hikes', offlineHikes);
      
      dev.log("Offline-Daten für Wanderung $hikeId erfolgreich gelöscht");
      return true;
    } catch (e) {
      dev.log("Fehler beim Löschen der Offline-Daten: $e", error: e);
      return false;
    }
  }
}

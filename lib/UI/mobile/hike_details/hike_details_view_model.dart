/// ViewModel for the HikeDetailsPage
/// Responsible for managing data and business logic for the hike details view
/// Uses repositories to fetch and manage hike-related data
library;

import 'dart:convert';
import 'dart:developer' as dev;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/repositories/hike_images_repository.dart';
import '../../../data/repositories/waypoint_repository.dart';
import '../../../domain/models/hike.dart';

class HikeDetailsPageViewModel extends ChangeNotifier {
  HikeDetailsPageViewModel({
    required HikeImagesRepository hikeImagesRepository,
    required WaypointRepository? waypointRepository,
  }) : _hikeImagesRepository = hikeImagesRepository {
    // Ensure WaypointRepository is not null
    _waypointRepository = waypointRepository;
    if (_waypointRepository == null) {
      dev.log(
        "WARNING: WaypointRepository is null in HikeDetailsPageViewModel",
      );
    }
  }

  final HikeImagesRepository _hikeImagesRepository;
  WaypointRepository? _waypointRepository;

  List<String> _hikeImages = [];
  List<String> get hikeImages => _hikeImages;
  set hikeImages(List<String> value) {
    _hikeImages = value;
    // Don't call notifyListeners() directly to avoid errors
    // when the widget tree is locked
    Future.microtask(() => notifyListeners());
  }

  // Cache for images to avoid repeated network requests
  final Map<int, List<String>> _imageCache = {};

  // Method to clear images in UI without affecting cache
  void clearImagesForUI() {
    _hikeImages = [];
    // Don't call notifyListeners() as setState is used in calling method
  }

  /// Get hike images from repository by hike ID
  Future<void> getHikeImages(int hikeId) async {
    // First check if images are already in cache
    if (_imageCache.containsKey(hikeId)) {
      _hikeImages = List<String>.from(
        _imageCache[hikeId]!,
      ); // Create copy to avoid reference issues
      // Safe call to notifyListeners()
      Future.microtask(() => notifyListeners());
      return;
    }

    // If not in cache, fetch from repository
    final images = await _hikeImagesRepository.getHikeImages(hikeId);

    // Store in cache
    _imageCache[hikeId] = List<String>.from(
      images,
    ); // Create copy to avoid reference issues

    // Only update if hike ID is still current (could have changed during loading)
    _hikeImages = List<String>.from(
      images,
    ); // Create copy to avoid reference issues

    // Safe call to notifyListeners()
    Future.microtask(() => notifyListeners());
  }

  /// Clear cache when no longer needed
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
        dev.log(
          "${images.length} Bilder für Wanderung geladen und gespeichert",
        );
      }

      // 4. Wegpunkte der Wanderung laden und speichern
      if (_waypointRepository != null) {
        try {
          final waypoints = await _waypointRepository!.getWaypointsForHike(
            hike.id,
          );
          final waypointsJsonList = waypoints
              .map((wp) => jsonEncode(wp.toJson()))
              .toList();
          await prefs.setStringList(
            'offline_hike_waypoints_${hike.id}',
            waypointsJsonList,
          );
          dev.log("${waypoints.length} Wegpunkte für Wanderung gespeichert");
        } catch (e) {
          dev.log("Fehler beim Laden der Wegpunkte: $e", error: e);
          // Wir setzen eine leere Liste, damit die App nicht abstürzt
          await prefs.setStringList('offline_hike_waypoints_${hike.id}', []);
        }
      } else {
        dev.log("WaypointRepository ist null, überspringe Wegpunkte");
        await prefs.setStringList('offline_hike_waypoints_${hike.id}', []);
      }

      // 5. Liste der offline verfügbaren Wanderungen aktualisieren
      final offlineHikes = prefs.getStringList('offline_hikes') ?? [];
      if (!offlineHikes.contains(hike.id.toString())) {
        offlineHikes.add(hike.id.toString());
        await prefs.setStringList('offline_hikes', offlineHikes);
      }

      dev.log(
        "Wanderung ${hike.id} erfolgreich für Offline-Nutzung gespeichert",
      );
      return true;
    } catch (e) {
      dev.log(
        "Fehler beim Speichern der Wanderung für Offline-Nutzung: $e",
        error: e,
      );
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

  @override
  void dispose() {
    // Clear caches to free memory
    _imageCache.clear();
    _hikeImages.clear();
    super.dispose();
  }
}

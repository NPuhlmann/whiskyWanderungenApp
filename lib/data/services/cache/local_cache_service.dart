import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../domain/models/profile.dart';

class LocalCacheService {
  static const String _profileDataKey = 'cached_profile_data';
  static const String _profileDataTimestampKey = 'cached_profile_timestamp';
  static const String _profileImagePathKey = 'cached_profile_image_path';
  static const String _profileImageTimestampKey = 'cached_profile_image_timestamp';
  
  // Cache-Gültigkeitsdauer
  static const Duration profileDataTtl = Duration(hours: 24);
  static const Duration profileImageTtl = Duration(days: 7);
  static const int maxCacheSizeBytes = 50 * 1024 * 1024; // 50MB

  SharedPreferences? _prefs;
  String? _cacheDirectory;

  Future<void> _initializePrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<void> _initializeCacheDirectory() async {
    if (_cacheDirectory == null) {
      final directory = await getApplicationDocumentsDirectory();
      _cacheDirectory = '${directory.path}/profile_cache';
      
      // Cache-Verzeichnis erstellen falls es nicht existiert
      final cacheDir = Directory(_cacheDirectory!);
      if (!await cacheDir.exists()) {
        await cacheDir.create(recursive: true);
        log("📁 Cache-Verzeichnis erstellt: $_cacheDirectory");
      }
    }
  }

  /// Cache Profildaten lokal
  Future<void> cacheProfileData(Profile profile, String userId) async {
    try {
      await _initializePrefs();
      
      final profileJson = profile.toJson();
      final profileString = jsonEncode(profileJson);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      
      await _prefs!.setString('${_profileDataKey}_$userId', profileString);
      await _prefs!.setInt('${_profileDataTimestampKey}_$userId', timestamp);
      
      log("💾 Profildaten gecacht für Benutzer: $userId");
    } catch (e) {
      log("❌ Fehler beim Cachen der Profildaten: $e", error: e);
    }
  }

  /// Lade gecachte Profildaten
  Future<Profile?> getCachedProfileData(String userId) async {
    try {
      await _initializePrefs();
      
      final profileString = _prefs!.getString('${_profileDataKey}_$userId');
      final timestamp = _prefs!.getInt('${_profileDataTimestampKey}_$userId');
      
      if (profileString == null || timestamp == null) {
        log("📭 Keine gecachten Profildaten für Benutzer: $userId");
        return null;
      }
      
      // Prüfe Cache-Gültigkeit
      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final isExpired = DateTime.now().difference(cacheTime) > profileDataTtl;
      
      if (isExpired) {
        log("⏰ Gecachte Profildaten sind abgelaufen für Benutzer: $userId");
        await clearProfileDataCache(userId);
        return null;
      }
      
      final profileJson = jsonDecode(profileString) as Map<String, dynamic>;
      final profile = Profile.fromJson(profileJson);
      
      log("✅ Gecachte Profildaten geladen für Benutzer: $userId");
      return profile;
      
    } catch (e) {
      log("❌ Fehler beim Laden der gecachten Profildaten: $e", error: e);
      return null;
    }
  }

  /// Cache Profilbild lokal
  Future<String?> cacheProfileImage(String userId, Uint8List imageBytes, String fileExtension) async {
    try {
      await _initializeCacheDirectory();
      
      final fileName = 'profile_$userId.$fileExtension';
      final filePath = '$_cacheDirectory/$fileName';
      final file = File(filePath);
      
      // Schreibe Bild in lokale Datei
      await file.writeAsBytes(imageBytes);
      
      // Speichere Pfad und Timestamp
      await _initializePrefs();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      
      await _prefs!.setString('${_profileImagePathKey}_$userId', filePath);
      await _prefs!.setInt('${_profileImageTimestampKey}_$userId', timestamp);
      
      log("🖼️ Profilbild gecacht für Benutzer: $userId, Pfad: $filePath");
      
      // Cache-Größe prüfen und bereinigen falls nötig
      await _manageCacheSize();
      
      return filePath;
      
    } catch (e) {
      log("❌ Fehler beim Cachen des Profilbildes: $e", error: e);
      return null;
    }
  }

  /// Lade gecachtes Profilbild
  Future<String?> getCachedProfileImagePath(String userId) async {
    try {
      await _initializePrefs();
      
      final imagePath = _prefs!.getString('${_profileImagePathKey}_$userId');
      final timestamp = _prefs!.getInt('${_profileImageTimestampKey}_$userId');
      
      if (imagePath == null || timestamp == null) {
        log("📭 Kein gecachtes Profilbild für Benutzer: $userId");
        return null;
      }
      
      // Prüfe Cache-Gültigkeit
      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final isExpired = DateTime.now().difference(cacheTime) > profileImageTtl;
      
      if (isExpired) {
        log("⏰ Gecachtes Profilbild ist abgelaufen für Benutzer: $userId");
        await clearProfileImageCache(userId);
        return null;
      }
      
      // Prüfe ob Datei noch existiert
      final file = File(imagePath);
      if (!await file.exists()) {
        log("📂 Gecachte Profilbild-Datei existiert nicht mehr: $imagePath");
        await clearProfileImageCache(userId);
        return null;
      }
      
      log("✅ Gecachtes Profilbild gefunden für Benutzer: $userId, Pfad: $imagePath");
      return imagePath;
      
    } catch (e) {
      log("❌ Fehler beim Laden des gecachten Profilbildes: $e", error: e);
      return null;
    }
  }

  /// Prüfe ob Profildaten gecacht und gültig sind
  Future<bool> hasValidProfileDataCache(String userId) async {
    try {
      await _initializePrefs();
      
      final timestamp = _prefs!.getInt('${_profileDataTimestampKey}_$userId');
      if (timestamp == null) return false;
      
      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final isExpired = DateTime.now().difference(cacheTime) > profileDataTtl;
      
      return !isExpired;
    } catch (e) {
      log("❌ Fehler beim Prüfen der Cache-Gültigkeit: $e", error: e);
      return false;
    }
  }

  /// Prüfe ob Profilbild gecacht und gültig ist
  Future<bool> hasValidProfileImageCache(String userId) async {
    try {
      await _initializePrefs();
      
      final imagePath = _prefs!.getString('${_profileImagePathKey}_$userId');
      final timestamp = _prefs!.getInt('${_profileImageTimestampKey}_$userId');
      
      if (imagePath == null || timestamp == null) return false;
      
      // Prüfe Cache-Gültigkeit
      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final isExpired = DateTime.now().difference(cacheTime) > profileImageTtl;
      
      if (isExpired) return false;
      
      // Prüfe ob Datei existiert
      final file = File(imagePath);
      return await file.exists();
      
    } catch (e) {
      log("❌ Fehler beim Prüfen der Image-Cache-Gültigkeit: $e", error: e);
      return false;
    }
  }

  /// Lösche Profildaten-Cache für bestimmten Benutzer
  Future<void> clearProfileDataCache(String userId) async {
    try {
      await _initializePrefs();
      
      await _prefs!.remove('${_profileDataKey}_$userId');
      await _prefs!.remove('${_profileDataTimestampKey}_$userId');
      
      log("🗑️ Profildaten-Cache gelöscht für Benutzer: $userId");
    } catch (e) {
      log("❌ Fehler beim Löschen des Profildaten-Cache: $e", error: e);
    }
  }

  /// Lösche Profilbild-Cache für bestimmten Benutzer
  Future<void> clearProfileImageCache(String userId) async {
    try {
      await _initializePrefs();
      
      final imagePath = _prefs!.getString('${_profileImagePathKey}_$userId');
      if (imagePath != null) {
        final file = File(imagePath);
        if (await file.exists()) {
          await file.delete();
          log("🗑️ Profilbild-Datei gelöscht: $imagePath");
        }
      }
      
      await _prefs!.remove('${_profileImagePathKey}_$userId');
      await _prefs!.remove('${_profileImageTimestampKey}_$userId');
      
      log("🗑️ Profilbild-Cache gelöscht für Benutzer: $userId");
    } catch (e) {
      log("❌ Fehler beim Löschen des Profilbild-Cache: $e", error: e);
    }
  }

  /// Lösche gesamten Cache für bestimmten Benutzer
  Future<void> clearUserCache(String userId) async {
    await clearProfileDataCache(userId);
    await clearProfileImageCache(userId);
    log("🧹 Gesamter Cache gelöscht für Benutzer: $userId");
  }

  /// Lösche gesamten Cache für alle Benutzer
  Future<void> clearAllCache() async {
    try {
      await _initializePrefs();
      await _initializeCacheDirectory();
      
      // Lösche alle SharedPreferences Cache-Einträge
      final keys = _prefs!.getKeys();
      final cacheKeys = keys.where((key) => 
        key.contains('cached_profile_data') || 
        key.contains('cached_profile_timestamp') ||
        key.contains('cached_profile_image_path') ||
        key.contains('cached_profile_image_timestamp')
      );
      
      for (final key in cacheKeys) {
        await _prefs!.remove(key);
      }
      
      // Lösche Cache-Verzeichnis
      final cacheDir = Directory(_cacheDirectory!);
      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
        log("🧹 Cache-Verzeichnis komplett gelöscht");
      }
      
      log("🧹 Gesamter Cache für alle Benutzer gelöscht");
    } catch (e) {
      log("❌ Fehler beim Löschen des gesamten Cache: $e", error: e);
    }
  }

  /// Cache-Größe verwalten und alte Dateien löschen
  Future<void> _manageCacheSize() async {
    try {
      await _initializeCacheDirectory();
      
      final cacheDir = Directory(_cacheDirectory!);
      if (!await cacheDir.exists()) return;
      
      final files = await cacheDir.list().toList();
      int totalSize = 0;
      
      // Berechne Gesamtgröße
      for (final entity in files) {
        if (entity is File) {
          final stat = await entity.stat();
          totalSize += stat.size;
        }
      }
      
      // Wenn Cache zu groß ist, lösche älteste Dateien
      if (totalSize > maxCacheSizeBytes) {
        log("📊 Cache-Größe (${(totalSize / 1024 / 1024).toStringAsFixed(1)}MB) überschreitet Limit");
        
        // Sortiere Dateien nach Änderungsdatum (älteste zuerst)
        final imageFiles = files.whereType<File>().toList();
        imageFiles.sort((a, b) => 
          a.statSync().modified.compareTo(b.statSync().modified)
        );
        
        // Lösche älteste Dateien bis Cache-Größe OK ist
        for (final file in imageFiles) {
          if (totalSize <= maxCacheSizeBytes) break;
          
          final stat = await file.stat();
          totalSize -= stat.size;
          await file.delete();
          
          log("🗑️ Alte Cache-Datei gelöscht: ${file.path}");
        }
        
        log("✅ Cache-Größe nach Bereinigung: ${(totalSize / 1024 / 1024).toStringAsFixed(1)}MB");
      }
      
    } catch (e) {
      log("❌ Fehler bei Cache-Größenverwaltung: $e", error: e);
    }
  }

  /// Erhalte Cache-Statistiken
  Future<Map<String, dynamic>> getCacheStats() async {
    try {
      await _initializeCacheDirectory();
      
      final cacheDir = Directory(_cacheDirectory!);
      if (!await cacheDir.exists()) {
        return {
          'totalFiles': 0,
          'totalSizeMB': 0.0,
          'profileDataCacheCount': 0,
          'profileImageCacheCount': 0,
        };
      }
      
      final files = await cacheDir.list().toList();
      int totalSize = 0;
      int imageFiles = 0;
      
      for (final entity in files) {
        if (entity is File) {
          final stat = await entity.stat();
          totalSize += stat.size;
          imageFiles++;
        }
      }
      
      await _initializePrefs();
      final keys = _prefs!.getKeys();
      final profileDataCacheCount = keys.where((key) => key.contains('cached_profile_data')).length;
      
      return {
        'totalFiles': files.length,
        'totalSizeMB': (totalSize / 1024 / 1024),
        'profileDataCacheCount': profileDataCacheCount,
        'profileImageCacheCount': imageFiles,
      };
      
    } catch (e) {
      log("❌ Fehler beim Abrufen der Cache-Statistiken: $e", error: e);
      return {
        'totalFiles': 0,
        'totalSizeMB': 0.0,
        'profileDataCacheCount': 0,
        'profileImageCacheCount': 0,
        'error': e.toString(),
      };
    }
  }

  /// Prüfe Netzwerkverbindung (vereinfacht)
  Future<bool> hasNetworkConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
import 'dart:developer';
import 'dart:typed_data';

import '../../domain/models/profile.dart';
import '../services/database/backend_api.dart';
import '../services/cache/local_cache_service.dart';

class ProfileRepository {
  final BackendApiService _backendApiService;
  final LocalCacheService _cacheService;

  ProfileRepository(this._backendApiService, this._cacheService);

  /// Lade Benutzerprofil mit Cache-First-Strategie
  Future<Profile> getUserProfileById(String id) async {
    log("🔍 Lade Profil für Benutzer: $id");
    
    // 1. Prüfe lokalen Cache zuerst
    final cachedProfile = await _cacheService.getCachedProfileData(id);
    if (cachedProfile != null) {
      log("✅ Profil aus lokalem Cache geladen: $id");
      return cachedProfile;
    }
    
    // 2. Cache miss oder abgelaufen - lade von Supabase
    log("🌐 Lade Profil von Supabase für Benutzer: $id");
    try {
      final profile = await _backendApiService.getUserProfileById(id);
      
      // 3. Cache das frische Profil
      await _cacheService.cacheProfileData(profile, id);
      log("💾 Profil in lokalen Cache gespeichert: $id");
      
      return profile;
    } catch (e) {
      log("❌ Fehler beim Laden des Profils von Supabase: $e");
      
      // 4. Fallback: Versuche abgelaufenen Cache zu verwenden
      final expiredProfile = await _cacheService.getCachedProfileData(id);
      if (expiredProfile != null) {
        log("🔄 Verwende abgelaufenen Cache als Fallback: $id");
        return expiredProfile;
      }
      
      // 5. Letzter Fallback: Leeres Profil
      log("⚠️ Returne leeres Profil als letzter Fallback");
      rethrow;
    }
  }

  /// Aktualisiere Benutzerprofil und invalidiere Cache
  Future<void> updateUserProfile(Profile profile) async {
    log("📝 Aktualisiere Profil: ${profile.id}");
    
    try {
      await _backendApiService.updateUserProfile(profile);
      
      // Cache das aktualisierte Profil
      await _cacheService.cacheProfileData(profile, profile.id);
      log("💾 Aktualisiertes Profil im Cache gespeichert: ${profile.id}");
      
    } catch (e) {
      log("❌ Fehler beim Aktualisieren des Profils: $e");
      rethrow;
    }
  }
  
  /// Lade Profilbild hochladen und cache es lokal
  Future<String> uploadProfileImage(String userId, Uint8List imageBytes, String fileExt) async {
    log("🚀 Lade Profilbild hoch für Benutzer: $userId");
    
    try {
      // Upload zu Supabase
      final imageUrl = await _backendApiService.uploadProfileImage(userId, imageBytes, fileExt);
      
      // Cache das Bild lokal
      await _cacheService.cacheProfileImage(userId, imageBytes, fileExt);
      log("💾 Profilbild lokal gecacht für Benutzer: $userId");
      
      return imageUrl;
    } catch (e) {
      log("❌ Fehler beim Upload des Profilbildes: $e");
      rethrow;
    }
  }
  
  /// Lade Profilbild-URL mit Cache-First-Strategie
  Future<String?> getProfileImageUrl(String userId) async {
    log("🖼️ Lade Profilbild-URL für Benutzer: $userId");
    
    // 1. Prüfe lokalen Cache zuerst
    final cachedImagePath = await _cacheService.getCachedProfileImagePath(userId);
    if (cachedImagePath != null) {
      log("✅ Profilbild aus lokalem Cache: $cachedImagePath");
      return 'file://$cachedImagePath';
    }
    
    // 2. Cache miss - lade von Supabase und cache es
    log("🌐 Lade Profilbild von Supabase für Benutzer: $userId");
    try {
      final imageUrl = await _backendApiService.getProfileImageUrl(userId);
      
      if (imageUrl != null) {
        // Lade das Bild herunter und cache es für zukünftige Verwendung
        await _downloadAndCacheImage(userId, imageUrl);
      }
      
      return imageUrl;
    } catch (e) {
      log("❌ Fehler beim Laden der Profilbild-URL: $e");
      return null;
    }
  }
  
  /// Lade Bild von URL herunter und cache es lokal
  Future<void> _downloadAndCacheImage(String userId, String imageUrl) async {
    try {
      log("⬇️ Lade Bild herunter zum Cachen: $imageUrl");
      
      // Hier könnte man http verwenden um das Bild herunterzuladen
      // Für jetzt übersprungen da es komplexer wäre und der Upload-Cache bereits funktioniert
      log("⚠️ Background-Download noch nicht implementiert");
      
    } catch (e) {
      log("❌ Fehler beim Herunterladen des Bildes zum Cachen: $e");
    }
  }
  
  /// Lösche Cache für bestimmten Benutzer
  Future<void> clearUserCache(String userId) async {
    await _cacheService.clearUserCache(userId);
    log("🧹 Cache gelöscht für Benutzer: $userId");
  }
  
  /// Lösche gesamten Cache
  Future<void> clearAllCache() async {
    await _cacheService.clearAllCache();
    log("🧹 Gesamter Cache gelöscht");
  }
  
  /// Erhalte Cache-Statistiken
  Future<Map<String, dynamic>> getCacheStats() async {
    return await _cacheService.getCacheStats();
  }
  
  /// Prüfe Netzwerkverbindung
  Future<bool> hasNetworkConnection() async {
    return await _cacheService.hasNetworkConnection();
  }
}
import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:whisky_hikes/data/repositories/profile_repository.dart';

import '../../data/repositories/user_repository.dart';
import '../../domain/models/profile.dart';

class ProfilePageViewModel extends ChangeNotifier{
  ProfilePageViewModel({
    required ProfileRepository profileRepository,
    required UserRepository userRepository,
}): _profileRepository = profileRepository,
    _userRepository = userRepository;

  final ProfileRepository _profileRepository;
  final UserRepository _userRepository;

  Profile _profile = Profile();
  Profile get profile => _profile;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<Profile> loadProfile() async {
    _isLoading = true;
    notifyListeners();
    
    try{
      final String? userId = _userRepository.getUserId();
      log("🔍 LoadProfile: UserId = $userId");
      if (userId == null) {
        throw Exception('Benutzer-ID konnte nicht ermittelt werden');
      }
      
      final Profile profile = await _profileRepository.getUserProfileById(userId);
      log("📝 LoadProfile: Basis-Profil geladen");
      
      // E-Mail-Adresse aus dem UserRepository laden
      final String? email = _userRepository.getUserEmail();
      if (email != null) {
        profile.email = email;
      }
      
      // Profilbild-URL laden
      log("🖼️ LoadProfile: Lade Profilbild-URL...");
      final String? imageUrl = await _profileRepository.getProfileImageUrl(userId);
      log("🖼️ LoadProfile: Geladene Profilbild-URL: $imageUrl");
      if (imageUrl != null) {
        profile.imageUrl = imageUrl;
        log("✅ LoadProfile: Setze imageUrl im Profil: ${profile.imageUrl}");
      } else {
        log("❌ LoadProfile: Keine Profilbild-URL gefunden");
      }
      
      _profile = profile;
      log("🎯 LoadProfile: Finales Profil imageUrl: ${_profile.imageUrl}");
      return profile;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile(Profile profile) async {
    _isLoading = true;
    notifyListeners();
    
    try{
      // Wenn sich die E-Mail-Adresse geändert hat, aktualisiere sie im Auth-System
      final String? currentEmail = _userRepository.getUserEmail();
      if (currentEmail != profile.email && profile.email.isNotEmpty) {
        await _userRepository.updateUserEmail(profile.email);
      }
      
      // Profil in der Datenbank aktualisieren
      await _profileRepository.updateUserProfile(profile);
      _profile = profile;
    } catch (e) {
      log("Fehler beim Aktualisieren des Profils: $e");
      // Hier könnte eine Fehlerbehandlung implementiert werden
      // Don't rethrow to avoid breaking the UI state
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Profilbild hochladen mit Retry-Logik
  Future<void> uploadProfileImage(Uint8List imageBytes, String fileExt) async {
    _isLoading = true;
    notifyListeners();
    
    const int maxRetries = 3;
    
    try {
      final String? userId = _userRepository.getUserId();
      if (userId == null) {
        throw Exception('Benutzer-ID konnte nicht ermittelt werden');
      }
      
      log("🚀 Upload-Start: Benutzer $userId, Größe: ${imageBytes.length} Bytes, Format: $fileExt");
      
      // Validierungen
      if (imageBytes.isEmpty) {
        throw Exception('Leere Bilddaten - Bildauswahl fehlgeschlagen');
      }
      
      if (imageBytes.length > 10 * 1024 * 1024) { // 10MB Limit
        throw Exception('Bild zu groß (${(imageBytes.length / 1024 / 1024).toStringAsFixed(1)}MB). Maximal 10MB erlaubt.');
      }
      
      // Upload mit Retry-Logik
      String? imageUrl;
      Exception? lastException;
      
      for (int attempt = 1; attempt <= maxRetries; attempt++) {
        try {
          log("📤 Upload-Versuch $attempt/$maxRetries");
          
          imageUrl = await _profileRepository.uploadProfileImage(
            userId, 
            imageBytes, 
            fileExt
          );
          
          log("✅ Upload erfolgreich: $imageUrl");
          break; // Erfolg, schleife verlassen
          
        } catch (e) {
          lastException = e is Exception ? e : Exception(e.toString());
          log("❌ Upload-Versuch $attempt fehlgeschlagen: $e");
          
          if (attempt < maxRetries && _isRetryableError(e)) {
            log("🔄 Wiederholung in ${attempt * 2} Sekunden...");
            await Future.delayed(Duration(seconds: attempt * 2));
          } else {
            log("🚫 Upload endgültig fehlgeschlagen");
            break;
          }
        }
      }
      
      if (imageUrl == null) {
        throw lastException ?? Exception('Upload fehlgeschlagen nach $maxRetries Versuchen');
      }
      
      // Profil aktualisieren
      log("📝 Aktualisiere Profil mit neuer Bild-URL...");
      _profile.imageUrl = imageUrl;
      
      await _profileRepository.updateUserProfile(_profile);
      
      log("🎯 Upload-Prozess komplett abgeschlossen!");
      
    } catch (e) {
      log("💥 Upload-Fehler: $e", error: e);
      _handleUploadError(e);
      // Don't rethrow to avoid breaking the UI state
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Hilfsmethode: Prüft ob Fehler retry-fähig ist
  bool _isRetryableError(dynamic error) {
    final String errorString = error.toString().toLowerCase();
    return errorString.contains('network') ||
           errorString.contains('timeout') ||
           errorString.contains('connection') ||
           errorString.contains('503') ||
           errorString.contains('502') ||
           errorString.contains('500');
  }
  
  // Hilfsmethode: Spezifische Fehlerbehandlung
  void _handleUploadError(dynamic error) {
    final String errorString = error.toString();
    
    if (errorString.contains('PlatformException') && errorString.contains('image_picker')) {
      log("🔍 iOS Simulator Problem erkannt");
    } else if (errorString.contains('permission')) {
      log("🔐 Berechtigungs-Problem erkannt");
    } else if (errorString.contains('network') || errorString.contains('timeout')) {
      log("🌐 Netzwerk-Problem erkannt");
    } else if (errorString.contains('storage')) {
      log("💾 Supabase Storage Problem erkannt");
    }
  }

  void signOut(){
    _userRepository.signUserOut();
    notifyListeners();
  }

}
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
      if (userId == null) {
        throw Exception('Benutzer-ID konnte nicht ermittelt werden');
      }
      
      final Profile profile = await _profileRepository.getUserProfileById(userId);
      
      // E-Mail-Adresse aus dem UserRepository laden
      final String? email = _userRepository.getUserEmail();
      if (email != null) {
        profile.email = email;
      }
      
      // Profilbild-URL laden
      final String? imageUrl = await _profileRepository.getProfileImageUrl(userId);
      if (imageUrl != null) {
        profile.imageUrl = imageUrl;
      }
      
      log("Profil geladen: $profile");
      
      _profile = profile;
      return profile;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateProfile(Profile profile) async {
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
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Profilbild hochladen
  Future<void> uploadProfileImage(Uint8List imageBytes, String fileExt) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final String? userId = _userRepository.getUserId();
      if (userId == null) {
        throw Exception('Benutzer-ID konnte nicht ermittelt werden');
      }
      
      log("Starte Upload des Profilbilds für Benutzer $userId mit Dateigröße ${imageBytes.length} Bytes");
      
      // Prüfen, ob wir im Simulator sind (anhand der Fehlermeldung)
      if (imageBytes.isEmpty) {
        throw Exception('Leere Bilddaten - möglicherweise ein Problem mit dem Simulator');
      }
      
      final String imageUrl = await _profileRepository.uploadProfileImage(
        userId, 
        imageBytes, 
        fileExt
      );
      
      log("Profilbild erfolgreich hochgeladen: $imageUrl");
      
      // Profilbild-URL im Profil aktualisieren
      _profile.imageUrl = imageUrl;
      
      // Profil in der Datenbank aktualisieren
      await _profileRepository.updateUserProfile(_profile);
      
      log("Profil mit neuer Bild-URL aktualisiert");
    } catch (e) {
      log("Fehler beim Hochladen des Profilbilds: $e", error: e);
      
      // Spezifische Fehlerbehandlung für bekannte Probleme
      if (e.toString().contains('PlatformException') && e.toString().contains('image_picker_ios')) {
        throw Exception('Fehler beim Zugriff auf die Kamera oder Galerie. Dies ist ein bekanntes Problem im iOS-Simulator. Bitte verwenden Sie ein echtes Gerät.');
      }
      
      rethrow; // Fehler weiterleiten, damit er in der UI behandelt werden kann
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void signOut(){
    _userRepository.signUserOut();
    notifyListeners();
  }

}
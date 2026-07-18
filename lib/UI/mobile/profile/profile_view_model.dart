import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:whisky_hikes/data/repositories/profile_repository.dart';

import '../../../data/repositories/user_repository.dart';
import '../../../domain/models/account.dart';
import '../../../domain/models/profile.dart';

class ProfilePageViewModel extends ChangeNotifier {
  ProfilePageViewModel({
    required ProfileRepository profileRepository,
    required UserRepository userRepository,
  }) : _profileRepository = profileRepository,
       _userRepository = userRepository;

  final ProfileRepository _profileRepository;
  final UserRepository _userRepository;

  Profile _profile = Profile();
  Profile get profile => _profile;

  Account _account = const Account();
  Account get account => _account;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Lädt Profile (Identität) und Account (E-Mail, Rolle) getrennt.
  /// Existiert noch keine `profiles`-Zeile (z.B. Signup-Trigger noch nicht
  /// gelaufen), zeigt der Screen ein leeres, editierbares Profil statt eines
  /// Fehlers.
  Future<Profile> loadProfile() async {
    _isLoading = true;
    notifyListeners();

    try {
      final String? userId = _userRepository.getUserId();
      log("🔍 LoadProfile: UserId = $userId");
      if (userId == null) {
        throw Exception('Benutzer-ID konnte nicht ermittelt werden');
      }

      final Profile? loadedProfile = await _profileRepository
          .getUserProfileById(userId);
      final Profile profile = loadedProfile ?? Profile(id: userId);
      log(
        "📝 LoadProfile: Profil geladen (existierte: ${loadedProfile != null})",
      );

      _account = await _userRepository.getAccount();

      _profile = profile;
      return profile;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Speichert Identität ([profile]) über [ProfileRepository] und E-Mail
  /// (falls geändert) über [UserRepository]. E-Mail wird nie über das
  /// Profile geschrieben.
  Future<void> updateProfile(Profile profile, {required String email}) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (email != _account.email && email.isNotEmpty) {
        await _userRepository.updateUserEmail(email);
        _account = _account.copyWith(email: email);
      }

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

      log(
        "🚀 Upload-Start: Benutzer $userId, Größe: ${imageBytes.length} Bytes, Format: $fileExt",
      );

      // Validierungen
      if (imageBytes.isEmpty) {
        throw Exception('Leere Bilddaten - Bildauswahl fehlgeschlagen');
      }

      if (imageBytes.length > 10 * 1024 * 1024) {
        // 10MB Limit
        throw Exception(
          'Bild zu groß (${(imageBytes.length / 1024 / 1024).toStringAsFixed(1)}MB). Maximal 10MB erlaubt.',
        );
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
            fileExt,
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
        throw lastException ??
            Exception('Upload fehlgeschlagen nach $maxRetries Versuchen');
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

    if (errorString.contains('PlatformException') &&
        errorString.contains('image_picker')) {
      log("🔍 iOS Simulator Problem erkannt");
    } else if (errorString.contains('permission')) {
      log("🔐 Berechtigungs-Problem erkannt");
    } else if (errorString.contains('network') ||
        errorString.contains('timeout')) {
      log("🌐 Netzwerk-Problem erkannt");
    } else if (errorString.contains('storage')) {
      log("💾 Supabase Storage Problem erkannt");
    }
  }

  void signOut() {
    _userRepository.signUserOut();
    notifyListeners();
  }
}

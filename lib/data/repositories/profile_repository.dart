import 'dart:typed_data';

import '../../domain/models/profile.dart';
import '../services/database/backend_api.dart';

class ProfileRepository {
  final BackendApiService _backendApiService;

  ProfileRepository(this._backendApiService);

  Future<Profile> getUserProfileById(String id) async {
    return await _backendApiService.getUserProfileById(id);
  }

  Future<void> updateUserProfile(Profile profile) async {
    await _backendApiService.updateUserProfile(profile);
  }
  
  // Profilbild hochladen
  Future<String> uploadProfileImage(String userId, Uint8List imageBytes, String fileExt) async {
    return await _backendApiService.uploadProfileImage(userId, imageBytes, fileExt);
  }
  
  // Profilbild-URL abrufen
  Future<String?> getProfileImageUrl(String userId) async {
    return await _backendApiService.getProfileImageUrl(userId);
  }
}
import '../../domain/models/profile.dart';
import '../services/database/backend_api.dart';

class ProfileRepository {
  final BackendApiService _backendApiService;

  ProfileRepository(this._backendApiService);

  Future<Profile> getUserProfileById(String id) async {
    return await _backendApiService.getUserProfileById(id);
  }
}
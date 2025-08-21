import 'package:mockito/annotations.dart';
import 'package:whisky_hikes/data/repositories/hike_repository.dart';
import 'package:whisky_hikes/data/repositories/profile_repository.dart';
import 'package:whisky_hikes/data/repositories/user_repository.dart';
import 'package:whisky_hikes/data/repositories/hike_images_repository.dart';
import 'package:whisky_hikes/data/repositories/waypoint_repository.dart';
import 'package:whisky_hikes/data/services/auth/auth_service.dart';
import 'package:whisky_hikes/data/services/cache/local_cache_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

@GenerateMocks([
  HikeRepository,
  ProfileRepository, 
  UserRepository,
  HikeImagesRepository,
  WaypointRepository,
  AuthService,
  LocalCacheService,
  SharedPreferences,
])
import 'mock_repositories.mocks.dart';

export 'mock_repositories.mocks.dart';
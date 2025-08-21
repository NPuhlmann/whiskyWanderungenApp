import 'package:mockito/annotations.dart';
import 'package:whisky_hikes/data/repositories/hike_repository.dart';
import 'package:whisky_hikes/data/repositories/profile_repository.dart';
import 'package:whisky_hikes/data/repositories/user_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

@GenerateMocks([
  HikeRepository,
  ProfileRepository, 
  UserRepository,
  SharedPreferences,
])
import 'mock_repositories.mocks.dart';

export 'mock_repositories.mocks.dart';
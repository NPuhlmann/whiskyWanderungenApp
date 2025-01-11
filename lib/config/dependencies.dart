// dependencies for repositories and services

import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import 'package:whisky_hikes/data/repositories/hike_repository.dart';

import '../UI/home/home_view_model.dart';
import '../data/repositories/profile_repository.dart';
import '../data/repositories/user_repository.dart';
import '../data/services/auth/auth_service.dart';
import '../data/services/database/backend_api.dart';

List<SingleChildWidget> get providers {
  return [
    // BackendApiService bereitstellen
    Provider<AuthService>(
      create: (_) => AuthService(),
    ),
    Provider<BackendApiService>(
      create: (_) => BackendApiService(),
    ),
    // ProfileRepository registrieren, mit BackendApiService als Abhängigkeit
    Provider<ProfileRepository>(
      create: (context) => ProfileRepository(
        context.read<BackendApiService>(),
      ),
    ),
    ChangeNotifierProvider<UserRepository>(
        create: (context) => UserRepository(context.read<AuthService>())),
    Provider<HikeRepository>(
      create: (context) => HikeRepository(context.read<BackendApiService>()),
    ),
    ChangeNotifierProvider<HomePageViewModel>(
      create: (context) => HomePageViewModel(
        hikeRepository: context.read(),
        profileRepository: context.read(),
        userRepository: context.read(),
      ),
    ),
  ];
}

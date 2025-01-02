// dependencies for repositories and services

import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:whisky_hikes/UI/auth/signup/SignUpPageViewModel.dart';
import 'package:whisky_hikes/UI/home/home_view_model.dart';

import '../UI/profile/profile_view_model.dart';
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
    Provider<UserRepository>(
        create: (context) => UserRepository(context.read<AuthService>())),
    ChangeNotifierProvider<ProfilePageViewModel>(
      create: (context) => ProfilePageViewModel(
          profileRepository: context.read<ProfileRepository>(),
          userRepository: context.read<UserRepository>()),
    ),
    ChangeNotifierProvider<HomePageViewModel>(
        create: (context) =>
            HomePageViewModel(userRepository: context.read<UserRepository>())),
    ChangeNotifierProvider(
        create: (context) =>
            SignUpPageViewModel(userRepository: context.read<UserRepository>()))
  ];
}

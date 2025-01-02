
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:whisky_hikes/UI/auth/login/login_page.dart';
import 'package:whisky_hikes/UI/auth/login/login_page_view_model.dart';
import 'package:whisky_hikes/UI/auth/signup/signup_page.dart';
import 'package:whisky_hikes/UI/home/home_page.dart';
import 'package:whisky_hikes/UI/home/home_view_model.dart';
import 'package:whisky_hikes/UI/my_hikes/my_hikes_page.dart';
import 'package:whisky_hikes/UI/profile/profile_page.dart';
import 'package:whisky_hikes/UI/profile/profile_view_model.dart';
import 'package:whisky_hikes/config/routing/routes.dart';
import 'package:whisky_hikes/data/repositories/user_repository.dart';


import '../../UI/auth/signup/SignUpPageViewModel.dart';
import '../../UI/core/ScaffoldWithNavigationBar.dart';

GoRouter router(UserRepository authRepository) => GoRouter(
        initialLocation: Routes.home,
        debugLogDiagnostics: true,
        redirect: _redirect,
        refreshListenable: authRepository,
        routes: [
          GoRoute(path: Routes.login, builder: (context, state) {
            final viewModel = LoginPageViewModel(userRepository: context.read());
            return LoginPage(viewModel: viewModel);
          }),
          GoRoute(path: Routes.signUp, builder: (context, state) {
            final viewModel = SignUpPageViewModel(userRepository: context.read());
            return SignupPage(viewModel: viewModel);
          }),
          StatefulShellRoute.indexedStack(
            builder: (BuildContext context, GoRouterState state, StatefulNavigationShell navigationShell){
              return ScaffoldWithNavigationBar(navigationShell: navigationShell);
            },
            branches: <StatefulShellBranch>[
              StatefulShellBranch(routes: <RouteBase> [
                GoRoute(
                    path: Routes.home,
                    builder: (context, state) {
                      final viewModel = HomePageViewModel(userRepository: context.read());
                      return HomePage(viewModel: viewModel,);
                    }),

              ]),
              StatefulShellBranch(routes: <RouteBase>[
                GoRoute(path: Routes.myHikes,
                    builder: (context, state) {
                      return MyHikesPage();
                    })
              ]),
              StatefulShellBranch(routes: <RouteBase> [
                GoRoute(path: Routes.profile,
                    builder: (context, state) {
                      final viewModel = ProfilePageViewModel(profileRepository: context.read(), userRepository: context.read());
                      return ProfilePage(viewModel: viewModel);
                    }),

              ]),
            ]
          )

        ]);



// From https://github.com/flutter/packages/blob/main/packages/go_router/example/lib/redirection.dart
Future<String?> _redirect(BuildContext context, GoRouterState state) async {
  // if the user is not logged in, they need to login
  final bool loggedIn = context.read<UserRepository>().isUserLoggedIn();
  final bool loggingIn = state.matchedLocation == Routes.login;
  final bool signingUp = state.matchedLocation == Routes.signUp;
  if (!loggedIn && !signingUp) {
    return Routes.login;
  } else if(!loggedIn && signingUp){
    return Routes.signUp;
  }

  // if the user is logged in but still on the login page, send them to
  // the home page
  if (loggingIn) {
    return Routes.home;
  }

  // no need to redirect at all
  return null;
}
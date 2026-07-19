import 'package:whisky_hikes/config/routing/routes.dart';

/// Routes reachable without a session. Anything not listed here bounces a
/// logged-out user to [Routes.login] — so a new unauthenticated screen must be
/// added here or it becomes unreachable.
const _unauthenticatedRoutes = {Routes.login, Routes.signUp, Routes.magicLink};

/// The router's redirect decision, extracted from [BuildContext] so it can be
/// tested directly. Returns the location to redirect to, or `null` to stay put.
///
/// The age gate is evaluated before auth: an undeclared or under-age user has
/// no business reaching a login screen for an alcohol-related app.
String? resolveRedirect({
  required String location,
  required bool ageAllowed,
  required bool loggedIn,
}) {
  final atAgeGate = location == Routes.ageGate;
  if (!ageAllowed) {
    // Undeclared and blocked users both live on the gate; the screen itself
    // renders either the question or the wall.
    return atAgeGate ? null : Routes.ageGate;
  }
  if (atAgeGate) {
    return loggedIn ? Routes.home : Routes.login;
  }

  if (!loggedIn) {
    return _unauthenticatedRoutes.contains(location) ? null : Routes.login;
  }
  if (_unauthenticatedRoutes.contains(location)) {
    return Routes.home;
  }
  return null;
}

import 'package:flutter_test/flutter_test.dart';
import 'package:whisky_hikes/config/routing/auth_redirect.dart';
import 'package:whisky_hikes/config/routing/routes.dart';

void main() {
  group('resolveRedirect', () {
    group('age gate (checked before auth)', () {
      test('sends an undeclared user to the age gate', () {
        expect(
          resolveRedirect(
            location: Routes.home,
            ageAllowed: false,
            loggedIn: false,
          ),
          Routes.ageGate,
        );
      });

      test('sends an undeclared but logged-in user to the age gate', () {
        expect(
          resolveRedirect(
            location: Routes.home,
            ageAllowed: false,
            loggedIn: true,
          ),
          Routes.ageGate,
        );
      });

      test('keeps a blocked user on the age gate', () {
        expect(
          resolveRedirect(
            location: Routes.home,
            ageAllowed: false,
            loggedIn: true,
          ),
          Routes.ageGate,
        );
      });

      test('does not bounce when already on the age gate', () {
        expect(
          resolveRedirect(
            location: Routes.ageGate,
            ageAllowed: false,
            loggedIn: false,
          ),
          isNull,
        );
      });

      test('moves an allowed user off the age gate', () {
        expect(
          resolveRedirect(
            location: Routes.ageGate,
            ageAllowed: true,
            loggedIn: false,
          ),
          Routes.login,
        );
      });
    });

    group('auth', () {
      test('sends a logged-out user to login', () {
        expect(
          resolveRedirect(
            location: Routes.home,
            ageAllowed: true,
            loggedIn: false,
          ),
          Routes.login,
        );
      });

      test('does not bounce a logged-out user off login', () {
        expect(
          resolveRedirect(
            location: Routes.login,
            ageAllowed: true,
            loggedIn: false,
          ),
          isNull,
        );
      });

      test('does not bounce a logged-out user off signup', () {
        expect(
          resolveRedirect(
            location: Routes.signUp,
            ageAllowed: true,
            loggedIn: false,
          ),
          isNull,
        );
      });

      // The trap: any new unauthenticated route must be in the allowlist or
      // it bounces to /login forever.
      test('does not bounce a logged-out user off the magic link page', () {
        expect(
          resolveRedirect(
            location: Routes.magicLink,
            ageAllowed: true,
            loggedIn: false,
          ),
          isNull,
        );
      });

      test('sends a logged-in user away from login to home', () {
        expect(
          resolveRedirect(
            location: Routes.login,
            ageAllowed: true,
            loggedIn: true,
          ),
          Routes.home,
        );
      });

      test('sends a logged-in user away from the magic link page', () {
        expect(
          resolveRedirect(
            location: Routes.magicLink,
            ageAllowed: true,
            loggedIn: true,
          ),
          Routes.home,
        );
      });

      test('leaves a logged-in user on an ordinary page alone', () {
        expect(
          resolveRedirect(
            location: Routes.myHikes,
            ageAllowed: true,
            loggedIn: true,
          ),
          isNull,
        );
      });
    });
  });
}

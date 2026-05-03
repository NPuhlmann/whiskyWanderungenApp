import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthService {
  final SupabaseClient client;
  final bool? _testDevMode;

  // Constructor für Dependency Injection in Tests
  AuthService({SupabaseClient? client, bool? isDevMode})
    : client = client ?? Supabase.instance.client,
      _testDevMode = isDevMode;

  bool get isDevMode {
    // In production, always return false
    const bool isProduction = bool.fromEnvironment('dart.vm.product');
    if (isProduction) {
      return false;
    }

    // In development, check test mode or environment variable
    return _testDevMode ?? (dotenv.env['DEV_MODE']?.toLowerCase() == 'true');
  }

  // sign in with email and password
  Future<AuthResponse> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    final response = await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return response;
  }

  // sign up with email and password
  Future<AuthResponse> signUpWithEmailPassword(
    String email,
    String password, [
    Map<String, dynamic>? data,
  ]) async {
    if (isDevMode) {
      // In development mode, automatically confirm email
      final response = await client.auth.signUp(
        email: email,
        password: password,
        data: data,
        emailRedirectTo: null,
      );

      // Auto-confirm email in development mode
      if (response.user != null && response.user!.emailConfirmedAt == null) {
        if (isDevMode) debugPrint('=== DEV MODE: Auto-confirming email ===');
        try {
          // Sign out first to clear any session
          await client.auth.signOut();

          // Try to sign in immediately - in dev mode this should work
          // even without email confirmation if Supabase is configured properly
          final signInResponse = await client.auth.signInWithPassword(
            email: email,
            password: password,
          );

          if (isDevMode) {
            debugPrint('DEV MODE: Email auto-confirmed and user signed in');
          }
          return AuthResponse(
            user: signInResponse.user,
            session: signInResponse.session,
          );
        } catch (e) {
          if (isDevMode) {
            debugPrint(
              'DEV MODE: Could not auto-confirm. User needs manual confirmation.',
            );
            debugPrint('Error: $e');
          }
          return response;
        }
      }

      return response;
    } else {
      // In production, use deep link for email confirmation
      final response = await client.auth.signUp(
        email: email,
        password: password,
        data: data,
        emailRedirectTo: 'whiskyhikes://email-confirm',
      );
      return response;
    }
  }

  // sign out
  Future<void> signOut() async {
    await client.auth.signOut();
  }

  // get current user mail
  String? getCurrentUserEmail() {
    final session = client.auth.currentSession;
    final user = session?.user;
    return user?.email;
  }

  String? getCurrentUserId() {
    final session = client.auth.currentSession;
    final user = session?.user;
    return user?.id;
  }

  bool isUserLoggedIn() {
    final session = client.auth.currentSession;
    final user = session?.user;

    return user == null ? false : true;
  }

  // E-Mail-Adresse des Benutzers aktualisieren
  Future<void> updateUserEmail(String newEmail) async {
    try {
      await client.auth.updateUser(UserAttributes(email: newEmail));
    } catch (e) {
      // Fehlerbehandlung
      // Logging der Fehler - in Production sollte ein proper Logger verwendet werden
      throw Exception('Fehler beim Aktualisieren der E-Mail-Adresse: $e');
    }
  }

  // Manual email confirmation for development mode
  Future<void> confirmEmailManually() async {
    if (!isDevMode) {
      throw Exception(
        'Manual email confirmation is only available in development mode',
      );
    }

    final user = client.auth.currentUser;
    if (user == null) {
      throw Exception('No user logged in');
    }

    if (user.emailConfirmedAt != null) {
      debugPrint('Email already confirmed');
      return;
    }

    try {
      // This is a workaround for development - in real scenario you'd use the confirm endpoint
      // For now, we'll just inform the developer
      debugPrint('=== MANUAL EMAIL CONFIRMATION ===');
      debugPrint('In development mode, you can:');
      debugPrint('1. Check your email for the confirmation link');
      debugPrint('2. Or manually confirm in Supabase Dashboard');
      debugPrint('3. Or disable email confirmation in Supabase Auth settings');
      debugPrint('================================');
    } catch (e) {
      throw Exception('Error during manual email confirmation: $e');
    }
  }

  // Handle deep link email confirmation
  Future<void> handleEmailConfirmation(String token, String type) async {
    try {
      await client.auth.verifyOTP(token: token, type: OtpType.email);
    } catch (e) {
      throw Exception('Error confirming email: $e');
    }
  }

  // Send a magic link / OTP to the given email address
  Future<void> signInWithMagicLink(String email) async {
    await client.auth.signInWithOtp(
      email: email,
      emailRedirectTo: isDevMode ? null : 'whiskyhikes://magic-link-confirm',
    );
  }

  // Verify the 6-digit OTP received via magic link email
  Future<AuthResponse> verifyMagicLinkOtp(String email, String token) async {
    return await client.auth.verifyOTP(
      email: email,
      token: token,
      type: OtpType.magiclink,
    );
  }
}

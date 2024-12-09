import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService{
  final SupabaseClient client = Supabase.instance.client;

  // sign in with email and password
  Future<AuthResponse> signInWithEmailPassword(String email, String password) async {
    final response = await client.auth.signInWithPassword(email: email, password: password);
    return response;
  }
  // sign up with email and password
  Future<AuthResponse> signUpWithEmailPassword(String email, String password, [Map<String, dynamic>? data]) async {
    final response = await client.auth.signUp(email: email, password: password, data: data);
    return response;
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
}
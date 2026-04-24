import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:whisky_hikes/data/repositories/user_repository.dart';
import 'package:whisky_hikes/data/services/auth/auth_service.dart';

class SignUpPageViewModel extends ChangeNotifier {
  SignUpPageViewModel({
    required UserRepository userRepository,
    required AuthService authService,
  }) : _userRepository = userRepository,
       _authService = authService;

  final UserRepository _userRepository;
  final AuthService _authService;

  AuthService get authService => _authService;

  Future<AuthResponse> signUpWithEmailPassword(
    String email,
    String password, [
    Map<String, dynamic>? data,
  ]) async {
    return await _userRepository.signUpWithEmailPassword(email, password, data);
  }
}

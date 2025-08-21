import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:whisky_hikes/data/repositories/user_repository.dart';

class SignUpPageViewModel extends ChangeNotifier {
  SignUpPageViewModel({required UserRepository userRepository})
      : _userRepository = userRepository;

  final UserRepository _userRepository;

  Future<AuthResponse> signUpWithEmailPassword(String email, String password,
      [Map<String, dynamic>? data]) async {
    return await _userRepository.signUpWithEmailPassword(email, password, data);
  }
}

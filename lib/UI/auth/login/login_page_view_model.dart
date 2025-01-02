import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:whisky_hikes/data/repositories/user_repository.dart';

class LoginPageViewModel extends ChangeNotifier{
  LoginPageViewModel({required UserRepository userRepository}): _userRepository = userRepository;

  final UserRepository _userRepository;

  Future<AuthResponse> loginWithEmailAndPassword(String email, String password) async{
    return await _userRepository.loginWithEmailAndPassword(email, password);
  }
}
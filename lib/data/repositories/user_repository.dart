
import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/auth/auth_service.dart';

class UserRepository extends ChangeNotifier{
  final AuthService _authService;

  bool isLoggedIn = false;

  UserRepository(this._authService);

  Future<void> signUserOut() async{
    await _authService.signOut();
    notifyListeners();
  }

  Future<AuthResponse> signUpWithEmailPassword(String email, String password, [Map<String, dynamic>? data]) async{
    try{
      return await _authService.signUpWithEmailPassword(email, password, data);
    } finally {
      notifyListeners();
    }
  }

  Future<AuthResponse> loginWithEmailAndPassword(String email, String password) async {
    try{
      return await _authService.signInWithEmailPassword(email, password);
    } finally {
      notifyListeners();
    }
  }

  bool isUserLoggedIn() {
     isLoggedIn = _authService.isUserLoggedIn();
     return isLoggedIn;
  }

  String? getUserId() {
    return _authService.getCurrentUserId();
  }

}
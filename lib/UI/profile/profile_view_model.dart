import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:whisky_hikes/data/repositories/profile_repository.dart';

import '../../data/repositories/user_repository.dart';
import '../../domain/models/profile.dart';

class ProfilePageViewModel extends ChangeNotifier{
  ProfilePageViewModel({
    required ProfileRepository profileRepository,
    required UserRepository userRepository,
}): _profileRepository = profileRepository,
    _userRepository = userRepository;

  final ProfileRepository _profileRepository;
  final UserRepository _userRepository;

  Profile _profile = Profile();
  Profile get profile => _profile;

  Future<Profile> loadProfile() async {
    try{
      final String? userId = _userRepository.getUserId();
      final Profile profile = await _profileRepository.getUserProfileById(userId!);
      
      log("Profil geladen: $profile");
      
      _profile = profile;
      return profile;
    } finally {
      notifyListeners();
    }
  }

  void updateProfile(Profile profile) async {
    try{
      await _profileRepository.updateUserProfile(profile);
      _profile = profile;
    } finally {
      notifyListeners();
    }
  }

  void signOut(){
    _userRepository.signUserOut();
    notifyListeners();
  }

}
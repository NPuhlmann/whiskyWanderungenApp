
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:whisky_hikes/data/repositories/hike_repository.dart';
import 'package:whisky_hikes/data/repositories/profile_repository.dart';

import '../../data/repositories/user_repository.dart';
import '../../domain/models/hike.dart';
import '../../domain/models/profile.dart';

class HomePageViewModel extends ChangeNotifier{

  HomePageViewModel({required HikeRepository hikeRepository, required ProfileRepository profileRepository, required UserRepository userRepository}):
        _hikeRepository = hikeRepository,
        _profileRepository = profileRepository,
        _userRepository = userRepository;

  final HikeRepository _hikeRepository;
  final ProfileRepository _profileRepository;
  final UserRepository _userRepository;

  List<Hike> _hikes = [];
  List<Hike> get hikes => _hikes;
  String _firstName = "";
  String get firstName => _firstName;

  Future<void> loadHikes() async {
    try {
      _hikes = await _hikeRepository.getAllAvailableHikes();
    } finally {
      notifyListeners();
    }
  }

Future<void> getUserFirstName() async {
  try {
    final String? userId = _userRepository.getUserId();
    if (userId == null) {
      log("User ID is null");
      return;
    }
    final Profile? profile = await _profileRepository.getUserProfileById(userId);
    if (profile == null) {
      log("Can't load Profile! $profile");
      return;
    }
    _firstName = profile.first_name;
  } catch (e) {
    log("Error loading user first name: $e");
  } finally {
    notifyListeners();
  }
}

}
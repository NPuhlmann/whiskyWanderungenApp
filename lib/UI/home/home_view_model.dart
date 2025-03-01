import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  List<Hike> get hikes => _showFavorites ? _hikes.where((hike) => hike.isFavorite).toList() : _hikes;
  
  String _firstName = "";
  String get firstName => _firstName;
  
  bool _showFavorites = false;
  bool get showFavorites => _showFavorites;

  Future<void> loadHikes() async {
    try {
      _hikes = await _hikeRepository.getAllAvailableHikes();
      await _loadFavorites();
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

  void toggleFavorite(Hike hike) {
    final index = _hikes.indexWhere((h) => h.id == hike.id);
    if (index != -1) {
      final newFavoriteState = !hike.isFavorite;
      _hikes[index] = hike.copyWith(isFavorite: newFavoriteState);
      _saveFavorites();
      
      // Wenn wir gerade Favoriten anzeigen und ein Favorit wird entfernt,
      // müssen wir die UI aktualisieren, bevor das Element aus der Liste verschwindet
      notifyListeners();
    }
  }

  void toggleShowFavorites() {
    _showFavorites = !_showFavorites;
    notifyListeners();
  }

  Future<void> _saveFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoriteIds = _hikes.where((h) => h.isFavorite).map((h) => h.id).toList();
      await prefs.setString('favorite_hikes', favoriteIds.join(','));
    } catch (e) {
      log("Error saving favorites: $e");
    }
  }

  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoriteString = prefs.getString('favorite_hikes') ?? '';
      if (favoriteString.isNotEmpty) {
        final favoriteIds = favoriteString.split(',').map((id) => int.parse(id)).toSet();
        for (var i = 0; i < _hikes.length; i++) {
          if (favoriteIds.contains(_hikes[i].id)) {
            _hikes[i] = _hikes[i].copyWith(isFavorite: true);
          }
        }
      }
    } catch (e) {
      log("Error loading favorites: $e");
    }
  }
}
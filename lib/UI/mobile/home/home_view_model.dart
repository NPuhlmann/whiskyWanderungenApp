import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whisky_hikes/data/repositories/hike_repository.dart';
import 'package:whisky_hikes/data/repositories/profile_repository.dart';

import '../../../data/repositories/user_repository.dart';
import '../../../domain/models/hike.dart';
import '../../../domain/models/profile.dart';

class HomePageViewModel extends ChangeNotifier{

  HomePageViewModel({required HikeRepository hikeRepository, required ProfileRepository profileRepository, required UserRepository userRepository}):
        _hikeRepository = hikeRepository,
        _profileRepository = profileRepository,
        _userRepository = userRepository;

  final HikeRepository _hikeRepository;
  final ProfileRepository _profileRepository;
  final UserRepository _userRepository;

  List<Hike> _hikes = [];
  List<Hike> get hikes => _showFavorites ? _favoriteHikes : _hikes;
  List<Hike> get _favoriteHikes => _hikes.where((hike) => hike.isFavorite).toList();
  
  String _firstName = "";
  String get firstName => _firstName;
  
  bool _showFavorites = false;
  bool get showFavorites => _showFavorites;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> loadHikes() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // Load hikes and favorites concurrently
      final results = await Future.wait([
        _hikeRepository.getAllAvailableHikes(),
        _loadFavoriteIds(),
      ]);
      
      _hikes = results[0] as List<Hike>;
      final favoriteIds = results[1] as Set<int>;
      
      // Apply favorites asynchronously
      await _applyFavorites(favoriteIds);
    } catch (e) {
      log("Error loading hikes: $e");
    } finally {
      _isLoading = false;
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
      final Profile profile = await _profileRepository.getUserProfileById(userId);
      _firstName = profile.firstName;
    } catch (e) {
      log("Error loading user first name: $e");
    } finally {
      notifyListeners();
    }
  }

  void toggleFavorite(Hike hike) async {
    final index = _hikes.indexWhere((h) => h.id == hike.id);
    if (index != -1) {
      final newFavoriteState = !hike.isFavorite;
      _hikes[index] = hike.copyWith(isFavorite: newFavoriteState);
      
      // Save favorites asynchronously without blocking UI
      _saveFavorites();
      
      // Update UI immediately
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

  /// Load favorite IDs from SharedPreferences
  Future<Set<int>> _loadFavoriteIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoriteString = prefs.getString('favorite_hikes') ?? '';
      if (favoriteString.isEmpty) return <int>{};
      
      return favoriteString
          .split(',')
          .map((id) => int.tryParse(id))
          .where((id) => id != null)
          .cast<int>()
          .toSet();
    } catch (e) {
      log("Error loading favorites: $e");
      return <int>{};
    }
  }

  /// Apply favorite status to hikes asynchronously
  Future<void> _applyFavorites(Set<int> favoriteIds) async {
    if (favoriteIds.isEmpty) return;
    
    // Process in chunks to avoid blocking the main thread
    const chunkSize = 50;
    for (int i = 0; i < _hikes.length; i += chunkSize) {
      final end = (i + chunkSize < _hikes.length) ? i + chunkSize : _hikes.length;
      final chunk = _hikes.sublist(i, end);
      
      // Process chunk
      for (int j = 0; j < chunk.length; j++) {
        final globalIndex = i + j;
        if (favoriteIds.contains(_hikes[globalIndex].id)) {
          _hikes[globalIndex] = _hikes[globalIndex].copyWith(isFavorite: true);
        }
      }
      
      // Yield control back to the event loop between chunks
      await Future.delayed(Duration.zero);
    }
  }

  @override
  void dispose() {
    // Clear large data structures to free memory
    _hikes.clear();
    super.dispose();
  }
}
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:whisky_hikes/data/repositories/offline_first_hike_repository.dart';
import 'package:whisky_hikes/data/repositories/user_repository.dart';

import '../../../domain/models/hike.dart';

class MyHikesViewModel extends ChangeNotifier {
  MyHikesViewModel({
    required OfflineFirstHikeRepository hikeRepository,
    required UserRepository userRepository,
  }) : _hikeRepository = hikeRepository,
       _userRepository = userRepository;

  final OfflineFirstHikeRepository _hikeRepository;
  final UserRepository _userRepository;

  List<Hike> _userHikes = [];
  List<Hike> get userHikes => _userHikes;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> loadUserHikes({bool forceRefresh = false}) async {
    if (_isLoading) return; // Verhindere mehrfaches Laden

    try {
      _errorMessage = null;
      _isLoading = true;

      final String? userId = _userRepository.getUserId();
      if (userId == null) {
        log("User ID is null");
        _errorMessage = "loginRequiredForHikes"; // Schlüssel für i18n
        return;
      }

      _userHikes = await _hikeRepository.getUserHikes(
        userId,
        forceRefresh: forceRefresh,
      );
    } catch (e) {
      log("Error loading user hikes: $e");
      _errorMessage = "errorLoadingHikes"; // Schlüssel für i18n
      _userHikes = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Methode zum erneuten Laden der Daten
  Future<void> refresh() async {
    await loadUserHikes(forceRefresh: true);
  }
}

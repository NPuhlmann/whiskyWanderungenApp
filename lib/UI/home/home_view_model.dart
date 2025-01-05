
import 'package:flutter/material.dart';
import 'package:whisky_hikes/data/repositories/hike_repository.dart';

import '../../domain/models/hike.dart';

class HomePageViewModel extends ChangeNotifier{

  HomePageViewModel({required HikeRepository hikeRepository}): _hikeRepository = hikeRepository;

  final HikeRepository _hikeRepository;

  List<Hike> _hikes = [];
  List<Hike> get hikes => _hikes;

  Future<List<Hike>> loadHikes() async {
    try {
      _hikes = await _hikeRepository.getAllAvailableHikes();
      return _hikes;
    } finally {
      notifyListeners();
    }
  }

}
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AgeGateService extends ChangeNotifier {
  static const _keyShown = 'age_gate_shown';
  static const _keyConfirmed = 'age_gate_confirmed';

  bool _shown = false;
  bool _confirmed = false;

  bool get ageGateShown => _shown;
  bool get isAgeConfirmed => _confirmed;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _shown = prefs.getBool(_keyShown) ?? false;
    _confirmed = prefs.getBool(_keyConfirmed) ?? false;
    notifyListeners();
  }

  Future<void> confirmAge() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyShown, true);
    await prefs.setBool(_keyConfirmed, true);
    _shown = true;
    _confirmed = true;
    notifyListeners();
  }

  Future<void> denyAge() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyShown, true);
    await prefs.setBool(_keyConfirmed, false);
    _shown = true;
    _confirmed = false;
    notifyListeners();
  }
}

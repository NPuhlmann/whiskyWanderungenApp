import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists the user's self-declared legal drinking age across cold restarts.
///
/// Deliberately a tri-state: `null` means the user has never been asked, which
/// is a different thing from having answered "no". The gate is a legal blocker
/// (JuSchG/HWG), so a declaration must never be silently forgotten — but it is
/// a self-declaration only, not identity verification.
///
/// Kept out of [LocalCacheService] on purpose: that service's `clearAllCache()`
/// would wipe the declaration along with the profile cache.
class AgeGateService extends ChangeNotifier {
  static const _key = 'age_gate_of_legal_age';

  bool? _ofLegalAge;

  /// Whether the user has answered the gate at all.
  bool get isDeclared => _ofLegalAge != null;

  /// Whether the user declared themselves of legal drinking age.
  bool get isAllowed => _ofLegalAge == true;

  /// Whether the user declared themselves under age.
  bool get isBlocked => _ofLegalAge == false;

  /// Reads the persisted declaration. Call once before `runApp` so the router
  /// redirect can read it without awaiting.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _ofLegalAge = prefs.getBool(_key);
    notifyListeners();
  }

  Future<void> declare({required bool ofLegalAge}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, ofLegalAge);
    _ofLegalAge = ofLegalAge;
    notifyListeners();
  }
}

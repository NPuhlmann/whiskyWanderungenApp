import 'package:flutter/foundation.dart';

import '../../../../data/services/auth/age_gate_service.dart';

/// Keeps the age gate page off the service directly, per ADR-0004
/// (`Widget -> ViewModel -> Repository -> Service`).
class AgeGateViewModel extends ChangeNotifier {
  AgeGateViewModel({required AgeGateService ageGateService})
    : _ageGateService = ageGateService {
    // The service outlives this ViewModel, so the page must be able to react
    // to a declaration without depending on the router happening to rebuild
    // the route.
    _ageGateService.addListener(notifyListeners);
  }

  final AgeGateService _ageGateService;

  bool get isBlocked => _ageGateService.isBlocked;

  Future<void> declare({required bool ofLegalAge}) =>
      _ageGateService.declare(ofLegalAge: ofLegalAge);

  @override
  void dispose() {
    _ageGateService.removeListener(notifyListeners);
    super.dispose();
  }
}

import 'package:flutter/foundation.dart';

import '../../../../data/repositories/user_repository.dart';

/// Drives the two-step magic-link flow: enter email, then enter the code that
/// arrives by email. Errors are rethrown for the page to surface, matching the
/// existing login page's snackbar handling.
class MagicLinkViewModel extends ChangeNotifier {
  MagicLinkViewModel({required UserRepository userRepository})
    : _userRepository = userRepository;

  final UserRepository _userRepository;

  bool _isBusy = false;
  bool _linkSent = false;
  String _email = '';

  bool get isBusy => _isBusy;

  /// True once the email has gone out — the page switches to code entry.
  bool get linkSent => _linkSent;

  /// The normalised address the link was sent to.
  String get email => _email;

  Future<void> sendMagicLink(String email) async {
    // Normalised once here so verifyOtp is given the identical address; a
    // trailing space or different casing makes Supabase reject the code.
    final normalised = email.trim().toLowerCase();
    if (!_looksLikeEmail(normalised)) {
      throw const FormatException('Enter a valid email address');
    }

    _isBusy = true;
    notifyListeners();
    try {
      await _userRepository.sendMagicLink(normalised);
      _email = normalised;
      _linkSent = true;
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  Future<void> verifyCode(String code) async {
    final trimmed = code.trim();
    if (trimmed.isEmpty) {
      throw const FormatException('Enter the code from your email');
    }

    _isBusy = true;
    notifyListeners();
    try {
      await _userRepository.verifyMagicLinkCode(_email, trimmed);
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  /// Back to the email step, e.g. after a typo in the address.
  void restart() {
    _linkSent = false;
    notifyListeners();
  }

  // ponytail: shape check only — the real validation is Supabase failing to
  // deliver. A full RFC 5322 regex buys nothing here.
  bool _looksLikeEmail(String value) {
    final at = value.indexOf('@');
    return at > 0 && at < value.length - 1 && !value.contains(' ');
  }
}

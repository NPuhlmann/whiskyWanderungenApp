// Auth-verwaltetes Konto (E-Mail, Rolle) - getrennt vom Profile (Identität).
// Siehe ADR-0009.

import 'package:freezed_annotation/freezed_annotation.dart';
part 'account.freezed.dart';
part 'account.g.dart';

@freezed
abstract class Account with _$Account {
  const factory Account({
    @Default('') String id,
    @Default('') String email,
    @Default('user') String role, // 'user' | 'admin'
  }) = _Account;

  factory Account.fromJson(Map<String, dynamic> json) =>
      _$AccountFromJson(json);
}

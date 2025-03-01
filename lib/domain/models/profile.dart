// Ein Model für das Profil des Benutzers, erstellt mir freezed

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';
part 'profile.freezed.dart';
part 'profile.g.dart';

@unfreezed
class Profile with _$Profile {
  factory Profile({
    @Default('') String id,         // ID des Benutzers
    @Default('') String first_name, // Standardwert: leerer String
    @Default('') String last_name,  // Standardwert: leerer String
    @Default(null) DateTime? date_of_birth,
    @Default('') String email,      // Standardwert: leerer String

    @Default('') String imageUrl,   // Standardwert: leerer String
  }) = _Profile;

  factory Profile.fromJson(Map<String, dynamic> json) => _$ProfileFromJson(json);
}
// Ein Model für das Profil des Benutzers, erstellt mir freezed

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';
part 'profile.freezed.dart';
part 'profile.g.dart';

@unfreezed
abstract class Profile with _$Profile {
  factory Profile({
    @Default('') String id, // ID des Benutzers
    @JsonKey(name: 'first_name')
    @Default('')
    String firstName, // Standardwert: leerer String
    @JsonKey(name: 'last_name')
    @Default('')
    String lastName, // Standardwert: leerer String
    @JsonKey(name: 'date_of_birth') @Default(null) DateTime? dateOfBirth,
    @Default('') String email, // Standardwert: leerer String
    @JsonKey(name: 'image_url')
    @Default('')
    String imageUrl, // Standardwert: leerer String
  }) = _Profile;

  factory Profile.fromJson(Map<String, dynamic> json) =>
      _$ProfileFromJson(json);
}

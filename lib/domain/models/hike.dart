import 'package:freezed_annotation/freezed_annotation.dart';
part 'hike.freezed.dart';
part 'hike.g.dart';

@unfreezed
class Hike with _$Hike {
  factory Hike({
    @Default('') String name,
    @Default(1.0) double length,
    @Default(0.2) double steep,
    @Default(100) int elevation,
    @Default('') String description,
    @Default(1.0) double price,
}) = _Hike;

  factory Hike.fromJson(Map<String, dynamic> json) => _$HikeFromJson(json);
}
import 'package:freezed_annotation/freezed_annotation.dart';
part 'hike.freezed.dart';
part 'hike.g.dart';

enum Difficulty { easy, mid, hard, very_hard }

@unfreezed
class Hike with _$Hike {
  factory Hike({
    @Default('') String name,
    @Default(1.0) double length,
    @Default(0.2) double steep,
    @Default(100) int elevation,
    @Default('') String description,
    @Default(1.0) double price,
    @Default(Difficulty.mid) Difficulty difficulty,
    String? thumbnail_image_url,
}) = _Hike;

  factory Hike.fromJson(Map<String, dynamic> json) => _$HikeFromJson(json);
}
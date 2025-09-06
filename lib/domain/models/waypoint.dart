import 'package:freezed_annotation/freezed_annotation.dart';

part 'waypoint.freezed.dart';
part 'waypoint.g.dart';

@freezed
abstract class Waypoint with _$Waypoint {
  const factory Waypoint({
    required int id,
    @JsonKey(name: 'hike_id') required int hikeId,
    required String name,
    required String description,
    required double latitude,
    required double longitude,
    @JsonKey(name: 'order_index') @Default(0) int orderIndex,
    @Default([]) List<String> images,
    @JsonKey(name: 'is_visited') @Default(false) bool isVisited,
  }) = _Waypoint;

  factory Waypoint.fromJson(Map<String, dynamic> json) =>
      _$WaypointFromJson(json);
}

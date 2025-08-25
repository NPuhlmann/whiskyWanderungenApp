// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'waypoint.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Waypoint _$WaypointFromJson(Map<String, dynamic> json) => _Waypoint(
  id: (json['id'] as num).toInt(),
  hikeId: (json['hike_id'] as num).toInt(),
  name: json['name'] as String,
  description: json['description'] as String,
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
  orderIndex: (json['order_index'] as num?)?.toInt() ?? 0,
  images:
      (json['images'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  isVisited: json['is_visited'] as bool? ?? false,
);

Map<String, dynamic> _$WaypointToJson(_Waypoint instance) => <String, dynamic>{
  'id': instance.id,
  'hike_id': instance.hikeId,
  'name': instance.name,
  'description': instance.description,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'order_index': instance.orderIndex,
  'images': instance.images,
  'is_visited': instance.isVisited,
};

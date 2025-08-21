// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'waypoint.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Waypoint _$WaypointFromJson(Map<String, dynamic> json) => _Waypoint(
  id: (json['id'] as num).toInt(),
  hikeId: (json['hikeId'] as num).toInt(),
  name: json['name'] as String,
  description: json['description'] as String,
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
  images:
      (json['images'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  isVisited: json['isVisited'] as bool? ?? false,
);

Map<String, dynamic> _$WaypointToJson(_Waypoint instance) => <String, dynamic>{
  'id': instance.id,
  'hikeId': instance.hikeId,
  'name': instance.name,
  'description': instance.description,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'images': instance.images,
  'isVisited': instance.isVisited,
};

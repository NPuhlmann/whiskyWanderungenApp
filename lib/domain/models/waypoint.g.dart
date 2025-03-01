// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'waypoint.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WaypointImpl _$$WaypointImplFromJson(Map<String, dynamic> json) =>
    _$WaypointImpl(
      id: (json['id'] as num).toInt(),
      hikeId: (json['hikeId'] as num).toInt(),
      name: json['name'] as String,
      description: json['description'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      orderIndex: (json['orderIndex'] as num).toInt(),
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      isVisited: json['isVisited'] as bool? ?? false,
    );

Map<String, dynamic> _$$WaypointImplToJson(_$WaypointImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'hikeId': instance.hikeId,
      'name': instance.name,
      'description': instance.description,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'orderIndex': instance.orderIndex,
      'images': instance.images,
      'isVisited': instance.isVisited,
    };

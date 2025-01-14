// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hike.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$HikeImpl _$$HikeImplFromJson(Map<String, dynamic> json) => _$HikeImpl(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? '',
      length: (json['length'] as num?)?.toDouble() ?? 1.0,
      steep: (json['steep'] as num?)?.toDouble() ?? 0.2,
      elevation: (json['elevation'] as num?)?.toInt() ?? 100,
      description: json['description'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 1.0,
      difficulty:
          $enumDecodeNullable(_$DifficultyEnumMap, json['difficulty']) ??
              Difficulty.mid,
      thumbnail_image_url: json['thumbnail_image_url'] as String?,
    );

Map<String, dynamic> _$$HikeImplToJson(_$HikeImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'length': instance.length,
      'steep': instance.steep,
      'elevation': instance.elevation,
      'description': instance.description,
      'price': instance.price,
      'difficulty': _$DifficultyEnumMap[instance.difficulty]!,
      'thumbnail_image_url': instance.thumbnail_image_url,
    };

const _$DifficultyEnumMap = {
  Difficulty.easy: 'easy',
  Difficulty.mid: 'mid',
  Difficulty.hard: 'hard',
  Difficulty.very_hard: 'very_hard',
};

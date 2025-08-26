// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hike.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Hike _$HikeFromJson(Map<String, dynamic> json) => _Hike(
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
  thumbnailImageUrl: json['thumbnail_image_url'] as String?,
  isFavorite: json['is_favorite'] as bool? ?? false,
  companyId: json['company_id'] as String?,
  company:
      json['company'] == null
          ? null
          : Company.fromJson(json['company'] as Map<String, dynamic>),
  isAvailable: json['isAvailable'] as bool? ?? true,
  availableFrom:
      json['availableFrom'] == null
          ? null
          : DateTime.parse(json['availableFrom'] as String),
  availableUntil:
      json['availableUntil'] == null
          ? null
          : DateTime.parse(json['availableUntil'] as String),
  category: json['category'] as String? ?? 'Whisky',
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
  reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
  createdAt:
      json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
  updatedAt:
      json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$HikeToJson(_Hike instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'length': instance.length,
  'steep': instance.steep,
  'elevation': instance.elevation,
  'description': instance.description,
  'price': instance.price,
  'difficulty': _$DifficultyEnumMap[instance.difficulty]!,
  'thumbnail_image_url': instance.thumbnailImageUrl,
  'is_favorite': instance.isFavorite,
  'company_id': instance.companyId,
  'company': instance.company,
  'isAvailable': instance.isAvailable,
  'availableFrom': instance.availableFrom?.toIso8601String(),
  'availableUntil': instance.availableUntil?.toIso8601String(),
  'category': instance.category,
  'tags': instance.tags,
  'averageRating': instance.averageRating,
  'reviewCount': instance.reviewCount,
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
};

const _$DifficultyEnumMap = {
  Difficulty.easy: 'easy',
  Difficulty.mid: 'mid',
  Difficulty.hard: 'hard',
  Difficulty.veryHard: 'veryHard',
};

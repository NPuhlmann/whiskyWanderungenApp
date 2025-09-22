// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tasting_set.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WhiskySample _$WhiskySampleFromJson(Map<String, dynamic> json) =>
    _WhiskySample(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      distillery: json['distillery'] as String,
      age: (json['age'] as num).toInt(),
      region: json['region'] as String,
      tastingNotes: json['tasting_notes'] as String,
      imageUrl: json['image_url'] as String,
      abv: (json['abv'] as num).toDouble(),
      category: json['category'] as String?,
      sampleSizeMl: (json['sample_size_ml'] as num?)?.toDouble() ?? 5.0,
      orderIndex: (json['order_index'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$WhiskySampleToJson(_WhiskySample instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'distillery': instance.distillery,
      'age': instance.age,
      'region': instance.region,
      'tasting_notes': instance.tastingNotes,
      'image_url': instance.imageUrl,
      'abv': instance.abv,
      'category': instance.category,
      'sample_size_ml': instance.sampleSizeMl,
      'order_index': instance.orderIndex,
    };

_TastingSet _$TastingSetFromJson(Map<String, dynamic> json) => _TastingSet(
  id: (json['id'] as num).toInt(),
  hikeId: (json['hike_id'] as num).toInt(),
  name: json['name'] as String,
  description: json['description'] as String,
  samples: (json['samples'] as List<dynamic>)
      .map((e) => WhiskySample.fromJson(e as Map<String, dynamic>))
      .toList(),
  price: (json['price'] as num?)?.toDouble() ?? 0.0,
  imageUrl: json['image_url'] as String?,
  isIncluded: json['is_included'] as bool? ?? true,
  isAvailable: json['is_available'] as bool? ?? true,
  availableFrom: json['available_from'] == null
      ? null
      : DateTime.parse(json['available_from'] as String),
  availableUntil: json['available_until'] == null
      ? null
      : DateTime.parse(json['available_until'] as String),
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$TastingSetToJson(_TastingSet instance) =>
    <String, dynamic>{
      'id': instance.id,
      'hike_id': instance.hikeId,
      'name': instance.name,
      'description': instance.description,
      'samples': instance.samples,
      'price': instance.price,
      'image_url': instance.imageUrl,
      'is_included': instance.isIncluded,
      'is_available': instance.isAvailable,
      'available_from': instance.availableFrom?.toIso8601String(),
      'available_until': instance.availableUntil?.toIso8601String(),
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

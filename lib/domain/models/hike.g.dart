// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hike.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$HikeImpl _$$HikeImplFromJson(Map<String, dynamic> json) => _$HikeImpl(
      name: json['name'] as String? ?? '',
      length: (json['length'] as num?)?.toDouble() ?? 1.0,
      steep: (json['steep'] as num?)?.toDouble() ?? 0.2,
      elevation: (json['elevation'] as num?)?.toInt() ?? 100,
      description: json['description'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 1.0,
    );

Map<String, dynamic> _$$HikeImplToJson(_$HikeImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'length': instance.length,
      'steep': instance.steep,
      'elevation': instance.elevation,
      'description': instance.description,
      'price': instance.price,
    };

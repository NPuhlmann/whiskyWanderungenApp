// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pagination_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PaginationResult<T> _$PaginationResultFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) => _PaginationResult<T>(
  items: (json['items'] as List<dynamic>).map(fromJsonT).toList(),
  currentPage: (json['currentPage'] as num).toInt(),
  totalPages: (json['totalPages'] as num).toInt(),
  totalItems: (json['totalItems'] as num).toInt(),
  pageSize: (json['pageSize'] as num).toInt(),
  hasNextPage: json['hasNextPage'] as bool,
  hasPreviousPage: json['hasPreviousPage'] as bool,
);

Map<String, dynamic> _$PaginationResultToJson<T>(
  _PaginationResult<T> instance,
  Object? Function(T value) toJsonT,
) => <String, dynamic>{
  'items': instance.items.map(toJsonT).toList(),
  'currentPage': instance.currentPage,
  'totalPages': instance.totalPages,
  'totalItems': instance.totalItems,
  'pageSize': instance.pageSize,
  'hasNextPage': instance.hasNextPage,
  'hasPreviousPage': instance.hasPreviousPage,
};

_PaginationParams _$PaginationParamsFromJson(Map<String, dynamic> json) =>
    _PaginationParams(
      page: (json['page'] as num?)?.toInt() ?? 1,
      pageSize: (json['pageSize'] as num?)?.toInt() ?? 20,
      orderBy: json['orderBy'] as String? ?? 'created_at',
      ascending: json['ascending'] as bool? ?? false,
      filters: json['filters'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$PaginationParamsToJson(_PaginationParams instance) =>
    <String, dynamic>{
      'page': instance.page,
      'pageSize': instance.pageSize,
      'orderBy': instance.orderBy,
      'ascending': instance.ascending,
      'filters': instance.filters,
    };

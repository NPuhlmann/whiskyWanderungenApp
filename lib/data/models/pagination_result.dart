import 'package:freezed_annotation/freezed_annotation.dart';

part 'pagination_result.freezed.dart';
part 'pagination_result.g.dart';

/// Generic pagination result wrapper
@Freezed(genericArgumentFactories: true)
abstract class PaginationResult<T> with _$PaginationResult<T> {
  const factory PaginationResult({
    required List<T> items,
    required int currentPage,
    required int totalPages,
    required int totalItems,
    required int pageSize,
    required bool hasNextPage,
    required bool hasPreviousPage,
  }) = _PaginationResult<T>;

  factory PaginationResult.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) => _$PaginationResultFromJson(json, fromJsonT);
}

/// Pagination parameters for requests
@freezed
abstract class PaginationParams with _$PaginationParams {
  const factory PaginationParams({
    @Default(1) int page,
    @Default(20) int pageSize,
    @Default('created_at') String orderBy,
    @Default(false) bool ascending,
    Map<String, dynamic>? filters,
  }) = _PaginationParams;

  factory PaginationParams.fromJson(Map<String, dynamic> json) =>
      _$PaginationParamsFromJson(json);
}

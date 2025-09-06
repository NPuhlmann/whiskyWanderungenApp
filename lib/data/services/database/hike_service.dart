import 'dart:developer' as dev;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../domain/models/hike.dart';
import '../error/error_handler.dart';
import '../../models/pagination_result.dart';

/// Dedicated service for hike-related operations
class HikeService {
  final SupabaseClient client;

  HikeService({SupabaseClient? client}) 
      : client = client ?? Supabase.instance.client;

  /// Get list of hikes from the 'hikes' table
  Future<List<Hike>> fetchHikes() async {
    try {
      final response = await client.from('hikes').select();
      final List<dynamic> hikeData = response as List<dynamic>;

      return hikeData.map((element) => Hike.fromJson(element as Map<String, dynamic>)).toList();
    } catch (e) {
      throw ErrorHandler.createSafeException('Fetch hikes', e);
    }
  }

  /// Get paginated list of hikes
  Future<PaginationResult<Hike>> fetchHikesPaginated(PaginationParams params) async {
    try {
      // Calculate offset
      final offset = (params.page - 1) * params.pageSize;
      final limit = params.pageSize;

      // Get total count first
      final countResponse = await client
          .from('hikes')
          .select('id');
      final totalItems = countResponse.length;
      final totalPages = (totalItems / params.pageSize).ceil();

      // Get paginated data
      var query = client
          .from('hikes')
          .select()
          .order(params.orderBy, ascending: params.ascending)
          .range(offset, offset + limit - 1);

      // Apply filters if provided
      if (params.filters != null) {
        for (final entry in params.filters!.entries) {
          query = query.eq(entry.key, entry.value);
        }
      }

      final response = await query;
      final List<dynamic> hikeData = response as List<dynamic>;

      final hikes = hikeData.map((element) => Hike.fromJson(element as Map<String, dynamic>)).toList();

      return PaginationResult<Hike>(
        items: hikes,
        currentPage: params.page,
        totalPages: totalPages,
        totalItems: totalItems,
        pageSize: params.pageSize,
        hasNextPage: params.page < totalPages,
        hasPreviousPage: params.page > 1,
      );
    } catch (e) {
      throw ErrorHandler.createSafeException('Fetch paginated hikes', e);
    }
  }

  /// Get list of hikes purchased by a user
  Future<List<Hike>> fetchUserHikes(String userId) async {
    try {
      final response = await client
          .from('purchased_hikes')
          .select('hike_id')
          .eq('user_id', userId);
      
      final List<dynamic> userHikeData = response as List<dynamic>;
      if (userHikeData.isEmpty) {
        return [];
      }

      final List<int> hikeIds = _extractHikeIds(userHikeData);
      if (hikeIds.isEmpty) {
        return [];
      }

      return await _fetchHikesByIds(hikeIds);
    } catch (e) {
      ErrorHandler.logError('Fetch user hikes', e);
      return [];
    }
  }

  /// Check if user has purchased a specific hike
  Future<bool> hasUserPurchasedHike(String userId, int hikeId) async {
    if (userId.isEmpty) {
      throw ArgumentError('User ID cannot be empty');
    }
    if (hikeId <= 0) {
      throw ArgumentError('Hike ID must be greater than 0');
    }

    try {
      dev.log('🔍 Checking if user $userId purchased hike $hikeId');

      final response = await client
          .from('purchased_hikes')
          .select('id')
          .eq('user_id', userId)
          .eq('hike_id', hikeId);

      final List<dynamic> purchaseData = response as List<dynamic>;
      final bool hasPurchased = purchaseData.isNotEmpty;

      dev.log('✅ User $userId has${hasPurchased ? '' : ' not'} purchased hike $hikeId');
      return hasPurchased;
    } catch (e) {
      throw ErrorHandler.createSafeException('Check hike purchase', e);
    }
  }

  /// Record successful hike purchase
  Future<void> recordHikePurchase(String userId, int hikeId, int orderId) async {
    if (userId.isEmpty) {
      throw ArgumentError('User ID cannot be empty');
    }
    if (hikeId <= 0) {
      throw ArgumentError('Hike ID must be greater than 0');
    }
    if (orderId <= 0) {
      throw ArgumentError('Order ID must be greater than 0');
    }

    try {
      dev.log('💰 Recording hike purchase: user=$userId, hike=$hikeId, order=$orderId');

      final purchaseData = {
        'user_id': userId,
        'hike_id': hikeId,
        'order_id': orderId,
        'purchased_at': DateTime.now().toIso8601String(),
      };

      await client.from('purchased_hikes').insert(purchaseData);
      dev.log('✅ Hike purchase recorded successfully');
    } catch (e) {
      throw ErrorHandler.createSafeException('Record hike purchase', e);
    }
  }

  /// Extract hike IDs from purchase data
  List<int> _extractHikeIds(List<dynamic> userHikeData) {
    final List<int> hikeIds = [];
    for (final element in userHikeData) {
      if (element['hike_id'] != null) {
        hikeIds.add(int.parse(element['hike_id'].toString()));
      }
    }
    return hikeIds;
  }

  /// Fetch hikes by their IDs
  Future<List<Hike>> _fetchHikesByIds(List<int> hikeIds) async {
    List<Hike> userHikes = [];
    for (final hikeId in hikeIds) {
      try {
        final hikeResponse = await client
            .from('hikes')
            .select()
            .eq('id', hikeId);
        
        final List<dynamic> hikeDataList = hikeResponse as List<dynamic>;
        if (hikeDataList.isNotEmpty) {
          final hikeData = hikeDataList.first as Map<String, dynamic>;
          userHikes.add(Hike.fromJson(hikeData));
        }
      } catch (e) {
        ErrorHandler.logError('Fetch hike by ID $hikeId', e);
        continue;
      }
    }
    return userHikes;
  }
}
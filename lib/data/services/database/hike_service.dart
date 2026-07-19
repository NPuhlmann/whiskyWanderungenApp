import 'dart:developer' as dev;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../domain/models/hike.dart';
import '../error/error_handler.dart';

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

      return hikeData
          .map((element) => Hike.fromJson(element as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ErrorHandler.createSafeException('Fetch hikes', e);
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

      dev.log(
        '✅ User $userId has${hasPurchased ? '' : ' not'} purchased hike $hikeId',
      );
      return hasPurchased;
    } catch (e) {
      throw ErrorHandler.createSafeException('Check hike purchase', e);
    }
  }

  /// Record successful hike purchase
  Future<void> recordHikePurchase(
    String userId,
    int hikeId,
    int orderId,
  ) async {
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
      dev.log(
        '💰 Recording hike purchase: user=$userId, hike=$hikeId, order=$orderId',
      );

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

  /// Permanently delete a hike and all its dependent records.
  ///
  /// Deletes in dependency order to avoid violating foreign-key
  /// constraints on tables that lack ON DELETE CASCADE:
  ///   1. hike_images        (images for the hike)
  ///   2. whisky_samples     (samples of the hike's tasting set)
  ///   3. tasting_sets       (the hike's tasting set, 1:1)
  ///   4. hikes_waypoints    (junction linking hike -> waypoints)
  ///   5. purchased_hikes    (user purchase records)
  ///   6. hikes              (the hike itself)
  ///
  /// Waypoints themselves are NOT deleted because they may be shared
  /// between multiple hikes.
  Future<void> deleteHike(int hikeId) async {
    if (hikeId <= 0) {
      throw ArgumentError('Hike ID must be greater than 0');
    }

    try {
      dev.log('🗑️ Deleting hike $hikeId and dependent records');

      // 1. hike_images
      await client.from('hike_images').delete().eq('hike_id', hikeId);

      // 2. whisky_samples belonging to this hike's tasting set
      final tastingSetResponse = await client
          .from('tasting_sets')
          .select('id')
          .eq('hike_id', hikeId);

      for (final row in tastingSetResponse as List<dynamic>) {
        final int setId = int.parse(row['id'].toString());
        await client
            .from('whisky_samples')
            .delete()
            .eq('tasting_set_id', setId);
      }

      // 3. tasting_sets
      await client.from('tasting_sets').delete().eq('hike_id', hikeId);

      // 4. hikes_waypoints junction (keeps the waypoints themselves)
      await client.from('hikes_waypoints').delete().eq('hike_id', hikeId);

      // 5. purchased_hikes
      await client.from('purchased_hikes').delete().eq('hike_id', hikeId);

      // 6. the hike itself
      await client.from('hikes').delete().eq('id', hikeId);

      dev.log('✅ Hike $hikeId deleted successfully');
    } catch (e) {
      dev.log('❌ Error deleting hike $hikeId: $e', error: e);
      throw ErrorHandler.createSafeException('Delete hike', e);
    }
  }
}

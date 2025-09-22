/// Test helper utilities for creating test data
library test_helpers;

import 'package:whisky_hikes/domain/models/hike.dart';
import 'package:whisky_hikes/domain/models/profile.dart';
import 'package:whisky_hikes/domain/models/waypoint.dart';
import 'package:whisky_hikes/domain/models/order.dart';

/// Helper class for creating test data
class TestHelpers {
  /// Creates a test hike JSON map
  static Map<String, dynamic> createTestHikeJson({
    required int id,
    required String name,
    String? description,
    String? difficulty,
    double? price,
    double? distance,
    int? duration,
    bool? isActive,
    String? region,
    String? imageUrl,
    String? previewImageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return {
      'id': id,
      'name': name,
      'description': description ?? 'Test description for $name',
      'difficulty': difficulty ?? 'medium',
      'price': price ?? 49.99,
      'distance': distance ?? 5.5,
      'duration': duration ?? 180,
      'is_active': isActive ?? true,
      'region': region ?? 'Speyside',
      'image_url': imageUrl ?? 'https://example.com/hike$id.jpg',
      'preview_image_url': previewImageUrl ?? 'https://example.com/preview$id.jpg',
      'created_at': (createdAt ?? DateTime.now()).toIso8601String(),
      'updated_at': (updatedAt ?? DateTime.now()).toIso8601String(),
    };
  }

  /// Creates a test Hike object
  static Hike createTestHike({
    required int id,
    required String name,
    String? description,
    String? difficulty,
    double? price,
    double? distance,
    int? duration,
    bool? isActive,
    String? region,
    String? imageUrl,
    String? previewImageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Hike.fromJson(createTestHikeJson(
      id: id,
      name: name,
      description: description,
      difficulty: difficulty,
      price: price,
      distance: distance,
      duration: duration,
      isActive: isActive,
      region: region,
      imageUrl: imageUrl,
      previewImageUrl: previewImageUrl,
      createdAt: createdAt,
      updatedAt: updatedAt,
    ));
  }

  /// Creates a test profile JSON map
  static Map<String, dynamic> createTestProfileJson({
    required String id,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return {
      'id': id,
      'first_name': firstName ?? 'Test',
      'last_name': lastName ?? 'User',
      'email': email ?? 'test@example.com',
      'phone': phone,
      'image_url': imageUrl,
      'created_at': (createdAt ?? DateTime.now()).toIso8601String(),
      'updated_at': (updatedAt ?? DateTime.now()).toIso8601String(),
    };
  }

  /// Creates a test Profile object
  static Profile createTestProfile({
    String? id,
    String? userId, // Alternative parameter name for compatibility
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final finalId = id ?? userId ?? 'test-user-123';
    return Profile.fromJson(createTestProfileJson(
      id: finalId,
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
      imageUrl: imageUrl,
      createdAt: createdAt,
      updatedAt: updatedAt,
    ));
  }

  /// Creates a test waypoint JSON map
  static Map<String, dynamic> createTestWaypointJson({
    required int id,
    required String name,
    String? description,
    double? latitude,
    double? longitude,
    int? orderIndex,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return {
      'id': id,
      'name': name,
      'description': description ?? 'Test waypoint description',
      'latitude': latitude ?? 52.5200,
      'longitude': longitude ?? 13.4050,
      'order_index': orderIndex ?? 1,
      'image_url': imageUrl,
      'created_at': (createdAt ?? DateTime.now()).toIso8601String(),
      'updated_at': (updatedAt ?? DateTime.now()).toIso8601String(),
    };
  }

  /// Creates a test Waypoint object
  static Waypoint createTestWaypoint({
    required int id,
    required String name,
    String? description,
    double? latitude,
    double? longitude,
    int? orderIndex,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Waypoint.fromJson(createTestWaypointJson(
      id: id,
      name: name,
      description: description,
      latitude: latitude,
      longitude: longitude,
      orderIndex: orderIndex,
      imageUrl: imageUrl,
      createdAt: createdAt,
      updatedAt: updatedAt,
    ));
  }

  /// Creates a test order JSON map
  static Map<String, dynamic> createTestOrderJson({
    required int id,
    required String userId,
    required int hikeId,
    String? status,
    double? totalAmount,
    String? paymentMethod,
    String? paymentStatus,
    String? shippingAddress,
    String? trackingNumber,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return {
      'id': id,
      'user_id': userId,
      'hike_id': hikeId,
      'status': status ?? 'pending',
      'total_amount': totalAmount ?? 49.99,
      'payment_method': paymentMethod ?? 'credit_card',
      'payment_status': paymentStatus ?? 'pending',
      'shipping_address': shippingAddress ?? 'Test Address 123, Test City',
      'tracking_number': trackingNumber,
      'created_at': (createdAt ?? DateTime.now()).toIso8601String(),
      'updated_at': (updatedAt ?? DateTime.now()).toIso8601String(),
    };
  }

  /// Creates a test Order object
  static Order createTestOrder({
    required int id,
    required String userId,
    required int hikeId,
    String? status,
    double? totalAmount,
    String? paymentMethod,
    String? paymentStatus,
    String? shippingAddress,
    String? trackingNumber,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Order.fromJson(createTestOrderJson(
      id: id,
      userId: userId,
      hikeId: hikeId,
      status: status,
      totalAmount: totalAmount,
      paymentMethod: paymentMethod,
      paymentStatus: paymentStatus,
      shippingAddress: shippingAddress,
      trackingNumber: trackingNumber,
      createdAt: createdAt,
      updatedAt: updatedAt,
    ));
  }

  /// Creates a list of test hikes
  static List<Hike> createTestHikesList({int count = 3}) {
    return List.generate(count, (index) => createTestHike(
      id: index + 1,
      name: 'Test Hike ${index + 1}',
      description: 'Description for test hike ${index + 1}',
      price: 39.99 + (index * 10),
      difficulty: index == 0 ? 'easy' : index == 1 ? 'medium' : 'hard',
    ));
  }

  /// Creates a list of test waypoints
  static List<Waypoint> createTestWaypointsList({int count = 3, int startId = 1}) {
    return List.generate(count, (index) => createTestWaypoint(
      id: startId + index,
      name: 'Waypoint ${index + 1}',
      latitude: 52.5200 + (index * 0.001),
      longitude: 13.4050 + (index * 0.001),
      orderIndex: index + 1,
    ));
  }

  /// Creates a list of test orders
  static List<Order> createTestOrdersList({int count = 3}) {
    return List.generate(count, (index) => createTestOrder(
      id: index + 1,
      userId: 'user-${index + 1}',
      hikeId: index + 1,
      status: index == 0 ? 'pending' : index == 1 ? 'processing' : 'shipped',
      totalAmount: 49.99 + (index * 10),
    ));
  }

  /// Creates test dashboard metrics data
  static Map<String, dynamic> createTestDashboardMetrics() {
    return {
      'total_revenue': 2567.89,
      'total_orders': 45,
      'total_routes': 12,
      'average_rating': 4.6,
      'revenue_growth': 15.2,
      'orders_growth': 8.7,
      'routes_growth': 0.0,
      'rating_growth': 2.3,
      'recent_orders': createTestOrdersList(count: 5)
          .map((order) => order.toJson())
          .toList(),
      'popular_routes': createTestHikesList(count: 3)
          .map((hike) => hike.toJson())
          .toList(),
    };
  }

  /// Creates test route management data
  static Map<String, dynamic> createTestRouteWithWaypoints({
    required int routeId,
    required String routeName,
    int waypointCount = 5,
  }) {
    return {
      'route': createTestHikeJson(id: routeId, name: routeName),
      'waypoints': createTestWaypointsList(count: waypointCount)
          .map((waypoint) => waypoint.toJson())
          .toList(),
    };
  }

  /// Creates test user purchase data
  static Map<String, dynamic> createTestUserPurchase({
    required String userId,
    required int hikeId,
    DateTime? purchaseDate,
  }) {
    return {
      'user_id': userId,
      'hike_id': hikeId,
      'purchase_date': (purchaseDate ?? DateTime.now()).toIso8601String(),
      'status': 'completed',
    };
  }

  /// Helper method to create valid email addresses for testing
  static String createTestEmail({String prefix = 'test', String domain = 'example.com'}) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '$prefix$timestamp@$domain';
  }

  /// Helper method to create valid phone numbers for testing
  static String createTestPhoneNumber({String countryCode = '+49'}) {
    final random = DateTime.now().millisecondsSinceEpoch % 1000000000;
    return '$countryCode$random';
  }

  /// Helper method to create test coordinates within Germany
  static Map<String, double> createTestCoordinatesGermany() {
    // Coordinates roughly within Germany bounds
    final latBase = 47.0 + (DateTime.now().millisecondsSinceEpoch % 8000) / 1000.0;
    final lngBase = 6.0 + (DateTime.now().millisecondsSinceEpoch % 10000) / 1000.0;

    return {
      'latitude': double.parse(latBase.toStringAsFixed(6)),
      'longitude': double.parse(lngBase.toStringAsFixed(6)),
    };
  }

  /// Creates a test basic order JSON map (simplified version)
  static Map<String, dynamic> createTestBasicOrderJson({
    required int id,
    required String userId,
    int? hikeId,
    String? status,
    double? totalAmount,
  }) {
    return {
      'id': id,
      'user_id': userId,
      'hike_id': hikeId ?? 1,
      'status': status ?? 'pending',
      'total_amount': totalAmount ?? 49.99,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  /// Creates a test tasting set JSON map
  static Map<String, dynamic> createTestTastingSetJson({
    required int id,
    required int hikeId,
    String? name,
    String? description,
    double? price,
    List<Map<String, dynamic>>? samples,
  }) {
    return {
      'id': id,
      'hike_id': hikeId,
      'name': name ?? 'Test Tasting Set',
      'description': description ?? 'A delicious whisky tasting set',
      'price': price ?? 0.0, // Tasting sets are included in hike price
      'samples': samples ?? [
        {
          'id': 1,
          'name': 'Highland Single Malt',
          'description': 'A smooth highland whisky',
          'region': 'Highland',
          'age': 12,
        },
        {
          'id': 2,
          'name': 'Speyside Classic',
          'description': 'A classic speyside expression',
          'region': 'Speyside',
          'age': 15,
        }
      ],
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  /// Creates a test review object
  static Map<String, dynamic> createTestReview({
    required int id,
    required String userId,
    required int hikeId,
    int? rating,
    String? comment,
    DateTime? createdAt,
  }) {
    return {
      'id': id,
      'user_id': userId,
      'hike_id': hikeId,
      'rating': rating ?? 5,
      'comment': comment ?? 'Great hike with excellent whisky selection!',
      'created_at': (createdAt ?? DateTime.now()).toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  /// Creates test payment result data
  static Map<String, dynamic> createTestPaymentResult({
    required String paymentIntentId,
    required String status,
    double? amount,
    String? currency,
    Map<String, dynamic>? metadata,
  }) {
    return {
      'payment_intent_id': paymentIntentId,
      'status': status,
      'amount': amount ?? 4999, // in cents
      'currency': currency ?? 'eur',
      'metadata': metadata ?? {'hike_id': '1', 'user_id': 'user123'},
      'created_at': DateTime.now().toIso8601String(),
    };
  }

  /// Creates test company data
  static Map<String, dynamic> createTestCompanyJson({
    required String id,
    required String name,
    String? description,
    String? website,
    String? email,
    String? phone,
    String? address,
    DateTime? createdAt,
  }) {
    return {
      'id': id,
      'name': name,
      'description': description ?? 'A premium whisky distillery',
      'website': website ?? 'https://example.com',
      'email': email ?? 'contact@example.com',
      'phone': phone ?? '+49 123 456789',
      'address': address ?? 'Distillery Street 123, Highland, Scotland',
      'created_at': (createdAt ?? DateTime.now()).toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  /// Creates test review JSON (alias for createTestReview)
  static Map<String, dynamic> createTestReviewJson({
    int? id,
    required int hikeId,
    String? userId,
    int? rating,
    String? comment,
    DateTime? createdAt,
  }) {
    return createTestReview(
      id: id ?? 1,
      userId: userId ?? 'user123',
      hikeId: hikeId,
      rating: rating,
      comment: comment,
      createdAt: createdAt,
    );
  }
}
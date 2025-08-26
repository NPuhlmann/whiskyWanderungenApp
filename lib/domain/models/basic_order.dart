/// Order status enum for tracking order progression
enum OrderStatus {
  pending,
  confirmed,
  processing,
  shipped,
  delivered,
  cancelled
}

/// Delivery type enum for order fulfillment
enum DeliveryType {
  pickup,
  shipping
}

/// Basic Order model (without Freezed) for TDD progression
class BasicOrder {
  final int id;
  final String orderNumber;
  final int hikeId;
  final String userId;
  final double totalAmount;
  final DeliveryType deliveryType;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime? estimatedDelivery;
  final String? trackingNumber;
  final Map<String, dynamic>? deliveryAddress;
  final String? paymentIntentId;
  final DateTime? updatedAt;

  const BasicOrder({
    required this.id,
    required this.orderNumber,
    required this.hikeId,
    required this.userId,
    required this.totalAmount,
    required this.deliveryType,
    required this.status,
    required this.createdAt,
    this.estimatedDelivery,
    this.trackingNumber,
    this.deliveryAddress,
    this.paymentIntentId,
    this.updatedAt,
  });

  /// Create a copy of BasicOrder with updated fields
  BasicOrder copyWith({
    int? id,
    String? orderNumber,
    int? hikeId,
    String? userId,
    double? totalAmount,
    DeliveryType? deliveryType,
    OrderStatus? status,
    DateTime? createdAt,
    DateTime? estimatedDelivery,
    String? trackingNumber,
    Map<String, dynamic>? deliveryAddress,
    String? paymentIntentId,
    DateTime? updatedAt,
  }) {
    return BasicOrder(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      hikeId: hikeId ?? this.hikeId,
      userId: userId ?? this.userId,
      totalAmount: totalAmount ?? this.totalAmount,
      deliveryType: deliveryType ?? this.deliveryType,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      estimatedDelivery: estimatedDelivery ?? this.estimatedDelivery,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      paymentIntentId: paymentIntentId ?? this.paymentIntentId,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderNumber': orderNumber,
      'hikeId': hikeId,
      'userId': userId,
      'totalAmount': totalAmount,
      'deliveryType': deliveryType.name,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      if (estimatedDelivery != null) 'estimatedDelivery': estimatedDelivery!.toIso8601String(),
      if (trackingNumber != null) 'trackingNumber': trackingNumber,
      if (deliveryAddress != null) 'deliveryAddress': deliveryAddress,
      if (paymentIntentId != null) 'paymentIntentId': paymentIntentId,
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  /// Create from JSON
  factory BasicOrder.fromJson(Map<String, dynamic> json) {
    return BasicOrder(
      id: json['id'] as int,
      orderNumber: json['orderNumber'] as String,
      hikeId: json['hikeId'] as int,
      userId: json['userId'] as String,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      deliveryType: DeliveryType.values.firstWhere(
        (e) => e.name == json['deliveryType'],
      ),
      status: OrderStatus.values.firstWhere(
        (e) => e.name == json['status'],
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      estimatedDelivery: json['estimatedDelivery'] != null
          ? DateTime.parse(json['estimatedDelivery'] as String)
          : null,
      trackingNumber: json['trackingNumber'] as String?,
      deliveryAddress: json['deliveryAddress'] as Map<String, dynamic>?,
      paymentIntentId: json['paymentIntentId'] as String?,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BasicOrder &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          orderNumber == other.orderNumber &&
          hikeId == other.hikeId &&
          userId == other.userId &&
          totalAmount == other.totalAmount &&
          deliveryType == other.deliveryType &&
          status == other.status &&
          createdAt == other.createdAt;

  @override
  int get hashCode => Object.hash(
        id,
        orderNumber,
        hikeId,
        userId,
        totalAmount,
        deliveryType,
        status,
        createdAt,
      );

  @override
  String toString() {
    return 'BasicOrder(id: $id, orderNumber: $orderNumber, status: $status)';
  }
}

/// Extension for business logic on BasicOrder
extension BasicOrderExtensions on BasicOrder {
  /// Check if the order requires a delivery address
  bool get requiresDeliveryAddress => deliveryType == DeliveryType.shipping;
  
  /// Check if the order is in a final state (completed or cancelled)
  bool get isFinalStatus => status == OrderStatus.delivered || status == OrderStatus.cancelled;
  
  /// Check if the order can be cancelled
  bool get canBeCancelled => status == OrderStatus.pending || status == OrderStatus.confirmed;
  
  /// Get the delivery cost based on delivery type
  double get deliveryCost => deliveryType == DeliveryType.shipping ? 5.0 : 0.0;
  
  /// Get base price (total minus delivery cost)
  double get basePrice => totalAmount - deliveryCost;
  
  /// Generate a formatted order number display
  String get formattedOrderNumber => '#$orderNumber';
}
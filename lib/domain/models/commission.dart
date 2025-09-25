import 'package:freezed_annotation/freezed_annotation.dart';

part 'commission.freezed.dart';
part 'commission.g.dart';

/// Enum representing the status of a commission
enum CommissionStatus {
  pending,
  calculated,
  paid,
  cancelled,
}

/// Represents a commission record for a hike order
@freezed
abstract class Commission with _$Commission {
  const factory Commission({
    required int id,
    @JsonKey(name: 'hike_id') required int hikeId,
    @JsonKey(name: 'company_id') required String companyId,
    @JsonKey(name: 'order_id') required String orderId,
    @JsonKey(name: 'commission_rate') required double commissionRate,
    @JsonKey(name: 'base_amount') required double baseAmount,
    @JsonKey(name: 'commission_amount') required double commissionAmount,
    required CommissionStatus status,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'paid_at') DateTime? paidAt,
    @JsonKey(name: 'billing_period_id') String? billingPeriodId,
    String? notes,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _Commission;

  factory Commission.fromJson(Map<String, dynamic> json) => _$CommissionFromJson(json);
}

/// Extension for business logic on Commission
extension CommissionExtensions on Commission {
  /// Get commission rate as percentage (0.15 -> 15.0)
  double get commissionRatePercentage => commissionRate * 100;

  /// Get formatted commission amount with currency symbol
  String get formattedCommissionAmount => '€${commissionAmount.toStringAsFixed(2)}';

  /// Get formatted base amount with currency symbol
  String get formattedBaseAmount => '€${baseAmount.toStringAsFixed(2)}';

  /// Check if commission is pending
  bool get isPending => status == CommissionStatus.pending;

  /// Check if commission is calculated
  bool get isCalculated => status == CommissionStatus.calculated;

  /// Check if commission is paid
  bool get isPaid => status == CommissionStatus.paid;

  /// Check if commission is cancelled
  bool get isCancelled => status == CommissionStatus.cancelled;

  /// Check if the commission calculation is mathematically correct
  bool get isCalculationValid {
    final expected = expectedCommissionAmount;
    const tolerance = 0.01; // Allow 1 cent tolerance for rounding
    return (commissionAmount - expected).abs() <= tolerance;
  }

  /// Calculate the expected commission amount based on rate and base amount
  double get expectedCommissionAmount => baseAmount * commissionRate;

  /// Check if commission is overdue (more than 30 days since creation and not paid)
  bool get isOverdue {
    if (isPaid) return false;
    const overdueThreshold = Duration(days: 30);
    return DateTime.now().difference(createdAt) > overdueThreshold;
  }

  /// Get the age of the commission in days
  int get ageInDays => DateTime.now().difference(createdAt).inDays;

  /// Get a display name for the commission
  String get displayName => 'Commission #$id (Hike $hikeId)';

  /// Get status display text with proper formatting
  String get statusDisplay {
    switch (status) {
      case CommissionStatus.pending:
        return 'Pending';
      case CommissionStatus.calculated:
        return 'Calculated';
      case CommissionStatus.paid:
        return 'Paid';
      case CommissionStatus.cancelled:
        return 'Cancelled';
    }
  }

  /// Check if the commission can be marked as paid
  bool get canBeMarkedAsPaid => 
      (status == CommissionStatus.pending || status == CommissionStatus.calculated) && 
      !isCancelled;

  /// Check if the commission can be cancelled
  bool get canBeCancelled => !isPaid && !isCancelled;

  /// Get the time since creation as a human-readable string
  String get timeSinceCreation {
    final difference = DateTime.now().difference(createdAt);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays != 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours != 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes != 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}
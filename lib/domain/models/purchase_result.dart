/// Outcome of a purchase intake attempt.
///
/// ponytail: plain immutable class, not Freezed — never serialised, so
/// codegen would buy nothing.
class PurchaseResult {
  final bool isSuccess;
  final int? orderId;
  final String? orderNumber;
  final String? paymentIntentId;

  /// Machine-readable failure code, e.g. `noCompany`, `cancelled`.
  final String? reason;

  /// Human-readable message for the UI.
  final String? message;

  const PurchaseResult._({
    required this.isSuccess,
    this.orderId,
    this.orderNumber,
    this.paymentIntentId,
    this.reason,
    this.message,
  });

  const PurchaseResult.success({
    required int orderId,
    required String orderNumber,
    String? paymentIntentId,
  }) : this._(
         isSuccess: true,
         orderId: orderId,
         orderNumber: orderNumber,
         paymentIntentId: paymentIntentId,
       );

  const PurchaseResult.failure({required String reason, String? message})
    : this._(isSuccess: false, reason: reason, message: message);
}

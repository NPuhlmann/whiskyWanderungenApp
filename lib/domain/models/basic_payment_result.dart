import 'basic_order.dart';

/// Payment status enum for tracking payment state
enum PaymentStatus {
  succeeded,
  failed,
  pending,
  cancelled,
  requiresAction
}

/// Result of a payment operation (Basic version without Freezed)
class BasicPaymentResult {
  final bool isSuccess;
  final BasicOrder? order;
  final String? clientSecret;
  final String? errorMessage;
  final PaymentStatus? status;
  final String? paymentIntentId;
  final Map<String, dynamic>? metadata;

  const BasicPaymentResult({
    required this.isSuccess,
    this.order,
    this.clientSecret,
    this.errorMessage,
    this.status,
    this.paymentIntentId,
    this.metadata,
  });
  
  /// Factory constructor for successful payment
  factory BasicPaymentResult.success({
    required BasicOrder order,
    String? clientSecret,
    String? paymentIntentId,
    Map<String, dynamic>? metadata,
  }) {
    return BasicPaymentResult(
      isSuccess: true,
      order: order,
      clientSecret: clientSecret,
      status: PaymentStatus.succeeded,
      paymentIntentId: paymentIntentId,
      metadata: metadata,
    );
  }
  
  /// Factory constructor for failed payment
  factory BasicPaymentResult.failure({
    required String error,
    PaymentStatus? status,
    String? paymentIntentId,
    Map<String, dynamic>? metadata,
  }) {
    return BasicPaymentResult(
      isSuccess: false,
      errorMessage: error,
      status: status ?? PaymentStatus.failed,
      paymentIntentId: paymentIntentId,
      metadata: metadata,
    );
  }
  
  /// Factory constructor for cancelled payment
  factory BasicPaymentResult.cancelled({
    String? message,
    String? paymentIntentId,
  }) {
    return BasicPaymentResult(
      isSuccess: false,
      errorMessage: message ?? 'Payment was cancelled by user',
      status: PaymentStatus.cancelled,
      paymentIntentId: paymentIntentId,
    );
  }
  
  /// Factory constructor for pending payment (requires additional action)
  factory BasicPaymentResult.requiresAction({
    required String clientSecret,
    String? paymentIntentId,
    Map<String, dynamic>? metadata,
  }) {
    return BasicPaymentResult(
      isSuccess: false,
      clientSecret: clientSecret,
      status: PaymentStatus.requiresAction,
      paymentIntentId: paymentIntentId,
      metadata: metadata,
      errorMessage: 'Additional authentication required',
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'isSuccess': isSuccess,
      if (order != null) 'order': order!.toJson(),
      if (clientSecret != null) 'clientSecret': clientSecret,
      if (errorMessage != null) 'errorMessage': errorMessage,
      if (status != null) 'status': status!.name,
      if (paymentIntentId != null) 'paymentIntentId': paymentIntentId,
      if (metadata != null) 'metadata': metadata,
    };
  }

  /// Create from JSON
  factory BasicPaymentResult.fromJson(Map<String, dynamic> json) {
    return BasicPaymentResult(
      isSuccess: json['isSuccess'] as bool,
      order: json['order'] != null 
          ? BasicOrder.fromJson(json['order'] as Map<String, dynamic>)
          : null,
      clientSecret: json['clientSecret'] as String?,
      errorMessage: json['errorMessage'] as String?,
      status: json['status'] != null
          ? PaymentStatus.values.firstWhere((e) => e.name == json['status'])
          : null,
      paymentIntentId: json['paymentIntentId'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BasicPaymentResult &&
          runtimeType == other.runtimeType &&
          isSuccess == other.isSuccess &&
          order == other.order &&
          clientSecret == other.clientSecret &&
          errorMessage == other.errorMessage &&
          status == other.status &&
          paymentIntentId == other.paymentIntentId;

  @override
  int get hashCode => Object.hash(
        isSuccess,
        order,
        clientSecret,
        errorMessage,
        status,
        paymentIntentId,
      );

  @override
  String toString() {
    return 'BasicPaymentResult(isSuccess: $isSuccess, status: $status, error: $errorMessage)';
  }
}

/// Extension for business logic on BasicPaymentResult
extension BasicPaymentResultExtensions on BasicPaymentResult {
  /// Check if payment requires additional user action (3D Secure, etc.)
  bool get requiresUserAction => status == PaymentStatus.requiresAction;
  
  /// Check if payment was cancelled by user
  bool get wasCancelled => status == PaymentStatus.cancelled;
  
  /// Check if payment is still processing
  bool get isPending => status == PaymentStatus.pending;
  
  /// Get user-friendly error message in German
  String get friendlyErrorMessage {
    if (errorMessage == null) return 'Unknown error occurred';
    
    final message = errorMessage!.toLowerCase();
    
    if (message.contains('declined') || message.contains('insufficient')) {
      return 'Ihre Karte wurde abgelehnt. Bitte versuchen Sie eine andere Zahlungsmethode.';
    }
    
    if (message.contains('expired')) {
      return 'Ihre Karte ist abgelaufen. Bitte verwenden Sie eine aktuelle Karte.';
    }
    
    if (message.contains('network') || message.contains('connection')) {
      return 'Netzwerkfehler. Bitte überprüfen Sie Ihre Internetverbindung und versuchen Sie es erneut.';
    }
    
    if (message.contains('invalid') || message.contains('incorrect')) {
      return 'Ungültige Kartendaten. Bitte überprüfen Sie Ihre Eingaben.';
    }
    
    if (message.contains('cancelled')) {
      return 'Zahlung wurde abgebrochen.';
    }
    
    // Fallback für unbekannte Fehler
    return 'Ein Fehler ist aufgetreten. Bitte versuchen Sie es erneut oder kontaktieren Sie den Support.';
  }
}
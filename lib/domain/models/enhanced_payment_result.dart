// import 'package:freezed_annotation/freezed_annotation.dart';
import 'enhanced_order.dart';
import 'delivery_address.dart';
import 'company.dart';
import 'payment_intent.dart';

// part 'enhanced_payment_result.freezed.dart';
// part 'enhanced_payment_result.g.dart';

/// Enhanced Payment Status für erweiterte Funktionalität
enum EnhancedPaymentStatus {
  succeeded,
  failed,
  pending,
  cancelled,
  requiresAction, // 3D Secure, etc.
  requiresPaymentMethod,
  processing,
  partiallyRefunded,
  fullyRefunded,
}

/// Enhanced Payment Result für Multi-Vendor System
/// Umfasst alle Aspekte der Payment-Verarbeitung mit Company-Kontext
class EnhancedPaymentResult {
  final bool isSuccess;
  final EnhancedPaymentStatus status;
  
  // Order Information
  final EnhancedOrder? order;
  
  // Payment Information
  final String? paymentIntentId;
  final String? clientSecret;
  final String? paymentMethodId;
  final PaymentProvider? paymentProvider;
  
  // Multi-Vendor Context
  final String? companyId;
  final Company? company;
  
  // Shipping Context
  final ShippingCostResult? shippingResult;
  final DeliveryAddress? deliveryAddress;
  
  // Error Information
  final String? errorMessage;
  final String? errorCode;
  final PaymentErrorType? errorType;
  
  // Financial Information
  final double? amount; // In Euros
  final int? amountInCents; // Stripe format
  final String? currency;
  
  // Metadata und Additional Info
  final Map<String, dynamic> metadata;
  
  // Timing Information
  final DateTime? createdAt;
  final DateTime? processedAt;
  
  // Customer Information (for context)
  final String? customerEmail;
  final String? customerId;
  
  // Next Actions (für requires_action status)
  final PaymentNextAction? nextAction;

  const EnhancedPaymentResult({
    required this.isSuccess,
    required this.status,
    this.order,
    this.paymentIntentId,
    this.clientSecret,
    this.paymentMethodId,
    this.paymentProvider,
    this.companyId,
    this.company,
    this.shippingResult,
    this.deliveryAddress,
    this.errorMessage,
    this.errorCode,
    this.errorType,
    this.amount,
    this.amountInCents,
    this.currency,
    this.metadata = const {},
    this.createdAt,
    this.processedAt,
    this.customerEmail,
    this.customerId,
    this.nextAction,
  });

  factory EnhancedPaymentResult.fromJson(Map<String, dynamic> json) {
    return EnhancedPaymentResult(
      isSuccess: json['is_success'] as bool,
      status: EnhancedPaymentStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => EnhancedPaymentStatus.pending,
      ),
      paymentIntentId: json['payment_intent_id'] as String?,
      clientSecret: json['client_secret'] as String?,
      paymentMethodId: json['payment_method_id'] as String?,
      amount: json['amount'] != null ? (json['amount'] as num).toDouble() : null,
      amountInCents: json['amount_in_cents'] as int?,
      currency: json['currency'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
      processedAt: json['processed_at'] != null ? DateTime.parse(json['processed_at'] as String) : null,
      customerEmail: json['customer_email'] as String?,
      customerId: json['customer_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'is_success': isSuccess,
      'status': status.name,
      'payment_intent_id': paymentIntentId,
      'client_secret': clientSecret,
      'payment_method_id': paymentMethodId,
      'amount': amount,
      'amount_in_cents': amountInCents,
      'currency': currency,
      'metadata': metadata,
      'created_at': createdAt?.toIso8601String(),
      'processed_at': processedAt?.toIso8601String(),
      'customer_email': customerEmail,
      'customer_id': customerId,
    };
  }
}

/// Payment Error Type für kategorisierte Fehlerbehandlung
enum PaymentErrorType {
  cardDeclined,
  insufficientFunds,
  expiredCard,
  invalidCvc,
  processingError,
  networkError,
  authenticationRequired,
  userCancelled,
  shippingError,
  companyError,
  invalidAmount,
  systemError,
  unknown,
}

/// Payment Next Action für requires_action Status
class PaymentNextAction {
  final String type;
  final String? instructions;
  final String? redirectUrl;
  final Map<String, dynamic>? actionData;

  const PaymentNextAction({
    required this.type,
    this.instructions,
    this.redirectUrl,
    this.actionData,
  });

  factory PaymentNextAction.fromJson(Map<String, dynamic> json) {
    return PaymentNextAction(
      type: json['type'] as String,
      instructions: json['instructions'] as String?,
      redirectUrl: json['redirect_url'] as String?,
      actionData: json['action_data'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'instructions': instructions,
      'redirect_url': redirectUrl,
      'action_data': actionData,
    };
  }
}

/// Extension für EnhancedPaymentResult
extension EnhancedPaymentResultExtensions on EnhancedPaymentResult {
  /// Generiert einen Anzeige-String für den Payment-Status
  String get statusDisplayText {
    switch (status) {
      case EnhancedPaymentStatus.succeeded:
        return 'Zahlung erfolgreich';
      case EnhancedPaymentStatus.failed:
        return 'Zahlung fehlgeschlagen';
      case EnhancedPaymentStatus.pending:
        return 'Zahlung ausstehend';
      case EnhancedPaymentStatus.cancelled:
        return 'Zahlung abgebrochen';
      case EnhancedPaymentStatus.requiresAction:
        return 'Zusätzliche Aktion erforderlich';
      case EnhancedPaymentStatus.requiresPaymentMethod:
        return 'Zahlungsmethode erforderlich';
      case EnhancedPaymentStatus.processing:
        return 'Zahlung wird verarbeitet';
      case EnhancedPaymentStatus.partiallyRefunded:
        return 'Teilweise erstattet';
      case EnhancedPaymentStatus.fullyRefunded:
        return 'Vollständig erstattet';
    }
  }

  /// Generiert einen Fehlertext für fehlgeschlagene Zahlungen
  String? get errorDisplayText {
    if (isSuccess || errorMessage == null) return null;
    
    if (errorType != null) {
      switch (errorType!) {
        case PaymentErrorType.cardDeclined:
          return 'Karte wurde abgelehnt. Bitte verwenden Sie eine andere Karte.';
        case PaymentErrorType.insufficientFunds:
          return 'Nicht ausreichende Deckung. Bitte prüfen Sie Ihr Konto oder verwenden Sie eine andere Karte.';
        case PaymentErrorType.expiredCard:
          return 'Ihre Karte ist abgelaufen. Bitte verwenden Sie eine aktuelle Karte.';
        case PaymentErrorType.invalidCvc:
          return 'Ungültige Kartendaten. Bitte überprüfen Sie Ihre Eingaben.';
        case PaymentErrorType.networkError:
          return 'Netzwerkfehler. Bitte versuchen Sie es erneut.';
        case PaymentErrorType.authenticationRequired:
          return 'Zusätzliche Authentifizierung erforderlich.';
        case PaymentErrorType.userCancelled:
          return 'Zahlung wurde vom Benutzer abgebrochen.';
        case PaymentErrorType.shippingError:
          return 'Fehler bei der Lieferung. Bitte überprüfen Sie Ihre Adresse.';
        case PaymentErrorType.companyError:
          return 'Fehler bei der Firma. Bitte kontaktieren Sie den Support.';
        case PaymentErrorType.invalidAmount:
          return 'Ungültiger Betrag. Bitte überprüfen Sie Ihre Eingabe.';
        case PaymentErrorType.systemError:
          return 'Systemfehler. Bitte versuchen Sie es später erneut.';
        case PaymentErrorType.processingError:
        case PaymentErrorType.unknown:
        default:
          return errorMessage;
      }
    }
    
    return errorMessage;
  }

  /// Prüft ob die Zahlung erfolgreich war
  bool get isSuccessful => status == EnhancedPaymentStatus.succeeded;

  /// Prüft ob die Zahlung fehlgeschlagen ist
  bool get isFailed => status == EnhancedPaymentStatus.failed;

  /// Prüft ob die Zahlung ausstehend ist
  bool get isPending => status == EnhancedPaymentStatus.pending;

  /// Prüft ob die Zahlung eine Aktion erfordert
  bool get requiresAction => status == EnhancedPaymentStatus.requiresAction;

  /// Prüft ob die Zahlung verarbeitet wird
  bool get isProcessing => status == EnhancedPaymentStatus.processing;

  /// Generiert einen formatierten Betrag
  String? get formattedAmount {
    if (amount == null) return null;
    return '€${amount!.toStringAsFixed(2)}';
  }

  /// Generiert einen formatierten Betrag in Cent
  String? get formattedAmountInCents {
    if (amountInCents == null) return null;
    return '€${(amountInCents! / 100).toStringAsFixed(2)}';
  }
}
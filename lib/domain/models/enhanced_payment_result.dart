import 'package:freezed_annotation/freezed_annotation.dart';
import 'enhanced_order.dart';
import 'delivery_address.dart';
import 'company.dart';

part 'enhanced_payment_result.freezed.dart';
part 'enhanced_payment_result.g.dart';

/// Enhanced Payment Status für erweiterte Funktionalität
enum EnhancedPaymentStatus {
  @JsonValue('succeeded') succeeded,
  @JsonValue('failed') failed,
  @JsonValue('pending') pending,
  @JsonValue('cancelled') cancelled,
  @JsonValue('requires_action') requiresAction, // 3D Secure, etc.
  @JsonValue('requires_payment_method') requiresPaymentMethod,
  @JsonValue('processing') processing,
  @JsonValue('partially_refunded') partiallyRefunded,
  @JsonValue('fully_refunded') fullyRefunded,
}

/// Enhanced Payment Result für Multi-Vendor System
/// Umfasst alle Aspekte der Payment-Verarbeitung mit Company-Kontext
@freezed
class EnhancedPaymentResult with _$EnhancedPaymentResult {
  const factory EnhancedPaymentResult({
    required bool isSuccess,
    required EnhancedPaymentStatus status,
    
    // Order Information
    EnhancedOrder? order,
    
    // Payment Information
    String? paymentIntentId,
    String? clientSecret,
    String? paymentMethodId,
    PaymentProvider? paymentProvider,
    
    // Multi-Vendor Context
    String? companyId,
    Company? company,
    
    // Shipping Context
    ShippingCostResult? shippingResult,
    DeliveryAddress? deliveryAddress,
    
    // Error Information
    String? errorMessage,
    String? errorCode,
    PaymentErrorType? errorType,
    
    // Financial Information
    double? amount, // In Euros
    int? amountInCents, // Stripe format
    String? currency,
    
    // Metadata und Additional Info
    @Default({}) Map<String, dynamic> metadata,
    
    // Timing Information
    DateTime? createdAt,
    DateTime? processedAt,
    
    // Customer Information (for context)
    String? customerEmail,
    String? customerId,
    
    // Next Actions (für requires_action status)
    PaymentNextAction? nextAction,
  }) = _EnhancedPaymentResult;

  factory EnhancedPaymentResult.fromJson(Map<String, dynamic> json) => 
      _$EnhancedPaymentResultFromJson(json);

  // Factory constructors für verschiedene Szenarien
  factory EnhancedPaymentResult.success({
    required EnhancedOrder order,
    String? paymentIntentId,
    String? clientSecret,
    String? paymentMethodId,
    PaymentProvider? paymentProvider,
    Map<String, dynamic>? metadata,
  }) {
    return EnhancedPaymentResult(
      isSuccess: true,
      status: EnhancedPaymentStatus.succeeded,
      order: order,
      paymentIntentId: paymentIntentId,
      clientSecret: clientSecret,
      paymentMethodId: paymentMethodId,
      paymentProvider: paymentProvider,
      companyId: order.companyId,
      company: order.company,
      shippingResult: order.shippingDetails,
      deliveryAddress: order.deliveryAddress,
      amount: order.totalAmount,
      amountInCents: (order.totalAmount * 100).round(),
      currency: order.currency ?? 'EUR',
      metadata: metadata ?? {},
      createdAt: DateTime.now(),
      processedAt: DateTime.now(),
    );
  }

  factory EnhancedPaymentResult.failure({
    required String errorMessage,
    String? errorCode,
    PaymentErrorType? errorType,
    String? paymentIntentId,
    String? companyId,
    Company? company,
    double? amount,
    Map<String, dynamic>? metadata,
  }) {
    return EnhancedPaymentResult(
      isSuccess: false,
      status: EnhancedPaymentStatus.failed,
      errorMessage: errorMessage,
      errorCode: errorCode,
      errorType: errorType ?? PaymentErrorType.unknown,
      paymentIntentId: paymentIntentId,
      companyId: companyId,
      company: company,
      amount: amount,
      amountInCents: amount != null ? (amount * 100).round() : null,
      currency: 'EUR',
      metadata: metadata ?? {},
      createdAt: DateTime.now(),
    );
  }

  factory EnhancedPaymentResult.requiresAction({
    required String clientSecret,
    String? paymentIntentId,
    PaymentNextAction? nextAction,
    String? companyId,
    Company? company,
    double? amount,
    Map<String, dynamic>? metadata,
  }) {
    return EnhancedPaymentResult(
      isSuccess: false,
      status: EnhancedPaymentStatus.requiresAction,
      clientSecret: clientSecret,
      paymentIntentId: paymentIntentId,
      nextAction: nextAction,
      companyId: companyId,
      company: company,
      amount: amount,
      amountInCents: amount != null ? (amount * 100).round() : null,
      currency: 'EUR',
      errorMessage: 'Zusätzliche Authentifizierung erforderlich',
      metadata: metadata ?? {},
      createdAt: DateTime.now(),
    );
  }

  factory EnhancedPaymentResult.cancelled({
    String? paymentIntentId,
    String? reason,
    Map<String, dynamic>? metadata,
  }) {
    return EnhancedPaymentResult(
      isSuccess: false,
      status: EnhancedPaymentStatus.cancelled,
      paymentIntentId: paymentIntentId,
      errorMessage: reason ?? 'Zahlung wurde vom Benutzer abgebrochen',
      errorType: PaymentErrorType.userCancelled,
      metadata: metadata ?? {},
      createdAt: DateTime.now(),
    );
  }
}

/// Payment Error Type für bessere Fehlerklassifikation
enum PaymentErrorType {
  @JsonValue('card_declined') cardDeclined,
  @JsonValue('insufficient_funds') insufficientFunds,
  @JsonValue('card_expired') cardExpired,
  @JsonValue('invalid_card') invalidCard,
  @JsonValue('network_error') networkError,
  @JsonValue('authentication_required') authenticationRequired,
  @JsonValue('user_cancelled') userCancelled,
  @JsonValue('processing_error') processingError,
  @JsonValue('invalid_amount') invalidAmount,
  @JsonValue('shipping_error') shippingError,
  @JsonValue('company_error') companyError,
  @JsonValue('system_error') systemError,
  @JsonValue('unknown') unknown,
}

/// Next Action für Payments die weitere Schritte benötigen
@freezed
class PaymentNextAction with _$PaymentNextAction {
  const factory PaymentNextAction({
    required PaymentActionType type,
    String? redirectUrl,
    Map<String, dynamic>? actionData,
    String? instructions,
  }) = _PaymentNextAction;

  factory PaymentNextAction.fromJson(Map<String, dynamic> json) => 
      _$PaymentNextActionFromJson(json);
}

enum PaymentActionType {
  @JsonValue('redirect_to_url') redirectToUrl,
  @JsonValue('use_stripe_sdk') useStripeSdk,
  @JsonValue('verify_with_microdeposits') verifyWithMicrodeposits,
  @JsonValue('oxxo_display_details') oxxoDisplayDetails,
}

/// Extension für Enhanced Payment Result Business Logic
extension EnhancedPaymentResultExtensions on EnhancedPaymentResult {
  /// Prüft ob die Zahlung weitere Benutzeraktionen benötigt
  bool get requiresUserAction => status == EnhancedPaymentStatus.requiresAction;
  
  /// Prüft ob die Zahlung vom Benutzer abgebrochen wurde
  bool get wasCancelled => status == EnhancedPaymentStatus.cancelled;
  
  /// Prüft ob die Zahlung noch in Bearbeitung ist
  bool get isPending => [
    EnhancedPaymentStatus.pending,
    EnhancedPaymentStatus.processing,
  ].contains(status);
  
  /// Prüft ob die Zahlung erfolgreich war
  bool get wasSuccessful => status == EnhancedPaymentStatus.succeeded;
  
  /// Prüft ob die Zahlung fehlgeschlagen ist
  bool get hasFailed => [
    EnhancedPaymentStatus.failed,
    EnhancedPaymentStatus.cancelled,
  ].contains(status);
  
  /// Generiert eine benutzerfreundliche Fehlermeldung auf Deutsch
  String get friendlyErrorMessage {
    if (errorMessage == null) return 'Ein unbekannter Fehler ist aufgetreten';
    
    // Verwende spezifische Fehlermeldungen basierend auf ErrorType
    switch (errorType) {
      case PaymentErrorType.cardDeclined:
        return 'Ihre Karte wurde abgelehnt. Bitte versuchen Sie eine andere Zahlungsmethode.';
      case PaymentErrorType.insufficientFunds:
        return 'Nicht ausreichende Deckung. Bitte prüfen Sie Ihr Konto oder verwenden Sie eine andere Karte.';
      case PaymentErrorType.cardExpired:
        return 'Ihre Karte ist abgelaufen. Bitte verwenden Sie eine aktuelle Karte.';
      case PaymentErrorType.invalidCard:
        return 'Ungültige Kartendaten. Bitte überprüfen Sie Ihre Eingaben.';
      case PaymentErrorType.networkError:
        return 'Netzwerkfehler. Bitte überprüfen Sie Ihre Internetverbindung und versuchen Sie es erneut.';
      case PaymentErrorType.authenticationRequired:
        return 'Zusätzliche Authentifizierung erforderlich. Bitte befolgen Sie die Anweisungen Ihrer Bank.';
      case PaymentErrorType.userCancelled:
        return 'Zahlung wurde abgebrochen.';
      case PaymentErrorType.shippingError:
        return 'Fehler bei der Versandkostenberechnung. Bitte überprüfen Sie Ihre Lieferadresse.';
      case PaymentErrorType.companyError:
        return 'Fehler beim Anbieter. Bitte versuchen Sie es später erneut oder kontaktieren Sie den Support.';
      case PaymentErrorType.invalidAmount:
        return 'Ungültiger Betrag. Bitte versuchen Sie es erneut.';
      case PaymentErrorType.processingError:
        return 'Fehler bei der Zahlungsverarbeitung. Bitte versuchen Sie es erneut.';
      case PaymentErrorType.systemError:
        return 'Systemfehler. Bitte versuchen Sie es später erneut.';
      default:
        // Fallback auf die ursprüngliche Fehlermeldung
        return errorMessage ?? 'Ein Fehler ist aufgetreten. Bitte versuchen Sie es erneut oder kontaktieren Sie den Support.';
    }
  }
  
  /// Generiert einen Status-Display-Text auf Deutsch
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
        return 'Authentifizierung erforderlich';
      case EnhancedPaymentStatus.requiresPaymentMethod:
        return 'Zahlungsmethode erforderlich';
      case EnhancedPaymentStatus.processing:
        return 'Zahlung wird bearbeitet';
      case EnhancedPaymentStatus.partiallyRefunded:
        return 'Teilweise erstattet';
      case EnhancedPaymentStatus.fullyRefunded:
        return 'Vollständig erstattet';
    }
  }
  
  /// Generiert einen Payment Provider Display-Text
  String? get paymentProviderDisplayText {
    switch (paymentProvider) {
      case PaymentProvider.stripe:
        return 'Kreditkarte';
      case PaymentProvider.paypal:
        return 'PayPal';
      case PaymentProvider.applePay:
        return 'Apple Pay';
      case PaymentProvider.googlePay:
        return 'Google Pay';
      default:
        return null;
    }
  }
  
  /// Generiert eine Zusammenfassung der Bestellung (für UI-Anzeige)
  String? get orderSummary {
    if (order == null) return null;
    
    final parts = <String>[];
    
    // Bestellnummer
    parts.add('Bestellung ${order!.formattedOrderNumber}');
    
    // Firma (falls vorhanden)
    if (order!.company != null) {
      parts.add('von ${order!.company!.name}');
    }
    
    // Betrag
    parts.add('${order!.totalAmount.toStringAsFixed(2)} €');
    
    // Liefertyp
    parts.add(order!.deliveryTypeDisplayText);
    
    return parts.join(' • ');
  }
  
  /// Prüft ob eine Erstattung möglich ist
  bool get canBeRefunded {
    return wasSuccessful && 
           order != null && 
           !order!.isFinalStatus;
  }
  
  /// Berechnet die Verarbeitungsdauer (falls verfügbar)
  Duration? get processingDuration {
    if (createdAt != null && processedAt != null) {
      return processedAt!.difference(createdAt!);
    }
    return null;
  }
  
  /// Generiert Debugging-Informationen (für Support)
  String get debugInfo {
    final info = <String>[];
    
    info.add('Payment ID: ${paymentIntentId ?? 'N/A'}');
    info.add('Status: ${status.name}');
    info.add('Company: ${companyId ?? 'N/A'}');
    
    if (errorCode != null) {
      info.add('Error Code: $errorCode');
    }
    
    if (amount != null) {
      info.add('Amount: ${amount!.toStringAsFixed(2)} €');
    }
    
    if (createdAt != null) {
      info.add('Created: ${createdAt!.toIso8601String()}');
    }
    
    return info.join(' | ');
  }
}
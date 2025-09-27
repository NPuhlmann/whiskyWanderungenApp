import 'dart:developer' as dev;
import '../../../domain/models/enhanced_order.dart';
import '../commission/commission_service.dart';
import '../database/backend_api.dart';
import '../notifications/supabase_notification_service.dart';
import '../tracking/order_tracking_service.dart';
import 'order_status_workflow.dart';

/// Enhanced Order Status Workflow mit automatischer Commission-Erstellung
class EnhancedOrderWorkflowWithCommission extends OrderStatusWorkflow {
  final CommissionService _commissionService;

  EnhancedOrderWorkflowWithCommission({
    required BackendApiService backendApi,
    required SupabaseNotificationService notificationService,
    required OrderTrackingService trackingService,
    required CommissionService commissionService,
  }) : _commissionService = commissionService,
       super(
         backendApi: backendApi,
         notificationService: notificationService,
         trackingService: trackingService,
       );

  /// Override der Order-Delivered-Behandlung mit Commission-Erstellung
  @override
  Future<EnhancedOrder> transitionOrderStatus({
    required int orderId,
    required EnhancedOrderStatus toStatus,
    String? reason,
    String? notes,
    Map<String, dynamic>? transitionData,
    String? userId,
  }) async {
    try {
      // Führe die Standard-Transition aus
      final updatedOrder = await super.transitionOrderStatus(
        orderId: orderId,
        toStatus: toStatus,
        reason: reason,
        notes: notes,
        transitionData: transitionData,
        userId: userId,
      );

      // Zusätzliche Logic für Commission-Erstellung bei Delivered-Status
      if (toStatus == EnhancedOrderStatus.delivered) {
        await _handleAutomaticCommissionCreation(updatedOrder);
      }

      return updatedOrder;
    } catch (e) {
      dev.log('❌ Error in enhanced order workflow: $e');
      rethrow;
    }
  }

  /// Automatische Commission-Erstellung bei Order-Delivery
  Future<void> _handleAutomaticCommissionCreation(EnhancedOrder order) async {
    try {
      dev.log('🔄 Creating automatic commission for delivered order ${order.id}');

      // Prüfe, ob bereits eine Commission für diese Bestellung existiert
      final existingCommissions = await _commissionService.getCommissionsForCompany(
        order.companyId ?? 'default-company', // TODO: Get actual company ID
      );

      final hasExistingCommission = existingCommissions.any(
        (commission) => commission.orderId == order.orderNumber,
      );

      if (hasExistingCommission) {
        dev.log('ℹ️ Commission already exists for order ${order.orderNumber}');
        return;
      }

      // Lade Company-spezifische Commission-Rate (falls konfiguriert)
      final commissionRate = await _getCommissionRateForCompany(
        order.companyId ?? 'default-company',
      );

      // Erstelle automatisch Commission
      await _commissionService.createCommissionForOrder(
        hikeId: order.hikeId,
        companyId: order.companyId ?? 'default-company',
        orderId: order.orderNumber,
        baseAmount: order.totalAmount,
        commissionRate: commissionRate,
        notes: 'Automatisch erstellt bei Order-Delivery (${DateTime.now().toIso8601String()})',
      );

      dev.log('✅ Commission successfully created for order ${order.orderNumber}');

      // Optional: Sende Notification an Admin
      await _sendCommissionCreatedNotification(order, commissionRate);

    } catch (e) {
      dev.log('❌ Error creating automatic commission for order ${order.id}: $e');
      // Fehler in Commission-Erstellung soll Order-Status-Update nicht blockieren
      // Daher wird der Fehler geloggt, aber nicht weitergegeben
    }
  }

  /// Hole Commission-Rate für eine Company (mit Fallback)
  Future<double> _getCommissionRateForCompany(String companyId) async {
    try {
      // TODO: Implementiere Company-Settings-Service für konfigurierbare Rates
      // Für jetzt verwenden wir Standard-Rate von 15%
      
      // Beispiel für zukünftige Implementation:
      // final companySettings = await _companySettingsService.getSettings(companyId);
      // return companySettings.defaultCommissionRate ?? 0.15;
      
      return 0.15; // 15% Standard-Commission-Rate
    } catch (e) {
      dev.log('⚠️ Error getting commission rate for company $companyId, using default: $e');
      return 0.15; // Fallback auf 15%
    }
  }

  /// Sende Notification über Commission-Erstellung
  Future<void> _sendCommissionCreatedNotification(
    EnhancedOrder order,
    double commissionRate,
  ) async {
    try {
      final commissionAmount = order.totalAmount * commissionRate;
      
      // TODO: Implementiere Notification an Admin über neue Commission
      dev.log('📧 Would send notification: New commission €${commissionAmount.toStringAsFixed(2)} for order ${order.orderNumber}');
      
      // Beispiel für zukünftige Implementation:
      // await _notificationService.sendAdminNotification(
      //   type: NotificationType.commissionCreated,
      //   title: 'Neue Commission erstellt',
      //   message: 'Commission von €${commissionAmount.toStringAsFixed(2)} für Bestellung ${order.orderNumber}',
      //   data: {
      //     'orderId': order.id,
      //     'orderNumber': order.orderNumber,
      //     'commissionAmount': commissionAmount,
      //     'hikeId': order.hikeId,
      //   },
      // );
      
    } catch (e) {
      dev.log('⚠️ Error sending commission notification: $e');
      // Notification-Fehler sollen den Hauptprozess nicht blockieren
    }
  }

  /// Business Rules für Commission-Erstellung
  bool _shouldCreateCommissionForOrder(EnhancedOrder order) {
    // Commission nur erstellen wenn:
    // 1. Order wurde erfolgreich delivered
    // 2. Order ist nicht storniert oder refunded
    // 3. Order hat gültigen Betrag > 0
    // 4. Hike-ID ist vorhanden
    
    return order.status == EnhancedOrderStatus.delivered &&
           order.totalAmount > 0 &&
           order.hikeId > 0;
  }

  /// Berechne Commission-Betrag mit Business Rules
  double _calculateCommissionAmount(
    double baseAmount, 
    double commissionRate,
  ) {
    // Business Rules für Commission-Berechnung:
    // 1. Mindest-Commission: €1.00
    // 2. Maximum-Commission: €500.00 pro Order
    // 3. Rate zwischen 0% und 100%
    
    if (commissionRate < 0 || commissionRate > 1.0) {
      throw ArgumentError('Commission rate must be between 0 and 1.0');
    }
    
    final calculatedCommission = baseAmount * commissionRate;
    
    // Anwenden der Mindest- und Maximum-Grenzen
    return calculatedCommission.clamp(1.0, 500.0);
  }

  /// Validierung von Order für Commission-Erstellung
  void _validateOrderForCommission(EnhancedOrder order) {
    if (order.hikeId <= 0) {
      throw ArgumentError('Invalid hike ID for commission creation');
    }
    
    if (order.totalAmount <= 0) {
      throw ArgumentError('Order total amount must be greater than 0');
    }
    
    if (order.orderNumber.isEmpty) {
      throw ArgumentError('Order number is required for commission creation');
    }
    
    if (!_shouldCreateCommissionForOrder(order)) {
      throw ArgumentError('Order does not meet criteria for commission creation');
    }
  }
}
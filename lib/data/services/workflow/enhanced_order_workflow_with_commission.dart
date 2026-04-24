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
      dev.log(
        '🔄 Creating automatic commission for delivered order ${order.id}',
      );

      // Prüfe, ob bereits eine Commission für diese Bestellung existiert
      final existingCommissions = await _commissionService
          .getCommissionsForCompany(
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
        notes:
            'Automatisch erstellt bei Order-Delivery (${DateTime.now().toIso8601String()})',
      );

      dev.log(
        '✅ Commission successfully created for order ${order.orderNumber}',
      );

      // Optional: Sende Notification an Admin
      await _sendCommissionCreatedNotification(order, commissionRate);
    } catch (e) {
      dev.log(
        '❌ Error creating automatic commission for order ${order.id}: $e',
      );
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
      dev.log(
        '⚠️ Error getting commission rate for company $companyId, using default: $e',
      );
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
      dev.log(
        '📧 Would send notification: New commission €${commissionAmount.toStringAsFixed(2)} for order ${order.orderNumber}',
      );

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
}

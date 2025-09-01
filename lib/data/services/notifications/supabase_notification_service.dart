import 'dart:developer';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../domain/models/notification_model.dart';

class SupabaseNotificationService {
  final SupabaseClient _supabase;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  RealtimeChannel? _orderUpdatesChannel;

  SupabaseNotificationService(this._supabase);

  /// Initialize the notification service
  Future<void> initialize() async {
    try {
      // Configure local notifications
      await _configureLocalNotifications();
      
      // Subscribe to order updates
      await subscribeToOrderUpdates();
      
      log("✅ Notification service initialized successfully");
    } catch (e) {
      log("❌ Failed to initialize notification service: $e", error: e);
      rethrow;
    }
  }

  /// Configure local notifications
  Future<void> _configureLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  /// Subscribe to order updates via Supabase Realtime
  Future<void> subscribeToOrderUpdates() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        log("⚠️ User not authenticated, skipping order updates subscription");
        return;
      }

      _orderUpdatesChannel = _supabase
          .channel('order_updates')
          .onPostgresChanges(
            event: PostgresChangeEvent.update,
            schema: 'public',
            table: 'orders',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'user_id',
              value: user.id,
            ),
            callback: _handleOrderUpdate,
          )
          .subscribe();

      log("✅ Subscribed to order updates for user: ${user.id}");
    } catch (e) {
      log("❌ Failed to subscribe to order updates: $e", error: e);
    }
  }

  /// Handle order update from Supabase Realtime
  void _handleOrderUpdate(PostgresChangePayload payload) {
    try {
      log("📨 Received order update: $payload");
      
      if (payload.newRecord != null && payload.oldRecord != null) {
        final newStatus = payload.newRecord['status'] as String?;
        final oldStatus = payload.oldRecord['status'] as String?;
        final orderNumber = payload.newRecord['order_number'] as String?;
        
        if (newStatus != null && oldStatus != null && 
            newStatus != oldStatus && orderNumber != null) {
          _showOrderStatusNotification(orderNumber, newStatus);
        }
      }
    } catch (e) {
      log("❌ Error handling order update: $e", error: e);
    }
  }

  /// Show local notification for order status update
  Future<void> _showOrderStatusNotification(String orderNumber, String newStatus) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'order_updates',
        'Bestellstatus-Updates',
        channelDescription: 'Benachrichtigungen über Bestellstatus-Änderungen',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
      );
      
      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );
      
      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(
        DateTime.now().millisecondsSinceEpoch.remainder(100000),
        'Bestellstatus aktualisiert',
        'Deine Bestellung #$orderNumber hat den Status: $newStatus',
        details,
        payload: 'order_$orderNumber',
      );

      log("✅ Order status notification shown: $orderNumber -> $newStatus");
    } catch (e) {
      log("❌ Failed to show order status notification: $e", error: e);
    }
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    log("👆 Notification tapped: ${response.payload}");
    
    // TODO: Navigate to order details when notification is tapped
    // This will be implemented when the navigation system is ready
  }

  /// Show custom notification
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
    NotificationType type = NotificationType.general,
  }) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'custom_notifications',
        'Benutzerdefinierte Benachrichtigungen',
        channelDescription: 'Allgemeine Benachrichtigungen',
        importance: Importance.none,
        priority: Priority.low,
        showWhen: true,
      );
      
      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );
      
      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(
        DateTime.now().millisecondsSinceEpoch.remainder(100000),
        title,
        body,
        details,
        payload: payload,
      );

      log("✅ Custom notification shown: $title");
    } catch (e) {
      log("❌ Failed to show custom notification: $e", error: e);
    }
  }

  /// Get all notifications for a specific user
  Future<List<NotificationModel>> getUserNotifications(String userId) async {
    try {
      // TODO: Implement Supabase query for user notifications
      // This would typically query a notifications table
      // For now, return empty list as placeholder
      return <NotificationModel>[];
    } catch (e) {
      log("❌ Failed to get user notifications: $e", error: e);
      rethrow;
    }
  }

  /// Mark a notification as read
  Future<bool> markNotificationAsRead(String notificationId) async {
    try {
      // TODO: Implement Supabase update for marking notification as read
      // This would typically update a notifications table
      // For now, return true as placeholder
      return true;
    } catch (e) {
      log("❌ Failed to mark notification as read: $e", error: e);
      return false;
    }
  }

  /// Delete a notification
  Future<bool> deleteNotification(String notificationId) async {
    try {
      // TODO: Implement Supabase delete for notification
      // This would typically delete from a notifications table
      // For now, return true as placeholder
      return true;
    } catch (e) {
      log("❌ Failed to delete notification: $e", error: e);
      return false;
    }
  }

  /// Get the count of unread notifications for a user
  Future<int> getUnreadNotificationCount(String userId) async {
    try {
      // TODO: Implement Supabase count query for unread notifications
      // This would typically count unread notifications in a notifications table
      // For now, return 0 as placeholder
      return 0;
    } catch (e) {
      log("❌ Failed to get unread notification count: $e", error: e);
      return 0;
    }
  }

  /// Mark all notifications as read for a user
  Future<bool> markAllNotificationsAsRead(String userId) async {
    try {
      // TODO: Implement Supabase bulk update for marking all notifications as read
      // This would typically update all notifications for a user
      // For now, return true as placeholder
      return true;
    } catch (e) {
      log("❌ Failed to mark all notifications as read: $e", error: e);
      return false;
    }
  }

  /// Clear all notifications for a user
  Future<bool> clearAllNotifications(String userId) async {
    try {
      // TODO: Implement Supabase bulk delete for all user notifications
      // This would typically delete all notifications for a user
      // For now, return true as placeholder
      return true;
    } catch (e) {
      log("❌ Failed to clear all notifications: $e", error: e);
      return false;
    }
  }

  // ================================
  // Order Tracking Notifications
  // ================================

  /// Send tracking number assignment notification
  Future<void> sendOrderTrackingNotification({
    required String customerId,
    required int orderId,
    required String orderNumber,
    required String trackingNumber,
    required String shippingCarrier,
    DateTime? estimatedDelivery,
  }) async {
    try {
      final deliveryText = estimatedDelivery != null 
          ? ' Voraussichtliche Lieferung: ${_formatDate(estimatedDelivery)}'
          : '';

      await showNotification(
        title: '📦 Bestellung versendet',
        body: 'Deine Bestellung #$orderNumber wurde versendet. Tracking: $trackingNumber$deliveryText',
        payload: 'order_tracking_$orderId',
        type: NotificationType.orderUpdate,
      );

      log("✅ Tracking notification sent for order $orderNumber");
    } catch (e) {
      log("❌ Failed to send tracking notification: $e", error: e);
    }
  }

  /// Send order status change notification
  Future<void> sendOrderStatusChangeNotification({
    required String customerId,
    required int orderId,
    required String orderNumber,
    required String newStatus,
    String? statusDescription,
    String? trackingNumber,
  }) async {
    try {
      final statusText = _getStatusDisplayText(newStatus);
      final description = statusDescription ?? _getStatusDescription(newStatus);

      await showNotification(
        title: '📋 Bestellstatus aktualisiert',
        body: 'Bestellung #$orderNumber: $statusText - $description',
        payload: 'order_status_$orderId',
        type: NotificationType.orderUpdate,
      );

      log("✅ Status change notification sent for order $orderNumber");
    } catch (e) {
      log("❌ Failed to send status change notification: $e", error: e);
    }
  }

  /// Send out for delivery notification
  Future<void> sendOrderOutForDeliveryNotification({
    required String customerId,
    required int orderId,
    required String orderNumber,
    DateTime? estimatedDeliveryTime,
    String? courierName,
    String? courierPhone,
  }) async {
    try {
      final timeText = estimatedDeliveryTime != null
          ? ' bis ${_formatTime(estimatedDeliveryTime)}'
          : '';
      
      final courierText = courierName != null
          ? ' Kurier: $courierName'
          : '';

      await showNotification(
        title: '🚛 Zustellung heute!',
        body: 'Deine Bestellung #$orderNumber wird heute$timeText geliefert.$courierText',
        payload: 'order_delivery_$orderId',
        type: NotificationType.urgent,
      );

      log("✅ Out for delivery notification sent for order $orderNumber");
    } catch (e) {
      log("❌ Failed to send out for delivery notification: $e", error: e);
    }
  }

  /// Send delivery confirmation notification
  Future<void> sendOrderDeliveredNotification({
    required String customerId,
    required int orderId,
    required String orderNumber,
    required DateTime deliveryTime,
    String? recipientName,
    String? deliveryProofUrl,
  }) async {
    try {
      final recipientText = recipientName != null
          ? ' an $recipientName'
          : '';

      await showNotification(
        title: '✅ Bestellung zugestellt!',
        body: 'Deine Bestellung #$orderNumber wurde um ${_formatTime(deliveryTime)}$recipientText zugestellt.',
        payload: 'order_delivered_$orderId',
        type: NotificationType.success,
      );

      log("✅ Delivery confirmation sent for order $orderNumber");
    } catch (e) {
      log("❌ Failed to send delivery confirmation: $e", error: e);
    }
  }

  /// Subscribe to enhanced order updates
  Future<void> subscribeToEnhancedOrderUpdates() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        log("⚠️ User not authenticated, skipping enhanced order updates subscription");
        return;
      }

      // Unsubscribe existing channel if any
      if (_orderUpdatesChannel != null) {
        await _orderUpdatesChannel!.unsubscribe();
      }

      _orderUpdatesChannel = _supabase
          .channel('enhanced_order_updates')
          .onPostgresChanges(
            event: PostgresChangeEvent.update,
            schema: 'public',
            table: 'enhanced_orders',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'customer_id',
              value: user.id,
            ),
            callback: _handleEnhancedOrderUpdate,
          )
          .subscribe();

      log("✅ Subscribed to enhanced order updates for user: ${user.id}");
    } catch (e) {
      log("❌ Failed to subscribe to enhanced order updates: $e", error: e);
    }
  }

  /// Handle enhanced order update from Supabase Realtime
  void _handleEnhancedOrderUpdate(PostgresChangePayload payload) {
    try {
      log("📨 Received enhanced order update: ${payload.eventType}");
      
      if (payload.newRecord != null && payload.oldRecord != null) {
        final newStatus = payload.newRecord['status'] as String?;
        final oldStatus = payload.oldRecord['status'] as String?;
        final orderNumber = payload.newRecord['order_number'] as String?;
        final trackingNumber = payload.newRecord['tracking_number'] as String?;
        final orderId = payload.newRecord['id'] as int?;

        if (newStatus != null && oldStatus != null && newStatus != oldStatus && 
            orderNumber != null && orderId != null) {
          
          // Show appropriate notification based on status change
          if (newStatus == 'shipped' && trackingNumber != null) {
            sendOrderTrackingNotification(
              customerId: payload.newRecord['customer_id'],
              orderId: orderId,
              orderNumber: orderNumber,
              trackingNumber: trackingNumber,
              shippingCarrier: payload.newRecord['shipping_carrier'] ?? 'Carrier',
              estimatedDelivery: payload.newRecord['estimated_delivery'] != null
                  ? DateTime.parse(payload.newRecord['estimated_delivery'])
                  : null,
            );
          } else if (newStatus == 'outForDelivery') {
            sendOrderOutForDeliveryNotification(
              customerId: payload.newRecord['customer_id'],
              orderId: orderId,
              orderNumber: orderNumber,
              estimatedDeliveryTime: payload.newRecord['estimated_delivery'] != null
                  ? DateTime.parse(payload.newRecord['estimated_delivery'])
                  : null,
            );
          } else if (newStatus == 'delivered') {
            sendOrderDeliveredNotification(
              customerId: payload.newRecord['customer_id'],
              orderId: orderId,
              orderNumber: orderNumber,
              deliveryTime: payload.newRecord['delivered_at'] != null
                  ? DateTime.parse(payload.newRecord['delivered_at'])
                  : DateTime.now(),
            );
          } else {
            sendOrderStatusChangeNotification(
              customerId: payload.newRecord['customer_id'],
              orderId: orderId,
              orderNumber: orderNumber,
              newStatus: newStatus,
              trackingNumber: trackingNumber,
            );
          }
        }
      }
    } catch (e) {
      log("❌ Error handling enhanced order update: $e", error: e);
    }
  }

  // ================================
  // Helper Methods
  // ================================

  /// Get display text for order status
  String _getStatusDisplayText(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return 'Ausstehend';
      case 'paymentpending': return 'Zahlung ausstehend';
      case 'confirmed': return 'Bestätigt';
      case 'processing': return 'In Bearbeitung';
      case 'shipped': return 'Versendet';
      case 'outfordelivery': return 'Zustellung unterwegs';
      case 'delivered': return 'Zugestellt';
      case 'cancelled': return 'Storniert';
      case 'refunded': return 'Erstattet';
      case 'failed': return 'Fehlgeschlagen';
      default: return status;
    }
  }

  /// Get description for order status
  String _getStatusDescription(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return 'Bestellung eingegangen';
      case 'paymentpending': return 'Warte auf Zahlungsbestätigung';
      case 'confirmed': return 'Zahlung bestätigt, Bestellung wird vorbereitet';
      case 'processing': return 'Bestellung wird bearbeitet';
      case 'shipped': return 'Paket ist auf dem Weg';
      case 'outfordelivery': return 'Zustellung erfolgt heute';
      case 'delivered': return 'Paket wurde zugestellt';
      case 'cancelled': return 'Bestellung wurde storniert';
      case 'refunded': return 'Betrag wurde erstattet';
      case 'failed': return 'Bestellung konnte nicht verarbeitet werden';
      default: return 'Status wurde aktualisiert';
    }
  }

  /// Format date for notifications
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final targetDate = DateTime(date.year, date.month, date.day);

    if (targetDate == today) {
      return 'heute';
    } else if (targetDate == tomorrow) {
      return 'morgen';
    } else {
      return '${date.day}.${date.month}.${date.year}';
    }
  }

  /// Format time for notifications
  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  /// Dispose the service and unsubscribe from channels
  Future<void> dispose() async {
    try {
      if (_orderUpdatesChannel != null) {
        await _orderUpdatesChannel!.unsubscribe();
        _orderUpdatesChannel = null;
      }
      log("✅ Notification service disposed");
    } catch (e) {
      log("❌ Error disposing notification service: $e", error: e);
    }
  }
}

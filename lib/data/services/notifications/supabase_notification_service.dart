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

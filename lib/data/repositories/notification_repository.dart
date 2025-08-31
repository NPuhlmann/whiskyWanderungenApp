import 'package:whisky_hikes/data/services/notifications/supabase_notification_service.dart';
import '../../domain/models/notification_model.dart';

/// Repository for managing notifications
class NotificationRepository {
  final SupabaseNotificationService _notificationService;

  NotificationRepository(this._notificationService);

  /// Get all notifications for a specific user
  Future<List<NotificationModel>> getUserNotifications(String userId) async {
    try {
      return await _notificationService.getUserNotifications(userId);
    } catch (e) {
      throw Exception('Fehler beim Laden der Benachrichtigungen: $e');
    }
  }

  /// Mark a notification as read
  Future<bool> markNotificationAsRead(String notificationId) async {
    try {
      return await _notificationService.markNotificationAsRead(notificationId);
    } catch (e) {
      throw Exception('Fehler beim Markieren der Benachrichtigung als gelesen: $e');
    }
  }

  /// Delete a notification
  Future<bool> deleteNotification(String notificationId) async {
    try {
      return await _notificationService.deleteNotification(notificationId);
    } catch (e) {
      throw Exception('Fehler beim Löschen der Benachrichtigung: $e');
    }
  }

  /// Get the count of unread notifications for a user
  Future<int> getUnreadNotificationCount(String userId) async {
    try {
      return await _notificationService.getUnreadNotificationCount(userId);
    } catch (e) {
      throw Exception('Fehler beim Laden der ungelesenen Benachrichtigungen: $e');
    }
  }

  /// Mark all notifications as read for a user
  Future<bool> markAllNotificationsAsRead(String userId) async {
    try {
      return await _notificationService.markAllNotificationsAsRead(userId);
    } catch (e) {
      throw Exception('Fehler beim Markieren aller Benachrichtigungen als gelesen: $e');
    }
  }

  /// Get notifications by type for a user
  Future<List<NotificationModel>> getNotificationsByType(
    String userId,
    NotificationType type,
  ) async {
    try {
      final allNotifications = await getUserNotifications(userId);
      return allNotifications.where((notification) => notification.type == type).toList();
    } catch (e) {
      throw Exception('Fehler beim Laden der Benachrichtigungen nach Typ: $e');
    }
  }

  /// Get recent notifications (last 7 days) for a user
  Future<List<NotificationModel>> getRecentNotifications(String userId) async {
    try {
      final allNotifications = await getUserNotifications(userId);
      final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
      
      return allNotifications
          .where((notification) => notification.createdAt.isAfter(sevenDaysAgo))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt)); // Sort by newest first
    } catch (e) {
      throw Exception('Fehler beim Laden der kürzlichen Benachrichtigungen: $e');
    }
  }

  /// Clear all notifications for a user
  Future<bool> clearAllNotifications(String userId) async {
    try {
      return await _notificationService.clearAllNotifications(userId);
    } catch (e) {
      throw Exception('Fehler beim Löschen aller Benachrichtigungen: $e');
    }
  }

  /// Get notification statistics for a user
  Future<Map<String, int>> getNotificationStatistics(String userId) async {
    try {
      final allNotifications = await getUserNotifications(userId);
      
      final stats = <String, int>{
        'total': allNotifications.length,
        'unread': allNotifications.where((n) => !n.isRead).length,
        'order_updates': allNotifications.where((n) => n.type == NotificationType.orderUpdate).length,
        'delivery_updates': allNotifications.where((n) => n.type == NotificationType.deliveryUpdate).length,
        'general': allNotifications.where((n) => n.type == NotificationType.general).length,
      };
      
      return stats;
    } catch (e) {
      throw Exception('Fehler beim Laden der Benachrichtigungsstatistiken: $e');
    }
  }
}

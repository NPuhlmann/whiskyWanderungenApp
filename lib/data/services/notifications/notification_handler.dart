import 'dart:convert';
import 'dart:math';
import 'package:whisky_hikes/domain/models/notification_model.dart';

/// Service for handling different types of notifications
class NotificationHandler {
  static final Random _random = Random.secure();

  /// Handle order status updates and create appropriate notifications
  static NotificationModel handleOrderStatusUpdate(Map<String, dynamic> data) {
    final orderId = data['order_id']?.toString() ?? 'null';
    final status = data['status']?.toString() ?? 'null';
    final orderNumber = data['order_number']?.toString() ?? orderId;

    return NotificationModel(
      id: _generateNotificationId(data),
      title: 'Bestellstatus aktualisiert',
      body: 'Deine Bestellung #$orderNumber hat den Status: $status',
      type: NotificationType.orderUpdate,
      data: data,
    );
  }

  /// Handle delivery updates and create appropriate notifications
  static NotificationModel handleDeliveryUpdate(Map<String, dynamic> data) {
    final orderId = data['order_id']?.toString() ?? 'null';
    final trackingNumber = data['tracking_number']?.toString() ?? 'null';
    final orderNumber = data['order_number']?.toString() ?? orderId;

    return NotificationModel(
      id: _generateNotificationId(data),
      title: 'Versand-Updates',
      body: 'Bestellung #$orderNumber wurde versendet. Tracking: $trackingNumber',
      type: NotificationType.deliveryUpdate,
      data: data,
    );
  }

  /// Create general notifications with custom content
  static NotificationModel createGeneralNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) {
    return NotificationModel(
      id: _generateNotificationId({'title': title, 'body': body, 'data': data}),
      title: title,
      body: body,
      type: NotificationType.general,
      data: data ?? {},
    );
  }

  /// Generate a unique notification ID based on content
  static String _generateNotificationId(Map<String, dynamic> data) {
    // Create a deterministic hash based on the data content
    final jsonString = jsonEncode(data);
    final hash = jsonString.hashCode;
    
    // Add some randomness to ensure uniqueness
    final random = _random.nextInt(10000);
    
    return 'notification_${hash}_$random';
  }

  /// Create a notification for hike reminders
  static NotificationModel createHikeReminderNotification({
    required String hikeName,
    required DateTime hikeDate,
    required String location,
  }) {
    final formattedDate = '${hikeDate.day}.${hikeDate.month}.${hikeDate.year}';
    
    return NotificationModel(
      id: _generateNotificationId({
        'hike_name': hikeName,
        'hike_date': hikeDate.toIso8601String(),
        'location': location,
      }),
      title: 'Hike-Erinnerung',
      body: 'Dein Hike "$hikeName" findet am $formattedDate in $location statt.',
      type: NotificationType.general,
      data: {
        'hike_name': hikeName,
        'hike_date': hikeDate.toIso8601String(),
        'location': location,
        'notification_type': 'hike_reminder',
      },
    );
  }

  /// Create a notification for payment confirmations
  static NotificationModel createPaymentConfirmationNotification({
    required String orderNumber,
    required double amount,
    required String paymentMethod,
  }) {
    final formattedAmount = amount.toStringAsFixed(2);
    
    return NotificationModel(
      id: _generateNotificationId({
        'order_number': orderNumber,
        'amount': amount,
        'payment_method': paymentMethod,
      }),
      title: 'Zahlung bestätigt',
      body: 'Deine Zahlung für Bestellung #$orderNumber (€$formattedAmount) wurde erfolgreich mit $paymentMethod abgewickelt.',
      type: NotificationType.orderUpdate,
      data: {
        'order_number': orderNumber,
        'amount': amount,
        'payment_method': paymentMethod,
        'notification_type': 'payment_confirmation',
      },
    );
  }

  /// Create a notification for system maintenance
  static NotificationModel createMaintenanceNotification({
    required String title,
    required String description,
    DateTime? scheduledTime,
    Duration? estimatedDuration,
  }) {
    String body = description;
    
    if (scheduledTime != null) {
      final formattedTime = '${scheduledTime.hour}:${scheduledTime.minute.toString().padLeft(2, '0')}';
      body += ' Geplante Zeit: $formattedTime Uhr.';
    }
    
    if (estimatedDuration != null) {
      final hours = estimatedDuration.inHours;
      final minutes = estimatedDuration.inMinutes % 60;
      body += ' Geschätzte Dauer: ${hours}h ${minutes}min.';
    }

    return NotificationModel(
      id: _generateNotificationId({
        'title': title,
        'description': description,
        'scheduled_time': scheduledTime?.toIso8601String(),
        'estimated_duration': estimatedDuration?.inMinutes,
      }),
      title: title,
      body: body,
      type: NotificationType.general,
      data: {
        'title': title,
        'description': description,
        'scheduled_time': scheduledTime?.toIso8601String(),
        'estimated_duration': estimatedDuration?.inMinutes,
        'notification_type': 'maintenance',
      },
    );
  }
}

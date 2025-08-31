import 'package:flutter_test/flutter_test.dart';
import 'package:whisky_hikes/data/services/notifications/notification_handler.dart';
import 'package:whisky_hikes/domain/models/notification_model.dart';

void main() {
  group('NotificationHandler', () {
    group('handleOrderStatusUpdate', () {
      test('should create notification for order status update', () {
        // Arrange
        final data = {
          'order_id': '123',
          'status': 'confirmed',
          'order_number': 'ORD-123',
        };

        // Act
        final notification = NotificationHandler.handleOrderStatusUpdate(data);

        // Assert
        expect(notification.title, 'Bestellstatus aktualisiert');
        expect(notification.body, 'Deine Bestellung #ORD-123 hat den Status: confirmed');
        expect(notification.type, NotificationType.orderUpdate);
        expect(notification.data, data);
        expect(notification.isRead, false);
        expect(notification.id, isNotEmpty);
      });

      test('should handle missing order_id gracefully', () {
        // Arrange
        final data = {
          'status': 'confirmed',
          'order_number': 'ORD-123',
        };

        // Act
        final notification = NotificationHandler.handleOrderStatusUpdate(data);

        // Assert
        expect(notification.body, 'Deine Bestellung #ORD-123 hat den Status: confirmed');
      });

      test('should handle missing status gracefully', () {
        // Arrange
        final data = {
          'order_id': '123',
          'order_number': 'ORD-123',
        };

        // Act
        final notification = NotificationHandler.handleOrderStatusUpdate(data);

        // Assert
        expect(notification.body, 'Deine Bestellung #ORD-123 hat den Status: null');
      });
    });

    group('handleDeliveryUpdate', () {
      test('should create notification for delivery update', () {
        // Arrange
        final data = {
          'order_id': '123',
          'tracking_number': 'TRK-456',
          'order_number': 'ORD-123',
        };

        // Act
        final notification = NotificationHandler.handleDeliveryUpdate(data);

        // Assert
        expect(notification.title, 'Versand-Updates');
        expect(notification.body, 'Bestellung #ORD-123 wurde versendet. Tracking: TRK-456');
        expect(notification.type, NotificationType.deliveryUpdate);
        expect(notification.data, data);
        expect(notification.isRead, false);
        expect(notification.id, isNotEmpty);
      });

      test('should handle missing tracking number gracefully', () {
        // Arrange
        final data = {
          'order_id': '123',
          'order_number': 'ORD-123',
        };

        // Act
        final notification = NotificationHandler.handleDeliveryUpdate(data);

        // Assert
        expect(notification.body, 'Bestellung #ORD-123 wurde versendet. Tracking: null');
      });
    });

    group('createGeneralNotification', () {
      test('should create general notification with custom title and body', () {
        // Arrange
        const title = 'Wichtige Nachricht';
        const body = 'Dies ist eine wichtige Nachricht für alle Benutzer.';

        // Act
        final notification = NotificationHandler.createGeneralNotification(
          title: title,
          body: body,
        );

        // Assert
        expect(notification.title, title);
        expect(notification.body, body);
        expect(notification.type, NotificationType.general);
        expect(notification.data, isEmpty);
        expect(notification.isRead, false);
        expect(notification.id, isNotEmpty);
      });

      test('should create general notification with custom data', () {
        // Arrange
        const title = 'Test';
        const body = 'Test body';
        final data = {'key': 'value', 'number': 42};

        // Act
        final notification = NotificationHandler.createGeneralNotification(
          title: title,
          body: body,
          data: data,
        );

        // Assert
        expect(notification.title, title);
        expect(notification.body, body);
        expect(notification.type, NotificationType.general);
        expect(notification.data, data);
        expect(notification.data['key'], 'value');
        expect(notification.data['number'], 42);
      });
    });

    group('notification ID generation', () {
      test('should generate unique IDs for different notifications', () {
        // Arrange
        final data1 = {'order_id': '123'};
        final data2 = {'order_id': '456'};

        // Act
        final notification1 = NotificationHandler.handleOrderStatusUpdate(data1);
        final notification2 = NotificationHandler.handleOrderStatusUpdate(data2);

        // Assert
        expect(notification1.id, isNot(notification2.id));
      });

      test('should generate different IDs for different data', () {
        // Arrange
        final data1 = {'order_id': '123', 'status': 'confirmed'};
        final data2 = {'order_id': '456', 'status': 'confirmed'};

        // Act
        final notification1 = NotificationHandler.handleOrderStatusUpdate(data1);
        final notification2 = NotificationHandler.handleOrderStatusUpdate(data2);

        // Assert
        expect(notification1.id, isNot(notification2.id));
      });
    });
  });
}


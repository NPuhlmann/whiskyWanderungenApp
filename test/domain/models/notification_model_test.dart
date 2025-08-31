import 'package:flutter_test/flutter_test.dart';
import 'package:whisky_hikes/domain/models/notification_model.dart';

void main() {
  group('NotificationModel', () {
    test('should create NotificationModel with required fields', () {
      final notification = NotificationModel(
        id: '1',
        title: 'Bestellstatus aktualisiert',
        body: 'Deine Bestellung #123 hat den Status: bestätigt',
        type: NotificationType.orderUpdate,
        data: {'order_id': '123', 'status': 'confirmed'},
        isRead: false,
        createdAt: DateTime(2024, 1, 1, 12, 0),
      );

      expect(notification.id, '1');
      expect(notification.title, 'Bestellstatus aktualisiert');
      expect(notification.body, 'Deine Bestellung #123 hat den Status: bestätigt');
      expect(notification.type, NotificationType.orderUpdate);
      expect(notification.data, {'order_id': '123', 'status': 'confirmed'});
      expect(notification.isRead, false);
      expect(notification.createdAt, DateTime(2024, 1, 1, 12, 0));
    });

    test('should create NotificationModel with default values', () {
      final notification = NotificationModel(
        id: '2',
        title: 'Test',
        body: 'Test body',
        type: NotificationType.orderUpdate,
        data: {},
      );

      expect(notification.isRead, false);
      expect(notification.createdAt, isA<DateTime>());
    });

    test('should convert to and from JSON', () {
      final originalNotification = NotificationModel(
        id: '3',
        title: 'JSON Test',
        body: 'JSON body',
        type: NotificationType.deliveryUpdate,
        data: {'key': 'value'},
        isRead: true,
        createdAt: DateTime(2024, 1, 1, 12, 0),
      );

      final json = originalNotification.toJson();
      final restoredNotification = NotificationModel.fromJson(json);

      expect(restoredNotification.id, originalNotification.id);
      expect(restoredNotification.title, originalNotification.title);
      expect(restoredNotification.body, originalNotification.body);
      expect(restoredNotification.type, originalNotification.type);
      expect(restoredNotification.data, originalNotification.data);
      expect(restoredNotification.isRead, originalNotification.isRead);
      expect(restoredNotification.createdAt.millisecondsSinceEpoch, 
             originalNotification.createdAt.millisecondsSinceEpoch);
    });

    test('should handle different notification types', () {
      final orderUpdate = NotificationModel(
        id: '4',
        title: 'Order Update',
        body: 'Order body',
        type: NotificationType.orderUpdate,
        data: {},
      );

      final deliveryUpdate = NotificationModel(
        id: '5',
        title: 'Delivery Update',
        body: 'Delivery body',
        type: NotificationType.deliveryUpdate,
        data: {},
      );

      final generalUpdate = NotificationModel(
        id: '6',
        title: 'General Update',
        body: 'General body',
        type: NotificationType.general,
        data: {},
      );

      expect(orderUpdate.type, NotificationType.orderUpdate);
      expect(deliveryUpdate.type, NotificationType.deliveryUpdate);
      expect(generalUpdate.type, NotificationType.general);
    });

    test('should mark as read', () {
      final notification = NotificationModel(
        id: '7',
        title: 'Test',
        body: 'Test body',
        type: NotificationType.orderUpdate,
        data: {},
        isRead: false,
      );

      final readNotification = notification.copyWith(isRead: true);
      expect(readNotification.isRead, true);
      expect(notification.isRead, false); // Original unchanged
    });

    test('should handle empty data', () {
      final notification = NotificationModel(
        id: '8',
        title: 'Test',
        body: 'Test body',
        type: NotificationType.orderUpdate,
        data: {},
      );

      expect(notification.data, isEmpty);
    });
  });

  group('NotificationType', () {
    test('should have correct enum values', () {
      expect(NotificationType.values.length, 3);
      expect(NotificationType.orderUpdate, NotificationType.orderUpdate);
      expect(NotificationType.deliveryUpdate, NotificationType.deliveryUpdate);
      expect(NotificationType.general, NotificationType.general);
    });

    test('should convert to and from string', () {
      expect(NotificationType.orderUpdate.name, 'orderUpdate');
      expect(NotificationType.deliveryUpdate.name, 'deliveryUpdate');
      expect(NotificationType.general.name, 'general');
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:whisky_hikes/data/repositories/notification_repository.dart';
import 'package:whisky_hikes/data/services/notifications/supabase_notification_service.dart';
import 'package:whisky_hikes/domain/models/notification_model.dart';

import 'notification_repository_test.mocks.dart';

@GenerateMocks([SupabaseNotificationService])
void main() {
  group('NotificationRepository', () {
    late NotificationRepository notificationRepository;
    late MockSupabaseNotificationService mockNotificationService;

    setUp(() {
      mockNotificationService = MockSupabaseNotificationService();
      notificationRepository = NotificationRepository(mockNotificationService);
    });

    group('getUserNotifications', () {
      test('should return list of user notifications', () async {
        // Arrange
        const userId = 'test-user-id';
        final expectedNotifications = [
          NotificationModel(
            id: '1',
            title: 'Test 1',
            body: 'Body 1',
            type: NotificationType.orderUpdate,
            data: {},
          ),
          NotificationModel(
            id: '2',
            title: 'Test 2',
            body: 'Body 2',
            type: NotificationType.deliveryUpdate,
            data: {},
          ),
        ];

        when(mockNotificationService.getUserNotifications(userId))
            .thenAnswer((_) async => expectedNotifications);

        // Act
        final result = await notificationRepository.getUserNotifications(userId);

        // Assert
        expect(result, equals(expectedNotifications));
        verify(mockNotificationService.getUserNotifications(userId)).called(1);
      });

      test('should handle empty notifications list', () async {
        // Arrange
        const userId = 'test-user-id';
        when(mockNotificationService.getUserNotifications(userId))
            .thenAnswer((_) async => <NotificationModel>[]);

        // Act
        final result = await notificationRepository.getUserNotifications(userId);

        // Assert
        expect(result, isEmpty);
        verify(mockNotificationService.getUserNotifications(userId)).called(1);
      });

      test('should handle service errors gracefully', () async {
        // Arrange
        const userId = 'test-user-id';
        when(mockNotificationService.getUserNotifications(userId))
            .thenThrow(Exception('Service error'));

        // Act & Assert
        expect(
          () => notificationRepository.getUserNotifications(userId),
          throwsException,
        );
        verify(mockNotificationService.getUserNotifications(userId)).called(1);
      });
    });

    group('markNotificationAsRead', () {
      test('should mark notification as read successfully', () async {
        // Arrange
        const notificationId = 'test-notification-id';
        when(mockNotificationService.markNotificationAsRead(notificationId))
            .thenAnswer((_) async => true);

        // Act
        final result = await notificationRepository.markNotificationAsRead(notificationId);

        // Assert
        expect(result, isTrue);
        verify(mockNotificationService.markNotificationAsRead(notificationId)).called(1);
      });

      test('should handle mark as read failure', () async {
        // Arrange
        const notificationId = 'test-notification-id';
        when(mockNotificationService.markNotificationAsRead(notificationId))
            .thenAnswer((_) async => false);

        // Act
        final result = await notificationRepository.markNotificationAsRead(notificationId);

        // Assert
        expect(result, isFalse);
        verify(mockNotificationService.markNotificationAsRead(notificationId)).called(1);
      });

      test('should handle service errors gracefully', () async {
        // Arrange
        const notificationId = 'test-notification-id';
        when(mockNotificationService.markNotificationAsRead(notificationId))
            .thenThrow(Exception('Service error'));

        // Act & Assert
        expect(
          () => notificationRepository.markNotificationAsRead(notificationId),
          throwsException,
        );
        verify(mockNotificationService.markNotificationAsRead(notificationId)).called(1);
      });
    });

    group('deleteNotification', () {
      test('should delete notification successfully', () async {
        // Arrange
        const notificationId = 'test-notification-id';
        when(mockNotificationService.deleteNotification(notificationId))
            .thenAnswer((_) async => true);

        // Act
        final result = await notificationRepository.deleteNotification(notificationId);

        // Assert
        expect(result, isTrue);
        verify(mockNotificationService.deleteNotification(notificationId)).called(1);
      });

      test('should handle delete failure', () async {
        // Arrange
        const notificationId = 'test-notification-id';
        when(mockNotificationService.deleteNotification(notificationId))
            .thenAnswer((_) async => false);

        // Act
        final result = await notificationRepository.deleteNotification(notificationId);

        // Assert
        expect(result, isFalse);
        verify(mockNotificationService.deleteNotification(notificationId)).called(1);
      });

      test('should handle service errors gracefully', () async {
        // Arrange
        const notificationId = 'test-notification-id';
        when(mockNotificationService.deleteNotification(notificationId))
            .thenThrow(Exception('Service error'));

        // Act & Assert
        expect(
          () => notificationRepository.deleteNotification(notificationId),
          throwsException,
        );
        verify(mockNotificationService.deleteNotification(notificationId)).called(1);
      });
    });

    group('getUnreadNotificationCount', () {
      test('should return correct unread count', () async {
        // Arrange
        const userId = 'test-user-id';
        const expectedCount = 5;
        when(mockNotificationService.getUnreadNotificationCount(userId))
            .thenAnswer((_) async => expectedCount);

        // Act
        final result = await notificationRepository.getUnreadNotificationCount(userId);

        // Assert
        expect(result, equals(expectedCount));
        verify(mockNotificationService.getUnreadNotificationCount(userId)).called(1);
      });

      test('should return zero for no unread notifications', () async {
        // Arrange
        const userId = 'test-user-id';
        when(mockNotificationService.getUnreadNotificationCount(userId))
            .thenAnswer((_) async => 0);

        // Act
        final result = await notificationRepository.getUnreadNotificationCount(userId);

        // Assert
        expect(result, equals(0));
        verify(mockNotificationService.getUnreadNotificationCount(userId)).called(1);
      });

      test('should handle service errors gracefully', () async {
        // Arrange
        const userId = 'test-user-id';
        when(mockNotificationService.getUnreadNotificationCount(userId))
            .thenThrow(Exception('Service error'));

        // Act & Assert
        expect(
          () => notificationRepository.getUnreadNotificationCount(userId),
          throwsException,
        );
        verify(mockNotificationService.getUnreadNotificationCount(userId)).called(1);
      });
    });
  });
}

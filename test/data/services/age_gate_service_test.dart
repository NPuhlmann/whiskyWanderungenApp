import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whisky_hikes/data/services/cache/age_gate_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AgeGateService', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('starts undeclared before load', () {
      // Arrange & Act
      final service = AgeGateService();

      // Assert
      expect(service.isDeclared, isFalse);
      expect(service.isAllowed, isFalse);
      expect(service.isBlocked, isFalse);
    });

    test('load leaves it undeclared when nothing was persisted', () async {
      // Arrange
      final service = AgeGateService();

      // Act
      await service.load();

      // Assert
      expect(service.isDeclared, isFalse);
      expect(service.isAllowed, isFalse);
      expect(service.isBlocked, isFalse);
    });

    test('declare(ofLegalAge: true) allows access and notifies', () async {
      // Arrange
      final service = AgeGateService();
      var notifications = 0;
      service.addListener(() => notifications++);

      // Act
      await service.declare(ofLegalAge: true);

      // Assert
      expect(service.isAllowed, isTrue);
      expect(service.isBlocked, isFalse);
      expect(service.isDeclared, isTrue);
      expect(notifications, 1);
    });

    test('declare(ofLegalAge: false) blocks access and notifies', () async {
      // Arrange
      final service = AgeGateService();
      var notifications = 0;
      service.addListener(() => notifications++);

      // Act
      await service.declare(ofLegalAge: false);

      // Assert
      expect(service.isAllowed, isFalse);
      expect(service.isBlocked, isTrue);
      expect(service.isDeclared, isTrue);
      expect(notifications, 1);
    });

    // The stated test-plan item on the original PR: the declaration has to
    // survive a cold restart, which here means a brand-new service instance
    // reading back what a previous one wrote.
    test('a confirmed declaration survives a cold restart', () async {
      // Arrange
      await AgeGateService().declare(ofLegalAge: true);

      // Act
      final afterRestart = AgeGateService();
      await afterRestart.load();

      // Assert
      expect(afterRestart.isAllowed, isTrue);
    });

    test('a denied declaration survives a cold restart', () async {
      // Arrange
      await AgeGateService().declare(ofLegalAge: false);

      // Act
      final afterRestart = AgeGateService();
      await afterRestart.load();

      // Assert
      expect(afterRestart.isBlocked, isTrue);
      expect(afterRestart.isAllowed, isFalse);
    });

    test(
      'reset returns to undeclared and does not survive a restart',
      () async {
        // Arrange
        final service = AgeGateService();
        await service.declare(ofLegalAge: false);

        // Act
        await service.reset();

        // Assert
        expect(service.isDeclared, isFalse);
        expect(service.isBlocked, isFalse);
        final afterRestart = AgeGateService();
        await afterRestart.load();
        expect(afterRestart.isDeclared, isFalse);
      },
    );

    test('a later declaration overwrites an earlier one', () async {
      // Arrange
      final service = AgeGateService();
      await service.declare(ofLegalAge: false);

      // Act
      await service.declare(ofLegalAge: true);

      // Assert
      expect(service.isAllowed, isTrue);
      final afterRestart = AgeGateService();
      await afterRestart.load();
      expect(afterRestart.isAllowed, isTrue);
    });
  });
}

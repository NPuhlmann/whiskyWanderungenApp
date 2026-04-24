import 'package:flutter_test/flutter_test.dart';
import 'package:whisky_hikes/domain/models/commission.dart';

void main() {
  group('Commission Model Tests', () {
    group('Commission Creation', () {
      test('should create Commission with all required fields', () {
        final commission = Commission(
          id: 1,
          hikeId: 100,
          companyId: 'company-123',
          orderId: 'order-456',
          commissionRate: 0.15, // 15%
          baseAmount: 50.0,
          commissionAmount: 7.50,
          status: CommissionStatus.pending,
          createdAt: DateTime(2025, 1, 15),
        );

        expect(commission.id, equals(1));
        expect(commission.hikeId, equals(100));
        expect(commission.companyId, equals('company-123'));
        expect(commission.orderId, equals('order-456'));
        expect(commission.commissionRate, equals(0.15));
        expect(commission.baseAmount, equals(50.0));
        expect(commission.commissionAmount, equals(7.50));
        expect(commission.status, equals(CommissionStatus.pending));
        expect(commission.createdAt, equals(DateTime(2025, 1, 15)));
      });

      test('should create Commission with optional fields as null', () {
        final commission = Commission(
          id: 1,
          hikeId: 100,
          companyId: 'company-123',
          orderId: 'order-456',
          commissionRate: 0.15,
          baseAmount: 50.0,
          commissionAmount: 7.50,
          status: CommissionStatus.pending,
          createdAt: DateTime(2025, 1, 15),
        );

        expect(commission.paidAt, isNull);
        expect(commission.billingPeriodId, isNull);
        expect(commission.notes, isNull);
        expect(commission.updatedAt, isNull);
      });

      test('should create Commission with optional fields provided', () {
        final commission = Commission(
          id: 1,
          hikeId: 100,
          companyId: 'company-123',
          orderId: 'order-456',
          commissionRate: 0.15,
          baseAmount: 50.0,
          commissionAmount: 7.50,
          status: CommissionStatus.paid,
          createdAt: DateTime(2025, 1, 15),
          paidAt: DateTime(2025, 2, 1),
          billingPeriodId: 'period-2025-01',
          notes: 'January commission payment',
          updatedAt: DateTime(2025, 2, 1),
        );

        expect(commission.paidAt, equals(DateTime(2025, 2, 1)));
        expect(commission.billingPeriodId, equals('period-2025-01'));
        expect(commission.notes, equals('January commission payment'));
        expect(commission.updatedAt, equals(DateTime(2025, 2, 1)));
      });
    });

    group('Commission Status Enum', () {
      test('should have correct commission status values', () {
        expect(CommissionStatus.values.length, equals(4));
        expect(
          CommissionStatus.values.contains(CommissionStatus.pending),
          isTrue,
        );
        expect(
          CommissionStatus.values.contains(CommissionStatus.calculated),
          isTrue,
        );
        expect(CommissionStatus.values.contains(CommissionStatus.paid), isTrue);
        expect(
          CommissionStatus.values.contains(CommissionStatus.cancelled),
          isTrue,
        );
      });

      test('should convert status to string correctly', () {
        expect(CommissionStatus.pending.toString(), contains('pending'));
        expect(CommissionStatus.calculated.toString(), contains('calculated'));
        expect(CommissionStatus.paid.toString(), contains('paid'));
        expect(CommissionStatus.cancelled.toString(), contains('cancelled'));
      });
    });

    group('Commission Business Logic Extensions', () {
      late Commission commission;

      setUp(() {
        commission = Commission(
          id: 1,
          hikeId: 100,
          companyId: 'company-123',
          orderId: 'order-456',
          commissionRate: 0.15,
          baseAmount: 50.0,
          commissionAmount: 7.50,
          status: CommissionStatus.pending,
          createdAt: DateTime(2025, 1, 15),
        );
      });

      test('should calculate commission rate percentage correctly', () {
        expect(commission.commissionRatePercentage, equals(15.0));
      });

      test('should format commission amount correctly', () {
        expect(commission.formattedCommissionAmount, equals('€7.50'));
      });

      test('should format base amount correctly', () {
        expect(commission.formattedBaseAmount, equals('€50.00'));
      });

      test('should check if commission is pending', () {
        expect(commission.isPending, isTrue);
        expect(commission.isCalculated, isFalse);
        expect(commission.isPaid, isFalse);
        expect(commission.isCancelled, isFalse);
      });

      test('should check if commission is paid', () {
        final paidCommission = commission.copyWith(
          status: CommissionStatus.paid,
        );

        expect(paidCommission.isPending, isFalse);
        expect(paidCommission.isCalculated, isFalse);
        expect(paidCommission.isPaid, isTrue);
        expect(paidCommission.isCancelled, isFalse);
      });

      test('should validate commission calculation is correct', () {
        expect(commission.isCalculationValid, isTrue);
      });

      test('should detect invalid commission calculation', () {
        final invalidCommission = commission.copyWith(
          commissionAmount: 10.0,
        ); // Should be 7.50
        expect(invalidCommission.isCalculationValid, isFalse);
      });

      test('should calculate expected commission amount', () {
        expect(commission.expectedCommissionAmount, equals(7.50));
      });

      test('should check if commission is overdue', () {
        final oldCommission = commission.copyWith(
          createdAt: DateTime(2024, 1, 1), // Over a year ago
        );
        expect(oldCommission.isOverdue, isTrue);

        final recentCommission = commission.copyWith(
          createdAt: DateTime.now().subtract(
            const Duration(days: 5),
          ), // 5 days ago
        );
        expect(recentCommission.isOverdue, isFalse);
      });

      test('should get age in days', () {
        final testDate = DateTime.now();
        final recentCommission = commission.copyWith(createdAt: testDate);
        expect(recentCommission.ageInDays, equals(0));

        final oldCommission = commission.copyWith(
          createdAt: testDate.subtract(const Duration(days: 30)),
        );
        expect(oldCommission.ageInDays, equals(30));
      });
    });

    group('Commission JSON Serialization', () {
      test('should convert to JSON and back', () {
        final commission = Commission(
          id: 1,
          hikeId: 100,
          companyId: 'company-123',
          orderId: 'order-456',
          commissionRate: 0.15,
          baseAmount: 50.0,
          commissionAmount: 7.50,
          status: CommissionStatus.paid,
          createdAt: DateTime(2025, 1, 15),
          paidAt: DateTime(2025, 2, 1),
          billingPeriodId: 'period-2025-01',
          notes: 'Test commission',
          updatedAt: DateTime(2025, 2, 1),
        );

        final json = commission.toJson();
        final restored = Commission.fromJson(json);

        expect(restored.id, equals(commission.id));
        expect(restored.hikeId, equals(commission.hikeId));
        expect(restored.companyId, equals(commission.companyId));
        expect(restored.orderId, equals(commission.orderId));
        expect(restored.commissionRate, equals(commission.commissionRate));
        expect(restored.baseAmount, equals(commission.baseAmount));
        expect(restored.commissionAmount, equals(commission.commissionAmount));
        expect(restored.status, equals(commission.status));
        expect(restored.createdAt, equals(commission.createdAt));
        expect(restored.paidAt, equals(commission.paidAt));
        expect(restored.billingPeriodId, equals(commission.billingPeriodId));
        expect(restored.notes, equals(commission.notes));
        expect(restored.updatedAt, equals(commission.updatedAt));
      });

      test('should handle null optional fields in JSON', () {
        final commission = Commission(
          id: 1,
          hikeId: 100,
          companyId: 'company-123',
          orderId: 'order-456',
          commissionRate: 0.15,
          baseAmount: 50.0,
          commissionAmount: 7.50,
          status: CommissionStatus.pending,
          createdAt: DateTime(2025, 1, 15),
        );

        final json = commission.toJson();
        final restored = Commission.fromJson(json);

        expect(restored.paidAt, isNull);
        expect(restored.billingPeriodId, isNull);
        expect(restored.notes, isNull);
        expect(restored.updatedAt, isNull);
      });
    });

    group('Commission copyWith Operations', () {
      late Commission originalCommission;

      setUp(() {
        originalCommission = Commission(
          id: 1,
          hikeId: 100,
          companyId: 'company-123',
          orderId: 'order-456',
          commissionRate: 0.15,
          baseAmount: 50.0,
          commissionAmount: 7.50,
          status: CommissionStatus.pending,
          createdAt: DateTime(2025, 1, 15),
        );
      });

      test('should handle copyWith with status change', () {
        final updatedCommission = originalCommission.copyWith(
          status: CommissionStatus.paid,
          paidAt: DateTime(2025, 2, 1),
          updatedAt: DateTime(2025, 2, 1),
        );

        expect(updatedCommission.status, equals(CommissionStatus.paid));
        expect(updatedCommission.paidAt, equals(DateTime(2025, 2, 1)));
        expect(updatedCommission.updatedAt, equals(DateTime(2025, 2, 1)));

        // Original fields should remain unchanged
        expect(updatedCommission.id, equals(originalCommission.id));
        expect(
          updatedCommission.commissionAmount,
          equals(originalCommission.commissionAmount),
        );
      });

      test('should handle copyWith with amount changes', () {
        final updatedCommission = originalCommission.copyWith(
          baseAmount: 60.0,
          commissionAmount: 9.0,
        );

        expect(updatedCommission.baseAmount, equals(60.0));
        expect(updatedCommission.commissionAmount, equals(9.0));
        expect(updatedCommission.id, equals(originalCommission.id));
        expect(updatedCommission.status, equals(originalCommission.status));
      });
    });

    group('Commission Equality', () {
      test('should implement equality correctly', () {
        final commission1 = Commission(
          id: 1,
          hikeId: 100,
          companyId: 'company-123',
          orderId: 'order-456',
          commissionRate: 0.15,
          baseAmount: 50.0,
          commissionAmount: 7.50,
          status: CommissionStatus.pending,
          createdAt: DateTime(2025, 1, 15),
        );

        final commission2 = Commission(
          id: 1,
          hikeId: 100,
          companyId: 'company-123',
          orderId: 'order-456',
          commissionRate: 0.15,
          baseAmount: 50.0,
          commissionAmount: 7.50,
          status: CommissionStatus.pending,
          createdAt: DateTime(2025, 1, 15),
        );

        expect(commission1, equals(commission2));
        expect(commission1.hashCode, equals(commission2.hashCode));
      });

      test('should detect inequality correctly', () {
        final commission1 = Commission(
          id: 1,
          hikeId: 100,
          companyId: 'company-123',
          orderId: 'order-456',
          commissionRate: 0.15,
          baseAmount: 50.0,
          commissionAmount: 7.50,
          status: CommissionStatus.pending,
          createdAt: DateTime(2025, 1, 15),
        );

        final commission2 = commission1.copyWith(commissionAmount: 8.0);

        expect(commission1, isNot(equals(commission2)));
      });
    });

    group('Commission toString', () {
      test('should provide meaningful toString representation', () {
        final commission = Commission(
          id: 1,
          hikeId: 100,
          companyId: 'company-123',
          orderId: 'order-456',
          commissionRate: 0.15,
          baseAmount: 50.0,
          commissionAmount: 7.50,
          status: CommissionStatus.pending,
          createdAt: DateTime(2025, 1, 15),
        );

        final stringRepresentation = commission.toString();

        expect(stringRepresentation, contains('Commission'));
        expect(stringRepresentation, contains('id: 1'));
        expect(stringRepresentation, contains('7.5'));
        expect(stringRepresentation, contains('pending'));
      });
    });
  });
}

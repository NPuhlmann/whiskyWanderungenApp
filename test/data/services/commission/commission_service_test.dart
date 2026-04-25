import 'package:flutter_test/flutter_test.dart';
import 'package:whisky_hikes/domain/models/commission.dart';

import '../../../test_helpers.dart';

void main() {
  group('CommissionService Business Logic Tests', () {
    group('Commission Validation Logic', () {
      test('should validate commission rate bounds', () {
        // Test valid commission rates
        const validRates = [0.0, 0.10, 0.15, 0.20, 0.25, 0.50, 1.0];
        for (final rate in validRates) {
          expect(
            rate >= 0 && rate <= 1.0,
            isTrue,
            reason: 'Rate $rate should be valid (0-100%)',
          );
        }

        // Test invalid commission rates
        const invalidRates = [-0.1, -1.0, 1.1, 1.5, 2.0];
        for (final rate in invalidRates) {
          expect(
            rate >= 0 && rate <= 1.0,
            isFalse,
            reason: 'Rate $rate should be invalid',
          );
        }
      });

      test('should calculate commission amounts correctly for valid rates', () {
        final testCases = [
          {'base': 100.0, 'rate': 0.0, 'expected': 0.0},
          {'base': 100.0, 'rate': 0.15, 'expected': 15.0},
          {'base': 100.0, 'rate': 1.0, 'expected': 100.0},
          {'base': 50.0, 'rate': 0.20, 'expected': 10.0},
        ];

        for (final testCase in testCases) {
          final base = testCase['base'] as double;
          final rate = testCase['rate'] as double;
          final expected = testCase['expected'] as double;

          final calculated = base * rate;
          expect(
            calculated,
            equals(expected),
            reason: 'Commission calculation failed for base=$base, rate=$rate',
          );
        }
      });
    });

    group('Commission Calculation Logic', () {
      test('should calculate commission amount correctly', () {
        // Test business logic calculations using test data
        final commission = TestHelpers.createTestCommission(
          baseAmount: 100.0,
          commissionRate: 0.20,
        );

        expect(commission.commissionAmount, equals(20.0));
        expect(commission.isCalculationValid, isTrue);
      });

      test('should detect invalid commission calculations', () {
        final invalidCommission = TestHelpers.createTestCommission(
          baseAmount: 100.0,
          commissionRate: 0.20,
          commissionAmount: 25.0, // Should be 20.0
        );

        expect(invalidCommission.isCalculationValid, isFalse);
      });

      test('should calculate expected commission amounts', () {
        final testCases = [
          {'base': 50.0, 'rate': 0.15, 'expected': 7.50},
          {'base': 100.0, 'rate': 0.20, 'expected': 20.0},
          {'base': 75.0, 'rate': 0.10, 'expected': 7.50},
          {'base': 33.33, 'rate': 0.15, 'expected': 4.9995},
        ];

        for (final testCase in testCases) {
          final commission = TestHelpers.createTestCommission(
            baseAmount: testCase['base'] as double,
            commissionRate: testCase['rate'] as double,
          );

          expect(
            commission.expectedCommissionAmount,
            closeTo(testCase['expected'] as double, 0.01),
            reason:
                'Failed for base=${testCase['base']}, rate=${testCase['rate']}',
          );
        }
      });
    });

    group('Commission Status Logic', () {
      test('should correctly identify commission status', () {
        final pendingCommission = TestHelpers.createTestCommission(
          status: CommissionStatus.pending,
        );
        expect(pendingCommission.isPending, isTrue);
        expect(pendingCommission.isCalculated, isFalse);
        expect(pendingCommission.isPaid, isFalse);
        expect(pendingCommission.isCancelled, isFalse);

        final paidCommission = TestHelpers.createTestCommission(
          status: CommissionStatus.paid,
        );
        expect(paidCommission.isPending, isFalse);
        expect(paidCommission.isCalculated, isFalse);
        expect(paidCommission.isPaid, isTrue);
        expect(paidCommission.isCancelled, isFalse);

        final calculatedCommission = TestHelpers.createTestCommission(
          status: CommissionStatus.calculated,
        );
        expect(calculatedCommission.isPending, isFalse);
        expect(calculatedCommission.isCalculated, isTrue);
        expect(calculatedCommission.isPaid, isFalse);
        expect(calculatedCommission.isCancelled, isFalse);

        final cancelledCommission = TestHelpers.createTestCommission(
          status: CommissionStatus.cancelled,
        );
        expect(cancelledCommission.isPending, isFalse);
        expect(cancelledCommission.isCalculated, isFalse);
        expect(cancelledCommission.isPaid, isFalse);
        expect(cancelledCommission.isCancelled, isTrue);
      });

      test('should check commission business rules', () {
        final pendingCommission = TestHelpers.createTestCommission(
          status: CommissionStatus.pending,
        );
        expect(pendingCommission.canBeMarkedAsPaid, isTrue);
        expect(pendingCommission.canBeCancelled, isTrue);

        final paidCommission = TestHelpers.createTestCommission(
          status: CommissionStatus.paid,
        );
        expect(paidCommission.canBeMarkedAsPaid, isFalse);
        expect(paidCommission.canBeCancelled, isFalse);

        final cancelledCommission = TestHelpers.createTestCommission(
          status: CommissionStatus.cancelled,
        );
        expect(cancelledCommission.canBeMarkedAsPaid, isFalse);
        expect(cancelledCommission.canBeCancelled, isFalse);
      });
    });

    group('Commission Analytics Logic', () {
      test('should calculate statistics from commission data', () {
        final commissions = TestHelpers.createSampleCommissions();

        // Calculate totals
        final totalAmount = commissions.fold<double>(
          0.0,
          (sum, commission) => sum + commission.commissionAmount,
        );
        expect(totalAmount, greaterThan(0));

        // Count by status
        final pendingCommissions = commissions
            .where((c) => c.status == CommissionStatus.pending)
            .length;
        final paidCommissions = commissions
            .where((c) => c.status == CommissionStatus.paid)
            .length;

        expect(
          pendingCommissions + paidCommissions,
          lessThanOrEqualTo(commissions.length),
        );

        // Average commission rate
        final avgRate =
            commissions.fold<double>(
              0.0,
              (sum, commission) => sum + commission.commissionRate,
            ) /
            commissions.length;
        expect(avgRate, greaterThan(0));
        expect(avgRate, lessThanOrEqualTo(1.0));
      });

      test('should identify overdue commissions', () {
        final now = DateTime.now();
        final overdueCommission = TestHelpers.createTestCommission(
          createdAt: now.subtract(const Duration(days: 35)), // 35 days old
          status: CommissionStatus.pending,
        );
        expect(overdueCommission.isOverdue, isTrue);

        final recentCommission = TestHelpers.createTestCommission(
          createdAt: now.subtract(const Duration(days: 5)), // 5 days old
          status: CommissionStatus.pending,
        );
        expect(recentCommission.isOverdue, isFalse);

        // Paid commissions are never overdue
        final paidCommission = TestHelpers.createTestCommission(
          createdAt: now.subtract(const Duration(days: 35)), // 35 days old
          status: CommissionStatus.paid,
        );
        expect(paidCommission.isOverdue, isFalse);
      });

      test('should calculate commission age correctly', () {
        final now = DateTime.now();
        final testCases = [
          {'days': 0, 'expected': 0},
          {'days': 1, 'expected': 1},
          {'days': 7, 'expected': 7},
          {'days': 30, 'expected': 30},
          {'days': 365, 'expected': 365},
        ];

        for (final testCase in testCases) {
          final commission = TestHelpers.createTestCommission(
            createdAt: now.subtract(Duration(days: testCase['days'] as int)),
          );
          expect(
            commission.ageInDays,
            equals(testCase['expected']),
            reason: 'Failed for ${testCase['days']} days ago',
          );
        }
      });
    });

    group('Commission Formatting and Display', () {
      test('should format amounts correctly', () {
        final commission = TestHelpers.createTestCommission(
          baseAmount: 50.0,
          commissionAmount: 7.50,
          commissionRate: 0.15,
        );

        expect(commission.formattedBaseAmount, equals('€50.00'));
        expect(commission.formattedCommissionAmount, equals('€7.50'));
        expect(commission.commissionRatePercentage, equals(15.0));
      });

      test('should provide status display text', () {
        final statusTests = [
          {'status': CommissionStatus.pending, 'display': 'Pending'},
          {'status': CommissionStatus.calculated, 'display': 'Calculated'},
          {'status': CommissionStatus.paid, 'display': 'Paid'},
          {'status': CommissionStatus.cancelled, 'display': 'Cancelled'},
        ];

        for (final test in statusTests) {
          final commission = TestHelpers.createTestCommission(
            status: test['status'] as CommissionStatus,
          );
          expect(
            commission.statusDisplay,
            equals(test['display']),
            reason: 'Status display failed for ${test['status']}',
          );
        }
      });

      test('should generate meaningful display names', () {
        final commission = TestHelpers.createTestCommission(
          id: 123,
          hikeId: 456,
        );
        expect(commission.displayName, equals('Commission #123 (Hike 456)'));
      });

      test('should format time since creation', () {
        final now = DateTime.now();

        // Just now
        final justNow = TestHelpers.createTestCommission(createdAt: now);
        expect(justNow.timeSinceCreation, equals('Just now'));

        // Minutes ago
        final minutesAgo = TestHelpers.createTestCommission(
          createdAt: now.subtract(const Duration(minutes: 5)),
        );
        expect(minutesAgo.timeSinceCreation, equals('5 minutes ago'));

        // Hours ago
        final hoursAgo = TestHelpers.createTestCommission(
          createdAt: now.subtract(const Duration(hours: 2)),
        );
        expect(hoursAgo.timeSinceCreation, equals('2 hours ago'));

        // Days ago
        final daysAgo = TestHelpers.createTestCommission(
          createdAt: now.subtract(const Duration(days: 3)),
        );
        expect(daysAgo.timeSinceCreation, equals('3 days ago'));

        // Single units (no plural)
        final oneDay = TestHelpers.createTestCommission(
          createdAt: now.subtract(const Duration(days: 1)),
        );
        expect(oneDay.timeSinceCreation, equals('1 day ago'));

        final oneHour = TestHelpers.createTestCommission(
          createdAt: now.subtract(const Duration(hours: 1)),
        );
        expect(oneHour.timeSinceCreation, equals('1 hour ago'));

        final oneMinute = TestHelpers.createTestCommission(
          createdAt: now.subtract(const Duration(minutes: 1)),
        );
        expect(oneMinute.timeSinceCreation, equals('1 minute ago'));
      });
    });

    group('Commission Data Validation', () {
      test('should validate required fields are present', () {
        // Test that Commission model requires all necessary fields
        final commission = Commission(
          id: 1,
          hikeId: 100,
          companyId: 'company-123',
          orderId: 'order-456',
          commissionRate: 0.15,
          baseAmount: 50.0,
          commissionAmount: 7.50,
          status: CommissionStatus.pending,
          createdAt: DateTime.now(),
        );

        expect(commission, isA<Commission>());
        expect(commission.id, equals(1));
        expect(commission.hikeId, equals(100));
      });

      test('should handle edge cases in calculations', () {
        // Zero base amount
        final zeroBase = TestHelpers.createTestCommission(
          baseAmount: 0.0,
          commissionRate: 0.15,
        );
        expect(zeroBase.expectedCommissionAmount, equals(0.0));

        // Zero commission rate
        final zeroRate = TestHelpers.createTestCommission(
          baseAmount: 100.0,
          commissionRate: 0.0,
        );
        expect(zeroRate.expectedCommissionAmount, equals(0.0));

        // Very small amounts
        final smallAmount = TestHelpers.createTestCommission(
          baseAmount: 0.01,
          commissionRate: 0.15,
        );
        expect(smallAmount.expectedCommissionAmount, equals(0.0015));
      });
    });

    group('Commission Collection Operations', () {
      test('should group commissions by company', () {
        final commissions = TestHelpers.createSampleCommissions();

        // All test commissions should be for the same company
        final uniqueCompanies = commissions.map((c) => c.companyId).toSet();
        expect(uniqueCompanies.length, equals(1));
        expect(uniqueCompanies.first, equals('company-123'));
      });

      test('should group commissions by status', () {
        final commissions = TestHelpers.createSampleCommissions();

        final statusGroups = <CommissionStatus, List<Commission>>{};
        for (final commission in commissions) {
          if (!statusGroups.containsKey(commission.status)) {
            statusGroups[commission.status] = [];
          }
          statusGroups[commission.status]!.add(commission);
        }

        // Should have multiple status groups
        expect(statusGroups.keys.length, greaterThan(1));

        // Each group should contain only commissions with that status
        for (final entry in statusGroups.entries) {
          expect(
            entry.value.every((c) => c.status == entry.key),
            isTrue,
            reason: 'Status group ${entry.key} contains mixed statuses',
          );
        }
      });

      test('should filter commissions by date range', () {
        final commissions = TestHelpers.createSampleCommissions();

        final startDate = DateTime(2025, 1, 5);
        final endDate = DateTime(2025, 1, 15);

        final filteredCommissions = commissions
            .where(
              (c) =>
                  c.createdAt.isAfter(startDate) &&
                  c.createdAt.isBefore(endDate),
            )
            .toList();

        // Should have some commissions in this range
        expect(filteredCommissions.length, greaterThan(0));

        // All filtered commissions should be within the date range
        for (final commission in filteredCommissions) {
          expect(commission.createdAt.isAfter(startDate), isTrue);
          expect(commission.createdAt.isBefore(endDate), isTrue);
        }
      });
    });
  });
}

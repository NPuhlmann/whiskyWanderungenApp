import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:whisky_hikes/data/services/commission/commission_chart_service.dart';
import 'package:whisky_hikes/data/services/commission/commission_service.dart';
import 'package:whisky_hikes/domain/models/commission.dart';

import '../../../test_helpers.dart';
import 'commission_chart_service_test.mocks.dart';

@GenerateMocks([CommissionService])

void main() {
  group('CommissionChartService', () {
    late CommissionChartService chartService;
    late MockCommissionService mockCommissionService;
    late List<Commission> testCommissions;

    setUp(() {
      mockCommissionService = MockCommissionService();
      chartService = CommissionChartService(mockCommissionService);
      testCommissions = TestHelpers.createSampleCommissions();
    });

    group('Timeline Chart Data', () {
      test('should generate timeline chart data for monthly view', () async {
        // Arrange
        const companyId = 'test-company';
        
        when(mockCommissionService.getCommissionsForDateRange(
          companyId,
          any,
          any,
        )).thenAnswer((_) async => testCommissions);

        // Act
        final chartData = await chartService.getTimelineChartData(
          companyId: companyId,
          period: ChartPeriod.monthly,
          months: 6,
        );

        // Assert
        expect(chartData, isA<CommissionTimelineData>());
        expect(chartData.dataPoints.isNotEmpty, true);
        expect(chartData.period, equals(ChartPeriod.monthly));
        expect(chartData.totalAmount, greaterThan(0));
        verify(mockCommissionService.getCommissionsForDateRange(
          companyId,
          any,
          any,
        )).called(1);
      });

      test('should generate timeline chart data for weekly view', () async {
        // Arrange
        const companyId = 'test-company';
        
        when(mockCommissionService.getCommissionsForDateRange(
          companyId,
          any,
          any,
        )).thenAnswer((_) async => testCommissions);

        // Act
        final chartData = await chartService.getTimelineChartData(
          companyId: companyId,
          period: ChartPeriod.weekly,
          weeks: 4,
        );

        // Assert
        expect(chartData, isA<CommissionTimelineData>());
        expect(chartData.dataPoints.isNotEmpty, true);
        expect(chartData.period, equals(ChartPeriod.weekly));
        verify(mockCommissionService.getCommissionsForDateRange(
          companyId,
          any,
          any,
        )).called(1);
      });

      test('should handle empty commission data', () async {
        // Arrange
        const companyId = 'empty-company';
        when(mockCommissionService.getCommissionsForDateRange(
          companyId,
          any,
          any,
        )).thenAnswer((_) async => <Commission>[]);

        // Act
        final chartData = await chartService.getTimelineChartData(
          companyId: companyId,
          period: ChartPeriod.monthly,
          months: 6,
        );

        // Assert
        expect(chartData.dataPoints, isEmpty);
        expect(chartData.totalAmount, equals(0.0));
      });

      test('should validate timeline parameters', () {
        // Act & Assert
        expect(
          () => chartService.getTimelineChartData(
            companyId: '',
            period: ChartPeriod.monthly,
            months: 6,
          ),
          throwsA(isA<ArgumentError>()),
        );

        expect(
          () => chartService.getTimelineChartData(
            companyId: 'test-company',
            period: ChartPeriod.monthly,
            months: 0,
          ),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('Status Distribution Chart Data', () {
      test('should generate status distribution chart data', () async {
        // Arrange
        const companyId = 'test-company';
        when(mockCommissionService.getCommissionsForCompany(companyId))
            .thenAnswer((_) async => testCommissions);

        // Act
        final chartData = await chartService.getStatusDistributionChartData(
          companyId: companyId,
        );

        // Assert
        expect(chartData, isA<CommissionStatusDistributionData>());
        expect(chartData.statusCounts.isNotEmpty, true);
        expect(chartData.totalCommissions, equals(testCommissions.length));
        
        // Verify all status types are accounted for
        final totalFromCounts = chartData.statusCounts.values.fold<int>(
          0, (sum, count) => sum + count,
        );
        expect(totalFromCounts, equals(testCommissions.length));
        
        verify(mockCommissionService.getCommissionsForCompany(companyId)).called(1);
      });

      test('should filter status distribution by date range', () async {
        // Arrange
        const companyId = 'test-company';
        final startDate = DateTime(2024, 1, 1);
        final endDate = DateTime(2024, 12, 31);
        final filteredCommissions = testCommissions.take(2).toList();
        
        when(mockCommissionService.getCommissionsForDateRange(
          companyId,
          startDate,
          endDate,
        )).thenAnswer((_) async => filteredCommissions);

        // Act
        final chartData = await chartService.getStatusDistributionChartData(
          companyId: companyId,
          startDate: startDate,
          endDate: endDate,
        );

        // Assert
        expect(chartData.totalCommissions, equals(filteredCommissions.length));
        verify(mockCommissionService.getCommissionsForDateRange(
          companyId,
          startDate,
          endDate,
        )).called(1);
      });
    });

    group('Commission by Hike Chart Data', () {
      test('should generate commission by hike chart data', () async {
        // Arrange
        const companyId = 'test-company';
        final hikeCommissions = {
          1: {'totalAmount': 150.0, 'commissions': testCommissions.take(2).toList()},
          2: {'totalAmount': 200.0, 'commissions': testCommissions.skip(2).take(1).toList()},
        };
        
        when(mockCommissionService.getCommissionSummaryByHike(companyId))
            .thenAnswer((_) async => hikeCommissions);

        // Act
        final chartData = await chartService.getCommissionByHikeChartData(
          companyId: companyId,
          limit: 10,
        );

        // Assert
        expect(chartData, isA<CommissionByHikeData>());
        expect(chartData.hikeData.isNotEmpty, true);
        expect(chartData.totalAmount, greaterThan(0));
        
        // Verify sorting (highest first)
        if (chartData.hikeData.length > 1) {
          expect(
            chartData.hikeData.first.commissionAmount,
            greaterThanOrEqualTo(chartData.hikeData[1].commissionAmount),
          );
        }
        
        verify(mockCommissionService.getCommissionSummaryByHike(companyId)).called(1);
      });

      test('should limit and sort hike data correctly', () async {
        // Arrange
        const companyId = 'test-company';
        final hikeCommissions = {
          1: {'totalAmount': 100.0, 'commissions': testCommissions.take(1).toList()},
          2: {'totalAmount': 300.0, 'commissions': testCommissions.take(1).toList()},
          3: {'totalAmount': 200.0, 'commissions': testCommissions.take(1).toList()},
          4: {'totalAmount': 150.0, 'commissions': testCommissions.take(1).toList()},
        };
        
        when(mockCommissionService.getCommissionSummaryByHike(companyId))
            .thenAnswer((_) async => hikeCommissions);

        // Act
        final chartData = await chartService.getCommissionByHikeChartData(
          companyId: companyId,
          limit: 3,
        );

        // Assert
        expect(chartData.hikeData.length, equals(3));
        // Should be sorted: 300, 200, 150
        expect(chartData.hikeData[0].commissionAmount, equals(300.0));
        expect(chartData.hikeData[1].commissionAmount, equals(200.0));
        expect(chartData.hikeData[2].commissionAmount, equals(150.0));
      });

      test('should validate commission by hike parameters', () {
        // Act & Assert
        expect(
          () => chartService.getCommissionByHikeChartData(
            companyId: '',
            limit: 10,
          ),
          throwsA(isA<ArgumentError>()),
        );

        expect(
          () => chartService.getCommissionByHikeChartData(
            companyId: 'test-company',
            limit: 0,
          ),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('Chart Data Aggregation', () {
      test('should aggregate commissions by time periods correctly', () {
        // Arrange
        final commissions = [
          TestHelpers.createTestCommission(
            createdAt: DateTime(2024, 1, 15),
            commissionAmount: 100.0,
          ),
          TestHelpers.createTestCommission(
            createdAt: DateTime(2024, 1, 20),
            commissionAmount: 150.0,
          ),
          TestHelpers.createTestCommission(
            createdAt: DateTime(2024, 2, 10),
            commissionAmount: 200.0,
          ),
        ];

        // Act
        final aggregated = chartService.aggregateCommissionsByMonth(commissions);

        // Assert
        expect(aggregated.length, equals(2)); // Jan and Feb
        expect(aggregated['2024-01'], equals(250.0)); // 100 + 150
        expect(aggregated['2024-02'], equals(200.0)); // 200
      });

      test('should group commissions by status correctly', () {
        // Arrange
        final commissions = [
          TestHelpers.createTestCommission(status: CommissionStatus.pending),
          TestHelpers.createTestCommission(status: CommissionStatus.pending),
          TestHelpers.createTestCommission(status: CommissionStatus.paid),
          TestHelpers.createTestCommission(status: CommissionStatus.cancelled),
        ];

        // Act
        final grouped = chartService.groupCommissionsByStatus(commissions);

        // Assert
        expect(grouped[CommissionStatus.pending], equals(2));
        expect(grouped[CommissionStatus.paid], equals(1));
        expect(grouped[CommissionStatus.cancelled], equals(1));
        expect(grouped[CommissionStatus.calculated], equals(0));
      });
    });

    group('Error Handling', () {
      test('should handle service errors gracefully', () async {
        // Arrange
        const companyId = 'error-company';
        when(mockCommissionService.getCommissionsForCompany(companyId))
            .thenThrow(Exception('Database error'));

        // Act & Assert
        expect(
          () => chartService.getStatusDistributionChartData(companyId: companyId),
          throwsA(isA<Exception>()),
        );
      });

      test('should validate date range parameters', () {
        // Arrange
        final startDate = DateTime(2024, 12, 31);
        final endDate = DateTime(2024, 1, 1); // End before start

        // Act & Assert
        expect(
          () => chartService.getTimelineChartData(
            companyId: 'test-company',
            period: ChartPeriod.monthly,
            months: 6,
            startDate: startDate,
            endDate: endDate,
          ),
          throwsA(isA<ArgumentError>()),
        );
      });
    });
  });
}
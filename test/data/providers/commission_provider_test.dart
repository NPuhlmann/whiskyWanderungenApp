import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:whisky_hikes/data/providers/commission_provider.dart';
import 'package:whisky_hikes/data/services/commission/commission_service.dart';
import 'package:whisky_hikes/domain/models/commission.dart';
import '../../test_helpers.dart';

@GenerateMocks([CommissionService])
import 'commission_provider_test.mocks.dart';

void main() {
  group('CommissionProvider Tests', () {
    late CommissionProvider provider;
    late MockCommissionService mockService;

    setUp(() {
      mockService = MockCommissionService();
      provider = CommissionProvider(commissionService: mockService);
    });

    group('State Management', () {
      test('should initialize with correct default values', () {
        // Assert
        expect(provider.commissions, isEmpty);
        expect(provider.selectedCommission, isNull);
        expect(provider.isLoading, isFalse);
        expect(provider.errorMessage, isNull);
        expect(provider.filteredCommissions, isEmpty);
        expect(provider.currentFilter, equals('all'));
        expect(provider.searchTerm, isEmpty);
        expect(provider.selectedPeriod, equals('month'));
      });

      test('should set loading state correctly', () {
        // Act
        provider.setLoading(true);

        // Assert
        expect(provider.isLoading, isTrue);
      });

      test('should clear error message when setting loading to true', () {
        // Arrange
        provider.setErrorMessage('Previous error');

        // Act
        provider.setLoading(true);

        // Assert
        expect(provider.errorMessage, isNull);
      });

      test('should set error message correctly', () {
        // Arrange
        const errorMessage = 'Test error';

        // Act
        provider.setErrorMessage(errorMessage);

        // Assert
        expect(provider.errorMessage, equals(errorMessage));
        expect(provider.isLoading, isFalse);
      });
    });

    group('Commission Loading', () {
      test('should load commissions for company successfully', () async {
        // Arrange
        final testCommissions = TestHelpers.createSampleCommissions();
        const companyId = 'company-123';
        when(mockService.getCommissionsForCompany(companyId))
            .thenAnswer((_) async => testCommissions);

        // Act
        await provider.loadCommissionsForCompany(companyId);

        // Assert
        expect(provider.commissions, equals(testCommissions));
        expect(provider.isLoading, isFalse);
        expect(provider.errorMessage, isNull);
        verify(mockService.getCommissionsForCompany(companyId)).called(1);
      });

      test('should handle commission loading error', () async {
        // Arrange
        const companyId = 'company-123';
        when(mockService.getCommissionsForCompany(companyId))
            .thenThrow(Exception('Service error'));

        // Act
        await provider.loadCommissionsForCompany(companyId);

        // Assert
        expect(provider.commissions, isEmpty);
        expect(provider.isLoading, isFalse);
        expect(provider.errorMessage, isNotNull);
        expect(provider.errorMessage, contains('Service error'));
      });

      test('should set loading state during commission loading', () async {
        // Arrange
        const companyId = 'company-123';
        final completer = Completer<List<Commission>>();
        when(mockService.getCommissionsForCompany(companyId))
            .thenAnswer((_) => completer.future);
        
        // Act
        final future = provider.loadCommissionsForCompany(companyId);
        
        // Assert loading state
        expect(provider.isLoading, isTrue);
        
        // Complete the future
        completer.complete(TestHelpers.createSampleCommissions());
        await future;
        
        expect(provider.isLoading, isFalse);
      });
    });

    group('Commission Filtering', () {
      test('should filter commissions by status', () async {
        // Arrange
        final testCommissions = TestHelpers.createSampleCommissions();
        const companyId = 'company-123';
        when(mockService.getCommissionsForCompany(companyId))
            .thenAnswer((_) async => testCommissions);
        await provider.loadCommissionsForCompany(companyId);

        // Act
        provider.setFilter('pending');

        // Assert
        expect(provider.currentFilter, equals('pending'));
        expect(provider.filteredCommissions.length, 
            equals(testCommissions.where((c) => c.status == CommissionStatus.pending).length));
      });

      test('should show all commissions when filter is "all"', () async {
        // Arrange
        final testCommissions = TestHelpers.createSampleCommissions();
        const companyId = 'company-123';
        when(mockService.getCommissionsForCompany(companyId))
            .thenAnswer((_) async => testCommissions);
        await provider.loadCommissionsForCompany(companyId);

        // Act
        provider.setFilter('all');

        // Assert
        expect(provider.currentFilter, equals('all'));
        expect(provider.filteredCommissions, equals(testCommissions));
      });

      test('should search commissions by company ID', () async {
        // Arrange
        final testCommissions = TestHelpers.createSampleCommissions();
        const companyId = 'company-123';
        when(mockService.getCommissionsForCompany(companyId))
            .thenAnswer((_) async => testCommissions);
        await provider.loadCommissionsForCompany(companyId);

        // Act
        provider.setSearchTerm('company-123');

        // Assert
        expect(provider.searchTerm, equals('company-123'));
        expect(provider.filteredCommissions.length, 
            equals(testCommissions.where((c) => c.companyId.contains('company-123')).length));
      });

      test('should combine status filter and search', () async {
        // Arrange
        final testCommissions = TestHelpers.createSampleCommissions();
        const companyId = 'company-123';
        when(mockService.getCommissionsForCompany(companyId))
            .thenAnswer((_) async => testCommissions);
        await provider.loadCommissionsForCompany(companyId);

        // Act
        provider.setFilter('pending');
        provider.setSearchTerm('company-123');

        // Assert
        final filtered = provider.filteredCommissions;
        expect(filtered.every((c) => 
            c.status == CommissionStatus.pending && 
            c.companyId.contains('company-123')), isTrue);
      });
    });

    group('Commission Statistics', () {
      test('should load commission statistics successfully', () async {
        // Arrange
        const companyId = 'company-123';
        final testStats = {
          'totalCommissions': 5,
          'pendingCommissions': 2,
          'paidCommissions': 3,
          'totalAmount': 500.0,
          'pendingAmount': 200.0,
          'paidAmount': 300.0,
        };
        when(mockService.getCommissionStatistics(companyId))
            .thenAnswer((_) async => testStats);

        // Act
        await provider.loadStatistics(companyId);

        // Assert
        expect(provider.statistics, equals(testStats));
        verify(mockService.getCommissionStatistics(companyId)).called(1);
      });

      test('should handle statistics loading error', () async {
        // Arrange
        const companyId = 'company-123';
        when(mockService.getCommissionStatistics(companyId))
            .thenThrow(Exception('Stats error'));

        // Act
        await provider.loadStatistics(companyId);

        // Assert
        expect(provider.statistics, isEmpty);
        expect(provider.errorMessage, isNotNull);
      });
    });

    group('Commission Updates', () {
      test('should update commission status successfully', () async {
        // Arrange
        final commission = TestHelpers.createTestCommission();
        final updatedCommission = commission.copyWith(status: CommissionStatus.paid);
        when(mockService.updateCommissionStatus(commission.id, CommissionStatus.paid))
            .thenAnswer((_) async => updatedCommission);
        when(mockService.getCommissionsForCompany(any))
            .thenAnswer((_) async => [updatedCommission]);

        provider.commissions = [commission];

        // Act
        await provider.updateCommissionStatus(commission.id, CommissionStatus.paid);

        // Assert
        expect(provider.commissions.first.status, equals(CommissionStatus.paid));
        verify(mockService.updateCommissionStatus(commission.id, CommissionStatus.paid)).called(1);
      });

      test('should handle commission status update error', () async {
        // Arrange
        final commission = TestHelpers.createTestCommission();
        when(mockService.updateCommissionStatus(commission.id, CommissionStatus.paid))
            .thenThrow(Exception('Update error'));

        provider.commissions = [commission];

        // Act
        await provider.updateCommissionStatus(commission.id, CommissionStatus.paid);

        // Assert
        expect(provider.errorMessage, isNotNull);
        expect(provider.errorMessage, contains('Update error'));
        expect(provider.commissions.first.status, equals(commission.status)); // Status unchanged
      });
    });

    group('Date Range Filtering', () {
      test('should set date range correctly', () {
        // Arrange
        final startDate = DateTime(2025, 1, 1);
        final endDate = DateTime(2025, 1, 31);

        // Act
        provider.setDateRange(startDate, endDate);

        // Assert
        expect(provider.startDate, equals(startDate));
        expect(provider.endDate, equals(endDate));
      });

      test('should filter commissions by date range', () async {
        // Arrange
        final testCommissions = TestHelpers.createSampleCommissions();
        const companyId = 'company-123';
        when(mockService.getCommissionsForCompany(companyId))
            .thenAnswer((_) async => testCommissions);
        await provider.loadCommissionsForCompany(companyId);

        final startDate = DateTime(2025, 1, 15);
        final endDate = DateTime(2025, 1, 31);

        // Act
        provider.setDateRange(startDate, endDate);

        // Assert
        final filtered = provider.filteredCommissions;
        expect(filtered.every((c) => 
            c.createdAt.isAfter(startDate) && c.createdAt.isBefore(endDate)), isTrue);
      });
    });

    group('Overdue Commissions', () {
      test('should load overdue commissions successfully', () async {
        // Arrange
        const companyId = 'company-123';
        final overdueCommissions = [TestHelpers.createOverdueCommission()];
        when(mockService.getOverdueCommissions(companyId))
            .thenAnswer((_) async => overdueCommissions);

        // Act
        await provider.loadOverdueCommissions(companyId);

        // Assert
        expect(provider.overdueCommissions, equals(overdueCommissions));
        verify(mockService.getOverdueCommissions(companyId)).called(1);
      });
    });

  });
}
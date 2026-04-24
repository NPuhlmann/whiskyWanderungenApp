import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pdf/pdf.dart';
import 'package:whisky_hikes/data/services/commission/commission_export_service.dart';
import 'package:whisky_hikes/data/services/commission/commission_service.dart';
import 'package:whisky_hikes/domain/models/commission.dart';

import '../../../test_helpers.dart';
import 'commission_export_service_test.mocks.dart';

@GenerateMocks([CommissionService])
void main() {
  group('CommissionExportService', () {
    late CommissionExportService exportService;
    late MockCommissionService mockCommissionService;
    late List<Commission> testCommissions;

    setUp(() {
      mockCommissionService = MockCommissionService();
      exportService = CommissionExportService(mockCommissionService);
      testCommissions = TestHelpers.createSampleCommissions();
    });

    group('PDF Export', () {
      test('should generate PDF for commission list', () async {
        // Arrange
        const companyId = 'test-company';
        when(
          mockCommissionService.getCommissionsForCompany(companyId),
        ).thenAnswer((_) async => testCommissions);

        // Act
        final pdfBytes = await exportService.generateCommissionPDF(
          companyId: companyId,
          title: 'Commission Report',
        );

        // Assert
        expect(pdfBytes, isA<Uint8List>());
        expect(pdfBytes.isNotEmpty, true);
        verify(
          mockCommissionService.getCommissionsForCompany(companyId),
        ).called(1);
      });

      test('should generate PDF with date range filter', () async {
        // Arrange
        const companyId = 'test-company';
        final startDate = DateTime(2024, 1, 1);
        final endDate = DateTime(2024, 12, 31);
        final filteredCommissions = testCommissions.take(2).toList();

        when(
          mockCommissionService.getCommissionsForDateRange(
            companyId,
            startDate,
            endDate,
          ),
        ).thenAnswer((_) async => filteredCommissions);

        // Act
        final pdfBytes = await exportService.generateCommissionPDF(
          companyId: companyId,
          title: 'Commission Report 2024',
          startDate: startDate,
          endDate: endDate,
        );

        // Assert
        expect(pdfBytes, isA<Uint8List>());
        expect(pdfBytes.isNotEmpty, true);
        verify(
          mockCommissionService.getCommissionsForDateRange(
            companyId,
            startDate,
            endDate,
          ),
        ).called(1);
      });

      test('should generate PDF with commission statistics', () async {
        // Arrange
        const companyId = 'test-company';
        final stats = {
          'totalCommissions': 5,
          'totalAmount': 250.0,
          'pendingAmount': 100.0,
          'paidAmount': 150.0,
          'averageCommissionRate': 0.15,
        };

        when(
          mockCommissionService.getCommissionsForCompany(companyId),
        ).thenAnswer((_) async => testCommissions);
        when(
          mockCommissionService.getCommissionStatistics(companyId),
        ).thenAnswer((_) async => stats);

        // Act
        final pdfBytes = await exportService.generateCommissionPDF(
          companyId: companyId,
          title: 'Commission Report with Stats',
          includeStatistics: true,
        );

        // Assert
        expect(pdfBytes, isA<Uint8List>());
        expect(pdfBytes.isNotEmpty, true);
        verify(
          mockCommissionService.getCommissionsForCompany(companyId),
        ).called(1);
        verify(
          mockCommissionService.getCommissionStatistics(companyId),
        ).called(1);
      });

      test('should handle empty commission list', () async {
        // Arrange
        const companyId = 'empty-company';
        when(
          mockCommissionService.getCommissionsForCompany(companyId),
        ).thenAnswer((_) async => <Commission>[]);

        // Act
        final pdfBytes = await exportService.generateCommissionPDF(
          companyId: companyId,
          title: 'Empty Commission Report',
        );

        // Assert
        expect(pdfBytes, isA<Uint8List>());
        expect(
          pdfBytes.isNotEmpty,
          true,
        ); // PDF should still be generated with "No data" message
      });

      test('should format PDF content correctly', () async {
        // Arrange
        const companyId = 'test-company';
        when(
          mockCommissionService.getCommissionsForCompany(companyId),
        ).thenAnswer((_) async => testCommissions);

        // Act
        final pdfBytes = await exportService.generateCommissionPDF(
          companyId: companyId,
          title: 'Test Commission Report',
        );

        // Assert
        expect(pdfBytes, isA<Uint8List>());
        expect(
          pdfBytes.length,
          greaterThan(1000),
        ); // PDF should have substantial content
      });
    });

    group('CSV Export', () {
      test('should generate CSV for commission list', () async {
        // Arrange
        const companyId = 'test-company';
        when(
          mockCommissionService.getCommissionsForCompany(companyId),
        ).thenAnswer((_) async => testCommissions);

        // Act
        final csvContent = await exportService.generateCommissionCSV(
          companyId: companyId,
        );

        // Assert
        expect(csvContent, isA<String>());
        expect(csvContent.isNotEmpty, true);
        expect(csvContent, contains('Commission ID'));
        expect(csvContent, contains('Hike ID'));
        expect(csvContent, contains('Commission Rate'));
        expect(csvContent, contains('Base Amount'));
        expect(csvContent, contains('Commission Amount'));
        expect(csvContent, contains('Status'));
        verify(
          mockCommissionService.getCommissionsForCompany(companyId),
        ).called(1);
      });

      test('should generate CSV with date range filter', () async {
        // Arrange
        const companyId = 'test-company';
        final startDate = DateTime(2024, 1, 1);
        final endDate = DateTime(2024, 12, 31);
        final filteredCommissions = testCommissions.take(2).toList();

        when(
          mockCommissionService.getCommissionsForDateRange(
            companyId,
            startDate,
            endDate,
          ),
        ).thenAnswer((_) async => filteredCommissions);

        // Act
        final csvContent = await exportService.generateCommissionCSV(
          companyId: companyId,
          startDate: startDate,
          endDate: endDate,
        );

        // Assert
        expect(csvContent, isA<String>());
        expect(csvContent.isNotEmpty, true);
        expect(csvContent, contains('Commission ID'));
        verify(
          mockCommissionService.getCommissionsForDateRange(
            companyId,
            startDate,
            endDate,
          ),
        ).called(1);
      });

      test('should format CSV data correctly', () async {
        // Arrange
        const companyId = 'test-company';
        final singleCommission = [testCommissions.first];
        when(
          mockCommissionService.getCommissionsForCompany(companyId),
        ).thenAnswer((_) async => singleCommission);

        // Act
        final csvContent = await exportService.generateCommissionCSV(
          companyId: companyId,
        );

        // Assert
        expect(csvContent, isA<String>());
        final lines = csvContent.split('\n');
        expect(
          lines.length,
          greaterThanOrEqualTo(2),
        ); // Header + at least one data row

        // Check CSV structure
        final headers = lines[0].split(',');
        expect(headers, contains('Commission ID'));
        expect(headers, contains('Commission Amount'));
        expect(headers, contains('Status'));

        // Check data row contains actual values
        final dataRow = lines[1];
        expect(dataRow, contains(singleCommission.first.id.toString()));
        expect(
          dataRow,
          contains(singleCommission.first.formattedCommissionAmount),
        );
        expect(dataRow, contains(singleCommission.first.statusDisplay));
      });

      test('should handle empty commission list for CSV', () async {
        // Arrange
        const companyId = 'empty-company';
        when(
          mockCommissionService.getCommissionsForCompany(companyId),
        ).thenAnswer((_) async => <Commission>[]);

        // Act
        final csvContent = await exportService.generateCommissionCSV(
          companyId: companyId,
        );

        // Assert
        expect(csvContent, isA<String>());
        expect(csvContent.isNotEmpty, true);
        expect(
          csvContent,
          contains('Commission ID'),
        ); // Headers should still exist
        final lines = csvContent.split('\n');
        expect(lines.length, equals(1)); // Only header row
      });
    });

    group('Export Utilities', () {
      test('should validate export parameters', () async {
        // Arrange & Act & Assert
        expect(
          () =>
              exportService.generateCommissionPDF(companyId: '', title: 'Test'),
          throwsA(isA<ArgumentError>()),
        );

        expect(
          () => exportService.generateCommissionCSV(companyId: ''),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should handle service errors gracefully', () async {
        // Arrange
        const companyId = 'error-company';
        when(
          mockCommissionService.getCommissionsForCompany(companyId),
        ).thenThrow(Exception('Database error'));

        // Act & Assert
        expect(
          () => exportService.generateCommissionPDF(
            companyId: companyId,
            title: 'Test',
          ),
          throwsA(isA<Exception>()),
        );

        expect(
          () => exportService.generateCommissionCSV(companyId: companyId),
          throwsA(isA<Exception>()),
        );
      });

      test('should generate unique filenames', () {
        // Act
        final filename1 = exportService.generateExportFilename(
          type: 'pdf',
          companyId: 'test-company',
          title: 'Report',
        );
        final filename2 = exportService.generateExportFilename(
          type: 'csv',
          companyId: 'test-company',
          title: 'Report',
        );

        // Assert
        expect(
          filename1,
          matches(r'commission_report_test-company_\d{8}_\d{6}\.pdf'),
        );
        expect(
          filename2,
          matches(r'commission_report_test-company_\d{8}_\d{6}\.csv'),
        );
        expect(filename1, isNot(equals(filename2)));
      });
    });

    group('Error Handling', () {
      test('should handle date range validation', () {
        // Arrange
        final startDate = DateTime(2024, 12, 31);
        final endDate = DateTime(2024, 1, 1); // End before start

        // Act & Assert
        expect(
          () => exportService.generateCommissionPDF(
            companyId: 'test-company',
            title: 'Test',
            startDate: startDate,
            endDate: endDate,
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should validate PDF page size', () async {
        // Arrange
        const companyId = 'test-company';
        when(
          mockCommissionService.getCommissionsForCompany(companyId),
        ).thenAnswer((_) async => testCommissions);

        // Act
        final pdfBytes = await exportService.generateCommissionPDF(
          companyId: companyId,
          title: 'Test Report',
          pageFormat: PdfPageFormat.a4,
        );

        // Assert
        expect(pdfBytes, isA<Uint8List>());
        expect(pdfBytes.isNotEmpty, true);
      });
    });
  });
}

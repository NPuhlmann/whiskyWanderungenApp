import 'dart:typed_data';
import 'dart:developer';
import 'package:csv/csv.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:whisky_hikes/data/services/commission/commission_service.dart';
import 'package:whisky_hikes/domain/models/commission.dart';

/// Service for exporting commission data to various formats (PDF, CSV)
class CommissionExportService {
  final CommissionService _commissionService;

  CommissionExportService(this._commissionService);

  /// Generate a PDF report for commissions
  Future<Uint8List> generateCommissionPDF({
    required String companyId,
    required String title,
    DateTime? startDate,
    DateTime? endDate,
    bool includeStatistics = false,
    PdfPageFormat pageFormat = PdfPageFormat.a4,
  }) async {
    try {
      // Validate parameters
      if (companyId.isEmpty) {
        throw ArgumentError('Company ID cannot be empty');
      }

      if (startDate != null && endDate != null && startDate.isAfter(endDate)) {
        throw ArgumentError('Start date cannot be after end date');
      }

      // Fetch commission data
      final List<Commission> commissions;
      if (startDate != null && endDate != null) {
        commissions = await _commissionService.getCommissionsForDateRange(
          companyId,
          startDate,
          endDate,
        );
      } else {
        commissions = await _commissionService.getCommissionsForCompany(companyId);
      }

      // Fetch statistics if requested
      Map<String, dynamic>? statistics;
      if (includeStatistics) {
        statistics = await _commissionService.getCommissionStatistics(companyId);
      }

      // Generate PDF
      final pdf = pw.Document();
      
      pdf.addPage(
        pw.MultiPage(
          pageFormat: pageFormat,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return [
              // Title
              pw.Header(
                level: 0,
                child: pw.Text(
                  title,
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 20),

              // Date range if specified
              if (startDate != null && endDate != null) ...[
                pw.Text(
                  'Period: ${_formatDate(startDate)} - ${_formatDate(endDate)}',
                  style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 20),
              ],

              // Statistics section
              if (includeStatistics && statistics != null) ...[
                pw.Header(
                  level: 1,
                  child: pw.Text('Summary Statistics'),
                ),
                pw.SizedBox(height: 10),
                _buildStatisticsTable(statistics),
                pw.SizedBox(height: 30),
              ],

              // Commission list
              pw.Header(
                level: 1,
                child: pw.Text('Commission Details'),
              ),
              pw.SizedBox(height: 10),

              if (commissions.isEmpty) ...[
                pw.Text(
                  'No commissions found for the specified criteria.',
                  style: const pw.TextStyle(fontSize: 14),
                ),
              ] else ...[
                _buildCommissionTable(commissions),
              ],

              // Footer with generation info
              pw.SizedBox(height: 30),
              pw.Divider(),
              pw.Text(
                'Generated on: ${_formatDateTime(DateTime.now())}',
                style: const pw.TextStyle(fontSize: 10),
              ),
            ];
          },
        ),
      );

      return pdf.save();
    } catch (e) {
      log('Error generating commission PDF: $e');
      rethrow;
    }
  }

  /// Generate a CSV export for commissions
  Future<String> generateCommissionCSV({
    required String companyId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      // Validate parameters
      if (companyId.isEmpty) {
        throw ArgumentError('Company ID cannot be empty');
      }

      // Fetch commission data
      final List<Commission> commissions;
      if (startDate != null && endDate != null) {
        commissions = await _commissionService.getCommissionsForDateRange(
          companyId,
          startDate,
          endDate,
        );
      } else {
        commissions = await _commissionService.getCommissionsForCompany(companyId);
      }

      // Generate CSV data
      final List<List<String>> csvData = [];

      // Headers
      csvData.add([
        'Commission ID',
        'Hike ID',
        'Order ID',
        'Commission Rate',
        'Base Amount',
        'Commission Amount',
        'Status',
        'Created At',
        'Paid At',
        'Notes',
      ]);

      // Data rows
      for (final commission in commissions) {
        csvData.add([
          commission.id.toString(),
          commission.hikeId.toString(),
          commission.orderId,
          '${(commission.commissionRate * 100).toStringAsFixed(1)}%',
          commission.formattedBaseAmount,
          commission.formattedCommissionAmount,
          commission.statusDisplay,
          _formatDateTime(commission.createdAt),
          commission.paidAt != null ? _formatDateTime(commission.paidAt!) : '',
          commission.notes ?? '',
        ]);
      }

      // Convert to CSV string
      return const ListToCsvConverter().convert(csvData);
    } catch (e) {
      log('Error generating commission CSV: $e');
      rethrow;
    }
  }

  /// Generate a unique filename for export
  String generateExportFilename({
    required String type,
    required String companyId,
    required String title,
  }) {
    final now = DateTime.now();
    final dateString = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final timeString = '${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';
    
    final sanitizedTitle = title.toLowerCase().replaceAll(' ', '_');
    final sanitizedCompanyId = companyId.replaceAll(' ', '_');
    
    return 'commission_${sanitizedTitle}_${sanitizedCompanyId}_${dateString}_$timeString.$type';
  }

  /// Build statistics table for PDF
  pw.Widget _buildStatisticsTable(Map<String, dynamic> statistics) {
    return pw.Table(
      border: pw.TableBorder.all(),
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text('Metric', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text('Value', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
          ],
        ),
        _buildStatisticRow('Total Commissions', statistics['totalCommissions'].toString()),
        _buildStatisticRow('Total Amount', '€${(statistics['totalAmount'] as double).toStringAsFixed(2)}'),
        _buildStatisticRow('Pending Amount', '€${(statistics['pendingAmount'] as double).toStringAsFixed(2)}'),
        _buildStatisticRow('Paid Amount', '€${(statistics['paidAmount'] as double).toStringAsFixed(2)}'),
        _buildStatisticRow('Average Rate', '${((statistics['averageCommissionRate'] as double) * 100).toStringAsFixed(1)}%'),
      ],
    );
  }

  /// Build a single statistic row
  pw.TableRow _buildStatisticRow(String label, String value) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(label),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(value),
        ),
      ],
    );
  }

  /// Build commission table for PDF
  pw.Widget _buildCommissionTable(List<Commission> commissions) {
    return pw.Table(
      border: pw.TableBorder.all(),
      columnWidths: {
        0: const pw.FixedColumnWidth(60),  // ID
        1: const pw.FixedColumnWidth(60),  // Hike ID
        2: const pw.FixedColumnWidth(80),  // Rate
        3: const pw.FixedColumnWidth(80),  // Base Amount
        4: const pw.FixedColumnWidth(80),  // Commission Amount
        5: const pw.FixedColumnWidth(80),  // Status
        6: const pw.FlexColumnWidth(),     // Created At
      },
      children: [
        // Header row
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            _buildTableHeader('ID'),
            _buildTableHeader('Hike'),
            _buildTableHeader('Rate'),
            _buildTableHeader('Base'),
            _buildTableHeader('Commission'),
            _buildTableHeader('Status'),
            _buildTableHeader('Created'),
          ],
        ),
        // Data rows
        ...commissions.map((commission) => pw.TableRow(
          children: [
            _buildTableCell(commission.id.toString()),
            _buildTableCell(commission.hikeId.toString()),
            _buildTableCell('${(commission.commissionRate * 100).toStringAsFixed(1)}%'),
            _buildTableCell(commission.formattedBaseAmount),
            _buildTableCell(commission.formattedCommissionAmount),
            _buildTableCell(commission.statusDisplay),
            _buildTableCell(_formatDate(commission.createdAt)),
          ],
        )),
      ],
    );
  }

  /// Build table header cell
  pw.Widget _buildTableHeader(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontWeight: pw.FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }

  /// Build table data cell
  pw.Widget _buildTableCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: const pw.TextStyle(fontSize: 9),
      ),
    );
  }

  /// Format date for display
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  /// Format date and time for display
  String _formatDateTime(DateTime dateTime) {
    return '${_formatDate(dateTime)} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
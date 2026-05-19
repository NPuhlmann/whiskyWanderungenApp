import 'dart:developer';
import 'dart:typed_data';

import 'package:csv/csv.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:whisky_hikes/domain/models/analytics/customer_insights.dart';
import 'package:whisky_hikes/domain/models/analytics/route_performance.dart';
import 'package:whisky_hikes/domain/models/analytics/sales_statistics.dart';

/// Service for exporting analytics data (Phase 7) to PDF and CSV.
///
/// The export is stateless — callers pass already-loaded [SalesStatistics],
/// [CustomerInsights] and [RoutePerformance] data so the service can run in
/// tests without Supabase access and stays decoupled from the provider.
class AnalyticsExportService {
  /// Generate a PDF report bundling sales statistics, customer insights and
  /// the top-routes table.
  ///
  /// Throws [ArgumentError] if [startDate] is after [endDate].
  Future<Uint8List> generateAnalyticsPDF({
    required SalesStatistics sales,
    required CustomerInsights insights,
    required List<RoutePerformance> topRoutes,
    required DateTime startDate,
    required DateTime endDate,
    Map<String, int>? segmentation,
    int? churnRisk,
    String title = 'Analytics-Report',
    PdfPageFormat pageFormat = PdfPageFormat.a4,
  }) async {
    if (startDate.isAfter(endDate)) {
      throw ArgumentError('startDate must be on or before endDate');
    }
    try {
      final pdf = pw.Document();
      pdf.addPage(
        pw.MultiPage(
          pageFormat: pageFormat,
          margin: const pw.EdgeInsets.all(32),
          build: (context) => [
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
            pw.SizedBox(height: 8),
            pw.Text(
              'Zeitraum: ${_formatDate(startDate)} – ${_formatDate(endDate)}',
              style: const pw.TextStyle(fontSize: 12),
            ),
            pw.SizedBox(height: 16),
            pw.Header(level: 1, child: pw.Text('Verkaufskennzahlen')),
            _buildSalesTable(sales),
            pw.SizedBox(height: 16),
            pw.Header(level: 1, child: pw.Text('Kundenverhalten')),
            _buildCustomerTable(insights, segmentation, churnRisk),
            pw.SizedBox(height: 16),
            pw.Header(level: 1, child: pw.Text('Top-Routen nach Umsatz')),
            if (topRoutes.isEmpty)
              pw.Text('Keine Routenumsätze im gewählten Zeitraum.')
            else
              _buildTopRoutesTable(topRoutes),
            pw.SizedBox(height: 16),
            if (sales.revenueTimeline.isNotEmpty) ...[
              pw.Header(level: 1, child: pw.Text('Tägliche Umsätze')),
              _buildRevenueTimelineTable(sales.revenueTimeline),
            ],
            pw.SizedBox(height: 32),
            pw.Divider(),
            pw.Text(
              'Erstellt am ${_formatDateTime(DateTime.now())}',
              style: const pw.TextStyle(fontSize: 10),
            ),
          ],
        ),
      );
      return pdf.save();
    } catch (e) {
      log('Error generating analytics PDF: $e');
      rethrow;
    }
  }

  /// Generate a CSV containing the daily revenue/orders timeline.
  String generateRevenueTimelineCSV(SalesStatistics sales) {
    final rows = <List<String>>[
      ['Datum', 'Umsatz (EUR)', 'Bestellungen'],
    ];
    final ordersByDate = sales.ordersByDate;
    for (final entry in sales.revenueTimeline) {
      rows.add([
        entry.key,
        entry.value.toStringAsFixed(2),
        (ordersByDate[entry.key] ?? 0).toString(),
      ]);
    }
    return csv.encode(rows);
  }

  /// Generate a CSV listing all routes with revenue and order counts.
  String generateRouteBreakdownCSV(
    SalesStatistics sales, {
    List<RoutePerformance> performances = const [],
  }) {
    final nameById = {
      for (final perf in performances) perf.routeId.toString(): perf.routeName,
    };
    final rows = <List<String>>[
      ['Route ID', 'Route Name', 'Umsatz (EUR)', 'Bestellungen'],
    ];
    final routeIds = <String>{
      ...sales.revenueByRoute.keys,
      ...sales.ordersByRoute.keys,
    }.toList()
      ..sort((a, b) {
        final revA = sales.revenueByRoute[a] ?? 0;
        final revB = sales.revenueByRoute[b] ?? 0;
        return revB.compareTo(revA);
      });
    for (final id in routeIds) {
      rows.add([
        id,
        nameById[id] ?? 'Route #$id',
        (sales.revenueByRoute[id] ?? 0.0).toStringAsFixed(2),
        (sales.ordersByRoute[id] ?? 0).toString(),
      ]);
    }
    return csv.encode(rows);
  }

  /// Compose a filename like `analytics_revenue_20260518_1330.csv`.
  String generateExportFilename({
    required String type,
    required String slug,
  }) {
    final now = DateTime.now();
    final date =
        '${now.year}${_pad(now.month)}${_pad(now.day)}_${_pad(now.hour)}${_pad(now.minute)}';
    final sanitized = slug
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
    return 'analytics_${sanitized.isEmpty ? 'export' : sanitized}_$date.$type';
  }

  // ---------------------------------------------------------------------------
  // PDF helpers
  // ---------------------------------------------------------------------------

  pw.Widget _buildSalesTable(SalesStatistics sales) {
    return pw.Table(
      border: pw.TableBorder.all(),
      children: [
        _kvRow('Umsatz gesamt', sales.formattedRevenue, header: true),
        _kvRow('Bestellungen', sales.totalOrders.toString()),
        _kvRow('Ø Bestellwert', sales.formattedAverageOrderValue),
        _kvRow('Anzahl Routen mit Umsatz', sales.routeCount.toString()),
      ],
    );
  }

  pw.Widget _buildCustomerTable(
    CustomerInsights insights,
    Map<String, int>? segmentation,
    int? churnRisk,
  ) {
    final seg = segmentation ?? const {};
    return pw.Table(
      border: pw.TableBorder.all(),
      children: [
        _kvRow('Kunden gesamt', insights.totalCustomers.toString(), header: true),
        _kvRow('Neukunden', insights.newCustomers.toString()),
        _kvRow('Wiederkehrend', insights.returningCustomers.toString()),
        _kvRow('Repeat-Rate', insights.formattedRepeatPurchaseRate),
        _kvRow('Ø LTV', insights.formattedLifetimeValue),
        _kvRow('Retention-Note', insights.retentionGrade),
        if (churnRisk != null) _kvRow('Churn-Risiko', churnRisk.toString()),
        if (seg.isNotEmpty) ...[
          _kvRow('High-Value Kunden', (seg['high'] ?? 0).toString()),
          _kvRow('Medium-Value Kunden', (seg['medium'] ?? 0).toString()),
          _kvRow('Low-Value Kunden', (seg['low'] ?? 0).toString()),
        ],
      ],
    );
  }

  pw.Widget _buildTopRoutesTable(List<RoutePerformance> routes) {
    return pw.Table(
      border: pw.TableBorder.all(),
      columnWidths: {
        0: const pw.FixedColumnWidth(40),
        1: const pw.FlexColumnWidth(3),
        2: const pw.FlexColumnWidth(2),
        3: const pw.FlexColumnWidth(2),
        4: const pw.FlexColumnWidth(2),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            _th('#'),
            _th('Route'),
            _th('Umsatz'),
            _th('Verkäufe'),
            _th('Ø ★'),
          ],
        ),
        for (var i = 0; i < routes.length; i++)
          pw.TableRow(
            children: [
              _td('${i + 1}'),
              _td(routes[i].routeName),
              _td(routes[i].formattedRevenue),
              _td(routes[i].totalSales.toString()),
              _td(routes[i].formattedRating),
            ],
          ),
      ],
    );
  }

  pw.Widget _buildRevenueTimelineTable(
    List<MapEntry<String, double>> timeline,
  ) {
    return pw.Table(
      border: pw.TableBorder.all(),
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [_th('Datum'), _th('Umsatz')],
        ),
        for (final entry in timeline)
          pw.TableRow(
            children: [
              _td(entry.key),
              _td('€${entry.value.toStringAsFixed(2)}'),
            ],
          ),
      ],
    );
  }

  pw.TableRow _kvRow(String label, String value, {bool header = false}) {
    final style = header
        ? pw.TextStyle(fontWeight: pw.FontWeight.bold)
        : const pw.TextStyle();
    return pw.TableRow(
      decoration: header
          ? const pw.BoxDecoration(color: PdfColors.grey200)
          : null,
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(6),
          child: pw.Text(label, style: style),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(6),
          child: pw.Text(value, style: style),
        ),
      ],
    );
  }

  pw.Widget _th(String text) => pw.Padding(
        padding: const pw.EdgeInsets.all(6),
        child: pw.Text(
          text,
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
        ),
      );

  pw.Widget _td(String text) => pw.Padding(
        padding: const pw.EdgeInsets.all(6),
        child: pw.Text(text, style: const pw.TextStyle(fontSize: 10)),
      );

  String _formatDate(DateTime d) =>
      '${_pad(d.day)}.${_pad(d.month)}.${d.year}';

  String _formatDateTime(DateTime d) =>
      '${_formatDate(d)} ${_pad(d.hour)}:${_pad(d.minute)}';

  String _pad(int v) => v.toString().padLeft(2, '0');
}

// Web-only export menu: renders a PopupMenuButton and triggers a browser
// download via dart:html. Mirrors `CommissionExportWidget`.
// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:html' as html show AnchorElement, Blob, Url, document;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../data/providers/analytics_provider.dart';
import '../../../../data/services/analytics/analytics_export_service.dart';

/// Renders an export icon with menu (PDF / Revenue CSV / Routes CSV).
///
/// Uses the loaded `AnalyticsProvider` state — no extra Supabase round-trips
/// — so the export reflects exactly what the user sees on screen.
class AnalyticsExportButton extends StatefulWidget {
  const AnalyticsExportButton({super.key});

  @override
  State<AnalyticsExportButton> createState() => _AnalyticsExportButtonState();
}

class _AnalyticsExportButtonState extends State<AnalyticsExportButton> {
  final AnalyticsExportService _service = AnalyticsExportService();
  bool _isExporting = false;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.download),
      tooltip: 'Analytics exportieren',
      enabled: !_isExporting,
      onSelected: (value) => _handle(context, value),
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: 'pdf',
          child: Row(
            children: [
              Icon(Icons.picture_as_pdf, color: Colors.red),
              SizedBox(width: 8),
              Text('PDF-Bericht (kompakt)'),
            ],
          ),
        ),
        PopupMenuDivider(),
        PopupMenuItem(
          value: 'csv_timeline',
          child: Row(
            children: [
              Icon(Icons.timeline, color: Colors.blue),
              SizedBox(width: 8),
              Text('Umsatz-Timeline als CSV'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'csv_routes',
          child: Row(
            children: [
              Icon(Icons.alt_route, color: Colors.green),
              SizedBox(width: 8),
              Text('Routen-Aufschlüsselung als CSV'),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _handle(BuildContext context, String action) async {
    final provider = context.read<AnalyticsProvider>();
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _isExporting = true);
    try {
      switch (action) {
        case 'pdf':
          await _exportPDF(provider);
          break;
        case 'csv_timeline':
          _exportTimelineCsv(provider);
          break;
        case 'csv_routes':
          _exportRoutesCsv(provider);
          break;
      }
      if (mounted) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Export gestartet.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('Export fehlgeschlagen: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<void> _exportPDF(AnalyticsProvider provider) async {
    final df = DateFormat('yyyyMMdd');
    final bytes = await _service.generateAnalyticsPDF(
      sales: provider.sales,
      insights: provider.customerInsights,
      topRoutes: provider.topRoutes,
      startDate: provider.startDate,
      endDate: provider.endDate,
      segmentation: provider.segmentation,
      churnRisk: provider.churnRisk,
      title:
          'Analytics ${df.format(provider.startDate)}–${df.format(provider.endDate)}',
    );
    final filename = _service.generateExportFilename(
      type: 'pdf',
      slug: 'report_${df.format(provider.startDate)}_${df.format(provider.endDate)}',
    );
    _download(bytes, filename, 'application/pdf');
  }

  void _exportTimelineCsv(AnalyticsProvider provider) {
    final csvContent = _service.generateRevenueTimelineCSV(provider.sales);
    final bytes = Uint8List.fromList(csvContent.codeUnits);
    final filename = _service.generateExportFilename(
      type: 'csv',
      slug: 'revenue_timeline',
    );
    _download(bytes, filename, 'text/csv');
  }

  void _exportRoutesCsv(AnalyticsProvider provider) {
    final csvContent = _service.generateRouteBreakdownCSV(
      provider.sales,
      performances: provider.topRoutes,
    );
    final bytes = Uint8List.fromList(csvContent.codeUnits);
    final filename = _service.generateExportFilename(
      type: 'csv',
      slug: 'route_breakdown',
    );
    _download(bytes, filename, 'text/csv');
  }

  void _download(Uint8List bytes, String filename, String mimeType) {
    final blob = html.Blob([bytes], mimeType);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.document.createElement('a') as html.AnchorElement
      ..href = url
      ..style.display = 'none'
      ..download = filename;
    html.document.body!.children.add(anchor);
    anchor.click();
    html.document.body!.children.remove(anchor);
    html.Url.revokeObjectUrl(url);
  }
}

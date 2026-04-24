import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:whisky_hikes/data/providers/commission_provider.dart';
import 'package:whisky_hikes/data/services/commission/commission_export_service.dart';
import 'package:whisky_hikes/data/services/commission/commission_service.dart';
import 'dart:typed_data';
import 'dart:html' as html show Blob, Url, AnchorElement, document;

/// Widget für den Export von Commission-Daten (PDF/CSV)
class CommissionExportWidget extends StatefulWidget {
  final String companyId;

  const CommissionExportWidget({super.key, required this.companyId});

  @override
  State<CommissionExportWidget> createState() => _CommissionExportWidgetState();
}

class _CommissionExportWidgetState extends State<CommissionExportWidget> {
  late final CommissionExportService _exportService;
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _exportService = CommissionExportService(
      CommissionService(Supabase.instance.client),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.download, color: Theme.of(context).colorScheme.primary),
      tooltip: 'Export',
      enabled: !_isExporting,
      onSelected: (value) => _handleExport(context, value),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'pdf',
          child: Row(
            children: [
              Icon(Icons.picture_as_pdf, color: Colors.red),
              SizedBox(width: 8),
              Text('Als PDF exportieren'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'csv',
          child: Row(
            children: [
              Icon(Icons.table_chart, color: Colors.green),
              SizedBox(width: 8),
              Text('Als CSV exportieren'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'pdf_filtered',
          child: Row(
            children: [
              Icon(Icons.filter_alt, color: Colors.blue),
              SizedBox(width: 8),
              Text('Gefiltert als PDF'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'csv_filtered',
          child: Row(
            children: [
              Icon(Icons.filter_list, color: Colors.orange),
              SizedBox(width: 8),
              Text('Gefiltert als CSV'),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _handleExport(BuildContext context, String exportType) async {
    setState(() {
      _isExporting = true;
    });

    try {
      final provider = context.read<CommissionProvider>();

      switch (exportType) {
        case 'pdf':
          await _exportPDF(provider, includeFilters: false);
          break;
        case 'csv':
          await _exportCSV(provider, includeFilters: false);
          break;
        case 'pdf_filtered':
          await _exportPDF(provider, includeFilters: true);
          break;
        case 'csv_filtered':
          await _exportCSV(provider, includeFilters: true);
          break;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export erfolgreich abgeschlossen'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fehler beim Export: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  Future<void> _exportPDF(
    CommissionProvider provider, {
    required bool includeFilters,
  }) async {
    final DateTime? startDate;
    final DateTime? endDate;
    final String title;

    if (includeFilters && provider.hasActiveFilters) {
      startDate = provider.startDate;
      endDate = provider.endDate;
      title =
          'Gefilterte Provisionen (${provider.filteredCommissions.length} Einträge)';
    } else {
      startDate = null;
      endDate = null;
      title = 'Alle Provisionen (${provider.commissions.length} Einträge)';
    }

    final pdfBytes = await _exportService.generateCommissionPDF(
      companyId: widget.companyId,
      title: title,
      startDate: startDate,
      endDate: endDate,
      includeStatistics: true,
    );

    final filename = _exportService.generateExportFilename(
      type: 'pdf',
      companyId: widget.companyId,
      title: includeFilters ? 'filtered_report' : 'full_report',
    );

    await _downloadFile(pdfBytes, filename, 'application/pdf');
  }

  Future<void> _exportCSV(
    CommissionProvider provider, {
    required bool includeFilters,
  }) async {
    final DateTime? startDate;
    final DateTime? endDate;

    if (includeFilters && provider.hasActiveFilters) {
      startDate = provider.startDate;
      endDate = provider.endDate;
    } else {
      startDate = null;
      endDate = null;
    }

    final csvContent = await _exportService.generateCommissionCSV(
      companyId: widget.companyId,
      startDate: startDate,
      endDate: endDate,
    );

    final filename = _exportService.generateExportFilename(
      type: 'csv',
      companyId: widget.companyId,
      title: includeFilters ? 'filtered_data' : 'full_data',
    );

    // Convert string to bytes for download
    final bytes = Uint8List.fromList(csvContent.codeUnits);
    await _downloadFile(bytes, filename, 'text/csv');
  }

  Future<void> _downloadFile(
    Uint8List bytes,
    String filename,
    String mimeType,
  ) async {
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.document.createElement('a') as html.AnchorElement
      ..href = url
      ..style.display = 'none'
      ..download = filename;
    html.document.body!.children.add(anchor);

    // trigger download
    anchor.click();

    // cleanup
    html.document.body!.children.remove(anchor);
    html.Url.revokeObjectUrl(url);
  }
}

/// Extension for checking if filters are active
extension CommissionProviderFilters on CommissionProvider {
  bool get hasActiveFilters {
    return startDate != null ||
        endDate != null ||
        searchTerm.isNotEmpty ||
        currentFilter != 'all';
  }
}

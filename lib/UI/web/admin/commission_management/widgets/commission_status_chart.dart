import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:whisky_hikes/data/services/commission/commission_chart_service.dart';
import 'package:whisky_hikes/domain/models/commission.dart';
import 'package:whisky_hikes/UI/core/responsive_layout.dart';

/// Widget für Status Distribution Pie Chart der Commissions
class CommissionStatusChart extends StatefulWidget {
  final String companyId;
  final CommissionStatusDistributionData data;
  final VoidCallback? onRefresh;

  const CommissionStatusChart({
    super.key,
    required this.companyId,
    required this.data,
    this.onRefresh,
  });

  @override
  State<CommissionStatusChart> createState() => _CommissionStatusChartState();
}

class _CommissionStatusChartState extends State<CommissionStatusChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 16),
            _buildChart(context),
            if (widget.data.totalCommissions > 0) ...[
              const SizedBox(height: 16),
              _buildLegend(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Status-Verteilung',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(
              'Commission-Status Übersicht',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        if (widget.onRefresh != null)
          IconButton(
            onPressed: widget.onRefresh,
            icon: const Icon(Icons.refresh),
            tooltip: 'Aktualisieren',
          ),
      ],
    );
  }

  Widget _buildChart(BuildContext context) {
    if (widget.data.totalCommissions == 0) {
      return Container(
        height: 300,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pie_chart_outline,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'Keine Commissions vorhanden',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Es wurden noch keine Commissions erstellt.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ResponsiveLayout(
      mobile: SizedBox(height: 250, child: _buildPieChart(context)),
      tablet: SizedBox(height: 300, child: _buildPieChart(context)),
      desktop: SizedBox(height: 350, child: _buildPieChart(context)),
    );
  }

  Widget _buildPieChart(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        pieTouchResponse == null ||
                        pieTouchResponse.touchedSection == null) {
                      touchedIndex = -1;
                      return;
                    }
                    touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              borderData: FlBorderData(show: false),
              sectionsSpace: 2,
              centerSpaceRadius: 60,
              sections: _createPieSections(context),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 1,
          child: _buildStatusSummary(context),
        ),
      ],
    );
  }

  Widget _buildStatusSummary(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Zusammenfassung',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        ...CommissionStatus.values.map((status) {
          final count = widget.data.statusCounts[status] ?? 0;
          final amount = widget.data.statusAmounts[status] ?? 0.0;
          
          if (count == 0) return const SizedBox.shrink();
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildStatusSummaryItem(context, status, count, amount),
          );
        }),
      ],
    );
  }

  Widget _buildStatusSummaryItem(
    BuildContext context,
    CommissionStatus status,
    int count,
    double amount,
  ) {
    final percentage = (count / widget.data.totalCommissions * 100);
    
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: _getStatusColor(status),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getStatusDisplayName(status),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '$count (${percentage.toStringAsFixed(1)}%) • €${amount.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegend(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildLegendItem(
            context,
            'Total',
            '${widget.data.totalCommissions}',
            Icons.receipt_long,
          ),
          _buildLegendItem(
            context,
            'Gesamt',
            '€${widget.data.totalAmount.toStringAsFixed(2)}',
            Icons.euro,
          ),
          _buildLegendItem(
            context,
            'Offen',
            '${widget.data.statusCounts[CommissionStatus.pending] ?? 0}',
            Icons.schedule,
          ),
          _buildLegendItem(
            context,
            'Bezahlt',
            '${widget.data.statusCounts[CommissionStatus.paid] ?? 0}',
            Icons.check_circle,
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  List<PieChartSectionData> _createPieSections(BuildContext context) {
    final sections = <PieChartSectionData>[];
    int sectionIndex = 0;

    for (final status in CommissionStatus.values) {
      final count = widget.data.statusCounts[status] ?? 0;
      if (count == 0) continue;

      final percentage = count / widget.data.totalCommissions * 100;
      final isTouched = sectionIndex == touchedIndex;
      
      sections.add(
        PieChartSectionData(
          color: _getStatusColor(status),
          value: count.toDouble(),
          title: isTouched ? '${percentage.toStringAsFixed(1)}%' : '',
          radius: isTouched ? 80 : 70,
          titleStyle: TextStyle(
            fontSize: isTouched ? 16 : 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          badgeWidget: isTouched
              ? Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    '$count',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : null,
          badgePositionPercentageOffset: 1.2,
        ),
      );
      sectionIndex++;
    }

    return sections;
  }

  Color _getStatusColor(CommissionStatus status) {
    switch (status) {
      case CommissionStatus.pending:
        return Colors.orange;
      case CommissionStatus.calculated:
        return Colors.blue;
      case CommissionStatus.paid:
        return Colors.green;
      case CommissionStatus.cancelled:
        return Colors.red;
    }
  }

  String _getStatusDisplayName(CommissionStatus status) {
    switch (status) {
      case CommissionStatus.pending:
        return 'Ausstehend';
      case CommissionStatus.calculated:
        return 'Berechnet';
      case CommissionStatus.paid:
        return 'Bezahlt';
      case CommissionStatus.cancelled:
        return 'Storniert';
    }
  }
}
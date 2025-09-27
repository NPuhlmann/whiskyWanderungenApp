import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:whisky_hikes/data/services/commission/commission_chart_service.dart';
import 'package:whisky_hikes/UI/core/responsive_layout.dart';

/// Widget für Timeline Chart der Commission-Entwicklung
class CommissionTimelineChart extends StatefulWidget {
  final String companyId;
  final CommissionTimelineData data;
  final VoidCallback? onRefresh;

  const CommissionTimelineChart({
    super.key,
    required this.companyId,
    required this.data,
    this.onRefresh,
  });

  @override
  State<CommissionTimelineChart> createState() => _CommissionTimelineChartState();
}

class _CommissionTimelineChartState extends State<CommissionTimelineChart> {
  int? touchedIndex;

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
            if (widget.data.dataPoints.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildSummary(context),
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
              'Commission-Entwicklung',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(
              _getPeriodDisplayName(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        Row(
          children: [
            _buildPeriodToggle(context),
            const SizedBox(width: 8),
            if (widget.onRefresh != null)
              IconButton(
                onPressed: widget.onRefresh,
                icon: const Icon(Icons.refresh),
                tooltip: 'Aktualisieren',
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildPeriodToggle(BuildContext context) {
    return SegmentedButton<ChartPeriod>(
      segments: const [
        ButtonSegment(
          value: ChartPeriod.weekly,
          label: Text('Woche'),
          icon: Icon(Icons.view_week),
        ),
        ButtonSegment(
          value: ChartPeriod.monthly,
          label: Text('Monat'),
          icon: Icon(Icons.calendar_month),
        ),
      ],
      selected: {widget.data.period},
      onSelectionChanged: (Set<ChartPeriod> selected) {
        // TODO: Implement period change callback
      },
    );
  }

  Widget _buildChart(BuildContext context) {
    if (widget.data.dataPoints.isEmpty) {
      return Container(
        height: 300,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'Keine Daten verfügbar',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Für den ausgewählten Zeitraum liegen keine Commission-Daten vor.',
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
      mobile: SizedBox(height: 250, child: _buildLineChart(context)),
      tablet: SizedBox(height: 300, child: _buildLineChart(context)),
      desktop: SizedBox(height: 350, child: _buildLineChart(context)),
    );
  }

  Widget _buildLineChart(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: _calculateHorizontalInterval(),
          verticalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: colorScheme.outline.withOpacity(0.2),
              strokeWidth: 1,
            );
          },
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: colorScheme.outline.withOpacity(0.2),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) => _buildBottomTitle(value.toInt(), context),
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: _calculateHorizontalInterval(),
              reservedSize: 60,
              getTitlesWidget: (value, meta) => _buildLeftTitle(value, context),
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
        ),
        minX: 0,
        maxX: (widget.data.dataPoints.length - 1).toDouble(),
        minY: 0,
        maxY: _calculateMaxY(),
        lineBarsData: [
          LineChartBarData(
            spots: _createSpots(),
            isCurved: true,
            gradient: LinearGradient(
              colors: [
                colorScheme.primary,
                colorScheme.primary.withOpacity(0.8),
              ],
            ),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: colorScheme.primary,
                  strokeWidth: 2,
                  strokeColor: colorScheme.surface,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  colorScheme.primary.withOpacity(0.3),
                  colorScheme.primary.withOpacity(0.1),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (touchedSpot) => colorScheme.inverseSurface,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((touchedSpot) {
                final dataPoint = widget.data.dataPoints[touchedSpot.x.toInt()];
                return LineTooltipItem(
                  '${dataPoint.label}\n€${dataPoint.amount.toStringAsFixed(2)}\n${dataPoint.count} Commission${dataPoint.count != 1 ? 's' : ''}',
                  TextStyle(
                    color: colorScheme.onInverseSurface,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSummary(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem(
            context,
            'Gesamt',
            '€${widget.data.totalAmount.toStringAsFixed(2)}',
            Icons.euro,
          ),
          _buildSummaryItem(
            context,
            'Anzahl',
            '${widget.data.totalCommissions}',
            Icons.receipt_long,
          ),
          _buildSummaryItem(
            context,
            'Durchschnitt',
            '€${(widget.data.totalAmount / widget.data.totalCommissions).toStringAsFixed(2)}',
            Icons.trending_up,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
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

  Widget _buildBottomTitle(int index, BuildContext context) {
    if (index < 0 || index >= widget.data.dataPoints.length) {
      return const SizedBox.shrink();
    }

    final dataPoint = widget.data.dataPoints[index];
    final isCompact = MediaQuery.of(context).size.width < 600;
    
    // Show every nth label on mobile to avoid crowding
    if (isCompact && index % 2 != 0) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        dataPoint.label,
        style: Theme.of(context).textTheme.bodySmall,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildLeftTitle(double value, BuildContext context) {
    return Text(
      '€${(value / 1000).toStringAsFixed(0)}k',
      style: Theme.of(context).textTheme.bodySmall,
      textAlign: TextAlign.right,
    );
  }

  List<FlSpot> _createSpots() {
    return widget.data.dataPoints.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.amount);
    }).toList();
  }

  double _calculateMaxY() {
    if (widget.data.dataPoints.isEmpty) return 100;
    
    final maxAmount = widget.data.dataPoints
        .map((point) => point.amount)
        .reduce((a, b) => a > b ? a : b);
    
    // Add 20% padding at the top
    return maxAmount * 1.2;
  }

  double _calculateHorizontalInterval() {
    final maxY = _calculateMaxY();
    return maxY / 5; // 5 horizontal lines
  }

  String _getPeriodDisplayName() {
    switch (widget.data.period) {
      case ChartPeriod.daily:
        return 'Tägliche Übersicht';
      case ChartPeriod.weekly:
        return 'Wöchentliche Übersicht';
      case ChartPeriod.monthly:
        return 'Monatliche Übersicht';
      case ChartPeriod.yearly:
        return 'Jährliche Übersicht';
    }
  }
}
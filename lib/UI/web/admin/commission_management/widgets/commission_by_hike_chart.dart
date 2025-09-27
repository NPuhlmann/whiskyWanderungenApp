import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:whisky_hikes/data/services/commission/commission_chart_service.dart';
import 'package:whisky_hikes/UI/core/responsive_layout.dart';

/// Widget für Bar Chart der Commission-Verteilung nach Hikes
class CommissionByHikeChart extends StatefulWidget {
  final String companyId;
  final CommissionByHikeData data;
  final VoidCallback? onRefresh;

  const CommissionByHikeChart({
    super.key,
    required this.companyId,
    required this.data,
    this.onRefresh,
  });

  @override
  State<CommissionByHikeChart> createState() => _CommissionByHikeChartState();
}

class _CommissionByHikeChartState extends State<CommissionByHikeChart> {
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
            if (widget.data.hikeData.isNotEmpty) ...[
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
              'Top Hikes',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(
              'Commission-Verteilung nach Wanderrouten',
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
    if (widget.data.hikeData.isEmpty) {
      return Container(
        height: 300,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'Keine Hike-Daten verfügbar',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Es wurden noch keine Commissions für Hikes erstellt.',
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
      mobile: SizedBox(height: 300, child: _buildBarChart(context)),
      tablet: SizedBox(height: 350, child: _buildBarChart(context)),
      desktop: SizedBox(height: 400, child: _buildBarChart(context)),
    );
  }

  Widget _buildBarChart(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: _calculateMaxY(),
        minY: 0,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: _calculateHorizontalInterval(),
          getDrawingHorizontalLine: (value) {
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
              reservedSize: 60,
              getTitlesWidget: (value, meta) => _buildBottomTitle(value.toInt(), context),
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: _calculateHorizontalInterval(),
              reservedSize: 50,
              getTitlesWidget: (value, meta) => _buildLeftTitle(value, context),
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
        ),
        barGroups: _createBarGroups(context),
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (group) => colorScheme.inverseSurface,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final hikeData = widget.data.hikeData[group.x.toInt()];
              return BarTooltipItem(
                '${hikeData.hikeName}\n€${hikeData.commissionAmount.toStringAsFixed(2)}\n${hikeData.commissionCount} Commission${hikeData.commissionCount != 1 ? 's' : ''}',
                TextStyle(
                  color: colorScheme.onInverseSurface,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
          touchCallback: (FlTouchEvent event, barTouchResponse) {
            setState(() {
              if (!event.isInterestedForInteractions ||
                  barTouchResponse == null ||
                  barTouchResponse.spot == null) {
                touchedIndex = -1;
                return;
              }
              touchedIndex = barTouchResponse.spot!.touchedBarGroupIndex;
            });
          },
        ),
      ),
    );
  }

  Widget _buildSummary(BuildContext context) {
    final topHike = widget.data.hikeData.first;
    final averageCommission = widget.data.totalAmount / widget.data.hikeData.length;
    
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
            'Top Hike',
            topHike.hikeName,
            Icons.hiking,
          ),
          _buildSummaryItem(
            context,
            'Beste Commission',
            '€${topHike.commissionAmount.toStringAsFixed(2)}',
            Icons.trending_up,
          ),
          _buildSummaryItem(
            context,
            'Durchschnitt',
            '€${averageCommission.toStringAsFixed(2)}',
            Icons.analytics,
          ),
          _buildSummaryItem(
            context,
            'Anzahl Hikes',
            '${widget.data.hikeData.length}',
            Icons.route,
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
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildBottomTitle(int index, BuildContext context) {
    if (index < 0 || index >= widget.data.hikeData.length) {
      return const SizedBox.shrink();
    }

    final hikeData = widget.data.hikeData[index];
    final isCompact = MediaQuery.of(context).size.width < 600;
    
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isCompact ? 'H${hikeData.hikeId}' : hikeData.hikeName,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
            maxLines: isCompact ? 1 : 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (!isCompact)
            Text(
              '${hikeData.commissionCount}x',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 10,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLeftTitle(double value, BuildContext context) {
    if (value == 0) return const SizedBox.shrink();
    
    return Text(
      '€${(value / 1000).toStringAsFixed(0)}k',
      style: Theme.of(context).textTheme.bodySmall,
      textAlign: TextAlign.right,
    );
  }

  List<BarChartGroupData> _createBarGroups(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return widget.data.hikeData.asMap().entries.map((entry) {
      final index = entry.key;
      final hikeData = entry.value;
      final isTouched = index == touchedIndex;
      
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: hikeData.commissionAmount,
            color: isTouched 
                ? colorScheme.primary 
                : colorScheme.primary.withOpacity(0.8),
            width: isTouched ? 20 : 16,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
            gradient: LinearGradient(
              colors: [
                colorScheme.primary,
                colorScheme.primary.withOpacity(0.7),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ],
        showingTooltipIndicators: isTouched ? [0] : [],
      );
    }).toList();
  }

  double _calculateMaxY() {
    if (widget.data.hikeData.isEmpty) return 100;
    
    final maxAmount = widget.data.hikeData
        .map((hike) => hike.commissionAmount)
        .reduce((a, b) => a > b ? a : b);
    
    // Add 20% padding at the top
    return maxAmount * 1.2;
  }

  double _calculateHorizontalInterval() {
    final maxY = _calculateMaxY();
    return maxY / 5; // 5 horizontal lines
  }
}
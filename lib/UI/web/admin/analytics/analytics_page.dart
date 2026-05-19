import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../data/providers/analytics_provider.dart';
import '../../../../domain/models/analytics/customer_insights.dart';
import '../../../../domain/models/analytics/route_performance.dart';
import '../../../../domain/models/analytics/sales_statistics.dart';
import 'analytics_export_button.dart';

/// Admin-Seite `/admin/analytics`. Bündelt Sales- und Customer-Analytics
/// mit Date-Range-Filter, KPI-Karten, Top-Routes-Liste und einer
/// Revenue-Timeline (fl_chart).
class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnalyticsProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics & Berichte'),
        backgroundColor: Colors.amber[800],
        foregroundColor: Colors.white,
        actions: const [
          AnalyticsExportButton(),
          SizedBox(width: 8),
          _RefreshButton(),
          SizedBox(width: 8),
        ],
      ),
      body: Consumer<AnalyticsProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              _Toolbar(provider: provider),
              if (provider.error != null)
                _ErrorBanner(message: provider.error!),
              Expanded(child: _Body(provider: provider)),
            ],
          );
        },
      ),
    );
  }
}

class _Toolbar extends StatelessWidget {
  final AnalyticsProvider provider;
  const _Toolbar({required this.provider});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat.yMMMd('de_DE');
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          OutlinedButton.icon(
            icon: const Icon(Icons.date_range),
            label: Text(
              '${fmt.format(provider.startDate)}  –  ${fmt.format(provider.endDate)}',
            ),
            onPressed: () => _pickRange(context, provider),
          ),
          _PresetButton(label: '7T', days: 7, provider: provider),
          _PresetButton(label: '30T', days: 30, provider: provider),
          _PresetButton(label: '90T', days: 90, provider: provider),
          _PresetButton(label: '365T', days: 365, provider: provider),
        ],
      ),
    );
  }

  Future<void> _pickRange(
    BuildContext context,
    AnalyticsProvider provider,
  ) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      initialDateRange: DateTimeRange(
        start: provider.startDate,
        end: provider.endDate,
      ),
    );
    if (picked != null) {
      await provider.setDateRange(
        startDate: picked.start,
        endDate: picked.end,
      );
    }
  }
}

class _PresetButton extends StatelessWidget {
  final String label;
  final int days;
  final AnalyticsProvider provider;
  const _PresetButton({
    required this.label,
    required this.days,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        final now = DateTime.now();
        provider.setDateRange(
          startDate: now.subtract(Duration(days: days)),
          endDate: now,
        );
      },
      child: Text('Letzte $label'),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.red.shade100,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 8),
          Expanded(child: Text(message)),
          TextButton(
            onPressed: () => context.read<AnalyticsProvider>().clearError(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final AnalyticsProvider provider;
  const _Body({required this.provider});

  @override
  Widget build(BuildContext context) {
    if (provider.isLoading && provider.sales.totalOrders == 0) {
      return const Center(child: CircularProgressIndicator());
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _KpiRow(sales: provider.sales, insights: provider.customerInsights),
        const SizedBox(height: 24),
        _RevenueTimelineCard(sales: provider.sales),
        const SizedBox(height: 24),
        _RouteRevenueChartCard(
          sales: provider.sales,
          performances: provider.topRoutes,
        ),
        const SizedBox(height: 24),
        _SegmentationChartCard(
          segmentation: provider.segmentation,
          churnRisk: provider.churnRisk,
        ),
        const SizedBox(height: 24),
        _CustomerCard(
          insights: provider.customerInsights,
          segmentation: provider.segmentation,
          churnRisk: provider.churnRisk,
        ),
        const SizedBox(height: 24),
        _TopRoutesCard(topRoutes: provider.topRoutes),
      ],
    );
  }
}

class _RefreshButton extends StatelessWidget {
  const _RefreshButton();

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Aktualisieren',
      icon: const Icon(Icons.refresh),
      onPressed: () => context.read<AnalyticsProvider>().load(),
    );
  }
}

class _KpiRow extends StatelessWidget {
  final SalesStatistics sales;
  final CustomerInsights insights;
  const _KpiRow({required this.sales, required this.insights});

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width >= 900;
    final tiles = <Widget>[
      _KpiTile(
        label: 'Umsatz',
        value: sales.formattedRevenue,
        icon: Icons.payments,
        color: Colors.green,
      ),
      _KpiTile(
        label: 'Bestellungen',
        value: '${sales.totalOrders}',
        icon: Icons.shopping_bag,
        color: Colors.blue,
      ),
      _KpiTile(
        label: 'Ø Bestellwert',
        value: sales.formattedAverageOrderValue,
        icon: Icons.trending_up,
        color: Colors.purple,
      ),
      _KpiTile(
        label: 'Kunden gesamt',
        value: '${insights.totalCustomers}',
        icon: Icons.people,
        color: Colors.orange,
      ),
    ];
    if (wide) {
      return Row(
        children: [
          for (final t in tiles) ...[Expanded(child: t), const SizedBox(width: 12)],
        ]..removeLast(),
      );
    }
    return GridView.count(
      crossAxisCount: 2,
      childAspectRatio: 1.6,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: tiles,
    );
  }
}

class _KpiTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _KpiTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.15),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(color: Colors.grey.shade700)),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RevenueTimelineCard extends StatelessWidget {
  final SalesStatistics sales;
  const _RevenueTimelineCard({required this.sales});

  @override
  Widget build(BuildContext context) {
    final timeline = sales.revenueTimeline;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Umsatzentwicklung',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 220,
              child: timeline.isEmpty
                  ? const Center(
                      child: Text('Keine Umsätze im gewählten Zeitraum.'),
                    )
                  : _RevenueChart(timeline: timeline),
            ),
          ],
        ),
      ),
    );
  }
}

class _RevenueChart extends StatelessWidget {
  final List<MapEntry<String, double>> timeline;
  const _RevenueChart({required this.timeline});

  @override
  Widget build(BuildContext context) {
    final spots = <FlSpot>[
      for (int i = 0; i < timeline.length; i++)
        FlSpot(i.toDouble(), timeline[i].value),
    ];
    final maxY = timeline
        .map((e) => e.value)
        .fold<double>(0, (a, b) => a > b ? a : b);
    return LineChart(
      LineChartData(
        minY: 0,
        maxY: maxY == 0 ? 1 : maxY * 1.1,
        gridData: const FlGridData(show: true, drawVerticalLine: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              interval: (timeline.length / 4).clamp(1, 99).toDouble(),
              getTitlesWidget: (value, _) {
                final idx = value.toInt();
                if (idx < 0 || idx >= timeline.length) {
                  return const SizedBox.shrink();
                }
                final iso = timeline[idx].key;
                final parts = iso.split('-');
                return Text(
                  parts.length == 3 ? '${parts[2]}.${parts[1]}' : iso,
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 48,
              getTitlesWidget: (value, _) => Text(
                NumberFormat.compactCurrency(
                  locale: 'de_DE',
                  symbol: '€',
                ).format(value),
                style: const TextStyle(fontSize: 10),
              ),
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.amber.shade800,
            barWidth: 3,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.amber.withValues(alpha: 0.15),
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomerCard extends StatelessWidget {
  final CustomerInsights insights;
  final Map<String, int> segmentation;
  final int churnRisk;
  const _CustomerCard({
    required this.insights,
    required this.segmentation,
    required this.churnRisk,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Kundenverhalten',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _MiniStat(
                  label: 'Neukunden',
                  value: '${insights.newCustomers}',
                ),
                _MiniStat(
                  label: 'Wiederkehrend',
                  value: '${insights.returningCustomers}',
                ),
                _MiniStat(
                  label: 'Repeat-Rate',
                  value:
                      '${(insights.repeatPurchaseRate * 100).toStringAsFixed(1)} %',
                ),
                _MiniStat(
                  label: 'Ø LTV',
                  value: NumberFormat.currency(
                    locale: 'de_DE',
                    symbol: '€',
                  ).format(insights.averageLifetimeValue),
                ),
                _MiniStat(
                  label: 'Churn-Risiko',
                  value: '$churnRisk',
                ),
                _MiniStat(
                  label: 'High-Value',
                  value: '${segmentation['high'] ?? 0}',
                ),
                _MiniStat(
                  label: 'Medium-Value',
                  value: '${segmentation['medium'] ?? 0}',
                ),
                _MiniStat(
                  label: 'Low-Value',
                  value: '${segmentation['low'] ?? 0}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  const _MiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _TopRoutesCard extends StatelessWidget {
  final List<RoutePerformance> topRoutes;
  const _TopRoutesCard({required this.topRoutes});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Top-Routen nach Umsatz',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (topRoutes.isEmpty)
              const Text('Keine Routen im gewählten Zeitraum.')
            else
              ...topRoutes.asMap().entries.map(
                (entry) => _TopRouteTile(
                  index: entry.key,
                  performance: entry.value,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TopRouteTile extends StatelessWidget {
  final int index;
  final RoutePerformance performance;
  const _TopRouteTile({required this.index, required this.performance});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'de_DE', symbol: '€');
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: Colors.amber.shade100,
        child: Text('${index + 1}'),
      ),
      title: Text(performance.routeName),
      subtitle: Text(
        '${performance.totalSales} Verkäufe • '
        'Ø ${performance.averageRating.toStringAsFixed(1)} ★',
      ),
      trailing: Text(
        fmt.format(performance.totalRevenue),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _RouteRevenueChartCard extends StatelessWidget {
  final SalesStatistics sales;
  final List<RoutePerformance> performances;
  const _RouteRevenueChartCard({
    required this.sales,
    required this.performances,
  });

  @override
  Widget build(BuildContext context) {
    final entries = sales.getTopRoutesByRevenue(6);
    final nameById = {
      for (final p in performances) p.routeId.toString(): p.routeName,
    };
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Umsatz je Route',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 260,
              child: entries.isEmpty
                  ? const Center(
                      child: Text('Keine Umsätze im gewählten Zeitraum.'),
                    )
                  : _RouteRevenueBarChart(
                      entries: entries,
                      nameById: nameById,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RouteRevenueBarChart extends StatelessWidget {
  final List<MapEntry<String, double>> entries;
  final Map<String, String> nameById;
  const _RouteRevenueBarChart({
    required this.entries,
    required this.nameById,
  });

  @override
  Widget build(BuildContext context) {
    final maxRevenue = entries
        .map((e) => e.value)
        .fold<double>(0, (a, b) => a > b ? a : b);
    return BarChart(
      BarChartData(
        maxY: maxRevenue == 0 ? 1 : maxRevenue * 1.15,
        alignment: BarChartAlignment.spaceAround,
        gridData: const FlGridData(show: true, drawVerticalLine: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 56,
              getTitlesWidget: (value, _) {
                final idx = value.toInt();
                if (idx < 0 || idx >= entries.length) {
                  return const SizedBox.shrink();
                }
                final routeId = entries[idx].key;
                final label = nameById[routeId] ?? '#$routeId';
                final short = label.length > 14
                    ? '${label.substring(0, 12)}…'
                    : label;
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    short,
                    style: const TextStyle(fontSize: 10),
                    textAlign: TextAlign.center,
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 48,
              getTitlesWidget: (value, _) => Text(
                NumberFormat.compactCurrency(locale: 'de_DE', symbol: '€')
                    .format(value),
                style: const TextStyle(fontSize: 10),
              ),
            ),
          ),
        ),
        barGroups: [
          for (var i = 0; i < entries.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: entries[i].value,
                  color: Colors.amber.shade700,
                  width: 18,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _SegmentationChartCard extends StatelessWidget {
  final Map<String, int> segmentation;
  final int churnRisk;
  const _SegmentationChartCard({
    required this.segmentation,
    required this.churnRisk,
  });

  @override
  Widget build(BuildContext context) {
    final high = segmentation['high'] ?? 0;
    final medium = segmentation['medium'] ?? 0;
    final low = segmentation['low'] ?? 0;
    final total = high + medium + low;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Kundensegmentierung',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Churn-Risiko: $churnRisk',
                  style: TextStyle(
                    color: churnRisk > 0
                        ? Colors.red.shade700
                        : Colors.grey.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 220,
              child: total == 0
                  ? const Center(
                      child: Text(
                        'Noch keine Kundensegmente vorhanden.',
                      ),
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: PieChart(
                            PieChartData(
                              sectionsSpace: 2,
                              centerSpaceRadius: 36,
                              sections: [
                                _section(
                                  value: high.toDouble(),
                                  color: Colors.green,
                                  label: 'High',
                                ),
                                _section(
                                  value: medium.toDouble(),
                                  color: Colors.amber,
                                  label: 'Med',
                                ),
                                _section(
                                  value: low.toDouble(),
                                  color: Colors.blueGrey,
                                  label: 'Low',
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _legendDot('High-Value', high, Colors.green),
                            const SizedBox(height: 6),
                            _legendDot(
                              'Medium-Value',
                              medium,
                              Colors.amber.shade700,
                            ),
                            const SizedBox(height: 6),
                            _legendDot(
                              'Low-Value',
                              low,
                              Colors.blueGrey,
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  PieChartSectionData _section({
    required double value,
    required Color color,
    required String label,
  }) {
    return PieChartSectionData(
      value: value,
      color: color,
      radius: 56,
      title: value == 0 ? '' : label,
      titleStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
    );
  }

  Widget _legendDot(String label, int value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text('$label: $value'),
      ],
    );
  }
}

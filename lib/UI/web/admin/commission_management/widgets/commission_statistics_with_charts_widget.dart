import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whisky_hikes/data/providers/commission_provider.dart';
import 'package:whisky_hikes/UI/core/responsive_layout.dart';
import 'commission_statistics_widget.dart';
import 'commission_charts_container.dart';

/// Erweiterte Commission Statistics Widget mit Charts
class CommissionStatisticsWithChartsWidget extends StatefulWidget {
  final String companyId;

  const CommissionStatisticsWithChartsWidget({
    super.key,
    required this.companyId,
  });

  @override
  State<CommissionStatisticsWithChartsWidget> createState() =>
      _CommissionStatisticsWithChartsWidgetState();
}

class _CommissionStatisticsWithChartsWidgetState
    extends State<CommissionStatisticsWithChartsWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showCharts = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CommissionProvider>(
      builder: (context, provider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // KPI Statistics Section (immer sichtbar)
            const CommissionStatisticsWidget(),

            const SizedBox(height: 16),

            // Charts Toggle Section
            _buildChartsToggleSection(context, provider),

            // Charts Section (wenn aktiviert)
            if (_showCharts) ...[
              const SizedBox(height: 16),
              _buildChartsSection(context),
            ],
          ],
        );
      },
    );
  }

  Widget _buildChartsToggleSection(
    BuildContext context,
    CommissionProvider provider,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Erweiterte Analytics',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  'Charts und visuelle Datenanalyse',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                if (_showCharts)
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _showCharts = false;
                      });
                    },
                    icon: const Icon(Icons.expand_less),
                    tooltip: 'Charts ausblenden',
                  )
                else
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _showCharts = true;
                      });
                    },
                    icon: const Icon(Icons.expand_more),
                    tooltip: 'Charts anzeigen',
                  ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _showCharts = !_showCharts;
                    });
                  },
                  icon: Icon(
                    _showCharts ? Icons.visibility_off : Icons.analytics,
                  ),
                  label: Text(
                    _showCharts ? 'Charts ausblenden' : 'Charts anzeigen',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartsSection(BuildContext context) {
    return ResponsiveLayout(
      mobile: _buildMobileChartsLayout(context),
      tablet: _buildTabletChartsLayout(context),
      desktop: _buildDesktopChartsLayout(context),
    );
  }

  Widget _buildMobileChartsLayout(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildChartsTabBar(context),
            const SizedBox(height: 16),
            SizedBox(
              height: 400,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildOverviewTab(context),
                  _buildDetailedTab(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabletChartsLayout(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildChartsTabBar(context),
            const SizedBox(height: 16),
            SizedBox(
              height: 500,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildOverviewTab(context),
                  _buildDetailedTab(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopChartsLayout(BuildContext context) {
    return CommissionChartsContainer(companyId: widget.companyId);
  }

  Widget _buildChartsTabBar(BuildContext context) {
    return TabBar(
      controller: _tabController,
      tabs: const [
        Tab(icon: Icon(Icons.dashboard), text: 'Übersicht'),
        Tab(icon: Icon(Icons.analytics), text: 'Details'),
      ],
    );
  }

  Widget _buildOverviewTab(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildQuickStatsGrid(context),
          const SizedBox(height: 16),
          _buildMiniChartsPreview(context),
        ],
      ),
    );
  }

  Widget _buildDetailedTab(BuildContext context) {
    return CommissionChartsContainer(companyId: widget.companyId);
  }

  Widget _buildQuickStatsGrid(BuildContext context) {
    return Consumer<CommissionProvider>(
      builder: (context, provider, child) {
        final stats = provider.statistics;

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 2.5,
          children: [
            _buildQuickStatCard(
              context,
              'Heute',
              '€${(stats['todayAmount'] ?? 0.0).toStringAsFixed(2)}',
              Icons.today,
              Colors.blue,
            ),
            _buildQuickStatCard(
              context,
              'Diese Woche',
              '€${(stats['weekAmount'] ?? 0.0).toStringAsFixed(2)}',
              Icons.date_range,
              Colors.green,
            ),
            _buildQuickStatCard(
              context,
              'Offene',
              '${stats['pendingCommissions'] ?? 0}',
              Icons.schedule,
              Colors.orange,
            ),
            _buildQuickStatCard(
              context,
              'Bezahlt',
              '${stats['paidCommissions'] ?? 0}',
              Icons.check_circle,
              Colors.purple,
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuickStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniChartsPreview(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Charts Vorschau',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              TextButton(
                onPressed: () {
                  _tabController.animateTo(1);
                },
                child: const Text('Alle anzeigen'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMiniChartIndicator(
                  context,
                  'Timeline',
                  Icons.show_chart,
                  'Commission-Entwicklung über Zeit',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMiniChartIndicator(
                  context,
                  'Status',
                  Icons.pie_chart,
                  'Verteilung nach Status',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildMiniChartIndicator(
            context,
            'Top Hikes',
            Icons.bar_chart,
            'Beste Wanderrouten nach Commission',
          ),
        ],
      ),
    );
  }

  Widget _buildMiniChartIndicator(
    BuildContext context,
    String title,
    IconData icon,
    String description,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                ),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

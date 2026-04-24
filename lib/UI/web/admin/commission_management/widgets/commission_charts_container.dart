import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:whisky_hikes/data/services/commission/commission_chart_service.dart';
import 'package:whisky_hikes/data/services/commission/commission_service.dart';
import 'package:whisky_hikes/UI/core/responsive_layout.dart';
import 'commission_timeline_chart.dart';
import 'commission_status_chart.dart';
import 'commission_by_hike_chart.dart';

/// Container Widget für alle Commission Charts
class CommissionChartsContainer extends StatefulWidget {
  final String companyId;

  const CommissionChartsContainer({super.key, required this.companyId});

  @override
  State<CommissionChartsContainer> createState() =>
      _CommissionChartsContainerState();
}

class _CommissionChartsContainerState extends State<CommissionChartsContainer> {
  late final CommissionChartService _chartService;

  bool _isLoading = false;
  String? _errorMessage;

  CommissionTimelineData? _timelineData;
  CommissionStatusDistributionData? _statusData;
  CommissionByHikeData? _hikeData;

  ChartPeriod _selectedPeriod = ChartPeriod.monthly;

  @override
  void initState() {
    super.initState();
    _chartService = CommissionChartService(
      CommissionService(Supabase.instance.client),
    );
    _loadChartData();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context),
        const SizedBox(height: 16),
        if (_isLoading) _buildLoadingState(context),
        if (_errorMessage != null) _buildErrorState(context),
        if (!_isLoading && _errorMessage == null) _buildCharts(context),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Analytics & Charts',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        Row(
          children: [
            _buildPeriodSelector(context),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _isLoading ? null : _loadChartData,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh),
              tooltip: 'Charts aktualisieren',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPeriodSelector(BuildContext context) {
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
      selected: {_selectedPeriod},
      onSelectionChanged: (Set<ChartPeriod> selected) {
        if (selected.isNotEmpty && selected.first != _selectedPeriod) {
          setState(() {
            _selectedPeriod = selected.first;
          });
          _loadTimelineData();
        }
      },
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Container(
      height: 300,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Charts werden geladen...',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Container(
      height: 200,
      alignment: Alignment.center,
      child: Card(
        color: Theme.of(context).colorScheme.errorContainer,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
              const SizedBox(height: 16),
              Text(
                'Fehler beim Laden der Charts',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage ?? 'Unbekannter Fehler',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadChartData,
                child: const Text('Erneut versuchen'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCharts(BuildContext context) {
    return ResponsiveLayout(
      mobile: _buildMobileLayout(context),
      tablet: _buildTabletLayout(context),
      desktop: _buildDesktopLayout(context),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      children: [
        if (_timelineData != null)
          CommissionTimelineChart(
            companyId: widget.companyId,
            data: _timelineData!,
            onRefresh: _loadTimelineData,
          ),
        const SizedBox(height: 16),
        if (_statusData != null)
          CommissionStatusChart(
            companyId: widget.companyId,
            data: _statusData!,
            onRefresh: _loadStatusData,
          ),
        const SizedBox(height: 16),
        if (_hikeData != null)
          CommissionByHikeChart(
            companyId: widget.companyId,
            data: _hikeData!,
            onRefresh: _loadHikeData,
          ),
      ],
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return Column(
      children: [
        if (_timelineData != null)
          CommissionTimelineChart(
            companyId: widget.companyId,
            data: _timelineData!,
            onRefresh: _loadTimelineData,
          ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_statusData != null)
              Expanded(
                child: CommissionStatusChart(
                  companyId: widget.companyId,
                  data: _statusData!,
                  onRefresh: _loadStatusData,
                ),
              ),
            const SizedBox(width: 16),
            if (_hikeData != null)
              Expanded(
                child: CommissionByHikeChart(
                  companyId: widget.companyId,
                  data: _hikeData!,
                  onRefresh: _loadHikeData,
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Column(
      children: [
        if (_timelineData != null)
          CommissionTimelineChart(
            companyId: widget.companyId,
            data: _timelineData!,
            onRefresh: _loadTimelineData,
          ),
        const SizedBox(height: 16),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_statusData != null)
                Expanded(
                  child: CommissionStatusChart(
                    companyId: widget.companyId,
                    data: _statusData!,
                    onRefresh: _loadStatusData,
                  ),
                ),
              const SizedBox(width: 16),
              if (_hikeData != null)
                Expanded(
                  flex: 2,
                  child: CommissionByHikeChart(
                    companyId: widget.companyId,
                    data: _hikeData!,
                    onRefresh: _loadHikeData,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _loadChartData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await Future.wait([
        _loadTimelineData(),
        _loadStatusData(),
        _loadHikeData(),
      ]);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadTimelineData() async {
    try {
      final data = await _chartService.getTimelineChartData(
        companyId: widget.companyId,
        period: _selectedPeriod,
        months: _selectedPeriod == ChartPeriod.monthly ? 6 : null,
        weeks: _selectedPeriod == ChartPeriod.weekly ? 8 : null,
      );

      setState(() {
        _timelineData = data;
      });
    } catch (e) {
      // Handle individual chart errors without affecting other charts
      debugPrint('Error loading timeline data: $e');
    }
  }

  Future<void> _loadStatusData() async {
    try {
      final data = await _chartService.getStatusDistributionChartData(
        companyId: widget.companyId,
      );

      setState(() {
        _statusData = data;
      });
    } catch (e) {
      debugPrint('Error loading status data: $e');
    }
  }

  Future<void> _loadHikeData() async {
    try {
      final data = await _chartService.getCommissionByHikeChartData(
        companyId: widget.companyId,
        limit: 10,
      );

      setState(() {
        _hikeData = data;
      });
    } catch (e) {
      debugPrint('Error loading hike data: $e');
    }
  }
}

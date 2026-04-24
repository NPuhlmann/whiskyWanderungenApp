import 'dart:developer';
import 'package:whisky_hikes/data/services/commission/commission_service.dart';
import 'package:whisky_hikes/domain/models/commission.dart';

/// Enum for chart time periods
enum ChartPeriod { daily, weekly, monthly, yearly }

/// Data class for commission timeline chart
class CommissionTimelineData {
  final List<TimelineDataPoint> dataPoints;
  final ChartPeriod period;
  final double totalAmount;
  final int totalCommissions;

  CommissionTimelineData({
    required this.dataPoints,
    required this.period,
    required this.totalAmount,
    required this.totalCommissions,
  });
}

/// Individual data point for timeline chart
class TimelineDataPoint {
  final DateTime date;
  final double amount;
  final int count;
  final String label;

  TimelineDataPoint({
    required this.date,
    required this.amount,
    required this.count,
    required this.label,
  });
}

/// Data class for commission status distribution chart
class CommissionStatusDistributionData {
  final Map<CommissionStatus, int> statusCounts;
  final Map<CommissionStatus, double> statusAmounts;
  final int totalCommissions;
  final double totalAmount;

  CommissionStatusDistributionData({
    required this.statusCounts,
    required this.statusAmounts,
    required this.totalCommissions,
    required this.totalAmount,
  });
}

/// Data class for commission by hike chart
class CommissionByHikeData {
  final List<HikeCommissionData> hikeData;
  final double totalAmount;
  final int totalCommissions;

  CommissionByHikeData({
    required this.hikeData,
    required this.totalAmount,
    required this.totalCommissions,
  });
}

/// Individual hike commission data
class HikeCommissionData {
  final int hikeId;
  final String hikeName;
  final double commissionAmount;
  final int commissionCount;

  HikeCommissionData({
    required this.hikeId,
    required this.hikeName,
    required this.commissionAmount,
    required this.commissionCount,
  });
}

/// Service for generating commission chart data and analytics
class CommissionChartService {
  final CommissionService _commissionService;

  CommissionChartService(this._commissionService);

  /// Generate timeline chart data for commission development over time
  Future<CommissionTimelineData> getTimelineChartData({
    required String companyId,
    required ChartPeriod period,
    int? months,
    int? weeks,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      // Validate parameters
      if (companyId.isEmpty) {
        throw ArgumentError('Company ID cannot be empty');
      }

      if (months != null && months <= 0) {
        throw ArgumentError('Months must be greater than 0');
      }

      if (weeks != null && weeks <= 0) {
        throw ArgumentError('Weeks must be greater than 0');
      }

      if (startDate != null && endDate != null && startDate.isAfter(endDate)) {
        throw ArgumentError('Start date cannot be after end date');
      }

      // Calculate date range if not provided
      final DateTime effectiveEndDate = endDate ?? DateTime.now();
      final DateTime effectiveStartDate =
          startDate ??
          _calculateStartDate(
            effectiveEndDate,
            period,
            months: months,
            weeks: weeks,
          );

      // Fetch commission data
      final commissions = await _commissionService.getCommissionsForDateRange(
        companyId,
        effectiveStartDate,
        effectiveEndDate,
      );

      // Aggregate data by time period
      final Map<String, double> aggregatedAmounts;
      final Map<String, int> aggregatedCounts;

      switch (period) {
        case ChartPeriod.monthly:
          aggregatedAmounts = aggregateCommissionsByMonth(commissions);
          aggregatedCounts = aggregateCommissionCountsByMonth(commissions);
          break;
        case ChartPeriod.weekly:
          aggregatedAmounts = aggregateCommissionsByWeek(commissions);
          aggregatedCounts = aggregateCommissionCountsByWeek(commissions);
          break;
        case ChartPeriod.daily:
          aggregatedAmounts = aggregateCommissionsByDay(commissions);
          aggregatedCounts = aggregateCommissionCountsByDay(commissions);
          break;
        case ChartPeriod.yearly:
          aggregatedAmounts = aggregateCommissionsByYear(commissions);
          aggregatedCounts = aggregateCommissionCountsByYear(commissions);
          break;
      }

      // Convert to timeline data points
      final dataPoints = <TimelineDataPoint>[];
      for (final entry in aggregatedAmounts.entries) {
        final date = _parseDataPointKey(entry.key, period);
        dataPoints.add(
          TimelineDataPoint(
            date: date,
            amount: entry.value,
            count: aggregatedCounts[entry.key] ?? 0,
            label: _formatDataPointLabel(date, period),
          ),
        );
      }

      // Sort by date
      dataPoints.sort((a, b) => a.date.compareTo(b.date));

      // Calculate totals
      final totalAmount = commissions.fold<double>(
        0.0,
        (sum, commission) => sum + commission.commissionAmount,
      );

      return CommissionTimelineData(
        dataPoints: dataPoints,
        period: period,
        totalAmount: totalAmount,
        totalCommissions: commissions.length,
      );
    } catch (e) {
      log('Error generating timeline chart data: $e');
      rethrow;
    }
  }

  /// Generate status distribution chart data
  Future<CommissionStatusDistributionData> getStatusDistributionChartData({
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
        commissions = await _commissionService.getCommissionsForCompany(
          companyId,
        );
      }

      // Group by status
      final statusCounts = groupCommissionsByStatus(commissions);
      final statusAmounts = groupCommissionAmountsByStatus(commissions);

      // Calculate totals
      final totalAmount = commissions.fold<double>(
        0.0,
        (sum, commission) => sum + commission.commissionAmount,
      );

      return CommissionStatusDistributionData(
        statusCounts: statusCounts,
        statusAmounts: statusAmounts,
        totalCommissions: commissions.length,
        totalAmount: totalAmount,
      );
    } catch (e) {
      log('Error generating status distribution chart data: $e');
      rethrow;
    }
  }

  /// Generate commission by hike chart data
  Future<CommissionByHikeData> getCommissionByHikeChartData({
    required String companyId,
    required int limit,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      // Validate parameters
      if (companyId.isEmpty) {
        throw ArgumentError('Company ID cannot be empty');
      }

      if (limit <= 0) {
        throw ArgumentError('Limit must be greater than 0');
      }

      // Fetch commission summary by hike
      final hikeCommissions = await _commissionService
          .getCommissionSummaryByHike(
            companyId,
            startDate: startDate,
            endDate: endDate,
          );

      // Convert to hike data list and sort by commission amount
      final hikeDataList = <HikeCommissionData>[];
      for (final entry in hikeCommissions.entries) {
        final hikeId = entry.key;
        final summary = entry.value;
        final commissions = summary['commissions'] as List<Commission>;

        hikeDataList.add(
          HikeCommissionData(
            hikeId: hikeId,
            hikeName:
                'Hike #$hikeId', // TODO: Get actual hike name from service
            commissionAmount: summary['totalAmount'] as double,
            commissionCount: commissions.length,
          ),
        );
      }

      // Sort by commission amount (highest first) and limit
      hikeDataList.sort(
        (a, b) => b.commissionAmount.compareTo(a.commissionAmount),
      );
      final limitedHikeData = hikeDataList.take(limit).toList();

      // Calculate totals
      final totalAmount = limitedHikeData.fold<double>(
        0.0,
        (sum, hike) => sum + hike.commissionAmount,
      );
      final totalCommissions = limitedHikeData.fold<int>(
        0,
        (sum, hike) => sum + hike.commissionCount,
      );

      return CommissionByHikeData(
        hikeData: limitedHikeData,
        totalAmount: totalAmount,
        totalCommissions: totalCommissions,
      );
    } catch (e) {
      log('Error generating commission by hike chart data: $e');
      rethrow;
    }
  }

  /// Aggregate commissions by month
  Map<String, double> aggregateCommissionsByMonth(
    List<Commission> commissions,
  ) {
    final Map<String, double> aggregated = {};

    for (final commission in commissions) {
      final key =
          '${commission.createdAt.year}-${commission.createdAt.month.toString().padLeft(2, '0')}';
      aggregated[key] = (aggregated[key] ?? 0.0) + commission.commissionAmount;
    }

    return aggregated;
  }

  /// Aggregate commission counts by month
  Map<String, int> aggregateCommissionCountsByMonth(
    List<Commission> commissions,
  ) {
    final Map<String, int> aggregated = {};

    for (final commission in commissions) {
      final key =
          '${commission.createdAt.year}-${commission.createdAt.month.toString().padLeft(2, '0')}';
      aggregated[key] = (aggregated[key] ?? 0) + 1;
    }

    return aggregated;
  }

  /// Aggregate commissions by week
  Map<String, double> aggregateCommissionsByWeek(List<Commission> commissions) {
    final Map<String, double> aggregated = {};

    for (final commission in commissions) {
      final weekStart = _getWeekStart(commission.createdAt);
      final key = '${weekStart.year}-W${_getWeekNumber(weekStart)}';
      aggregated[key] = (aggregated[key] ?? 0.0) + commission.commissionAmount;
    }

    return aggregated;
  }

  /// Aggregate commission counts by week
  Map<String, int> aggregateCommissionCountsByWeek(
    List<Commission> commissions,
  ) {
    final Map<String, int> aggregated = {};

    for (final commission in commissions) {
      final weekStart = _getWeekStart(commission.createdAt);
      final key = '${weekStart.year}-W${_getWeekNumber(weekStart)}';
      aggregated[key] = (aggregated[key] ?? 0) + 1;
    }

    return aggregated;
  }

  /// Aggregate commissions by day
  Map<String, double> aggregateCommissionsByDay(List<Commission> commissions) {
    final Map<String, double> aggregated = {};

    for (final commission in commissions) {
      final key =
          '${commission.createdAt.year}-${commission.createdAt.month.toString().padLeft(2, '0')}-${commission.createdAt.day.toString().padLeft(2, '0')}';
      aggregated[key] = (aggregated[key] ?? 0.0) + commission.commissionAmount;
    }

    return aggregated;
  }

  /// Aggregate commission counts by day
  Map<String, int> aggregateCommissionCountsByDay(
    List<Commission> commissions,
  ) {
    final Map<String, int> aggregated = {};

    for (final commission in commissions) {
      final key =
          '${commission.createdAt.year}-${commission.createdAt.month.toString().padLeft(2, '0')}-${commission.createdAt.day.toString().padLeft(2, '0')}';
      aggregated[key] = (aggregated[key] ?? 0) + 1;
    }

    return aggregated;
  }

  /// Aggregate commissions by year
  Map<String, double> aggregateCommissionsByYear(List<Commission> commissions) {
    final Map<String, double> aggregated = {};

    for (final commission in commissions) {
      final key = commission.createdAt.year.toString();
      aggregated[key] = (aggregated[key] ?? 0.0) + commission.commissionAmount;
    }

    return aggregated;
  }

  /// Aggregate commission counts by year
  Map<String, int> aggregateCommissionCountsByYear(
    List<Commission> commissions,
  ) {
    final Map<String, int> aggregated = {};

    for (final commission in commissions) {
      final key = commission.createdAt.year.toString();
      aggregated[key] = (aggregated[key] ?? 0) + 1;
    }

    return aggregated;
  }

  /// Group commissions by status
  Map<CommissionStatus, int> groupCommissionsByStatus(
    List<Commission> commissions,
  ) {
    final Map<CommissionStatus, int> grouped = {};

    // Initialize all statuses with 0
    for (final status in CommissionStatus.values) {
      grouped[status] = 0;
    }

    // Count commissions by status
    for (final commission in commissions) {
      grouped[commission.status] = (grouped[commission.status] ?? 0) + 1;
    }

    return grouped;
  }

  /// Group commission amounts by status
  Map<CommissionStatus, double> groupCommissionAmountsByStatus(
    List<Commission> commissions,
  ) {
    final Map<CommissionStatus, double> grouped = {};

    // Initialize all statuses with 0.0
    for (final status in CommissionStatus.values) {
      grouped[status] = 0.0;
    }

    // Sum commission amounts by status
    for (final commission in commissions) {
      grouped[commission.status] =
          (grouped[commission.status] ?? 0.0) + commission.commissionAmount;
    }

    return grouped;
  }

  /// Calculate start date based on period and duration
  DateTime _calculateStartDate(
    DateTime endDate,
    ChartPeriod period, {
    int? months,
    int? weeks,
  }) {
    switch (period) {
      case ChartPeriod.monthly:
        return DateTime(
          endDate.year,
          endDate.month - (months ?? 6),
          endDate.day,
        );
      case ChartPeriod.weekly:
        return DateTime(
          endDate.year,
          endDate.month,
          endDate.day - (weeks ?? 4) * 7,
        );
      case ChartPeriod.daily:
        return DateTime(endDate.year, endDate.month, endDate.day - 30);
      case ChartPeriod.yearly:
        return DateTime(endDate.year - 3, endDate.month, endDate.day);
    }
  }

  /// Parse data point key back to DateTime
  DateTime _parseDataPointKey(String key, ChartPeriod period) {
    switch (period) {
      case ChartPeriod.monthly:
        final parts = key.split('-');
        return DateTime(int.parse(parts[0]), int.parse(parts[1]), 1);
      case ChartPeriod.weekly:
        final parts = key.split('-W');
        final year = int.parse(parts[0]);
        final week = int.parse(parts[1]);
        return _getDateFromWeek(year, week);
      case ChartPeriod.daily:
        final parts = key.split('-');
        return DateTime(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
        );
      case ChartPeriod.yearly:
        return DateTime(int.parse(key), 1, 1);
    }
  }

  /// Format data point label for display
  String _formatDataPointLabel(DateTime date, ChartPeriod period) {
    switch (period) {
      case ChartPeriod.monthly:
        return '${date.month.toString().padLeft(2, '0')}/${date.year}';
      case ChartPeriod.weekly:
        return 'W${_getWeekNumber(date)}/${date.year}';
      case ChartPeriod.daily:
        return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}';
      case ChartPeriod.yearly:
        return date.year.toString();
    }
  }

  /// Get week start date (Monday)
  DateTime _getWeekStart(DateTime date) {
    final daysFromMonday = date.weekday - 1;
    return DateTime(date.year, date.month, date.day - daysFromMonday);
  }

  /// Get week number in year
  int _getWeekNumber(DateTime date) {
    final dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays;
    return (dayOfYear / 7).ceil();
  }

  /// Get date from year and week number
  DateTime _getDateFromWeek(int year, int week) {
    final firstDayOfYear = DateTime(year, 1, 1);
    final daysToAdd = (week - 1) * 7;
    return firstDayOfYear.add(Duration(days: daysToAdd));
  }
}

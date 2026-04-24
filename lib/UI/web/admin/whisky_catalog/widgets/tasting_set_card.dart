import 'package:flutter/material.dart';
import 'package:whisky_hikes/domain/models/tasting_set.dart';
import 'package:whisky_hikes/config/l10n/app_localizations.dart';

/// Card widget displaying a tasting set with actions
class TastingSetCard extends StatelessWidget {
  final TastingSet tastingSet;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const TastingSetCard({
    super.key,
    required this.tastingSet,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with image and actions
            _buildHeader(context),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTitle(context),
                    const SizedBox(height: 8),
                    _buildDescription(context),
                    const Spacer(),
                    _buildMetrics(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.amber[600]!, Colors.amber[800]!],
        ),
      ),
      child: Stack(
        children: [
          // Background pattern
          Positioned.fill(child: CustomPaint(painter: _WhiskyPatternPainter())),
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status indicator
                _buildStatusChip(context),
                const Spacer(),
                // Actions
                _buildActionButtons(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    final isAvailable = tastingSet.isCurrentlyAvailable;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isAvailable ? Colors.green : Colors.red,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isAvailable ? Icons.check_circle : Icons.cancel,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            isAvailable
                ? AppLocalizations.of(context)!.available
                : AppLocalizations.of(context)!.unavailable,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (onEdit != null)
          IconButton(
            onPressed: onEdit,
            icon: const Icon(Icons.edit),
            iconSize: 20,
            color: Colors.white,
            style: IconButton.styleFrom(backgroundColor: Colors.black26),
            tooltip: AppLocalizations.of(context)!.edit,
          ),
        const SizedBox(width: 4),
        if (onDelete != null)
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete),
            iconSize: 20,
            color: Colors.white,
            style: IconButton.styleFrom(backgroundColor: Colors.black26),
            tooltip: AppLocalizations.of(context)!.delete,
          ),
      ],
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      tastingSet.name,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildDescription(BuildContext context) {
    return Text(
      tastingSet.shortDescription,
      style: Theme.of(
        context,
      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildMetrics(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            _buildMetricChip(
              context,
              icon: Icons.local_bar,
              label: AppLocalizations.of(context)!.samples,
              value: tastingSet.sampleCount.toString(),
              color: Colors.blue,
            ),
            const SizedBox(width: 8),
            _buildMetricChip(
              context,
              icon: Icons.map,
              label: AppLocalizations.of(context)!.region,
              value: tastingSet.mainRegion,
              color: Colors.green,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildMetricChip(
              context,
              icon: Icons.access_time,
              label: AppLocalizations.of(context)!.avgAge,
              value: '${tastingSet.averageAge.toStringAsFixed(0)}y',
              color: Colors.orange,
            ),
            const SizedBox(width: 8),
            _buildMetricChip(
              context,
              icon: Icons.speed,
              label: AppLocalizations.of(context)!.avgAbv,
              value: '${tastingSet.averageAbv.toStringAsFixed(1)}%',
              color: Colors.purple,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: color,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
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

/// Custom painter for whisky-themed background pattern
class _WhiskyPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Draw some subtle circles representing whisky barrels
    final radius = size.width * 0.3;
    for (int i = 0; i < 3; i++) {
      final center = Offset(
        size.width * (0.3 + i * 0.4),
        size.height * (0.3 + i * 0.2),
      );
      canvas.drawCircle(center, radius * (0.5 + i * 0.2), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

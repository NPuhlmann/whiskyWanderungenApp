import 'package:flutter/material.dart';
import 'package:whisky_hikes/domain/models/tasting_set.dart';
import 'package:whisky_hikes/config/l10n/app_localizations.dart';

/// Dialog showing detailed information about a tasting set
class TastingSetDetailsDialog extends StatelessWidget {
  final TastingSet tastingSet;

  const TastingSetDetailsDialog({super.key, required this.tastingSet});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          children: [
            // Header
            _buildHeader(context),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBasicInfo(context),
                    const SizedBox(height: 24),
                    _buildSamplesSection(context),
                    const SizedBox(height: 24),
                    _buildStatistics(context),
                  ],
                ),
              ),
            ),
            // Actions
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.amber[600]!, Colors.amber[800]!],
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tastingSet.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildStatusBadge(context),
                    const SizedBox(width: 16),
                    Text(
                      '${AppLocalizations.of(context)!.hikeId}: ${tastingSet.hikeId}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    final isAvailable = tastingSet.isCurrentlyAvailable;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isAvailable ? Colors.green : Colors.red,
        borderRadius: BorderRadius.circular(16),
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

  Widget _buildBasicInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.basicInformation,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildInfoRow(
          context,
          label: AppLocalizations.of(context)!.description,
          value: tastingSet.description,
        ),
        _buildInfoRow(
          context,
          label: AppLocalizations.of(context)!.price,
          value: tastingSet.formattedPrice,
        ),
        _buildInfoRow(
          context,
          label: AppLocalizations.of(context)!.mainRegion,
          value: tastingSet.mainRegion,
        ),
        _buildInfoRow(
          context,
          label: AppLocalizations.of(context)!.totalVolume,
          value: '${tastingSet.totalVolumeMl.toStringAsFixed(1)}ml',
        ),
        if (tastingSet.createdAt != null)
          _buildInfoRow(
            context,
            label: AppLocalizations.of(context)!.createdAt,
            value: _formatDate(tastingSet.createdAt!),
          ),
        if (tastingSet.updatedAt != null)
          _buildInfoRow(
            context,
            label: AppLocalizations.of(context)!.lastUpdated,
            value: _formatDate(tastingSet.updatedAt!),
          ),
      ],
    );
  }

  Widget _buildSamplesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              AppLocalizations.of(context)!.whiskySamples,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Chip(
              label: Text(
                '${tastingSet.sampleCount} ${AppLocalizations.of(context)!.samples}',
              ),
              backgroundColor: Colors.amber[100],
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (tastingSet.samples.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(
                    Icons.local_bar_outlined,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)!.noSamplesYet,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: tastingSet.samples.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final sample = tastingSet.samples[index];
              return _buildSampleCard(context, sample, index + 1);
            },
          ),
      ],
    );
  }

  Widget _buildSampleCard(
    BuildContext context,
    WhiskySample sample,
    int position,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.amber[800],
                  child: Text(
                    position.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sample.displayName,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${sample.region} • ${sample.formattedAge} • ${sample.formattedAbv}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    sample.formattedSampleSize,
                    style: TextStyle(
                      color: Colors.blue[800],
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            if (sample.category != null && sample.category!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Chip(
                label: Text(sample.category!),
                backgroundColor: Colors.grey[200],
                labelStyle: const TextStyle(fontSize: 12),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              sample.tastingNotes,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatistics(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.statistics,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                title: AppLocalizations.of(context)!.averageAge,
                value: '${tastingSet.averageAge.toStringAsFixed(1)} Jahre',
                icon: Icons.access_time,
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                context,
                title: AppLocalizations.of(context)!.averageAbv,
                value: '${tastingSet.averageAbv.toStringAsFixed(1)}%',
                icon: Icons.speed,
                color: Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.close),
          ),
          const SizedBox(width: 16),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement edit functionality
            },
            icon: const Icon(Icons.edit),
            label: Text(AppLocalizations.of(context)!.edit),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber[800],
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

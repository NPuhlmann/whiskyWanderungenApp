import 'package:flutter/material.dart';
import '../../../../config/l10n/app_localizations.dart';

/// Einzelne Route-Karte für die Listenansicht
class RouteCard extends StatelessWidget {
  final Map<String, dynamic> route;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onToggleStatus;

  const RouteCard({
    super.key,
    required this.route,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onToggleStatus,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = route['is_active'] ?? false;
    final difficulty = route['difficulty'] ?? 'moderate';
    final name = route['name'] ?? 'Unbenannte Route';
    final description = route['description'] ?? '';
    final price = route['price'] ?? 0.0;
    final distance = route['distance'] ?? 0.0;
    final duration = route['duration'] ?? 0;
    final thumbnailUrl = route['thumbnail_image_url'];

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bild-Header
            _buildImageHeader(thumbnailUrl, isActive),

            // Content
            // Scrollt, statt zu overflowen, wenn die Kachel zu niedrig ist
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Titel und Status
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        _buildStatusChip(isActive),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Schwierigkeit
                    _buildDifficultyBadge(difficulty),

                    const SizedBox(height: 8),

                    // Beschreibung
                    if (description.isNotEmpty) ...[
                      Text(
                        description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Route-Details
                    _buildRouteDetails(price, distance, duration, context),

                    const SizedBox(height: 12),

                    // Action-Buttons
                    _buildActionButtons(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageHeader(String? thumbnailUrl, bool isActive) {
    return Container(
      height: 120,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
        color: Colors.grey[200],
      ),
      child: Stack(
        children: [
          // Bild oder Platzhalter
          if (thumbnailUrl != null && thumbnailUrl.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(8),
              ),
              child: Image.network(
                thumbnailUrl,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildImagePlaceholder(),
              ),
            )
          else
            _buildImagePlaceholder(),

          // Status-Overlay
          if (!isActive)
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(8),
                ),
                color: Colors.black.withValues(alpha: 0.6),
              ),
              child: const Center(
                child: Text(
                  'INAKTIV',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
        color: Colors.grey[300],
      ),
      child: Icon(Icons.landscape, size: 48, color: Colors.grey[500]),
    );
  }

  Widget _buildStatusChip(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? Colors.green[100] : Colors.red[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isActive ? 'Aktiv' : 'Inaktiv',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: isActive ? Colors.green[700] : Colors.red[700],
        ),
      ),
    );
  }

  Widget _buildDifficultyBadge(String difficulty) {
    Color color;
    String label;
    IconData icon;

    switch (difficulty) {
      case 'easy':
        color = Colors.green;
        label = 'Leicht';
        icon = Icons.terrain;
        break;
      case 'hard':
        color = Colors.red;
        label = 'Schwer';
        icon = Icons.landscape;
        break;
      default: // moderate
        color = Colors.orange;
        label = 'Mittel';
        icon = Icons.hiking;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteDetails(
    double price,
    double distance,
    int duration,
    BuildContext context,
  ) {
    // Wrap statt Row: bricht um, statt bei schmalen Karten zu overflowen
    return Wrap(
      spacing: 16,
      runSpacing: 4,
      children: [
        _buildDetailItem(
          context,
          Icons.euro,
          '${price.toStringAsFixed(2)} €',
          bold: true,
        ),
        _buildDetailItem(
          context,
          Icons.straighten,
          '${distance.toStringAsFixed(1)} km',
        ),
        _buildDetailItem(context, Icons.access_time, _formatDuration(duration)),
        _buildDetailItem(
          context,
          Icons.group,
          '${route['max_participants'] ?? 0} Pers.',
        ),
      ],
    );
  }

  Widget _buildDetailItem(
    BuildContext context,
    IconData icon,
    String text, {
    bool bold = false,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: bold ? FontWeight.w600 : null,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.end,
      children: [
        IconButton(
          onPressed: onTap,
          icon: const Icon(Icons.visibility),
          tooltip: 'Anzeigen',
          iconSize: 20,
        ),
        IconButton(
          onPressed: () {
            // Route-Vorschau auf Karte
            _showRoutePreview(context);
          },
          icon: const Icon(Icons.map),
          tooltip: 'Auf Karte anzeigen',
          iconSize: 20,
        ),
        IconButton(
          onPressed: onEdit,
          icon: const Icon(Icons.edit),
          tooltip: 'Bearbeiten',
          iconSize: 20,
        ),
        IconButton(
          onPressed: onDelete,
          icon: const Icon(Icons.delete),
          tooltip: 'Löschen',
          iconSize: 20,
          style: IconButton.styleFrom(foregroundColor: Colors.red[600]),
        ),
      ],
    );
  }

  String _formatDuration(int minutes) {
    if (minutes < 60) {
      return '${minutes}min';
    }

    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;

    if (remainingMinutes == 0) {
      return '${hours}h';
    }

    return '${hours}h ${remainingMinutes}min';
  }

  void _showRoutePreview(BuildContext context) {
    // TODO: Implementiere Karten-Vorschau in einem Dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${route['name']} - Karten-Vorschau'),
        content: Container(
          width: 400,
          height: 300,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.map, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('Karten-Vorschau'),
                Text('(In Entwicklung)'),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.close),
          ),
        ],
      ),
    );
  }
}

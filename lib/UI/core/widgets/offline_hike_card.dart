import 'package:flutter/material.dart';

import '../../../domain/models/hike.dart';
import '../../../data/services/connectivity/connectivity_service.dart';
import '../../../data/services/sync/data_sync_service.dart';
import 'sync_status_indicator.dart';

/// Erweiterte Hike-Card mit Offline-Funktionalität
class OfflineHikeCard extends StatelessWidget {
  final Hike hike;
  final bool isAvailableOffline;
  final VoidCallback? onTap;
  final VoidCallback? onDownload;
  final VoidCallback? onRemoveOffline;

  const OfflineHikeCard({
    super.key,
    required this.hike,
    required this.isAvailableOffline,
    this.onTap,
    this.onDownload,
    this.onRemoveOffline,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header mit Titel und Offline-Status
              Row(
                children: [
                  Expanded(
                    child: Text(
                      hike.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildOfflineStatusIndicator(context),
                ],
              ),

              const SizedBox(height: 8),

              // Beschreibung
              if (hike.description.isNotEmpty) ...[
                Text(
                  hike.description,
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
              ],

              // Hike-Details
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    hike.category.isNotEmpty ? hike.category : 'Whisky Tour',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.timer, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    hike.lengthDisplayText,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.euro, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    hike.price.toStringAsFixed(2),
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Action Buttons
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOfflineStatusIndicator(BuildContext context) {
    return StreamBuilder<NetworkStatus>(
      stream: ConnectivityService.instance.networkStatusStream,
      builder: (context, snapshot) {
        final networkStatus = snapshot.data ?? NetworkStatus.unknown;

        if (isAvailableOffline) {
          return OfflineAvailableBadge(
            isAvailableOffline: true,
            onTap: () => _showOfflineInfo(context),
          );
        } else if (!networkStatus.isConnected) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.cloud_off, size: 14, color: Colors.red.shade700),
                const SizedBox(width: 4),
                Text(
                  'Nicht verfügbar',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.red.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return StreamBuilder<NetworkStatus>(
      stream: ConnectivityService.instance.networkStatusStream,
      builder: (context, snapshot) {
        final networkStatus = snapshot.data ?? NetworkStatus.unknown;

        return Row(
          children: [
            // Hauptaktion (Öffnen/Kaufen)
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _getMainActionEnabled(networkStatus) ? onTap : null,
                icon: Icon(_getMainActionIcon()),
                label: Text(_getMainActionText(networkStatus)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getMainActionColor(networkStatus),
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Offline-Aktionen
            if (networkStatus.isConnected) ...[
              if (isAvailableOffline) ...[
                // Offline entfernen
                OutlinedButton.icon(
                  onPressed: onRemoveOffline,
                  icon: const Icon(Icons.cloud_off, size: 16),
                  label: const Text('Entfernen'),
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                ),
              ] else ...[
                // Für Offline herunterladen
                OutlinedButton.icon(
                  onPressed: onDownload,
                  icon: const Icon(Icons.download, size: 16),
                  label: const Text('Download'),
                ),
              ],
            ],
          ],
        );
      },
    );
  }

  bool _getMainActionEnabled(NetworkStatus networkStatus) {
    // Offline verfügbar -> immer aktiviert (bedeutet bereits gekauft)
    if (isAvailableOffline) return true;

    // Online und verfügbar -> aktiviert
    if (networkStatus.isConnected && hike.isCurrentlyAvailable) return true;

    // Offline und nicht verfügbar -> deaktiviert
    return false;
  }

  IconData _getMainActionIcon() {
    if (isAvailableOffline) {
      return Icons.hiking;
    } else {
      return Icons.shopping_cart;
    }
  }

  String _getMainActionText(NetworkStatus networkStatus) {
    if (isAvailableOffline) {
      return 'Wanderung starten';
    }

    if (!networkStatus.isConnected) {
      return 'Offline nicht verfügbar';
    }

    if (hike.isCurrentlyAvailable) {
      return 'Kaufen';
    } else {
      return 'Nicht verfügbar';
    }
  }

  Color? _getMainActionColor(NetworkStatus networkStatus) {
    if (isAvailableOffline) {
      return Colors.green;
    }

    if (!networkStatus.isConnected) {
      return Colors.grey;
    }

    if (hike.isCurrentlyAvailable) {
      return Colors.blue;
    } else {
      return Colors.grey;
    }
  }

  void _showOfflineInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.offline_bolt, color: Colors.green),
            SizedBox(width: 8),
            Text('Offline verfügbar'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Diese Wanderung ist offline verfügbar:'),
            const SizedBox(height: 12),
            const Row(
              children: [
                Icon(Icons.check, size: 16, color: Colors.green),
                SizedBox(width: 8),
                Text('Karten und Wegpunkte'),
              ],
            ),
            const SizedBox(height: 4),
            const Row(
              children: [
                Icon(Icons.check, size: 16, color: Colors.green),
                SizedBox(width: 8),
                Text('Tasting-Set-Informationen'),
              ],
            ),
            const SizedBox(height: 4),
            const Row(
              children: [
                Icon(Icons.check, size: 16, color: Colors.green),
                SizedBox(width: 8),
                Text('Wanderungsbeschreibung'),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Änderungen werden automatisch synchronisiert, sobald eine Internetverbindung verfügbar ist.',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
          if (onRemoveOffline != null)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onRemoveOffline!();
              },
              child: const Text('Offline entfernen'),
            ),
        ],
      ),
    );
  }
}

/// Spezielle Card für vollständig offline verfügbare Hikes
class OfflineOnlyHikeCard extends StatelessWidget {
  final Hike hike;
  final VoidCallback? onTap;
  final VoidCallback? onSync;

  const OfflineOnlyHikeCard({
    super.key,
    required this.hike,
    this.onTap,
    this.onSync,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Offline-Header
                Row(
                  children: [
                    Icon(
                      Icons.offline_bolt,
                      color: Colors.orange.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Offline-Modus',
                      style: TextStyle(
                        color: Colors.orange.shade700,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const Spacer(),
                    if (onSync != null)
                      StreamBuilder<SyncStatus>(
                        stream: DataSyncService.instance.syncStatusStream,
                        builder: (context, snapshot) {
                          final syncStatus = snapshot.data ?? SyncStatus.idle;

                          return IconButton(
                            onPressed: syncStatus.isActive ? null : onSync,
                            icon: syncStatus.isActive
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.sync),
                            tooltip: 'Synchronisieren',
                          );
                        },
                      ),
                  ],
                ),

                const SizedBox(height: 12),

                // Hike-Details
                Text(
                  hike.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                if (hike.description.isNotEmpty) ...[
                  Text(
                    hike.description,
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                ],

                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      hike.category.isNotEmpty ? hike.category : 'Whisky Tour',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.timer, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      hike.lengthDisplayText,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Info-Text
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.orange.shade700,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Diese Wanderung ist offline verfügbar. Änderungen werden synchronisiert, sobald eine Internetverbindung verfügbar ist.',
                          style: TextStyle(
                            color: Colors.orange.shade700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

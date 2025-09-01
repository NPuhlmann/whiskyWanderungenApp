import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/services/connectivity/connectivity_service.dart';
import '../../../data/services/sync/data_sync_service.dart';

/// Widget zur Anzeige des Offline-Status und Sync-Informationen
class OfflineIndicator extends StatelessWidget {
  const OfflineIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<NetworkStatus>(
      stream: ConnectivityService.instance.networkStatusStream,
      builder: (context, networkSnapshot) {
        final networkStatus = networkSnapshot.data ?? NetworkStatus.unknown;
        
        return StreamBuilder<SyncStatus>(
          stream: DataSyncService.instance.syncStatusStream,
          builder: (context, syncSnapshot) {
            final syncStatus = syncSnapshot.data ?? SyncStatus.idle;
            
            return _buildIndicator(context, networkStatus, syncStatus);
          },
        );
      },
    );
  }

  Widget _buildIndicator(BuildContext context, NetworkStatus networkStatus, SyncStatus syncStatus) {
    // Online und synchronisiert - kein Indikator nötig
    if (networkStatus.isConnected && syncStatus != SyncStatus.syncing) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _getBackgroundColor(networkStatus, syncStatus),
        border: Border(
          bottom: BorderSide(
            color: _getBorderColor(networkStatus, syncStatus),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _getIcon(networkStatus, syncStatus),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _getMessage(networkStatus, syncStatus),
              style: TextStyle(
                color: _getTextColor(networkStatus, syncStatus),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          if (syncStatus == SyncStatus.syncing) ...[
            const SizedBox(width: 8),
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getTextColor(networkStatus, syncStatus),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _getIcon(NetworkStatus networkStatus, SyncStatus syncStatus) {
    IconData iconData;
    
    if (syncStatus == SyncStatus.syncing) {
      iconData = Icons.sync;
    } else if (!networkStatus.isConnected) {
      iconData = Icons.cloud_off;
    } else if (networkStatus.isPoorQuality) {
      iconData = Icons.signal_wifi_bad;
    } else if (networkStatus.isWifi) {
      iconData = Icons.wifi;
    } else if (networkStatus.isMobile) {
      iconData = Icons.signal_cellular_alt;
    } else {
      iconData = Icons.network_check;
    }

    return Icon(
      iconData,
      size: 18,
      color: _getTextColor(networkStatus, syncStatus),
    );
  }

  String _getMessage(NetworkStatus networkStatus, SyncStatus syncStatus) {
    if (syncStatus == SyncStatus.syncing) {
      return 'Daten werden synchronisiert...';
    }

    if (syncStatus == SyncStatus.error) {
      return 'Synchronisation fehlgeschlagen';
    }

    switch (networkStatus) {
      case NetworkStatus.disconnected:
        return 'Offline - Gecachte Daten werden verwendet';
      case NetworkStatus.connected_no_internet:
        return 'Verbunden, aber kein Internet';
      case NetworkStatus.connected_wifi_poor:
      case NetworkStatus.connected_mobile_poor:
        return 'Schwache Verbindung - Möglicherweise langsam';
      case NetworkStatus.unknown:
        return 'Verbindungsstatus unbekannt';
      default:
        return networkStatus.displayName;
    }
  }

  Color _getBackgroundColor(NetworkStatus networkStatus, SyncStatus syncStatus) {
    if (syncStatus == SyncStatus.syncing) {
      return Colors.blue.shade50;
    }
    
    if (syncStatus == SyncStatus.error) {
      return Colors.red.shade50;
    }

    if (!networkStatus.isConnected) {
      return Colors.orange.shade50;
    }

    if (networkStatus.isPoorQuality) {
      return Colors.yellow.shade50;
    }

    return Colors.grey.shade100;
  }

  Color _getBorderColor(NetworkStatus networkStatus, SyncStatus syncStatus) {
    if (syncStatus == SyncStatus.syncing) {
      return Colors.blue.shade200;
    }
    
    if (syncStatus == SyncStatus.error) {
      return Colors.red.shade200;
    }

    if (!networkStatus.isConnected) {
      return Colors.orange.shade200;
    }

    if (networkStatus.isPoorQuality) {
      return Colors.yellow.shade200;
    }

    return Colors.grey.shade300;
  }

  Color _getTextColor(NetworkStatus networkStatus, SyncStatus syncStatus) {
    if (syncStatus == SyncStatus.syncing) {
      return Colors.blue.shade700;
    }
    
    if (syncStatus == SyncStatus.error) {
      return Colors.red.shade700;
    }

    if (!networkStatus.isConnected) {
      return Colors.orange.shade700;
    }

    if (networkStatus.isPoorQuality) {
      return Colors.yellow.shade700;
    }

    return Colors.grey.shade700;
  }
}

/// Kleinere Variante des Offline-Indikators für die AppBar
class OfflineIndicatorCompact extends StatelessWidget {
  const OfflineIndicatorCompact({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<NetworkStatus>(
      stream: ConnectivityService.instance.networkStatusStream,
      builder: (context, networkSnapshot) {
        final networkStatus = networkSnapshot.data ?? NetworkStatus.unknown;
        
        return StreamBuilder<SyncStatus>(
          stream: DataSyncService.instance.syncStatusStream,
          builder: (context, syncSnapshot) {
            final syncStatus = syncSnapshot.data ?? SyncStatus.idle;
            
            // Online und synchronisiert - kein Indikator nötig
            if (networkStatus.isConnected && syncStatus != SyncStatus.syncing) {
              return const SizedBox.shrink();
            }

            return Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getBackgroundColor(networkStatus, syncStatus),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getBorderColor(networkStatus, syncStatus),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (syncStatus == SyncStatus.syncing) ...[
                    SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getTextColor(networkStatus, syncStatus),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                  ] else
                    Icon(
                      _getIcon(networkStatus, syncStatus),
                      size: 14,
                      color: _getTextColor(networkStatus, syncStatus),
                    ),
                  const SizedBox(width: 4),
                  Text(
                    _getCompactMessage(networkStatus, syncStatus),
                    style: TextStyle(
                      color: _getTextColor(networkStatus, syncStatus),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  IconData _getIcon(NetworkStatus networkStatus, SyncStatus syncStatus) {
    if (syncStatus == SyncStatus.error) {
      return Icons.sync_problem;
    }
    
    if (!networkStatus.isConnected) {
      return Icons.cloud_off;
    }

    if (networkStatus.isPoorQuality) {
      return Icons.signal_wifi_bad;
    }

    return Icons.cloud_done;
  }

  String _getCompactMessage(NetworkStatus networkStatus, SyncStatus syncStatus) {
    if (syncStatus == SyncStatus.syncing) {
      return 'Sync...';
    }

    if (syncStatus == SyncStatus.error) {
      return 'Fehler';
    }

    if (!networkStatus.isConnected) {
      return 'Offline';
    }

    if (networkStatus.isPoorQuality) {
      return 'Schwach';
    }

    return 'Online';
  }

  Color _getBackgroundColor(NetworkStatus networkStatus, SyncStatus syncStatus) {
    if (syncStatus == SyncStatus.syncing) {
      return Colors.blue.shade100;
    }
    
    if (syncStatus == SyncStatus.error) {
      return Colors.red.shade100;
    }

    if (!networkStatus.isConnected) {
      return Colors.orange.shade100;
    }

    if (networkStatus.isPoorQuality) {
      return Colors.yellow.shade100;
    }

    return Colors.grey.shade200;
  }

  Color _getBorderColor(NetworkStatus networkStatus, SyncStatus syncStatus) {
    if (syncStatus == SyncStatus.syncing) {
      return Colors.blue.shade300;
    }
    
    if (syncStatus == SyncStatus.error) {
      return Colors.red.shade300;
    }

    if (!networkStatus.isConnected) {
      return Colors.orange.shade300;
    }

    if (networkStatus.isPoorQuality) {
      return Colors.yellow.shade300;
    }

    return Colors.grey.shade400;
  }

  Color _getTextColor(NetworkStatus networkStatus, SyncStatus syncStatus) {
    if (syncStatus == SyncStatus.syncing) {
      return Colors.blue.shade800;
    }
    
    if (syncStatus == SyncStatus.error) {
      return Colors.red.shade800;
    }

    if (!networkStatus.isConnected) {
      return Colors.orange.shade800;
    }

    if (networkStatus.isPoorQuality) {
      return Colors.yellow.shade800;
    }

    return Colors.grey.shade800;
  }
}

/// Dialog für detaillierte Offline-Informationen
class OfflineInfoDialog extends StatelessWidget {
  const OfflineInfoDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue),
          SizedBox(width: 8),
          Text('Offline-Status'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildNetworkSection(),
            const SizedBox(height: 16),
            _buildSyncSection(),
            const SizedBox(height: 16),
            _buildOfflineFeatures(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
        ElevatedButton(
          onPressed: () async {
            await DataSyncService.instance.syncNow();
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          },
          child: const Text('Sync starten'),
        ),
      ],
    );
  }

  Widget _buildNetworkSection() {
    return StreamBuilder<NetworkStatus>(
      stream: ConnectivityService.instance.networkStatusStream,
      builder: (context, snapshot) {
        final status = snapshot.data ?? NetworkStatus.unknown;
        
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Netzwerkverbindung',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      status.isConnected ? Icons.wifi : Icons.wifi_off,
                      size: 16,
                      color: status.isConnected ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 8),
                    Text(status.displayName),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSyncSection() {
    return StreamBuilder<SyncStatus>(
      stream: DataSyncService.instance.syncStatusStream,
      builder: (context, snapshot) {
        final status = snapshot.data ?? SyncStatus.idle;
        
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Synchronisation',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (status.isActive) ...[
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ] else
                      Icon(
                        status == SyncStatus.success ? Icons.check_circle : Icons.sync,
                        size: 16,
                        color: status == SyncStatus.success ? Colors.green : Colors.grey,
                      ),
                    const SizedBox(width: 8),
                    Text(status.displayName),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOfflineFeatures() {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Offline verfügbare Features',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.check, size: 16, color: Colors.green),
                SizedBox(width: 8),
                Text('Gecachte Wanderungen anzeigen'),
              ],
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.check, size: 16, color: Colors.green),
                SizedBox(width: 8),
                Text('Wegpunkte bearbeiten (Sync später)'),
              ],
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.check, size: 16, color: Colors.green),
                SizedBox(width: 8),
                Text('Profilansicht'),
              ],
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.close, size: 16, color: Colors.red),
                SizedBox(width: 8),
                Text('Neue Wanderungen kaufen'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const OfflineInfoDialog(),
    );
  }
}
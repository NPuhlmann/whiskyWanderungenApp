import 'package:flutter/material.dart';

import '../../../data/services/sync/data_sync_service.dart';

/// Widget zur Anzeige des Sync-Status mit Pull-to-Refresh-Integration
class SyncStatusIndicator extends StatelessWidget {
  final VoidCallback? onRefresh;
  final Widget child;
  final bool showPullToRefresh;
  final bool showSyncButton;

  const SyncStatusIndicator({
    super.key,
    this.onRefresh,
    required this.child,
    this.showPullToRefresh = true,
    this.showSyncButton = false,
  });

  @override
  Widget build(BuildContext context) {
    if (showPullToRefresh && onRefresh != null) {
      return RefreshIndicator(
        onRefresh: () async {
          onRefresh!();
          // Warten auf Sync-Completion
          await _waitForSyncCompletion();
        },
        child: _buildContent(context),
      );
    }

    return _buildContent(context);
  }

  Widget _buildContent(BuildContext context) {
    return StreamBuilder<SyncStatus>(
      stream: DataSyncService.instance.syncStatusStream,
      builder: (context, snapshot) {
        final syncStatus = snapshot.data ?? SyncStatus.idle;
        
        return Column(
          children: [
            if (syncStatus == SyncStatus.syncing)
              _buildSyncProgressBar(),
            
            Expanded(child: child),
            
            if (showSyncButton)
              _buildSyncButton(context, syncStatus),
          ],
        );
      },
    );
  }

  Widget _buildSyncProgressBar() {
    return SizedBox(
      height: 4,
      child: const LinearProgressIndicator(
        backgroundColor: Colors.grey,
        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
      ),
    );
  }

  Widget _buildSyncButton(BuildContext context, SyncStatus syncStatus) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton.icon(
            onPressed: syncStatus.isActive ? null : () async {
              await DataSyncService.instance.syncNow();
            },
            icon: syncStatus.isActive
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.sync),
            label: Text(syncStatus.isActive ? 'Synchronisiert...' : 'Synchronisieren'),
          ),
        ],
      ),
    );
  }

  Future<void> _waitForSyncCompletion() async {
    try {
      await for (final status in DataSyncService.instance.syncStatusStream) {
        if (!status.isActive) break;
      }
    } catch (e) {
      // Stream might be closed or disposed
    }
  }
}

/// Kleine Sync-Status-Anzeige für Listen-Items
class ItemSyncStatusIndicator extends StatelessWidget {
  final String itemType;
  final String itemId;
  final Widget child;

  const ItemSyncStatusIndicator({
    super.key,
    required this.itemType,
    required this.itemId,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SyncStatus>(
      stream: DataSyncService.instance.syncStatusStream,
      builder: (context, snapshot) {
        final syncStatus = snapshot.data ?? SyncStatus.idle;
        
        return Stack(
          children: [
            child,
            
            // Sync-Indikator falls Item synchronisiert wird
            if (syncStatus == SyncStatus.syncing)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Toast-Nachricht für Sync-Status-Updates
class SyncStatusToast {
  static void _show(BuildContext context, String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.sync, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static void showSuccess(BuildContext context) {
    _show(context, 'Synchronisation erfolgreich', Colors.green);
  }

  static void showPartialSuccess(BuildContext context) {
    _show(context, 'Synchronisation teilweise erfolgreich', Colors.orange);
  }

  static void showError(BuildContext context) {
    _show(context, 'Synchronisation fehlgeschlagen', Colors.red);
  }

  static void showOffline(BuildContext context) {
    _show(context, 'Offline - Sync später verfügbar', Colors.grey);
  }

  static void showSyncing(BuildContext context) {
    _show(context, 'Synchronisation gestartet...', Colors.blue);
  }
}

/// Mixin für einfache Sync-Status-Integration in Widgets
mixin SyncStatusMixin<T extends StatefulWidget> on State<T> {
  
  void _handleSyncStatusChanged(SyncStatus status) {
    if (!mounted) return;
    
    switch (status) {
      case SyncStatus.success:
        SyncStatusToast.showSuccess(context);
        break;
      case SyncStatus.partialSuccess:
        SyncStatusToast.showPartialSuccess(context);
        break;
      case SyncStatus.error:
        SyncStatusToast.showError(context);
        break;
      case SyncStatus.syncing:
        // Optional: Toast für Sync-Start
        // SyncStatusToast.showSyncing(context);
        break;
      case SyncStatus.idle:
        // Nichts tun
        break;
    }
    
    // Optional: Callback für abgeleitete Klassen
    onSyncStatusChanged(status);
  }

  /// Override in abgeleiteten Klassen für benutzerdefinierte Behandlung
  void onSyncStatusChanged(SyncStatus status) {}

  /// Sync-Status-Stream abonnieren
  void startListeningToSyncStatus() {
    DataSyncService.instance.syncStatusStream.listen(_handleSyncStatusChanged);
  }
}

/// Offline-verfügbarkeits-Badge für Hike-Cards
class OfflineAvailableBadge extends StatelessWidget {
  final bool isAvailableOffline;
  final VoidCallback? onTap;

  const OfflineAvailableBadge({
    super.key,
    required this.isAvailableOffline,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (!isAvailableOffline) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.1),
          border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.offline_bolt,
              size: 14,
              color: Colors.green.shade700,
            ),
            const SizedBox(width: 4),
            Text(
              'Offline verfügbar',
              style: TextStyle(
                fontSize: 12,
                color: Colors.green.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget für detaillierte Sync-Statistiken
class SyncStatsWidget extends StatelessWidget {
  const SyncStatsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: DataSyncService.instance.getSyncStats(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final stats = snapshot.data ?? {};
        
        return Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Synchronisations-Status',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                
                _buildStatRow(
                  'Letzte Synchronisation',
                  stats['lastSyncTime']?.toString() ?? 'Nie',
                  Icons.sync,
                ),
                
                _buildStatRow(
                  'Ausstehende Elemente',
                  stats['queueSize']?.toString() ?? '0',
                  Icons.queue,
                ),
                
                _buildStatRow(
                  'Status',
                  stats['isActive'] == true ? 'Aktiv' : 'Bereit',
                  stats['isActive'] == true ? Icons.sync : Icons.check_circle,
                ),
                
                _buildStatRow(
                  'Netzwerk',
                  stats['isOnline'] == true ? 'Online' : 'Offline',
                  stats['isOnline'] == true ? Icons.wifi : Icons.wifi_off,
                ),
                
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await DataSyncService.instance.syncNow(force: true);
                        },
                        icon: const Icon(Icons.sync),
                        label: const Text('Jetzt synchronisieren'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () async {
                        await DataSyncService.instance.clearSyncQueue();
                        // Refresh the widget
                        if (context.mounted) {
                          // Trigger rebuild by calling setState if needed
                        }
                      },
                      icon: const Icon(Icons.clear_all),
                      label: const Text('Queue leeren'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
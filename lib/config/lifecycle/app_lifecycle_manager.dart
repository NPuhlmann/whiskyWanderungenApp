import 'dart:developer';
import 'package:flutter/widgets.dart';
import '../../data/services/offline/offline_service.dart';
import '../../data/services/cache/local_cache_service.dart';

/// Manages application lifecycle events and proper resource cleanup
class AppLifecycleManager extends WidgetsBindingObserver {
  final OfflineService _offlineService;
  final LocalCacheService _localCacheService; // Currently unused but may be needed for future cache management
  bool _disposed = false;

  AppLifecycleManager({
    required OfflineService offlineService,
    required LocalCacheService localCacheService,
  })  : _offlineService = offlineService,
        _localCacheService = localCacheService;

  /// Initialize the lifecycle manager
  void initialize() {
    WidgetsBinding.instance.addObserver(this);
    log("🔄 AppLifecycleManager initialized");
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    switch (state) {
      case AppLifecycleState.resumed:
        _onAppResumed();
        break;
      case AppLifecycleState.inactive:
        _onAppInactive();
        break;
      case AppLifecycleState.paused:
        _onAppPaused();
        break;
      case AppLifecycleState.detached:
        _onAppDetached();
        break;
      case AppLifecycleState.hidden:
        _onAppHidden();
        break;
    }
  }

  void _onAppResumed() {
    log("📱 App resumed - performing maintenance cleanup");
    _performMaintenanceCleanup();
  }

  void _onAppInactive() {
    log("📱 App inactive");
  }

  void _onAppPaused() {
    log("📱 App paused - preparing for background state");
    _performMaintenanceCleanup();
  }

  void _onAppHidden() {
    log("📱 App hidden");
  }

  void _onAppDetached() {
    log("📱 App detached - performing final cleanup");
    dispose();
  }

  /// Perform maintenance cleanup on cache services
  void _performMaintenanceCleanup() async {
    try {
      if (!_disposed) {
        await _offlineService.performMaintenanceCleanup();
        // LocalCacheService cleanup could be added here if needed
        log("✅ Maintenance cleanup completed");
      }
    } catch (e) {
      log("❌ Error during maintenance cleanup: $e", error: e);
    }
  }

  /// Dispose all resources properly
  Future<void> dispose() async {
    if (_disposed) return;

    try {
      log("🧹 AppLifecycleManager disposing resources...");

      // Remove observer
      WidgetsBinding.instance.removeObserver(this);

      // Dispose services
      if (!_offlineService.isDisposed) {
        await _offlineService.dispose();
      }

      // LocalCacheService disposal if needed
      // await _localCacheService.dispose();

      _disposed = true;
      log("✅ AppLifecycleManager disposed successfully");
    } catch (e) {
      log("❌ Error during AppLifecycleManager disposal: $e", error: e);
    }
  }

  /// Check if the manager has been disposed
  bool get isDisposed => _disposed;
}
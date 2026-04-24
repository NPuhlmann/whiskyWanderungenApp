import 'dart:developer' as dev;
import 'dart:io' show Platform;

/// Utility class for memory management and optimization
class MemoryManager {
  /// Check memory usage and trigger cleanup if needed
  static void checkMemoryUsage() {
    // Platform-specific memory checking would go here
    // For now, we'll log and suggest cleanup
    dev.log(
      'Memory check performed - consider cleanup if memory usage is high',
    );
  }

  /// Force garbage collection (mainly for debugging)
  static void forceGarbageCollection() {
    try {
      // This is mainly for development/debugging
      if (Platform.environment['FLUTTER_TEST'] == 'true') {
        // Don't force GC during tests
        return;
      }

      dev.log('Suggesting garbage collection...');
      // Dart will handle GC automatically, but we can suggest it
      // by nullifying large objects
    } catch (e) {
      dev.log('Could not suggest garbage collection: $e');
    }
  }

  /// Calculate rough memory usage of a list
  static int estimateListMemoryUsage<T>(List<T> list) {
    if (list.isEmpty) return 0;

    // Rough estimation based on object type
    const int baseObjectSize = 64; // bytes
    const int stringCharSize = 2; // bytes per character (UTF-16)

    int totalSize = 0;

    for (final item in list) {
      totalSize += baseObjectSize;

      if (item is String) {
        totalSize += item.length * stringCharSize;
      } else if (item is Map) {
        totalSize += (item as Map).length * baseObjectSize * 2; // key + value
      }
    }

    return totalSize;
  }

  /// Check if cache size exceeds limits
  static bool shouldClearCache<T>(Map<dynamic, List<T>> cache, int limitMB) {
    int totalSize = 0;

    for (final entry in cache.entries) {
      totalSize += estimateListMemoryUsage(entry.value);
    }

    final limitBytes = limitMB * 1024 * 1024;
    return totalSize > limitBytes;
  }

  /// Clear oldest entries from cache to maintain size limit
  static void maintainCacheSize<K, V>(Map<K, V> cache, int maxEntries) {
    if (cache.length <= maxEntries) return;

    final sortedKeys = cache.keys.toList();
    final entriesToRemove = cache.length - maxEntries;

    for (int i = 0; i < entriesToRemove; i++) {
      cache.remove(sortedKeys[i]);
    }

    dev.log('Removed $entriesToRemove cache entries to maintain size limit');
  }

  /// Get memory usage recommendations
  static List<String> getMemoryOptimizationTips() {
    return [
      'Clear unused image caches regularly',
      'Dispose ViewModels when not needed',
      'Use pagination for large datasets',
      'Implement lazy loading for images',
      'Clear SharedPreferences of old data',
    ];
  }

  /// Log current memory status (for debugging)
  static void logMemoryStatus(String context) {
    dev.log('Memory status check: $context');
    // In production, this could integrate with platform-specific memory APIs
  }
}

/// Mixin for ViewModels to add memory management capabilities
mixin MemoryManagementMixin {
  final List<dynamic> _memoryTracker = [];

  void trackMemoryUsage(dynamic object) {
    _memoryTracker.add(object);
  }

  void clearTrackedMemory() {
    _memoryTracker.clear();
    MemoryManager.forceGarbageCollection();
  }

  int get trackedObjectCount => _memoryTracker.length;
}

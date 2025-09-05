import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';

import '../../../domain/models/waypoint.dart';
import '../location/location_service.dart';

/// Navigation Instruction für Turn-by-Turn Navigation
class NavigationInstruction {
  final Waypoint targetWaypoint;
  final double distanceToTarget;
  final double bearingToTarget;
  final String directionText;
  final Duration? estimatedTimeToArrival;
  final String instructionText;
  final NavigationInstructionType type;

  NavigationInstruction({
    required this.targetWaypoint,
    required this.distanceToTarget,
    required this.bearingToTarget,
    required this.directionText,
    this.estimatedTimeToArrival,
    required this.instructionText,
    required this.type,
  });
}

/// Typ der Navigation Instruction
enum NavigationInstructionType {
  start,
  continue_,
  approach,
  arrived,
  nextWaypoint,
  finished,
}

/// Status der aktuellen Navigation
enum NavigationStatus {
  idle,
  started,
  navigating,
  paused,
  waypoint_reached,
  completed,
  error,
}

/// Service für Turn-by-Turn Navigation zu Whisky Waypoints
/// 
/// Features:
/// - Automatische Wegpunkt-Navigation
/// - Turn-by-Turn Instructions
/// - Waypoint-Erreichung-Erkennung  
/// - Audio-Anweisungen Support
/// - Navigation State Management
class NavigationService extends ChangeNotifier {
  static NavigationService? _instance;
  static NavigationService get instance => _instance ??= NavigationService._internal();
  
  NavigationService._internal();

  final LocationService _locationService = LocationService.instance;
  
  List<Waypoint> _waypoints = [];
  int _currentWaypointIndex = 0;
  NavigationStatus _status = NavigationStatus.idle;
  NavigationInstruction? _currentInstruction;
  
  StreamSubscription<Position>? _positionSubscription;
  Timer? _navigationUpdateTimer;
  
  // Configuration
  static const double _approachingDistanceMeters = 50.0; // 50m = "approaching"
  static const double _arrivedDistanceMeters = 10.0; // 10m = "arrived"
  static const Duration _navigationUpdateInterval = Duration(seconds: 2);
  
  // Getters
  List<Waypoint> get waypoints => List.unmodifiable(_waypoints);
  int get currentWaypointIndex => _currentWaypointIndex;
  NavigationStatus get status => _status;
  NavigationInstruction? get currentInstruction => _currentInstruction;
  Waypoint? get currentWaypoint => 
    _currentWaypointIndex < _waypoints.length ? _waypoints[_currentWaypointIndex] : null;
  Waypoint? get nextWaypoint => 
    _currentWaypointIndex + 1 < _waypoints.length ? _waypoints[_currentWaypointIndex + 1] : null;

  /// Startet die Navigation zu einer Liste von Waypoints
  Future<bool> startNavigation(List<Waypoint> waypoints) async {
    if (waypoints.isEmpty) {
      log('Cannot start navigation: no waypoints provided');
      return false;
    }

    try {
      // Stoppe vorherige Navigation falls aktiv
      await stopNavigation();

      // Initialisiere Location Service
      bool locationReady = await _locationService.initialize();
      if (!locationReady) {
        _setStatus(NavigationStatus.error);
        return false;
      }

      // Starte GPS-Tracking
      bool trackingStarted = await _locationService.startTracking();
      if (!trackingStarted) {
        _setStatus(NavigationStatus.error);
        return false;
      }

      // Sortiere Waypoints nach orderIndex
      _waypoints = List.from(waypoints)..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
      _currentWaypointIndex = 0;

      // Starte Position Listener
      _positionSubscription = _locationService.positionStream.listen(
        _onPositionUpdate,
        onError: (error) {
          log('Navigation position error: $error');
          _setStatus(NavigationStatus.error);
        },
      );

      // Starte regelmäßige Navigation Updates
      _startNavigationUpdateTimer();

      _setStatus(NavigationStatus.started);
      _generateStartInstruction();

      log('Navigation started with ${_waypoints.length} waypoints');
      return true;
    } catch (e) {
      log('Error starting navigation: $e');
      _setStatus(NavigationStatus.error);
      return false;
    }
  }

  /// Pausiert die Navigation
  Future<void> pauseNavigation() async {
    if (_status == NavigationStatus.navigating) {
      _navigationUpdateTimer?.cancel();
      _setStatus(NavigationStatus.paused);
      log('Navigation paused');
    }
  }

  /// Setzt die Navigation fort
  Future<void> resumeNavigation() async {
    if (_status == NavigationStatus.paused) {
      _startNavigationUpdateTimer();
      _setStatus(NavigationStatus.navigating);
      log('Navigation resumed');
    }
  }

  /// Stoppt die Navigation komplett
  Future<void> stopNavigation() async {
    _navigationUpdateTimer?.cancel();
    await _positionSubscription?.cancel();
    
    _waypoints.clear();
    _currentWaypointIndex = 0;
    _currentInstruction = null;
    
    _setStatus(NavigationStatus.idle);
    log('Navigation stopped');
  }

  /// Springt zum nächsten Waypoint manuell
  Future<void> skipToNextWaypoint() async {
    if (_currentWaypointIndex < _waypoints.length - 1) {
      _currentWaypointIndex++;
      await _updateNavigationInstruction();
      log('Skipped to waypoint ${_currentWaypointIndex + 1}');
    }
  }

  /// Springt zum vorherigen Waypoint
  Future<void> skipToPreviousWaypoint() async {
    if (_currentWaypointIndex > 0) {
      _currentWaypointIndex--;
      await _updateNavigationInstruction();
      log('Skipped back to waypoint ${_currentWaypointIndex + 1}');
    }
  }

  /// Position Update Handler
  void _onPositionUpdate(Position position) {
    if (_status == NavigationStatus.idle || _status == NavigationStatus.completed) {
      return;
    }

    _checkWaypointProgress();
    _setStatus(NavigationStatus.navigating);
  }

  /// Prüft Fortschritt zu aktuellen Waypoint
  void _checkWaypointProgress() {
    final currentWp = currentWaypoint;
    if (currentWp == null) return;

    final distance = _locationService.calculateDistanceToWaypoint(currentWp);
    if (distance == null) return;

    // Prüfe ob Waypoint erreicht wurde
    if (distance <= _arrivedDistanceMeters) {
      _onWaypointReached(currentWp);
    }
  }

  /// Handler wenn Waypoint erreicht wurde
  void _onWaypointReached(Waypoint waypoint) {
    log('Waypoint reached: ${waypoint.name}');
    
    _setStatus(NavigationStatus.waypoint_reached);
    _generateArrivedInstruction(waypoint);

    // Automatisch zum nächsten Waypoint nach kurzer Verzögerung
    Timer(const Duration(seconds: 3), () {
      _proceedToNextWaypoint();
    });
  }

  /// Geht zum nächsten Waypoint über
  void _proceedToNextWaypoint() {
    if (_currentWaypointIndex < _waypoints.length - 1) {
      _currentWaypointIndex++;
      _updateNavigationInstruction();
      _setStatus(NavigationStatus.navigating);
    } else {
      // Navigation abgeschlossen
      _setStatus(NavigationStatus.completed);
      _generateCompletedInstruction();
      log('Navigation completed - all waypoints reached');
    }
  }

  /// Startet den Timer für regelmäßige Navigation Updates
  void _startNavigationUpdateTimer() {
    _navigationUpdateTimer?.cancel();
    _navigationUpdateTimer = Timer.periodic(_navigationUpdateInterval, (timer) {
      _updateNavigationInstruction();
    });
  }

  /// Aktualisiert die aktuelle Navigation Instruction
  Future<void> _updateNavigationInstruction() async {
    final currentWp = currentWaypoint;
    if (currentWp == null) return;

    final distance = _locationService.calculateDistanceToWaypoint(currentWp);
    final bearing = _locationService.calculateBearingToWaypoint(currentWp);
    final eta = _locationService.calculateEstimatedTimeToWaypoint(currentWp);

    if (distance == null || bearing == null) return;

    final directionText = _locationService.bearingToDirectionText(bearing);
    final distanceText = _locationService.formatDistance(distance);
    final etaText = eta != null ? _locationService.formatDuration(eta) : '';

    // Bestimme Instruction Type basierend auf Distanz
    NavigationInstructionType instructionType;
    String instructionText;

    if (distance <= _arrivedDistanceMeters) {
      instructionType = NavigationInstructionType.arrived;
      instructionText = 'Sie sind bei ${currentWp.name} angekommen!';
    } else if (distance <= _approachingDistanceMeters) {
      instructionType = NavigationInstructionType.approach;
      instructionText = 'Sie nähern sich ${currentWp.name} ($distanceText)';
    } else {
      instructionType = NavigationInstructionType.continue_;
      instructionText = 'Gehen Sie ${directionText} zu ${currentWp.name} ($distanceText, ca. $etaText)';
    }

    _currentInstruction = NavigationInstruction(
      targetWaypoint: currentWp,
      distanceToTarget: distance,
      bearingToTarget: bearing,
      directionText: directionText,
      estimatedTimeToArrival: eta,
      instructionText: instructionText,
      type: instructionType,
    );

    notifyListeners();
  }

  /// Generiert Start-Instruction
  void _generateStartInstruction() {
    final firstWp = currentWaypoint;
    if (firstWp == null) return;

    _currentInstruction = NavigationInstruction(
      targetWaypoint: firstWp,
      distanceToTarget: 0,
      bearingToTarget: 0,
      directionText: '',
      instructionText: 'Navigation zu ${firstWp.name} gestartet. Folgen Sie den Anweisungen.',
      type: NavigationInstructionType.start,
    );

    notifyListeners();
  }

  /// Generiert Ankunfts-Instruction
  void _generateArrivedInstruction(Waypoint waypoint) {
    _currentInstruction = NavigationInstruction(
      targetWaypoint: waypoint,
      distanceToTarget: 0,
      bearingToTarget: 0,
      directionText: '',
      instructionText: 'Sie haben ${waypoint.name} erreicht! Genießen Sie Ihr Whisky-Tasting.',
      type: NavigationInstructionType.arrived,
    );

    notifyListeners();
  }

  /// Generiert Abschluss-Instruction
  void _generateCompletedInstruction() {
    final lastWp = _waypoints.isNotEmpty ? _waypoints.last : null;
    
    _currentInstruction = NavigationInstruction(
      targetWaypoint: lastWp ?? Waypoint(
        id: 0, 
        hikeId: 0,
        name: 'Ende', 
        description: '', 
        latitude: 0, 
        longitude: 0, 
        orderIndex: 0,
        images: [],
        isVisited: true,
      ),
      distanceToTarget: 0,
      bearingToTarget: 0,
      directionText: '',
      instructionText: 'Herzlichen Glückwunsch! Sie haben alle Waypoints erreicht und die Whisky-Wanderung erfolgreich abgeschlossen.',
      type: NavigationInstructionType.finished,
    );

    notifyListeners();
  }

  /// Setzt den Navigation Status
  void _setStatus(NavigationStatus newStatus) {
    if (_status != newStatus) {
      _status = newStatus;
      notifyListeners();
    }
  }

  /// Gibt detaillierte Navigation Statistics zurück
  Map<String, dynamic> getNavigationStatistics() {
    final totalWaypoints = _waypoints.length;
    final completedWaypoints = _currentWaypointIndex;
    final remainingWaypoints = totalWaypoints - completedWaypoints;
    
    double totalDistanceRemaining = 0;
    if (_locationService.lastKnownPosition != null) {
      for (int i = _currentWaypointIndex; i < _waypoints.length; i++) {
        final distance = _locationService.calculateDistanceToWaypoint(_waypoints[i]);
        if (distance != null) {
          totalDistanceRemaining += distance;
        }
      }
    }

    return {
      'totalWaypoints': totalWaypoints,
      'completedWaypoints': completedWaypoints,
      'remainingWaypoints': remainingWaypoints,
      'progress': totalWaypoints > 0 ? completedWaypoints / totalWaypoints : 0.0,
      'status': _status.toString(),
      'totalDistanceRemaining': totalDistanceRemaining,
      'formattedDistanceRemaining': _locationService.formatDistance(totalDistanceRemaining),
    };
  }

  /// Cleanup resources
  @override
  void dispose() {
    stopNavigation();
    super.dispose();
  }

  /// Prüft ob alle nötigen Permissions verfügbar sind
  Future<bool> checkNavigationPermissions() async {
    return await _locationService.initialize();
  }

  /// Fordert nötige Permissions für Navigation an
  Future<bool> requestNavigationPermissions() async {
    bool locationReady = await _locationService.initialize();
    if (!locationReady) {
      await _locationService.openAppSettings();
      return false;
    }
    return true;
  }
}
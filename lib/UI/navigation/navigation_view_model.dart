import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';

import '../../domain/models/waypoint.dart';
import '../../data/services/location/location_service.dart';
import '../../data/services/navigation/navigation_service.dart';

/// ViewModel für die Navigationsansicht
/// 
/// Verwaltet:
/// - Navigation State und Instructions
/// - Audio-Anweisungen
/// - Turn-by-Turn UI Updates
/// - Navigation Controls
/// - Progress Tracking
class NavigationViewModel extends ChangeNotifier {
  final LocationService _locationService = LocationService.instance;
  final NavigationService _navigationService = NavigationService.instance;

  // Navigation State
  bool _isNavigating = false;
  bool _isPaused = false;
  List<Waypoint> _waypoints = [];
  NavigationInstruction? _currentInstruction;
  
  // Progress State
  int _currentWaypointIndex = 0;
  int _completedWaypoints = 0;
  double _progress = 0.0;
  
  // Audio State
  bool _audioEnabled = true;
  bool _isSpeaking = false;
  
  // Error State
  String? _error;
  
  // Subscriptions
  StreamSubscription<Position>? _positionSubscription;

  // Getters
  bool get isNavigating => _isNavigating;
  bool get isPaused => _isPaused;
  List<Waypoint> get waypoints => List.unmodifiable(_waypoints);
  NavigationInstruction? get currentInstruction => _currentInstruction;
  int get currentWaypointIndex => _currentWaypointIndex;
  int get completedWaypoints => _completedWaypoints;
  double get progress => _progress;
  bool get audioEnabled => _audioEnabled;
  bool get isSpeaking => _isSpeaking;
  String? get error => _error;
  
  // Convenience getters
  Waypoint? get currentWaypoint => 
    _currentWaypointIndex < _waypoints.length ? _waypoints[_currentWaypointIndex] : null;
  Waypoint? get nextWaypoint => 
    _currentWaypointIndex + 1 < _waypoints.length ? _waypoints[_currentWaypointIndex + 1] : null;
  int get totalWaypoints => _waypoints.length;
  int get remainingWaypoints => _waypoints.length - _completedWaypoints;

  /// Startet die Navigation mit gegebenen Waypoints
  Future<bool> startNavigation(List<Waypoint> waypoints) async {
    if (waypoints.isEmpty) {
      _error = 'Keine Waypoints für Navigation verfügbar';
      notifyListeners();
      return false;
    }

    try {
      _error = null;
      
      // Sortiere Waypoints nach orderIndex
      _waypoints = List.from(waypoints)..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
      _currentWaypointIndex = 0;
      _completedWaypoints = 0;
      _progress = 0.0;

      // Starte Navigation Service
      bool navigationStarted = await _navigationService.startNavigation(_waypoints);
      if (!navigationStarted) {
        _error = 'Navigation konnte nicht gestartet werden';
        notifyListeners();
        return false;
      }

      // Setup listeners
      _navigationService.addListener(_onNavigationUpdate);

      _isNavigating = true;
      _isPaused = false;
      
      // Sprich erste Anweisung
      await speakCurrentInstruction();

      notifyListeners();
      log('Navigation started with ${_waypoints.length} waypoints');
      return true;
    } catch (e) {
      log('Error starting navigation: $e');
      _error = 'Fehler beim Starten der Navigation: $e';
      notifyListeners();
      return false;
    }
  }

  /// Stoppt die Navigation
  Future<void> stopNavigation() async {
    try {
      await _navigationService.stopNavigation();
      _navigationService.removeListener(_onNavigationUpdate);

      _isNavigating = false;
      _isPaused = false;
      _currentInstruction = null;
      _waypoints.clear();
      _currentWaypointIndex = 0;
      _completedWaypoints = 0;
      _progress = 0.0;
      _error = null;

      notifyListeners();
      log('Navigation stopped');
    } catch (e) {
      log('Error stopping navigation: $e');
    }
  }

  /// Pausiert die Navigation
  Future<void> pauseNavigation() async {
    if (_isNavigating && !_isPaused) {
      await _navigationService.pauseNavigation();
      _isPaused = true;
      notifyListeners();
    }
  }

  /// Setzt die Navigation fort
  Future<void> resumeNavigation() async {
    if (_isNavigating && _isPaused) {
      await _navigationService.resumeNavigation();
      _isPaused = false;
      await speakCurrentInstruction();
      notifyListeners();
    }
  }

  /// Springt zum nächsten Waypoint
  Future<void> skipToNextWaypoint() async {
    if (_isNavigating && _currentWaypointIndex < _waypoints.length - 1) {
      await _navigationService.skipToNextWaypoint();
      _currentWaypointIndex++;
      _updateProgress();
      await speakCurrentInstruction();
      notifyListeners();
    }
  }

  /// Springt zum vorherigen Waypoint
  Future<void> skipToPreviousWaypoint() async {
    if (_isNavigating && _currentWaypointIndex > 0) {
      await _navigationService.skipToPreviousWaypoint();
      _currentWaypointIndex--;
      _updateProgress();
      await speakCurrentInstruction();
      notifyListeners();
    }
  }

  /// Aktiviert/Deaktiviert Audio-Anweisungen
  void toggleAudio() {
    _audioEnabled = !_audioEnabled;
    notifyListeners();
  }

  /// Spricht die aktuelle Anweisung
  Future<void> speakCurrentInstruction() async {
    if (_audioEnabled && _currentInstruction != null) {
      await _speakText(_currentInstruction!.instructionText);
    }
  }

  /// Navigation Update Handler
  void _onNavigationUpdate() {
    // Update current instruction from navigation service
    _currentInstruction = _navigationService.currentInstruction;
    
    // Update waypoint index and progress
    if (_navigationService.currentWaypointIndex != _currentWaypointIndex) {
      _currentWaypointIndex = _navigationService.currentWaypointIndex;
      _updateProgress();
    }

    // Handle navigation status changes
    final status = _navigationService.status;
    switch (status) {
      case NavigationStatus.waypoint_reached:
        _onWaypointReached();
        break;
      case NavigationStatus.completed:
        _onNavigationCompleted();
        break;
      case NavigationStatus.error:
        _error = 'Navigation Fehler aufgetreten';
        break;
      default:
        break;
    }

    // Auto-speak new instructions
    if (_audioEnabled && _currentInstruction != null) {
      speakCurrentInstruction();
    }

    notifyListeners();
  }

  /// Handler wenn Waypoint erreicht wurde
  void _onWaypointReached() {
    _completedWaypoints++;
    _updateProgress();
    
    // Vibration feedback
    HapticFeedback.mediumImpact();
    
    log('Waypoint reached: ${_completedWaypoints}/${_waypoints.length}');
  }

  /// Handler wenn Navigation abgeschlossen ist
  void _onNavigationCompleted() {
    _isNavigating = false;
    _isPaused = false;
    _completedWaypoints = _waypoints.length;
    _progress = 1.0;
    
    // Celebration feedback
    HapticFeedback.heavyImpact();
    
    log('Navigation completed successfully');
  }

  /// Aktualisiert den Progress
  void _updateProgress() {
    if (_waypoints.isNotEmpty) {
      _progress = _completedWaypoints / _waypoints.length;
    } else {
      _progress = 0.0;
    }
  }

  /// Spricht Text aus (Platzhalter für TTS Implementation)
  Future<void> _speakText(String text) async {
    if (!_audioEnabled || _isSpeaking) return;

    try {
      _isSpeaking = true;
      notifyListeners();

      // Hier würde eine TTS-Implementation stehen
      // Für jetzt simulieren wir nur die Sprachdauer
      log('Speaking: $text');
      await Future.delayed(Duration(seconds: text.length ~/ 20 + 1));

      _isSpeaking = false;
      notifyListeners();
    } catch (e) {
      log('Error speaking text: $e');
      _isSpeaking = false;
      notifyListeners();
    }
  }

  /// Gibt Navigation Statistics zurück
  Map<String, dynamic> getNavigationStatistics() {
    final stats = _navigationService.getNavigationStatistics();
    
    return {
      ...stats,
      'audioEnabled': _audioEnabled,
      'isPaused': _isPaused,
      'currentWaypoint': currentWaypoint?.name ?? 'N/A',
      'nextWaypoint': nextWaypoint?.name ?? 'Keine weiteren',
    };
  }

  /// Berechnet Zeit bis zum nächsten Waypoint
  String? getEstimatedTimeToCurrentWaypoint() {
    final currentWp = currentWaypoint;
    if (currentWp == null) return null;

    final eta = _locationService.calculateEstimatedTimeToWaypoint(currentWp);
    return eta != null ? _locationService.formatDuration(eta) : null;
  }

  /// Berechnet Distanz zum aktuellen Waypoint
  String? getDistanceToCurrentWaypoint() {
    final currentWp = currentWaypoint;
    if (currentWp == null) return null;

    final distance = _locationService.calculateDistanceToWaypoint(currentWp);
    return distance != null ? _locationService.formatDistance(distance) : null;
  }

  /// Berechnet Richtung zum aktuellen Waypoint
  String? getBearingToCurrentWaypoint() {
    final currentWp = currentWaypoint;
    if (currentWp == null) return null;

    final bearing = _locationService.calculateBearingToWaypoint(currentWp);
    return bearing != null ? _locationService.bearingToDirectionText(bearing) : null;
  }

  /// Prüft Navigation Permissions
  Future<bool> checkNavigationPermissions() async {
    return await _navigationService.checkNavigationPermissions();
  }

  /// Fordert Navigation Permissions an
  Future<bool> requestNavigationPermissions() async {
    return await _navigationService.requestNavigationPermissions();
  }

  /// Öffnet Location Settings
  Future<void> openLocationSettings() async {
    await _locationService.openLocationSettings();
  }

  /// Öffnet App Settings
  Future<void> openAppSettings() async {
    await _locationService.openAppSettings();
  }

  /// Setzt Fehler zurück
  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    // Cleanup subscriptions
    _positionSubscription?.cancel();
    _navigationService.removeListener(_onNavigationUpdate);
    
    // Stop navigation if active
    if (_isNavigating) {
      _navigationService.stopNavigation();
    }
    
    super.dispose();
  }
}

/// Extension für bessere Formatierung von Navigation Instructions
extension NavigationInstructionFormatting on NavigationInstruction {
  /// Gibt eine kurze Zusammenfassung der Instruction zurück
  String get shortSummary {
    switch (type) {
      case NavigationInstructionType.start:
        return 'Navigation gestartet';
      case NavigationInstructionType.continue_:
        return 'Weiter ${directionText}';
      case NavigationInstructionType.approach:
        return 'Nähert sich ${targetWaypoint.name}';
      case NavigationInstructionType.arrived:
        return 'Angekommen bei ${targetWaypoint.name}';
      case NavigationInstructionType.nextWaypoint:
        return 'Nächster Punkt: ${targetWaypoint.name}';
      case NavigationInstructionType.finished:
        return 'Navigation abgeschlossen';
    }
  }

  /// Gibt ein Icon für die Instruction zurück
  IconData get icon {
    switch (type) {
      case NavigationInstructionType.start:
        return Icons.play_arrow;
      case NavigationInstructionType.continue_:
        return Icons.straight;
      case NavigationInstructionType.approach:
        return Icons.near_me;
      case NavigationInstructionType.arrived:
        return Icons.location_on;
      case NavigationInstructionType.nextWaypoint:
        return Icons.next_plan;
      case NavigationInstructionType.finished:
        return Icons.flag;
    }
  }

  /// Gibt eine Farbe für die Instruction zurück
  Color get color {
    switch (type) {
      case NavigationInstructionType.start:
        return Colors.green;
      case NavigationInstructionType.continue_:
        return Colors.blue;
      case NavigationInstructionType.approach:
        return Colors.orange;
      case NavigationInstructionType.arrived:
        return Colors.red;
      case NavigationInstructionType.nextWaypoint:
        return Colors.purple;
      case NavigationInstructionType.finished:
        return Colors.green;
    }
  }
}
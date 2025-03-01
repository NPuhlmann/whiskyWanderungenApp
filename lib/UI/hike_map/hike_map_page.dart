import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:developer' as developer;

import '../../domain/models/hike.dart';
import '../../domain/models/waypoint.dart';
import 'hike_map_view_model.dart';
import 'widgets/waypoint_detail_sheet.dart';

class HikeMapPage extends StatefulWidget {
  const HikeMapPage({
    Key? key,
    required this.hike,
    required this.viewModel,
  }) : super(key: key);

  final Hike hike;
  final HikeMapViewModel viewModel;

  @override
  State<HikeMapPage> createState() => _HikeMapPageState();
}

class _HikeMapPageState extends State<HikeMapPage> with WidgetsBindingObserver {
  // MapController wird erst bei Bedarf initialisiert
  MapController? _mapController;
  Timer? _locationTimer;
  bool _isBottomSheetOpen = false;
  bool _isDisposed = false;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Verzögere das Laden der Wegpunkte
    Future.microtask(() {
      if (!_isDisposed) {
        _mapController = MapController();
        _loadWaypoints();
        _requestLocationPermission();
      }
    });
  }
  
  @override
  void dispose() {
    _isDisposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _locationTimer?.cancel();
    // Entsorge den Controller nur, wenn er existiert
    _mapController?.dispose();
    _mapController = null;
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // App wurde wieder in den Vordergrund gebracht
      if (_mapController == null && !_isDisposed) {
        _mapController = MapController();
      }
    }
  }
  
  Future<void> _loadWaypoints() async {
    if (_isDisposed) return;
    
    try {
      await widget.viewModel.loadWaypointsForHike(widget.hike.id);
      
      if (_isDisposed || !mounted) return; // Prüfe, ob das Widget noch montiert ist
      
      if (widget.viewModel.waypoints.isNotEmpty) {
        // Zentriere die Karte auf den ersten Wegpunkt
        final waypoint = widget.viewModel.waypoints.first;
        if (mounted && _mapController != null && !_isDisposed) { // Prüfe, ob der Controller existiert
          _mapController!.move(
            LatLng(waypoint.latitude, waypoint.longitude),
            13.0,
          );
        }
      } else {
        // Wenn keine Wegpunkte vorhanden sind, zeige eine Snackbar an
        developer.log("Keine Wegpunkte gefunden");
        if (mounted && !_isDisposed) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)?.noWaypointsFound ?? 'Keine Wegpunkte gefunden'),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      // Bei einem Fehler zeige eine Snackbar an
      developer.log("Fehler beim Laden der Wegpunkte - _loadWaypoints: $e");
      if (mounted && !_isDisposed) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fehler beim Laden der Wegpunkte: $e'),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }
  
  Future<void> _requestLocationPermission() async {
    if (_isDisposed || !mounted) return;
    
    bool serviceEnabled;
    LocationPermission permission;

    try {
      // Überprüfe, ob der Standortdienst aktiviert ist
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled || _isDisposed || !mounted) {
        return;
      }

      // Überprüfe die Standortberechtigung
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied || _isDisposed || !mounted) {
          return;
        }
      }
      
      if (permission == LocationPermission.deniedForever || _isDisposed || !mounted) {
        return;
      }

      // Starte die regelmäßige Positionsaktualisierung
      if (!_isDisposed && mounted) {
        _startLocationUpdates();
      }
    } catch (e) {
      developer.log("Fehler bei der Standortberechtigung: $e");
    }
  }
  
  void _startLocationUpdates() {
    _locationTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (_isDisposed) {
        timer.cancel();
        return;
      }
      
      try {
        await widget.viewModel.updateCurrentPosition();
        
        if (_isDisposed || !mounted) return;
        
        if (widget.viewModel.isNearWaypoint && 
            !_isBottomSheetOpen && 
            widget.viewModel.selectedWaypoint != null) {
          _showWaypointBottomSheet(widget.viewModel.selectedWaypoint!);
        }
      } catch (e) {
        developer.log("Fehler beim Aktualisieren der Position: $e");
      }
    });
  }
  
  void _showWaypointBottomSheet(Waypoint waypoint) {
    if (_isDisposed || !mounted) return;
    
    setState(() {
      _isBottomSheetOpen = true;
    });
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => WaypointDetailSheet(
        waypoint: waypoint,
        onClose: () {
          if (_isDisposed || !mounted) return;
          setState(() {
            _isBottomSheetOpen = false;
          });
        },
      ),
    ).then((_) {
      if (_isDisposed || !mounted) return;
      setState(() {
        _isBottomSheetOpen = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Wenn der Controller entsorgt wurde, erstelle einen neuen
    if (_mapController == null && !_isDisposed) {
      _mapController = MapController();
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.hike.name),
      ),
      body: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, _) {
          if (widget.viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          // Auch wenn ein Fehler vorliegt, zeigen wir die Karte an
          // Der Fehler wird bereits in der Snackbar angezeigt
          
          // Wenn der Controller entsorgt wurde, zeige eine Fehlermeldung
          if (_mapController == null) {
            return const Center(
              child: Text('Karte konnte nicht geladen werden. Bitte versuchen Sie es erneut.'),
            );
          }
          
          return FlutterMap(
            mapController: _mapController!,
            options: MapOptions(
              initialCenter: LatLng(47.3769, 8.5417), // Standard: Zürich als Fallback
              initialZoom: 13.0,
              onTap: (_, point) {
                // Schließe das Bottom Sheet, wenn auf die Karte getippt wird
                if (_isBottomSheetOpen) {
                  Navigator.of(context).pop();
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
              ),
              // Zeichne die Route
              if (widget.viewModel.routePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: widget.viewModel.routePoints
                          .map((point) => LatLng(point[0], point[1]))
                          .toList(),
                      color: Colors.blue,
                      strokeWidth: 4.0,
                    ),
                  ],
                ),
              // Zeichne die Wegpunkte
              if (widget.viewModel.waypoints.isNotEmpty)
                MarkerLayer(
                  markers: widget.viewModel.waypoints.map((waypoint) {
                    return Marker(
                      point: LatLng(waypoint.latitude, waypoint.longitude),
                      width: 40,
                      height: 40,
                      child: GestureDetector(
                        onTap: () => _showWaypointBottomSheet(waypoint),
                        child: Icon(
                          Icons.location_on,
                          color: widget.viewModel.selectedWaypoint?.id == waypoint.id
                              ? Colors.red
                              : Colors.blue,
                          size: 40,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              // Zeichne die aktuelle Position
              if (widget.viewModel.currentPosition != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(
                        widget.viewModel.currentPosition!.latitude,
                        widget.viewModel.currentPosition!.longitude,
                      ),
                      width: 30,
                      height: 30,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.my_location,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (widget.viewModel.currentPosition != null && _mapController != null && !_isDisposed) {
            _mapController!.move(
              LatLng(
                widget.viewModel.currentPosition!.latitude,
                widget.viewModel.currentPosition!.longitude,
              ),
              15.0,
            );
          }
        },
        child: const Icon(Icons.my_location),
      ),
    );
  }
} 
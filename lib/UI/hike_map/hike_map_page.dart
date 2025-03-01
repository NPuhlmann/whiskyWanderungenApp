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
  // Wir verwenden eine Referenz, um den Controller zu speichern, der von der Karte erstellt wird
  final _mapControllerRef = MapController();
  Timer? _locationTimer;
  bool _isBottomSheetOpen = false;
  bool _isDisposed = false;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Verzögere nur das Anfordern der Standortberechtigung
    Future.delayed(Duration(milliseconds: 100), () {
      if (!_isDisposed && mounted) {
        _requestLocationPermission();
      }
    });
  }
  
  @override
  void dispose() {
    _isDisposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _locationTimer?.cancel();
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Wir müssen hier nichts tun, da der Controller von der Karte verwaltet wird
  }
  
  // Diese Methode wird aufgerufen, wenn die Karte bereit ist
  void _onMapReady() {
    if (_isDisposed || !mounted) return;
    
    // Lade die Wegpunkte, nachdem die Karte erstellt wurde
    _loadWaypoints();
  }
  
  Future<void> _loadWaypoints() async {
    if (_isDisposed || !mounted) return;
    
    try {
      await widget.viewModel.loadWaypointsForHike(widget.hike.id);
      
      if (_isDisposed || !mounted) return; // Prüfe, ob das Widget noch montiert ist
      
      if (widget.viewModel.waypoints.isNotEmpty) {
        // Zentriere die Karte auf den ersten Wegpunkt
        final waypoint = widget.viewModel.waypoints.first;
        try {
          _mapControllerRef.move(
            LatLng(waypoint.latitude, waypoint.longitude),
            13.0,
          );
        } catch (e) {
          developer.log("Fehler beim Bewegen der Karte: $e");
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
    
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (_isDisposed || !mounted) return;
        
        // Standortdienste sind deaktiviert, zeige eine Meldung an
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Standortdienste sind deaktiviert'),
            duration: const Duration(seconds: 3),
          ),
        );
        return;
      }
      
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        if (_isDisposed || !mounted) return;
        
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (_isDisposed || !mounted) return;
          
          // Berechtigung verweigert, zeige eine Meldung an
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Standortberechtigung verweigert'),
              duration: const Duration(seconds: 3),
            ),
          );
          return;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        if (_isDisposed || !mounted) return;
        
        // Berechtigung dauerhaft verweigert, zeige eine Meldung an
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Standortberechtigung dauerhaft verweigert'),
            duration: const Duration(seconds: 3),
          ),
        );
        return;
      }
      
      // Berechtigung erteilt, starte Standortupdates
      if (!_isDisposed && mounted) {
        _startLocationUpdates();
      }
    } catch (e) {
      developer.log("Fehler bei der Standortberechtigung: $e");
      if (!_isDisposed && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fehler bei der Standortberechtigung: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
  
  void _startLocationUpdates() {
    if (_isDisposed || !mounted) return;
    
    // Starte einen Timer, der alle 5 Sekunden den Standort aktualisiert
    _locationTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (_isDisposed) {
        timer.cancel();
        return;
      }
      
      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        
        if (_isDisposed || !mounted) return;
        
        // Aktualisiere den Standort im ViewModel
        widget.viewModel.updateCurrentPosition(position);
        
        // Die Methode _checkIfNearWaypoint wird automatisch in updateCurrentPosition aufgerufen
        
        // Wenn ein Wegpunkt ausgewählt ist und der Benutzer in der Nähe ist, zeige das Bottom Sheet an
        if (widget.viewModel.isNearWaypoint && 
            widget.viewModel.selectedWaypoint != null && 
            !_isBottomSheetOpen &&
            !_isDisposed && 
            mounted) {
          _showWaypointBottomSheet(widget.viewModel.selectedWaypoint!);
        }
      } catch (e) {
        developer.log("Fehler bei der Standortaktualisierung: $e");
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
      builder: (context) => WaypointDetailSheet(
        waypoint: waypoint,
        onClose: () {
          if (!_isDisposed && mounted) {
            setState(() {
              _isBottomSheetOpen = false;
            });
          }
        },
      ),
    ).then((_) {
      if (!_isDisposed && mounted) {
        setState(() {
          _isBottomSheetOpen = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
          
          return FlutterMap(
            mapController: _mapControllerRef,
            options: MapOptions(
              initialCenter: LatLng(47.3769, 8.5417), // Standard: Zürich als Fallback
              initialZoom: 13.0,
              onTap: (_, point) {
                // Schließe das Bottom Sheet, wenn auf die Karte getippt wird
                if (_isBottomSheetOpen) {
                  Navigator.of(context).pop();
                }
              },
              onMapReady: _onMapReady,
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
          if (widget.viewModel.currentPosition != null && !_isDisposed) {
            _mapControllerRef.move(
              LatLng(
                widget.viewModel.currentPosition!.latitude,
                widget.viewModel.currentPosition!.longitude,
              ),
              13.0,
            );
          }
        },
        child: const Icon(Icons.my_location),
      ),
    );
  }
} 
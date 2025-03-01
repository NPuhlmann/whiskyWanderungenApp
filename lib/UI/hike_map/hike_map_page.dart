import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:geolocator/geolocator.dart';

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

class _HikeMapPageState extends State<HikeMapPage> {
  final MapController _mapController = MapController();
  Timer? _locationTimer;
  bool _isBottomSheetOpen = false;
  
  @override
  void initState() {
    super.initState();
    _loadWaypoints();
    _requestLocationPermission();
  }
  
  @override
  void dispose() {
    _locationTimer?.cancel();
    super.dispose();
  }
  
  Future<void> _loadWaypoints() async {
    await widget.viewModel.loadWaypointsForHike(widget.hike.id);
    
    if (widget.viewModel.waypoints.isNotEmpty) {
      // Zentriere die Karte auf den ersten Wegpunkt
      final waypoint = widget.viewModel.waypoints.first;
      _mapController.move(
        LatLng(waypoint.latitude, waypoint.longitude),
        13.0,
      );
    }
  }
  
  Future<void> _requestLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Überprüfe, ob der Standortdienst aktiviert ist
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    // Überprüfe die Standortberechtigung
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return;
    }

    // Starte die regelmäßige Positionsaktualisierung
    _startLocationUpdates();
  }
  
  void _startLocationUpdates() {
    _locationTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      await widget.viewModel.updateCurrentPosition();
      
      if (widget.viewModel.isNearWaypoint && !_isBottomSheetOpen) {
        _showWaypointBottomSheet(widget.viewModel.selectedWaypoint!);
      }
    });
  }
  
  void _showWaypointBottomSheet(Waypoint waypoint) {
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
          setState(() {
            _isBottomSheetOpen = false;
          });
        },
      ),
    ).then((_) {
      setState(() {
        _isBottomSheetOpen = false;
      });
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
          
          if (widget.viewModel.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.viewModel.errorMessage!,
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadWaypoints,
                    child: Text(AppLocalizations.of(context)!.tryAgain),
                  ),
                ],
              ),
            );
          }
          
          if (widget.viewModel.waypoints.isEmpty) {
            return Center(
              child: Text(
                AppLocalizations.of(context)!.noWaypointsFound,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
            );
          }
          
          return FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(0, 0), // Wird später aktualisiert
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
          if (widget.viewModel.currentPosition != null) {
            _mapController.move(
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
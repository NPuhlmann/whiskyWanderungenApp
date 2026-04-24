import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../../domain/models/waypoint.dart';
import '../../../data/repositories/waypoint_repository.dart';
import 'hike_map_view_model.dart';

class HikeMapScreen extends StatelessWidget {
  final int hikeId;

  const HikeMapScreen({super.key, required this.hikeId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HikeMapViewModel(
        hikeId: hikeId,
        waypointRepository: Provider.of<WaypointRepository>(
          context,
          listen: false,
        ),
      ),
      child: const HikeMapView(),
    );
  }
}

class HikeMapView extends StatefulWidget {
  const HikeMapView({super.key});

  @override
  State<HikeMapView> createState() => _HikeMapViewState();
}

class _HikeMapViewState extends State<HikeMapView> {
  late final MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();

    // Wegpunkte beim Start laden
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HikeMapViewModel>().loadWaypoints();
    });
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  // Hilfsmethode zum Aktualisieren der Karte
  void _updateMapView() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wanderkarte')),
      body: Consumer<HikeMapViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Fehler: ${viewModel.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: viewModel.loadWaypoints,
                    child: const Text('Erneut versuchen'),
                  ),
                ],
              ),
            );
          }

          final waypoints = viewModel.waypoints;

          // Wenn keine Wegpunkte vorhanden sind
          if (waypoints.isEmpty) {
            return const Center(
              child: Text('Keine Wegpunkte für diese Wanderung vorhanden.'),
            );
          }

          // Berechne den Mittelpunkt aller Wegpunkte für die initiale Kartenansicht
          LatLng centerPoint;
          try {
            final centerLat =
                waypoints.map((w) => w.latitude).reduce((a, b) => a + b) /
                waypoints.length;
            final centerLng =
                waypoints.map((w) => w.longitude).reduce((a, b) => a + b) /
                waypoints.length;
            centerPoint = LatLng(centerLat, centerLng);
          } catch (e) {
            // Fallback für Deutschland, falls ein Fehler auftritt
            centerPoint = const LatLng(51.1657, 10.4515);
          }

          return Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: centerPoint,
                  initialZoom: 13.0,
                  minZoom: 3.0,
                  maxZoom: 18.0,
                  interactionOptions: const InteractionOptions(
                    enableMultiFingerGestureRace: true,
                    flags: InteractiveFlag.all,
                  ),
                  onMapEvent: (event) {
                    // Aktualisiere die Ansicht bei Zoom-Änderungen
                    if (event is MapEventMoveEnd) {
                      _updateMapView();
                    }
                  },
                  onTap: (_, point) {
                    // Schließe offene Popups, wenn auf die Karte getippt wird
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.whisky_hikes.app',
                    subdomains: const ['a', 'b', 'c'],
                    maxZoom: 19,
                    tileProvider: NetworkTileProvider(),
                  ),
                  MarkerLayer(markers: _buildMarkers(waypoints)),
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: waypoints
                            .map(
                              (waypoint) =>
                                  LatLng(waypoint.latitude, waypoint.longitude),
                            )
                            .toList(),
                        color: Colors.blue,
                        strokeWidth: 3.0,
                      ),
                    ],
                  ),
                ],
              ),
              // Zoom-Steuerelemente
              Positioned(
                right: 16,
                bottom: 100,
                child: Column(
                  children: [
                    FloatingActionButton.small(
                      heroTag: 'zoomIn',
                      backgroundColor: Colors.white.withValues(alpha: 0.8),
                      foregroundColor: Colors.black,
                      onPressed: () {
                        final currentZoom = _mapController.camera.zoom;
                        if (currentZoom < 18.0) {
                          _mapController.move(
                            _mapController.camera.center,
                            currentZoom + 1.0,
                          );
                        }
                      },
                      child: const Icon(Icons.add),
                    ),
                    const SizedBox(height: 8),
                    FloatingActionButton.small(
                      heroTag: 'zoomOut',
                      backgroundColor: Colors.white.withValues(alpha: 0.8),
                      foregroundColor: Colors.black,
                      onPressed: () {
                        final currentZoom = _mapController.camera.zoom;
                        if (currentZoom > 3.0) {
                          _mapController.move(
                            _mapController.camera.center,
                            currentZoom - 1.0,
                          );
                        }
                      },
                      child: const Icon(Icons.remove),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white.withValues(alpha: 0.8),
        foregroundColor: Colors.black,
        onPressed: () {
          // Hier könnte man einen neuen Wegpunkt hinzufügen
          // oder die aktuelle Position anzeigen
          _mapController.moveAndRotate(
            context.read<HikeMapViewModel>().getCurrentCenter(),
            13.0,
            0.0,
          );
        },
        child: const Icon(Icons.my_location),
      ),
    );
  }

  List<Marker> _buildMarkers(List<Waypoint> waypoints) {
    return waypoints.map((waypoint) {
      return Marker(
        width: 40.0,
        height: 40.0,
        point: LatLng(waypoint.latitude, waypoint.longitude),
        child: GestureDetector(
          onTap: () => _showWaypointDetails(waypoint),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: waypoint.isVisited ? Colors.green : Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_on,
                  color: Colors.white,
                  size: 25.0,
                ),
              ),
              Text(
                waypoint.name,
                style: const TextStyle(
                  fontSize: 9.0,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  void _showWaypointDetails(Waypoint waypoint) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                waypoint.name,
                style: const TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),
              Text(waypoint.description),
              const SizedBox(height: 16.0),
              if (waypoint.images.isNotEmpty) ...[
                const Text(
                  'Bilder:',
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8.0),
                SizedBox(
                  height: 100.0,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: waypoint.images.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Image.network(
                          waypoint.images[index],
                          height: 100.0,
                          width: 100.0,
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),
                ),
              ],
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Besucht: ${waypoint.isVisited ? 'Ja' : 'Nein'}',
                    style: TextStyle(
                      color: waypoint.isVisited ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      context.read<HikeMapViewModel>().toggleWaypointVisited(
                        waypoint,
                      );
                      Navigator.pop(context);
                    },
                    child: Text(
                      waypoint.isVisited
                          ? 'Als unbesucht markieren'
                          : 'Als besucht markieren',
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

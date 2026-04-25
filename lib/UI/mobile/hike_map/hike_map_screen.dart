import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HikeMapViewModel>().loadWaypoints();
    });
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
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

          if (waypoints.isEmpty) {
            return const Center(
              child: Text('Keine Wegpunkte für diese Wanderung vorhanden.'),
            );
          }

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
                  onTap: (tap, point) {
                    viewModel.selectWaypoint(null);
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
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: waypoints
                            .map((w) => LatLng(w.latitude, w.longitude))
                            .toList(),
                        color: Colors.blue,
                        strokeWidth: 3.0,
                      ),
                    ],
                  ),
                  MarkerLayer(
                    markers: _buildMarkers(
                      waypoints,
                      viewModel.selectedWaypoint,
                    ),
                  ),
                ],
              ),
              // Permission denied banner
              if (viewModel.locationPermissionStatus ==
                      LocationPermissionStatus.deniedForever ||
                  viewModel.locationPermissionStatus ==
                      LocationPermissionStatus.denied)
                _LocationPermissionBanner(
                  isPermanentlyDenied:
                      viewModel.locationPermissionStatus ==
                      LocationPermissionStatus.deniedForever,
                ),
              // Zoom controls
              Positioned(
                right: 16,
                bottom: viewModel.selectedWaypoint != null ? 220 : 100,
                child: Column(
                  children: [
                    FloatingActionButton.small(
                      heroTag: 'zoomIn',
                      backgroundColor: Colors.white.withValues(alpha: 0.9),
                      foregroundColor: Colors.black,
                      onPressed: () {
                        final zoom = _mapController.camera.zoom;
                        if (zoom < 18.0) {
                          _mapController.move(
                            _mapController.camera.center,
                            zoom + 1.0,
                          );
                        }
                      },
                      child: const Icon(Icons.add),
                    ),
                    const SizedBox(height: 8),
                    FloatingActionButton.small(
                      heroTag: 'zoomOut',
                      backgroundColor: Colors.white.withValues(alpha: 0.9),
                      foregroundColor: Colors.black,
                      onPressed: () {
                        final zoom = _mapController.camera.zoom;
                        if (zoom > 3.0) {
                          _mapController.move(
                            _mapController.camera.center,
                            zoom - 1.0,
                          );
                        }
                      },
                      child: const Icon(Icons.remove),
                    ),
                  ],
                ),
              ),
              // POI preview card
              if (viewModel.selectedWaypoint != null)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _PoiPreviewCard(
                    waypoint: viewModel.selectedWaypoint!,
                    onClose: () => viewModel.selectWaypoint(null),
                    onToggleVisited: () => viewModel.toggleWaypointVisited(
                      viewModel.selectedWaypoint!,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: Consumer<HikeMapViewModel>(
        builder: (context, viewModel, _) => FloatingActionButton(
          backgroundColor: Colors.white.withValues(alpha: 0.9),
          foregroundColor: Colors.black,
          onPressed: () {
            _mapController.moveAndRotate(
              viewModel.getCurrentCenter(),
              13.0,
              0.0,
            );
          },
          child: const Icon(Icons.my_location),
        ),
      ),
    );
  }

  List<Marker> _buildMarkers(
    List<Waypoint> waypoints,
    Waypoint? selectedWaypoint,
  ) {
    return waypoints.map((waypoint) {
      final isSelected = selectedWaypoint?.id == waypoint.id;
      final color = waypoint.isVisited ? Colors.green : Colors.red;
      final size = isSelected ? 52.0 : 40.0;
      final iconSize = isSelected ? 32.0 : 25.0;

      return Marker(
        width: size,
        height: size + 14,
        point: LatLng(waypoint.latitude, waypoint.longitude),
        child: GestureDetector(
          onTap: () =>
              context.read<HikeMapViewModel>().selectWaypoint(waypoint),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.amber : color,
                  shape: BoxShape.circle,
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.amber.withValues(alpha: 0.6),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  Icons.local_bar,
                  color: Colors.white,
                  size: iconSize,
                ),
              ),
              if (isSelected)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    waypoint.name,
                    style: const TextStyle(
                      fontSize: 8.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              else
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
}

class _PoiPreviewCard extends StatelessWidget {
  final Waypoint waypoint;
  final VoidCallback onClose;
  final VoidCallback onToggleVisited;

  const _PoiPreviewCard({
    required this.waypoint,
    required this.onClose,
    required this.onToggleVisited,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: waypoint.isVisited
                        ? Colors.green.shade50
                        : Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.local_bar,
                    color: waypoint.isVisited ? Colors.green : Colors.red,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    waypoint.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: onClose,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            if (waypoint.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                waypoint.description,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (waypoint.images.isNotEmpty) ...[
              const SizedBox(height: 8),
              SizedBox(
                height: 72,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: waypoint.images.length,
                  separatorBuilder: (ctx, idx) => const SizedBox(width: 8),
                  itemBuilder: (context, index) => ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      waypoint.images[index],
                      height: 72,
                      width: 72,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: Icon(
                  waypoint.isVisited
                      ? Icons.check_circle
                      : Icons.circle_outlined,
                ),
                label: Text(
                  waypoint.isVisited
                      ? 'Als unbesucht markieren'
                      : 'Als besucht markieren',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: waypoint.isVisited
                      ? Colors.green
                      : Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: onToggleVisited,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationPermissionBanner extends StatelessWidget {
  final bool isPermanentlyDenied;

  const _LocationPermissionBanner({required this.isPermanentlyDenied});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Material(
        color: Colors.transparent,
        child: Container(
          color: Colors.orange.shade700,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              const Icon(Icons.location_off, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isPermanentlyDenied
                      ? 'Standortzugriff dauerhaft verweigert. Bitte in den Einstellungen aktivieren.'
                      : 'Kein Standortzugriff. GPS-Funktionen nicht verfügbar.',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
              if (isPermanentlyDenied)
                TextButton(
                  onPressed: () => Geolocator.openAppSettings(),
                  child: const Text(
                    'Einstellungen',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

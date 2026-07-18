import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../../config/l10n/app_localizations.dart';
import '../../../config/theme/app_tokens.dart';
import '../../core/widgets/poi_whisky_card.dart';
import '../../../domain/models/waypoint.dart';
import '../../../data/repositories/offline_first_waypoint_repository.dart';
import 'hike_map_view_model.dart';

class HikeMapScreen extends StatelessWidget {
  final int hikeId;

  const HikeMapScreen({super.key, required this.hikeId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HikeMapViewModel(
        hikeId: hikeId,
        waypointRepository: Provider.of<OfflineFirstWaypointRepository>(
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
                  onTap: (_, _) => viewModel.clearSelection(),
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
                            .map(
                              (waypoint) =>
                                  LatLng(waypoint.latitude, waypoint.longitude),
                            )
                            .toList(),
                        color: AppColors.green700,
                        strokeWidth: 3.0,
                      ),
                    ],
                  ),
                  MarkerLayer(markers: _buildMarkers(viewModel, waypoints)),
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
              if (viewModel.selectedWaypoint != null)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: SafeArea(
                    child: SingleChildScrollView(
                      child: _buildPreviewCard(
                        context,
                        viewModel,
                        viewModel.selectedWaypoint!,
                      ),
                    ),
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

  List<Marker> _buildMarkers(
    HikeMapViewModel viewModel,
    List<Waypoint> waypoints,
  ) {
    return waypoints.map((waypoint) {
      final isSelected = viewModel.selectedWaypoint?.id == waypoint.id;
      return Marker(
        width: 72.0,
        height: 64.0,
        point: LatLng(waypoint.latitude, waypoint.longitude),
        child: GestureDetector(
          onTap: () => viewModel.selectWaypoint(waypoint),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: AppMotion.fast,
                curve: AppMotion.standardCurve,
                padding: EdgeInsets.all(isSelected ? AppSpacing.sm : 4),
                decoration: BoxDecoration(
                  color: waypoint.isVisited
                      ? AppColors.green700
                      : AppColors.amber700,
                  shape: BoxShape.circle,
                  // Amber glow marks the selected POI without a modal.
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.amber700.withValues(alpha: 0.6),
                            blurRadius: 16,
                            spreadRadius: 4,
                          ),
                        ]
                      : AppElevation.cardShadow,
                ),
                child: Icon(
                  waypoint.isVisited ? Icons.check : Icons.local_bar,
                  color: AppColors.white,
                  size: isSelected ? 24.0 : 18.0,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                waypoint.name,
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.peat900,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  Widget _buildPreviewCard(
    BuildContext context,
    HikeMapViewModel viewModel,
    Waypoint waypoint,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return PoiWhiskyCard(
      key: ValueKey(waypoint.id),
      waypoint: waypoint,
      imageUrl: waypoint.images.isNotEmpty ? waypoint.images.first : null,
      storyText: waypoint.description,
      whiskyCta: waypoint.isVisited ? l10n.untasteCta : l10n.tasteCta,
      skipCta: l10n.closeCta,
      onTaste: () => viewModel.toggleWaypointVisited(waypoint),
      onSkip: viewModel.clearSelection,
    );
  }
}

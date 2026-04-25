import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../../config/theme/app_tokens.dart';
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
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        title: const Text('Wanderkarte'),
        backgroundColor: AppColors.peat900,
        foregroundColor: AppColors.white,
      ),
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
                  Text(
                    'Fehler: ${viewModel.error}',
                    style: AppTextStyles.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.md),
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
            return Center(
              child: Text(
                'Keine Wegpunkte für diese Wanderung vorhanden.',
                style: AppTextStyles.bodyMedium,
              ),
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
                        color: AppColors.green700,
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
              // Location permission banner
              if (viewModel.locationPermissionStatus ==
                      LocationPermissionStatus.deniedForever ||
                  viewModel.locationPermissionStatus ==
                      LocationPermissionStatus.denied)
                _LocationPermissionBanner(
                  isPermanentlyDenied: viewModel.locationPermissionStatus ==
                      LocationPermissionStatus.deniedForever,
                ),
              // Zoom controls
              Positioned(
                right: AppSpacing.md,
                bottom: viewModel.selectedWaypoint != null ? 220 : 100,
                child: Column(
                  children: [
                    _MapControlButton(
                      heroTag: 'zoomIn',
                      icon: Icons.add,
                      onPressed: () {
                        final zoom = _mapController.camera.zoom;
                        if (zoom < 18.0) {
                          _mapController.move(
                            _mapController.camera.center,
                            zoom + 1.0,
                          );
                        }
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _MapControlButton(
                      heroTag: 'zoomOut',
                      icon: Icons.remove,
                      onPressed: () {
                        final zoom = _mapController.camera.zoom;
                        if (zoom > 3.0) {
                          _mapController.move(
                            _mapController.camera.center,
                            zoom - 1.0,
                          );
                        }
                      },
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
          backgroundColor: AppColors.amber700,
          foregroundColor: AppColors.white,
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
      final markerColor =
          isSelected ? AppColors.amber700 : AppColors.peat700;
      final visitedColor = AppColors.green700;
      final color = isSelected
          ? markerColor
          : waypoint.isVisited
              ? visitedColor
              : markerColor;
      final size = isSelected ? 52.0 : 40.0;
      final iconSize = isSelected ? 32.0 : 24.0;

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
                duration: AppMotion.standard,
                curve: AppMotion.standard_,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.amber700.withValues(alpha: 0.5),
                            blurRadius: 10,
                            spreadRadius: 3,
                          )
                        ]
                      : AppElevation.cardShadow,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xs),
                  child: Icon(
                    Icons.local_bar,
                    color: AppColors.white,
                    size: iconSize,
                  ),
                ),
              ),
              if (isSelected)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.amber700,
                    borderRadius:
                        BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Text(
                    waypoint.name,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              else
                Text(
                  waypoint.name,
                  style: AppTextStyles.labelSmall,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      );
    }).toList();
  }
}

/// Inline POI preview card that slides up from the bottom of the map.
///
/// TODO: replace with HikeStoryCard from lib/UI/shared/hike_story_card.dart
/// once WHI-20 design tokens branch merges.
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
      elevation: AppElevation.modal,
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(AppRadius.lg),
      ),
      color: AppColors.cream,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.peat300,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: waypoint.isVisited
                        ? AppColors.green100
                        : AppColors.amber100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.local_bar,
                    color: waypoint.isVisited
                        ? AppColors.green700
                        : AppColors.amber700,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Whisky-Station',
                        style: AppTextStyles.overline,
                      ),
                      Text(
                        waypoint.name,
                        style: AppTextStyles.headlineSmall,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  color: AppColors.peat500,
                  onPressed: onClose,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            if (waypoint.description.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                waypoint.description,
                style: AppTextStyles.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (waypoint.images.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                height: 72,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: waypoint.images.length,
                  separatorBuilder: (ctx, idx) =>
                      const SizedBox(width: AppSpacing.sm),
                  itemBuilder: (context, index) => ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.md),
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
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              height: AppTouchTargets.comfortable,
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
                      ? AppColors.green700
                      : AppColors.amber700,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
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

class _MapControlButton extends StatelessWidget {
  final String heroTag;
  final IconData icon;
  final VoidCallback onPressed;

  const _MapControlButton({
    required this.heroTag,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.small(
      heroTag: heroTag,
      backgroundColor: AppColors.white.withValues(alpha: 0.92),
      foregroundColor: AppColors.peat700,
      elevation: AppElevation.raised,
      onPressed: onPressed,
      child: Icon(icon),
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
          color: AppColors.warning,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm + 2,
          ),
          child: Row(
            children: [
              const Icon(
                Icons.location_off,
                color: AppColors.white,
                size: 18,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  isPermanentlyDenied
                      ? 'Standortzugriff dauerhaft verweigert. Bitte in den Einstellungen aktivieren.'
                      : 'Kein Standortzugriff. GPS-Funktionen nicht verfügbar.',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.white,
                  ),
                ),
              ),
              if (isPermanentlyDenied)
                TextButton(
                  onPressed: () => Geolocator.openAppSettings(),
                  child: Text(
                    'Einstellungen',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
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

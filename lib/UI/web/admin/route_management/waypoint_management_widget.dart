import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../data/providers/route_management_provider.dart';
import '../../../../config/l10n/app_localizations.dart';

/// Widget für die Verwaltung von Wegpunkten einer Route
class WaypointManagementWidget extends StatefulWidget {
  const WaypointManagementWidget({super.key});

  @override
  State<WaypointManagementWidget> createState() => _WaypointManagementWidgetState();
}

class _WaypointManagementWidgetState extends State<WaypointManagementWidget> {
  bool _isMapView = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<RouteManagementProvider>(
      builder: (context, provider, child) {
        if (provider.selectedRoute == null) {
          return _buildNoRouteSelected();
        }

        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.errorMessage != null) {
          return _buildErrorState(provider);
        }

        return Column(
          children: [
            _buildHeader(provider),
            const SizedBox(height: 16),
            Expanded(
              child: _isMapView ? _buildMapView(provider) : _buildListView(provider),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNoRouteSelected() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.route,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Keine Route ausgewählt',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Wählen Sie eine Route aus, um Wegpunkte zu verwalten',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(RouteManagementProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error,
            size: 64,
            color: Colors.red[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Fehler beim Laden',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.red[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            provider.errorMessage!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.red[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => provider.selectRoute(provider.selectedRoute!),
            icon: const Icon(Icons.refresh),
            label: const Text('Erneut versuchen'),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(RouteManagementProvider provider) {
    final route = provider.selectedRoute!;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                route['name'],
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${provider.waypoints.length} Wegpunkte',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            IconButton(
              onPressed: () {
                setState(() {
                  _isMapView = !_isMapView;
                });
              },
              icon: Icon(_isMapView ? Icons.list : Icons.map),
              tooltip: _isMapView ? 'Listenansicht' : 'Kartenansicht',
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: () => _showAddWaypointDialog(provider),
              icon: const Icon(Icons.add_location),
              label: const Text('Wegpunkt hinzufügen'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber[800],
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildListView(RouteManagementProvider provider) {
    if (provider.waypoints.isEmpty) {
      return _buildEmptyWaypoints();
    }

    return ReorderableListView.builder(
      itemCount: provider.waypoints.length,
      onReorder: (oldIndex, newIndex) => _reorderWaypoints(provider, oldIndex, newIndex),
      itemBuilder: (context, index) {
        final waypointData = provider.waypoints[index];
        final waypoint = waypointData['waypoints'];
        final orderIndex = waypointData['order_index'];

        return _buildWaypointCard(
          key: Key('waypoint_${waypoint['id']}'),
          waypoint: waypoint,
          orderIndex: orderIndex,
          provider: provider,
        );
      },
    );
  }

  Widget _buildMapView(RouteManagementProvider provider) {
    // TODO: Implementiere Karten-Integration (z.B. mit flutter_map)
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Karten-Ansicht'),
            Text('(In Entwicklung)'),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWaypoints() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_location,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Keine Wegpunkte',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Fügen Sie Wegpunkte zu dieser Route hinzu',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddWaypointDialog(
              context.read<RouteManagementProvider>(),
            ),
            icon: const Icon(Icons.add_location),
            label: const Text('Ersten Wegpunkt hinzufügen'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber[800],
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaypointCard({
    required Key key,
    required Map<String, dynamic> waypoint,
    required int orderIndex,
    required RouteManagementProvider provider,
  }) {
    return Card(
      key: key,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              backgroundColor: Colors.amber[800],
              foregroundColor: Colors.white,
              radius: 16,
              child: Text(
                orderIndex.toString(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.drag_handle),
          ],
        ),
        title: Text(
          waypoint['name'] ?? 'Unbenannter Wegpunkt',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (waypoint['description'] != null && waypoint['description'].isNotEmpty)
              Text(waypoint['description']),
            Text(
              '${waypoint['latitude']}, ${waypoint['longitude']}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            if (waypoint['whisky_info'] != null && waypoint['whisky_info'].isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  waypoint['whisky_info'],
                  style: TextStyle(
                    color: Colors.amber[800],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () => _showEditWaypointDialog(provider, waypoint),
              icon: const Icon(Icons.edit),
              iconSize: 20,
            ),
            IconButton(
              onPressed: () => _showDeleteWaypointDialog(provider, waypoint),
              icon: const Icon(Icons.delete),
              iconSize: 20,
              style: IconButton.styleFrom(
                foregroundColor: Colors.red[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _reorderWaypoints(RouteManagementProvider provider, int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex--;
    }

    final routeId = provider.selectedRoute!['id'];
    final waypoints = List<Map<String, dynamic>>.from(provider.waypoints);

    final movedWaypoint = waypoints.removeAt(oldIndex);
    waypoints.insert(newIndex, movedWaypoint);

    // Erstelle neue Reihenfolge
    final newOrder = waypoints.asMap().entries.map((entry) {
      return {
        'waypointId': entry.value['waypoints']['id'],
        'orderIndex': entry.key + 1,
      };
    }).toList();

    provider.reorderWaypoints(routeId, newOrder);
  }

  void _showAddWaypointDialog(RouteManagementProvider provider) {
    _showWaypointDialog(provider, null);
  }

  void _showEditWaypointDialog(RouteManagementProvider provider, Map<String, dynamic> waypoint) {
    _showWaypointDialog(provider, waypoint);
  }

  void _showWaypointDialog(RouteManagementProvider provider, Map<String, dynamic>? waypoint) {
    final isEdit = waypoint != null;
    final nameController = TextEditingController(text: waypoint?['name'] ?? '');
    final descriptionController = TextEditingController(text: waypoint?['description'] ?? '');
    final latitudeController = TextEditingController(text: waypoint?['latitude']?.toString() ?? '');
    final longitudeController = TextEditingController(text: waypoint?['longitude']?.toString() ?? '');
    final whiskyInfoController = TextEditingController(text: waypoint?['whisky_info'] ?? '');

    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    isEdit ? Icons.edit_location : Icons.add_location,
                    color: Colors.amber[800],
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isEdit ? 'Wegpunkt bearbeiten' : 'Wegpunkt hinzufügen',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Form(
                key: formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name *',
                        hintText: 'z.B. Aussichtspunkt Berggipfel',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Name ist erforderlich';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Beschreibung',
                        hintText: 'Optionale Beschreibung des Wegpunkts',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: latitudeController,
                            decoration: const InputDecoration(
                              labelText: 'Breitengrad *',
                              hintText: '52.5200',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                              signed: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*')),
                            ],
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Breitengrad ist erforderlich';
                              }
                              final lat = double.tryParse(value);
                              if (lat == null || lat < -90 || lat > 90) {
                                return 'Ungültiger Breitengrad';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: longitudeController,
                            decoration: const InputDecoration(
                              labelText: 'Längengrad *',
                              hintText: '13.4050',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                              signed: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*')),
                            ],
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Längengrad ist erforderlich';
                              }
                              final lng = double.tryParse(value);
                              if (lng == null || lng < -180 || lng > 180) {
                                return 'Ungültiger Längengrad';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: whiskyInfoController,
                      decoration: const InputDecoration(
                        labelText: 'Whisky Information',
                        hintText: 'z.B. Glenfiddich 12 Year Old',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Abbrechen'),
                  ),
                  const SizedBox(width: 16),
                  FilledButton.icon(
                    onPressed: () => _saveWaypoint(
                      provider,
                      formKey,
                      nameController,
                      descriptionController,
                      latitudeController,
                      longitudeController,
                      whiskyInfoController,
                      waypoint,
                    ),
                    icon: Icon(isEdit ? Icons.save : Icons.add),
                    label: Text(isEdit ? 'Speichern' : 'Hinzufügen'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.amber[800],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveWaypoint(
    RouteManagementProvider provider,
    GlobalKey<FormState> formKey,
    TextEditingController nameController,
    TextEditingController descriptionController,
    TextEditingController latitudeController,
    TextEditingController longitudeController,
    TextEditingController whiskyInfoController,
    Map<String, dynamic>? existingWaypoint,
  ) async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    final waypointData = {
      'name': nameController.text.trim(),
      'description': descriptionController.text.trim(),
      'latitude': double.parse(latitudeController.text),
      'longitude': double.parse(longitudeController.text),
      'whisky_info': whiskyInfoController.text.trim(),
    };

    try {
      if (existingWaypoint != null) {
        await provider.updateWaypoint(existingWaypoint['id'], waypointData);
      } else {
        final routeId = provider.selectedRoute!['id'];
        await provider.addWaypoint(routeId, waypointData);
      }

      if (mounted) {
        Navigator.of(context).pop();
        if (provider.errorMessage == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                existingWaypoint != null
                    ? 'Wegpunkt erfolgreich aktualisiert'
                    : 'Wegpunkt erfolgreich hinzugefügt',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fehler: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showDeleteWaypointDialog(RouteManagementProvider provider, Map<String, dynamic> waypoint) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Wegpunkt löschen'),
        content: Text('Möchten Sie den Wegpunkt "${waypoint['name']}" wirklich löschen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              final routeId = provider.selectedRoute!['id'];
              provider.removeWaypoint(routeId, waypoint['id']);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Löschen'),
          ),
        ],
      ),
    );
  }
}
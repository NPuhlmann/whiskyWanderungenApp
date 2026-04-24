import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/responsive_layout.dart';
import '../../../shared/components/breadcrumbs.dart';
import '../../../../data/providers/route_management_provider.dart';
import '../../../../config/l10n/app_localizations.dart';
import 'route_card.dart';
import 'route_form_dialog.dart';
import 'waypoint_management_widget.dart';

/// Hauptseite für die Verwaltung von Wanderrouten
class RouteManagementPage extends StatefulWidget {
  const RouteManagementPage({super.key});

  @override
  State<RouteManagementPage> createState() => _RouteManagementPageState();
}

class _RouteManagementPageState extends State<RouteManagementPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchTerm = '';
  String? _selectedDifficulty;
  bool? _selectedStatus;
  String _sortBy = 'name';
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RouteManagementProvider>().loadRoutes();
    });
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchTerm = _searchController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _buildMobileLayout(),
      desktop: _buildDesktopLayout(),
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.manageHikingRoutes),
        backgroundColor: Colors.amber[800],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _showCreateRouteDialog,
            icon: const Icon(Icons.add),
            tooltip: 'Neue Route',
          ),
        ],
      ),
      body: _buildContent(),
    );
  }

  Widget _buildDesktopLayout() {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AdminBreadcrumbs(currentSection: 'Wanderrouten'),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Wanderrouten verwalten',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Erstellen und bearbeiten Sie Ihre Wanderrouten',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
            ElevatedButton.icon(
              onPressed: _showCreateRouteDialog,
              icon: const Icon(Icons.add),
              label: const Text('Neue Route'),
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

  Widget _buildContent() {
    return Consumer<RouteManagementProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.routes.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return Row(
          children: [
            Expanded(flex: 2, child: _buildRoutesList(provider)),
            if (!ResponsiveLayoutUtils.isMobile(context) &&
                provider.selectedRoute != null) ...[
              const SizedBox(width: 24),
              Expanded(flex: 1, child: _buildWaypointPanel()),
            ],
          ],
        );
      },
    );
  }

  Widget _buildRoutesList(RouteManagementProvider provider) {
    return Column(
      children: [
        _buildSearchAndFilters(),
        const SizedBox(height: 16),
        if (provider.errorMessage != null) _buildErrorBanner(provider),
        Expanded(child: _buildRoutesGrid(provider)),
      ],
    );
  }

  Widget _buildSearchAndFilters() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Suchfeld
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Routen suchen...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: _searchTerm.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchTerm = '';
                          });
                        },
                        icon: const Icon(Icons.clear),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 16),

            // Filter-Chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                // Status-Filter
                ChoiceChip(
                  label: const Text('Alle'),
                  selected: _selectedStatus == null,
                  onSelected: (selected) {
                    setState(() {
                      _selectedStatus = selected ? null : _selectedStatus;
                    });
                  },
                ),
                ChoiceChip(
                  label: const Text('Aktiv'),
                  selected: _selectedStatus == true,
                  onSelected: (selected) {
                    setState(() {
                      _selectedStatus = selected ? true : null;
                    });
                  },
                ),
                ChoiceChip(
                  label: const Text('Inaktiv'),
                  selected: _selectedStatus == false,
                  onSelected: (selected) {
                    setState(() {
                      _selectedStatus = selected ? false : null;
                    });
                  },
                ),

                // Schwierigkeit-Filter
                ChoiceChip(
                  label: const Text('Leicht'),
                  selected: _selectedDifficulty == 'easy',
                  onSelected: (selected) {
                    setState(() {
                      _selectedDifficulty = selected ? 'easy' : null;
                    });
                  },
                ),
                ChoiceChip(
                  label: const Text('Mittel'),
                  selected: _selectedDifficulty == 'moderate',
                  onSelected: (selected) {
                    setState(() {
                      _selectedDifficulty = selected ? 'moderate' : null;
                    });
                  },
                ),
                ChoiceChip(
                  label: const Text('Schwer'),
                  selected: _selectedDifficulty == 'hard',
                  onSelected: (selected) {
                    setState(() {
                      _selectedDifficulty = selected ? 'hard' : null;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Sortierung
            Row(
              children: [
                const Text('Sortieren nach:'),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _sortBy,
                  onChanged: (value) {
                    setState(() {
                      _sortBy = value!;
                    });
                  },
                  items: const [
                    DropdownMenuItem(value: 'name', child: Text('Name')),
                    DropdownMenuItem(value: 'price', child: Text('Preis')),
                    DropdownMenuItem(value: 'distance', child: Text('Distanz')),
                    DropdownMenuItem(value: 'duration', child: Text('Dauer')),
                    DropdownMenuItem(
                      value: 'created_at',
                      child: Text('Erstellt'),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _sortAscending = !_sortAscending;
                    });
                  },
                  icon: Icon(
                    _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                  ),
                  tooltip: _sortAscending ? 'Aufsteigend' : 'Absteigend',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorBanner(RouteManagementProvider provider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        border: Border.all(color: Colors.red[200]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.error, color: Colors.red[700]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              provider.errorMessage!,
              style: TextStyle(color: Colors.red[700]),
            ),
          ),
          TextButton(
            onPressed: provider.loadRoutes,
            child: const Text('Erneut versuchen'),
          ),
          IconButton(
            onPressed: provider.clearError,
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }

  Widget _buildRoutesGrid(RouteManagementProvider provider) {
    var filteredRoutes = provider.routes;

    // Anwenden der Filter
    if (_searchTerm.isNotEmpty) {
      filteredRoutes = provider.filterRoutes(_searchTerm);
    }

    if (_selectedStatus != null) {
      filteredRoutes = filteredRoutes
          .where((route) => route['is_active'] == _selectedStatus)
          .toList();
    }

    if (_selectedDifficulty != null) {
      filteredRoutes = filteredRoutes
          .where((route) => route['difficulty'] == _selectedDifficulty)
          .toList();
    }

    // Sortierung anwenden
    filteredRoutes.sort((a, b) {
      dynamic valueA, valueB;

      switch (_sortBy) {
        case 'name':
          valueA = a['name'] ?? '';
          valueB = b['name'] ?? '';
          break;
        case 'price':
          valueA = a['price'] ?? 0.0;
          valueB = b['price'] ?? 0.0;
          break;
        case 'distance':
          valueA = a['distance'] ?? 0.0;
          valueB = b['distance'] ?? 0.0;
          break;
        case 'duration':
          valueA = a['duration'] ?? 0;
          valueB = b['duration'] ?? 0;
          break;
        case 'created_at':
          valueA = DateTime.tryParse(a['created_at'] ?? '') ?? DateTime.now();
          valueB = DateTime.tryParse(b['created_at'] ?? '') ?? DateTime.now();
          break;
        default:
          valueA = a['name'] ?? '';
          valueB = b['name'] ?? '';
      }

      final comparison = valueA.compareTo(valueB);
      return _sortAscending ? comparison : -comparison;
    });

    if (filteredRoutes.isEmpty) {
      return _buildEmptyState();
    }

    if (ResponsiveLayoutUtils.isMobile(context)) {
      return ListView.builder(
        itemCount: filteredRoutes.length,
        itemBuilder: (context, index) {
          return RouteCard(
            route: filteredRoutes[index],
            onTap: () => _selectRoute(filteredRoutes[index]),
            onEdit: () => _showEditRouteDialog(filteredRoutes[index]),
            onDelete: () => _showDeleteConfirmation(filteredRoutes[index]),
            onToggleStatus: () => _toggleRouteStatus(filteredRoutes[index]),
          );
        },
      );
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: filteredRoutes.length,
      itemBuilder: (context, index) {
        return RouteCard(
          route: filteredRoutes[index],
          onTap: () => _selectRoute(filteredRoutes[index]),
          onEdit: () => _showEditRouteDialog(filteredRoutes[index]),
          onDelete: () => _showDeleteConfirmation(filteredRoutes[index]),
          onToggleStatus: () => _toggleRouteStatus(filteredRoutes[index]),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.map_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Keine Routen verfügbar',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Erstellen Sie Ihre erste Wanderroute',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showCreateRouteDialog,
            icon: const Icon(Icons.add),
            label: const Text('Erste Route erstellen'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber[800],
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaypointPanel() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Wegpunkte verwalten',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () {
                    context.read<RouteManagementProvider>().deselectRoute();
                  },
                  icon: const Icon(Icons.close),
                  tooltip: 'Schließen',
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Expanded(child: WaypointManagementWidget()),
          ],
        ),
      ),
    );
  }

  void _selectRoute(Map<String, dynamic> route) {
    context.read<RouteManagementProvider>().selectRoute(route);

    // Auf Mobile zum Wegpunkt-Management navigieren
    if (ResponsiveLayoutUtils.isMobile(context)) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: Text(route['name']),
              backgroundColor: Colors.amber[800],
              foregroundColor: Colors.white,
            ),
            body: const Padding(
              padding: EdgeInsets.all(16.0),
              child: WaypointManagementWidget(),
            ),
          ),
        ),
      );
    }
  }

  void _showCreateRouteDialog() {
    showDialog(context: context, builder: (context) => const RouteFormDialog());
  }

  void _showEditRouteDialog(Map<String, dynamic> route) {
    showDialog(
      context: context,
      builder: (context) => RouteFormDialog(route: route),
    );
  }

  void _showDeleteConfirmation(Map<String, dynamic> route) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Route löschen'),
        content: Text(
          'Möchten Sie die Route "${route['name']}" wirklich löschen? Diese Aktion kann nicht rückgängig gemacht werden.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<RouteManagementProvider>().deleteRoute(route['id']);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Löschen'),
          ),
        ],
      ),
    );
  }

  void _toggleRouteStatus(Map<String, dynamic> route) {
    final newStatus = !(route['is_active'] ?? false);
    context.read<RouteManagementProvider>().updateRoute(route['id'], {
      'is_active': newStatus,
    });
  }
}

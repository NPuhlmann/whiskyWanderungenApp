import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whisky_hikes/config/l10n/app_localizations.dart';
import 'package:whisky_hikes/data/providers/whisky_management_provider.dart';
import 'package:whisky_hikes/UI/core/responsive_layout.dart';
import 'widgets/whisky_catalog_overview.dart';
import 'widgets/tasting_set_list.dart';
import 'widgets/whisky_catalog_filters.dart';

/// Main page for Whisky Catalog Management in the admin interface
class WhiskyCatalogPage extends StatefulWidget {
  const WhiskyCatalogPage({super.key});

  @override
  State<WhiskyCatalogPage> createState() => _WhiskyCatalogPageState();
}

class _WhiskyCatalogPageState extends State<WhiskyCatalogPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Load data when page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WhiskyManagementProvider>().refreshData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _buildMobileLayout(context),
      tablet: _buildTabletLayout(context),
      desktop: _buildDesktopLayout(context),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.manageWhiskyCatalog),
        backgroundColor: Colors.amber[800],
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(
              icon: const Icon(Icons.dashboard),
              text: AppLocalizations.of(context)!.overview,
            ),
            Tab(
              icon: const Icon(Icons.local_bar),
              text: AppLocalizations.of(context)!.tastingSets,
            ),
            Tab(
              icon: const Icon(Icons.filter_list),
              text: AppLocalizations.of(context)!.filters,
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          const WhiskyCatalogOverview(),
          const TastingSetList(),
          WhiskyCatalogFilters(
            onFiltersChanged: () {
              setState(() {}); // Refresh the list
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.manageWhiskyCatalog),
        backgroundColor: Colors.amber[800],
        foregroundColor: Colors.white,
      ),
      body: Row(
        children: [
          // Sidebar with filters
          Container(
            width: 300,
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
              ),
            ),
            child: Column(
              children: [
                // Overview section
                Container(
                  height: 200,
                  padding: const EdgeInsets.all(16),
                  child: const WhiskyCatalogOverview(),
                ),
                const Divider(),
                // Filters section
                Expanded(
                  child: WhiskyCatalogFilters(
                    onFiltersChanged: () {
                      setState(() {}); // Refresh the list
                    },
                  ),
                ),
              ],
            ),
          ),
          // Main content
          const Expanded(child: TastingSetList()),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.manageWhiskyCatalog),
        backgroundColor: Colors.amber[800],
        foregroundColor: Colors.white,
        actions: [
          // Quick action buttons
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<WhiskyManagementProvider>().refreshData();
            },
            tooltip: AppLocalizations.of(context)!.refresh,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showCreateTastingSetDialog(context);
            },
            tooltip: AppLocalizations.of(context)!.createNewTastingSet,
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Row(
        children: [
          // Left sidebar with overview and filters
          Container(
            width: 350,
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
              ),
            ),
            child: Column(
              children: [
                // Overview section
                Container(
                  height: 250,
                  padding: const EdgeInsets.all(16),
                  child: const WhiskyCatalogOverview(),
                ),
                const Divider(),
                // Filters section
                Expanded(
                  child: WhiskyCatalogFilters(
                    onFiltersChanged: () {
                      setState(() {}); // Refresh the list
                    },
                  ),
                ),
              ],
            ),
          ),
          // Main content area
          const Expanded(child: TastingSetList()),
        ],
      ),
    );
  }

  void _showCreateTastingSetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.createNewTastingSet),
        content: const Text('Tasting Set Creation Dialog would go here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement tasting set creation
            },
            child: Text(AppLocalizations.of(context)!.create),
          ),
        ],
      ),
    );
  }
}

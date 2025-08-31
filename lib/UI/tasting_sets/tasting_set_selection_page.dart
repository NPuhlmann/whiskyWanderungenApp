import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whisky_hikes/domain/models/tasting_set.dart';
import 'package:whisky_hikes/domain/models/hike.dart';
import 'package:whisky_hikes/UI/tasting_sets/widgets/tasting_set_info_card.dart';
import 'package:whisky_hikes/UI/tasting_sets/tasting_set_selection_view_model.dart';

/// Page for displaying the tasting set included with a hike (1:1 relationship)
class TastingSetSelectionPage extends StatelessWidget {
  final Hike hike;

  const TastingSetSelectionPage({
    Key? key,
    required this.hike,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TastingSetSelectionViewModel(hike: hike),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Tasting Set'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
        ),
        body: Consumer<TastingSetSelectionViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (viewModel.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red[300],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Fehler beim Laden',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.red[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      viewModel.error ?? 'Unbekannter Fehler',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.red[600]),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: viewModel.refresh,
                      child: const Text('Erneut versuchen'),
                    ),
                  ],
                ),
              );
            }

            if (!viewModel.hasTastingSet) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.wine_bar,
                      size: 64,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Kein Tasting Set verfügbar',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Für diesen Hike ist derzeit kein Tasting Set verfügbar.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              );
            }

            final tastingSet = viewModel.tastingSet!;

            return Column(
              children: [
                // Header with hike info
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: Row(
                    children: [
                      if (hike.thumbnailImageUrl != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            hike.thumbnailImageUrl!,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 60,
                                height: 60,
                                color: Colors.grey[300],
                                child: const Icon(Icons.hiking, color: Colors.grey),
                              );
                            },
                          ),
                        )
                      else
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.hiking, color: Colors.grey),
                        ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              hike.name,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Inklusives Tasting Set',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Tasting set information
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: TastingSetInfoCard(tastingSet: tastingSet),
                  ),
                ),

                // Bottom action bar
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha:0.1),
                        blurRadius: 8,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Tasting Set inklusive',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.green[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '${viewModel.totalSampleCount} Samples • ${viewModel.totalVolumeMl.toStringAsFixed(0)}ml',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => _proceedToCheckout(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          child: const Text('Weiter zum Checkout'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _proceedToCheckout(BuildContext context) {
    // Navigate to checkout with the hike (tasting set is automatically included)
    // This will be implemented when the checkout system is ready
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Weiterleitung zum Checkout...'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

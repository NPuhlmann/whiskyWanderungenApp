import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:whisky_hikes/UI/home/widgets/card_widget.dart';
import 'package:whisky_hikes/UI/my_hikes/my_hikes_view_model.dart';

import '../../domain/models/hike.dart';

class MyHikesPage extends StatefulWidget {
  const MyHikesPage({super.key, required this.viewModel});

  final MyHikesViewModel viewModel;

  @override
  State<MyHikesPage> createState() => _MyHikesPageState();
}

class _MyHikesPageState extends State<MyHikesPage> {
  
  @override
  void initState() {
    super.initState();
    widget.viewModel.loadUserHikes();
  }
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(AppLocalizations.of(context)!.myHikes),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: widget.viewModel.isLoading 
                    ? null 
                    : () => widget.viewModel.refresh(),
                tooltip: AppLocalizations.of(context)!.refresh,
              ),
            ],
          ),
          body: _buildBody(),
        );
      },
    );
  }
  
  Widget _buildBody() {
    if (widget.viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (widget.viewModel.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _getLocalizedErrorMessage(widget.viewModel.errorMessage!),
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: widget.viewModel.refresh,
              child: Text(AppLocalizations.of(context)!.tryAgain),
            ),
          ],
        ),
      );
    }
    
    if (widget.viewModel.userHikes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppLocalizations.of(context)!.noHikesFound,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.noHikesPurchased,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      itemCount: widget.viewModel.userHikes.length,
      itemBuilder: (context, index) {
        Hike hike = widget.viewModel.userHikes[index];
        return HikeCard(
          id: index, 
          hike: hike,
          isInGeneralList: false,
          onFavoriteToggle: (_) {}, // Leere Funktion, da der Button nicht angezeigt wird
        );
      },
    );
  }
  
  // Hilfsmethode, um den lokalisierten Text für Fehlermeldungen zu erhalten
  String _getLocalizedErrorMessage(String errorKey) {
    final localizations = AppLocalizations.of(context)!;
    
    switch (errorKey) {
      case "loginRequiredForHikes":
        return localizations.loginRequiredForHikes;
      case "errorLoadingHikes":
        return localizations.errorLoadingHikes;
      default:
        return errorKey; // Fallback, falls der Schlüssel nicht gefunden wird
    }
  }
}

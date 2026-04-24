import 'package:flutter/material.dart';
import 'package:whisky_hikes/config/l10n/app_localizations.dart';
import 'package:whisky_hikes/UI/mobile/home/widgets/card_widget.dart';

import '../../../domain/models/hike.dart';
import 'home_view_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.viewModel});

  final HomePageViewModel viewModel;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.loadHikes();
    widget.viewModel.getUserFirstName();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        return Scaffold(
          body: CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(
                pinned: true,
                expandedHeight: 150,
                title: widget.viewModel.firstName.isNotEmpty
                    ? null
                    : Text(AppLocalizations.of(context)!.appTitle),
                actions: [
                  IconButton(
                    icon: Icon(
                      widget.viewModel.showFavorites
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: widget.viewModel.showFavorites
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                    onPressed: () {
                      widget.viewModel.toggleShowFavorites();
                    },
                    tooltip: widget.viewModel.showFavorites
                        ? AppLocalizations.of(context)!.show_all_hikes
                        : AppLocalizations.of(context)!.show_favorites,
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: false,
                  titlePadding: const EdgeInsets.only(bottom: 16, left: 16),
                  title: widget.viewModel.firstName.isNotEmpty
                      ? Text(
                          AppLocalizations.of(
                            context,
                          )!.greeting_home_page(widget.viewModel.firstName),
                          style: Theme.of(context).textTheme.titleMedium,
                        )
                      : null,
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate((
                  BuildContext context,
                  int index,
                ) {
                  Hike hike = widget.viewModel.hikes[index];
                  return HikeCard(
                    id: index,
                    hike: hike,
                    isInGeneralList: true,
                    onFavoriteToggle: widget.viewModel.toggleFavorite,
                  );
                }, childCount: widget.viewModel.hikes.length),
              ),
            ],
          ),
        );
      },
    );
  }
}

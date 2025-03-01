import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:whisky_hikes/UI/home/widgets/card_widget.dart';

import '../../domain/models/hike.dart';
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
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  collapseMode: CollapseMode.pin,
                  title: Text(AppLocalizations.of(context)!.greeting_home_page(widget.viewModel.firstName), style: Theme.of(context).textTheme.headlineSmall),
                  titlePadding: const EdgeInsets.only(bottom: 16, left: 16),
                ),
                actions: [
                  IconButton(
                    icon: Icon(
                      widget.viewModel.showFavorites ? Icons.favorite : Icons.favorite_border,
                      color: widget.viewModel.showFavorites ? Colors.red : null,
                    ),
                    onPressed: () {
                      widget.viewModel.toggleShowFavorites();
                    },
                    tooltip: widget.viewModel.showFavorites 
                      ? AppLocalizations.of(context)!.show_all_hikes 
                      : AppLocalizations.of(context)!.show_favorites,
                  ),
                ],
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    Hike hike = widget.viewModel.hikes[index];
                    return HikeCard(
                      id: index, 
                      hike: hike,
                      isInGeneralList: true,
                      onFavoriteToggle: widget.viewModel.toggleFavorite,
                    );
                  },
                  childCount: widget.viewModel.hikes.length,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
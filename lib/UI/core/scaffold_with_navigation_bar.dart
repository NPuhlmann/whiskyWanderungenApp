import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:whisky_hikes/config/l10n/app_localizations.dart';

class ScaffoldWithNavigationBar extends StatelessWidget {
  const ScaffoldWithNavigationBar({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.location_on),
            label: AppLocalizations.of(context)!.hikes,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.map_rounded),
            label: AppLocalizations.of(context)!.myHikes,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_2_outlined),
            label: AppLocalizations.of(context)!.profile,
          ),
        ],
        currentIndex: navigationShell.currentIndex,
        onTap: (int index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
      ),
    );
  }
}

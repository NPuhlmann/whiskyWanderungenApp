import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:whisky_hikes/config/l10n/app_localizations.dart';
import 'package:whisky_hikes/data/services/auth/auth_service.dart';

class ScaffoldWithNavigationBar extends StatefulWidget {
  const ScaffoldWithNavigationBar({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  State<ScaffoldWithNavigationBar> createState() =>
      _ScaffoldWithNavigationBarState();
}

class _ScaffoldWithNavigationBarState extends State<ScaffoldWithNavigationBar> {
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshRole());
  }

  Future<void> _refreshRole() async {
    final auth = context.read<AuthService>();
    final admin = await auth.isCurrentUserAdmin();
    if (!mounted) return;
    if (admin != _isAdmin) {
      setState(() => _isAdmin = admin);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final shellIndex = widget.navigationShell.currentIndex;
    final items = <BottomNavigationBarItem>[
      BottomNavigationBarItem(
        icon: const Icon(Icons.location_on),
        label: l10n.hikes,
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.map_rounded),
        label: l10n.myHikes,
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.person_2_outlined),
        label: l10n.profile,
      ),
      if (_isAdmin)
        const BottomNavigationBarItem(
          icon: Icon(Icons.admin_panel_settings),
          label: 'Admin',
        ),
    ];

    return Scaffold(
      body: widget.navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: items,
        currentIndex: shellIndex,
        onTap: (int index) {
          // Index 3 ist der Admin-Eintrag — wir verlassen die Shell und
          // springen in den separaten Admin-Bereich.
          if (_isAdmin && index == 3) {
            context.go('/admin/dashboard');
            return;
          }
          widget.navigationShell.goBranch(
            index,
            initialLocation: index == shellIndex,
          );
        },
      ),
    );
  }
}

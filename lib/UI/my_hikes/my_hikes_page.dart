import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../services/auth/auth_service.dart';
import '../core/bottom_navigation.dart';

class MyHikesPage extends StatefulWidget {
  const MyHikesPage({super.key});

  @override
  State<MyHikesPage> createState() => _MyHikesPageState();
}

class _MyHikesPageState extends State<MyHikesPage> {
  final authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.myHikes),
        actions: [
          IconButton(
            onPressed: () {
              authService.signOut();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: Text('Welcome to the MyHikes Page'),
      ),
      bottomNavigationBar: BottomNavigation(selectedIndex: 1,),
    );
  }
}

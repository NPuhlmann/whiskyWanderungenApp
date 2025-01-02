import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MyHikesPage extends StatefulWidget {
  const MyHikesPage({super.key});

  @override
  State<MyHikesPage> createState() => _MyHikesPageState();
}

class _MyHikesPageState extends State<MyHikesPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.myHikes),
      ),
      body: Text("Hello World!"),
    );
  }
}

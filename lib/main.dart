import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:whisky_hikes/config/routing/router.dart';
import 'config/dependencies.dart';


void main() async {
  // supabase setup
  await Supabase.initialize(
    // TODO: Check how to make more secure by not hardcoding the url and anonKey
    url: 'https://demmmqwxuoirwwnwijcx.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRlbW1tcXd4dW9pcnd3bndpamN4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzMzMTg4OTgsImV4cCI6MjA0ODg5NDg5OH0.Hs_jRvVxgw1BPSJS5wSqLwrSZeN4Nw76m-XLVFn_MeY',
    debug: true,
  );

  runApp(MultiProvider(
    providers: providers,
    child: const MyApp(
    ),
  ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router(context.read()),
      title: 'Flutter Demo',
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('de', 'DE'),
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
    );
  }
}



import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:whisky_hikes/config/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:whisky_hikes/config/routing/router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:async';
import 'config/dependencies.dart';


void main() async {
  // Load env variables
  await dotenv.load();
  
  // supabase setup
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    debug: true,
  );

  runApp(MultiProvider(
    providers: providers,
    child: const MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late StreamSubscription<AuthState> _linkSubscription;

  @override
  void initState() {
    super.initState();
    _handleInitialLink();
    _handleIncomingLinks();
  }

  @override
  void dispose() {
    _linkSubscription.cancel();
    super.dispose();
  }

  void _handleInitialLink() async {
    try {
      // Handle app opened by deep link when app was closed
      // Initial link handling would go here if needed
      debugPrint('App initialized for deep link handling');
    } catch (e) {
      debugPrint('Error handling initial link: $e');
    }
  }

  void _handleIncomingLinks() {
    // Listen for incoming deep links when app is already running
    _linkSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      if (event == AuthChangeEvent.signedIn) {
        // User successfully signed in via email confirmation
        debugPrint('User confirmed email and signed in');
      }
    });
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router(context.read()),
      title: 'Whisky Hikes',
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



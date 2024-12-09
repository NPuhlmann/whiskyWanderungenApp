import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:whisky_hikes/pages/signup_page.dart';
import 'package:whisky_hikes/pages/home_page.dart';
import 'package:whisky_hikes/pages/login_page.dart';
import 'package:whisky_hikes/services/auth/auth_gate.dart';

void main() async {
  // supabase setup
  await Supabase.initialize(
    url: 'https://demmmqwxuoirwwnwijcx.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRlbW1tcXd4dW9pcnd3bndpamN4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzMzMTg4OTgsImV4cCI6MjA0ODg5NDg5OH0.Hs_jRvVxgw1BPSJS5wSqLwrSZeN4Nw76m-XLVFn_MeY',
    debug: true,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: AuthGate(),
      routes: <String, WidgetBuilder>{
        '/login': (BuildContext context) => const LoginPage(),
        '/home': (BuildContext context) => const HomePage(),
        '/signup': (BuildContext context) => const SignupPage(),
      },
    );
  }
}



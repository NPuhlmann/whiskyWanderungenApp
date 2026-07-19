import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:whisky_hikes/config/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:whisky_hikes/config/routing/router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:async';
import 'config/dependencies.dart';
import 'config/theme/app_theme.dart';
import 'config/lifecycle/app_lifecycle_manager.dart';
import 'data/services/payment/multi_payment_service.dart';
import 'data/services/offline/offline_service.dart';
import 'data/services/auth/age_gate_service.dart';
import 'data/services/cache/local_cache_service.dart';
import 'data/repositories/user_repository.dart';
import 'data/services/connectivity/connectivity_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load env variables
  await dotenv.load();

  // supabase setup
  await Supabase.initialize(
    url: _ensureHttps(dotenv.env['SUPABASE_URL']!),
    publishableKey: dotenv.env['SUPABASE_ANON_KEY']!,
    debug: _isDebugMode(),
  );

  await ConnectivityService.instance.initialize();

  // Initialize payment services
  try {
    await MultiPaymentService.instance.initialize();
    debugPrint('✅ Payment services initialized successfully');
  } catch (e) {
    debugPrint('⚠️ Payment services initialization failed: $e');
    // Continue app startup even if payment initialization fails
  }

  // Loaded before runApp so the router redirect can read the age declaration
  // synchronously on the first frame.
  final ageGateService = AgeGateService();
  await ageGateService.load();

  runApp(
    MultiProvider(
      providers: buildProviders(ageGateService),
      child: const MyApp(),
    ),
  );
}

/// Ensures HTTPS is used for Supabase URL
String _ensureHttps(String url) {
  if (url.startsWith('http://')) {
    return url.replaceFirst('http://', 'https://');
  }
  return url;
}

/// Determines if debug mode should be enabled
bool _isDebugMode() {
  // In production, always disable debug mode
  // In development, check environment variable
  const bool isProduction = bool.fromEnvironment('dart.vm.product');
  if (isProduction) {
    return false;
  }

  // Check environment variable for development
  final devMode = dotenv.env['DEV_MODE']?.toLowerCase();
  return devMode == 'true';
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late StreamSubscription<AuthState> _linkSubscription;
  AppLifecycleManager? _lifecycleManager;

  // Built once: the router owns a merged Listenable, so rebuilding it on every
  // build would leak subscriptions and reset navigation state.
  GoRouter? _router;

  @override
  void initState() {
    super.initState();
    _handleInitialLink();
    _handleIncomingLinks();
    _initializeLifecycleManager();
  }

  @override
  void dispose() {
    _linkSubscription.cancel();
    if (_lifecycleManager != null && !_lifecycleManager!.isDisposed) {
      // Schedule disposal for the next event loop iteration
      // since dispose() cannot be async in StatefulWidget
      Future.microtask(() => _lifecycleManager!.dispose());
    }
    super.dispose();
  }

  void _handleInitialLink() async {
    try {
      // Handle app opened by deep link when app was closed
      // Initial link handling would go here if needed
      if (_isDebugMode()) debugPrint('App initialized for deep link handling');
    } catch (e) {
      debugPrint('Error handling initial link: $e');
    }
  }

  void _handleIncomingLinks() {
    // Listen for incoming deep links when app is already running
    _linkSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((
      data,
    ) {
      final event = data.event;
      if (event == AuthChangeEvent.signedIn ||
          event == AuthChangeEvent.signedOut) {
        // The SDK resolves magic-link deep links into a session on its own,
        // but the router only re-evaluates its guard when UserRepository
        // notifies. Without this the user stays stranded on /login with a
        // valid session.
        if (mounted) context.read<UserRepository>().signalAuthChanged();
        if (_isDebugMode()) debugPrint('Auth state changed: $event');
      }
    });
  }

  void _initializeLifecycleManager() async {
    try {
      // Create shared instances that will be managed by the lifecycle manager
      final offlineService = OfflineService();
      final localCacheService = LocalCacheService();

      _lifecycleManager = AppLifecycleManager(
        offlineService: offlineService,
        localCacheService: localCacheService,
      );

      _lifecycleManager!.initialize();

      if (_isDebugMode()) {
        debugPrint('✅ AppLifecycleManager initialized successfully');
      }
    } catch (e) {
      debugPrint('⚠️ AppLifecycleManager initialization failed: $e');
    }
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router ??= router(context.read(), context.read()),
      title: 'Whisky Hikes',
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en', 'US'), Locale('de', 'DE')],
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
    );
  }
}

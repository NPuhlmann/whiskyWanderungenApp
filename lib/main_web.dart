import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'UI/mobile/auth/login/login_page.dart';
import 'UI/mobile/auth/login/login_page_view_model.dart';
import 'UI/mobile/auth/magic_link/magic_link_page.dart';
import 'UI/mobile/auth/magic_link/magic_link_view_model.dart';
import 'UI/mobile/auth/signup/sign_up_page_view_model.dart';
import 'UI/mobile/auth/signup/signup_page.dart';
import 'UI/web/admin/admin_router.dart';
import 'config/l10n/app_localizations.dart';
import 'config/routing/routes.dart';
import 'data/providers/admin_provider.dart';
import 'data/repositories/metrics_repository.dart';
import 'data/repositories/user_repository.dart';
import 'data/services/admin/admin_service.dart';
import 'data/services/admin/dashboard_metrics_service.dart';
import 'data/services/auth/auth_service.dart';

/// Web-Admin-Version der App.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load();

  // The admin routes are guarded by AdminGuard, which queries the database on
  // the very first frame — without this the app dies on Supabase.instance.
  await Supabase.initialize(
    url: _ensureHttps(dotenv.env['SUPABASE_URL']!),
    publishableKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(const WhiskyHikesWebApp());
}

/// Ensures HTTPS is used for the Supabase URL.
String _ensureHttps(String url) =>
    url.startsWith('http://') ? url.replaceFirst('http://', 'https://') : url;

class WhiskyHikesWebApp extends StatelessWidget {
  const WhiskyHikesWebApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<MetricsRepository>(
          create: (_) =>
              MetricsRepository(AdminService(), DashboardMetricsService()),
        ),
        ChangeNotifierProvider(
          create: (context) => AdminProvider(metricsRepository: context.read()),
        ),
        // AdminGuard reads this on the first frame; without it every admin
        // route hung on its spinner.
        ChangeNotifierProvider<UserRepository>(
          create: (context) => UserRepository(context.read<AuthService>()),
        ),
      ],
      child: const _AdminApp(),
    );
  }
}

class _AdminApp extends StatefulWidget {
  const _AdminApp();

  @override
  State<_AdminApp> createState() => _AdminAppState();
}

class _AdminAppState extends State<_AdminApp> {
  GoRouter? _router;

  @override
  Widget build(BuildContext context) {
    // Built once: a fresh GoRouter per rebuild would reset the history.
    _router ??= _buildRouter(context.read<UserRepository>());
    return MaterialApp.router(
      title: 'Whisky Hikes - Web Admin',
      theme: ThemeData(primarySwatch: Colors.amber, useMaterial3: true),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en', 'US'), Locale('de', 'DE')],
      routerConfig: _router,
    );
  }
}

/// Routes a logged-in user has no business staying on.
const _authRoutes = {Routes.login, Routes.signUp, Routes.magicLink};

GoRouter _buildRouter(UserRepository userRepository) => GoRouter(
  initialLocation: AdminRouter.dashboardRoute,
  // LoginPage does not navigate itself — the mobile router moves the user on
  // via this listenable, and the admin router needs the same wiring.
  refreshListenable: userRepository,
  redirect: (context, state) =>
      _authRoutes.contains(state.matchedLocation) &&
          userRepository.isUserLoggedIn()
      ? AdminRouter.dashboardRoute
      : null,
  routes: [
    GoRoute(
      path: '/',
      redirect: (context, state) => AdminRouter.dashboardRoute,
    ),
    // AdminGuard redirects here when logged out.
    GoRoute(
      path: Routes.login,
      builder: (context, state) => ChangeNotifierProvider(
        create: (context) => LoginPageViewModel(userRepository: context.read()),
        child: Consumer<LoginPageViewModel>(
          builder: (context, viewModel, _) => LoginPage(viewModel: viewModel),
        ),
      ),
    ),
    // LoginPage links to both of these.
    GoRoute(
      path: Routes.magicLink,
      builder: (context, state) => ChangeNotifierProvider(
        create: (context) => MagicLinkViewModel(userRepository: context.read()),
        child: Consumer<MagicLinkViewModel>(
          builder: (context, viewModel, _) =>
              MagicLinkPage(viewModel: viewModel),
        ),
      ),
    ),
    GoRoute(
      path: Routes.signUp,
      builder: (context, state) => ChangeNotifierProvider(
        create: (context) => SignUpPageViewModel(
          userRepository: context.read(),
          authService: context.read(),
        ),
        child: Consumer<SignUpPageViewModel>(
          builder: (context, viewModel, _) => SignupPage(viewModel: viewModel),
        ),
      ),
    ),
    ...AdminRouter.getAdminRoutes(),
  ],
);

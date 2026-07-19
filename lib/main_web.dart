import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'UI/web/admin/admin_router.dart';
import 'data/providers/admin_provider.dart';
import 'data/repositories/metrics_repository.dart';
import 'data/services/admin/admin_service.dart';
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
          create: (_) => MetricsRepository(AdminService()),
        ),
        ChangeNotifierProvider(
          create: (context) => AdminProvider(metricsRepository: context.read()),
        ),
      ],
      child: MaterialApp.router(
        title: 'Whisky Hikes - Web Admin',
        theme: ThemeData(primarySwatch: Colors.amber, useMaterial3: true),
        routerConfig: GoRouter(
          initialLocation: AdminRouter.dashboardRoute,
          routes: [
            GoRoute(
              path: '/',
              redirect: (context, state) => AdminRouter.dashboardRoute,
            ),
            ...AdminRouter.getAdminRoutes(),
          ],
        ),
      ),
    );
  }
}

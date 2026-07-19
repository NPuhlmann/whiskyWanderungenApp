// dependencies for repositories and services

import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:whisky_hikes/UI/mobile/hike_details/hike_details_view_model.dart';
import 'package:whisky_hikes/UI/mobile/my_hikes/my_hikes_view_model.dart';
import 'package:whisky_hikes/data/repositories/hike_images_repository.dart';
import 'package:whisky_hikes/data/repositories/offline_first_hike_repository.dart';
import 'package:whisky_hikes/data/repositories/offline_first_waypoint_repository.dart';
import 'package:whisky_hikes/data/repositories/payment_repository.dart';
import 'package:whisky_hikes/data/repositories/purchase_intake_repository.dart';
import 'package:whisky_hikes/data/services/payment/stripe_confirm_adapter.dart';

import '../UI/mobile/home/home_view_model.dart';
import '../data/repositories/profile_repository.dart';
import '../data/repositories/user_repository.dart';
import '../data/services/auth/auth_service.dart';
import '../data/services/auth/age_gate_service.dart';
import '../data/services/cache/local_cache_service.dart';
import '../data/services/connectivity/connectivity_service.dart';
import '../data/services/offline/offline_service.dart';
import '../data/services/database/backend_api.dart';
import '../data/services/admin/order_management_service.dart';
import '../data/providers/order_management_provider.dart';
import '../data/services/whisky/whisky_management_service.dart';
import '../data/providers/whisky_management_provider.dart';
import '../data/services/commission/commission_service.dart';
import '../data/providers/commission_provider.dart';
import '../data/providers/team_provider.dart';
import '../data/services/analytics/sales_analytics_service.dart';
import '../data/services/analytics/customer_analytics_service.dart';
import '../data/providers/analytics_provider.dart';
import '../data/providers/admin_provider.dart';
import '../data/providers/dashboard_provider.dart';
import '../data/providers/route_management_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// [ageGateService] is created and loaded in `main` before `runApp` so the
/// router's redirect never sees a stale "undeclared" on the first frame and
/// flashes the age gate at a user who already answered it.
List<SingleChildWidget> buildProviders(AgeGateService ageGateService) {
  return [
    // Services zuerst bereitstellen
    ChangeNotifierProvider<AgeGateService>.value(value: ageGateService),
    Provider<AuthService>(create: (_) => AuthService()),
    Provider<BackendApiService>(create: (_) => BackendApiService()),
    Provider<LocalCacheService>(create: (_) => LocalCacheService()),
    Provider<OfflineService>(create: (_) => OfflineService()),
    // ConnectivityService: Singleton-Instanz, initialisiert in main.dart.
    Provider<ConnectivityService>(create: (_) => ConnectivityService.instance),
    Provider<OrderManagementService>(create: (_) => OrderManagementService()),
    Provider<WhiskyManagementService>(
      create: (_) => WhiskyManagementService(Supabase.instance.client),
    ),
    Provider<CommissionService>(
      create: (_) => CommissionService(Supabase.instance.client),
    ),
    Provider<SalesAnalyticsService>(
      create: (_) => SalesAnalyticsService(client: Supabase.instance.client),
    ),
    Provider<CustomerAnalyticsService>(
      create: (_) => CustomerAnalyticsService(client: Supabase.instance.client),
    ),

    // Dann alle Repositories
    Provider<ProfileRepository>(
      create: (context) => ProfileRepository(
        context.read<BackendApiService>(),
        context.read<LocalCacheService>(),
      ),
    ),
    ChangeNotifierProvider<UserRepository>(
      create: (context) => UserRepository(context.read<AuthService>()),
    ),
    Provider<OfflineFirstHikeRepository>(
      create: (context) => OfflineFirstHikeRepository(
        context.read<BackendApiService>(),
        context.read<OfflineService>(),
        context.read<ConnectivityService>(),
      ),
    ),
    Provider<HikeImagesRepository>(
      create: (context) =>
          HikeImagesRepository(context.read<BackendApiService>()),
    ),
    Provider<OfflineFirstWaypointRepository>(
      create: (context) => OfflineFirstWaypointRepository(
        context.read<BackendApiService>(),
        context.read<OfflineService>(),
        context.read<ConnectivityService>(),
      ),
    ),
    Provider<PaymentRepository>(
      create: (context) => PaymentRepositoryFactory.create(
        supabaseClient: null, // Will use default Supabase.instance.client
      ),
    ),
    Provider<StripeConfirmAdapter>(
      create: (context) => const FlutterStripeConfirmAdapter(),
    ),
    Provider<PurchaseIntakeRepository>(
      create: (context) => PurchaseIntakeRepository(
        confirmAdapter: context.read<StripeConfirmAdapter>(),
      ),
    ),

    // Dann alle ViewModels
    ChangeNotifierProvider<HomePageViewModel>(
      create: (context) => HomePageViewModel(
        hikeRepository: context.read(),
        profileRepository: context.read(),
        userRepository: context.read(),
      ),
    ),
    ChangeNotifierProvider<HikeDetailsPageViewModel>(
      create: (context) => HikeDetailsPageViewModel(
        hikeImagesRepository: context.read<HikeImagesRepository>(),
        waypointRepository: context.read<OfflineFirstWaypointRepository>(),
      ),
    ),
    ChangeNotifierProvider<MyHikesViewModel>(
      create: (context) => MyHikesViewModel(
        hikeRepository: context.read(),
        userRepository: context.read(),
      ),
    ),

    // Admin-Provider
    ChangeNotifierProvider<OrderManagementProvider>(
      create: (context) => OrderManagementProvider(
        orderManagementService: context.read<OrderManagementService>(),
      ),
    ),
    ChangeNotifierProvider<WhiskyManagementProvider>(
      create: (context) =>
          WhiskyManagementProvider(context.read<WhiskyManagementService>()),
    ),
    ChangeNotifierProvider<CommissionProvider>(
      create: (context) => CommissionProvider(
        commissionService: context.read<CommissionService>(),
      ),
    ),
    ChangeNotifierProvider<TeamProvider>(
      create: (context) =>
          TeamProvider(userRepository: context.read<UserRepository>()),
    ),
    ChangeNotifierProvider<AnalyticsProvider>(
      create: (context) => AnalyticsProvider(
        salesService: context.read<SalesAnalyticsService>(),
        customerService: context.read<CustomerAnalyticsService>(),
      ),
    ),
    // Admin-Dashboard & Route-Management
    ChangeNotifierProvider<AdminProvider>(create: (_) => AdminProvider()),
    ChangeNotifierProvider<DashboardProvider>(
      create: (_) => DashboardProvider(),
    ),
    ChangeNotifierProvider<RouteManagementProvider>(
      create: (_) => RouteManagementProvider(),
    ),

    // HikeMapViewModel wird in HikeMapScreen erstellt
  ];
}

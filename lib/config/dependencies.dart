// dependencies for repositories and services

import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:whisky_hikes/UI/mobile/hike_details/hike_details_view_model.dart';
import 'package:whisky_hikes/UI/mobile/my_hikes/my_hikes_view_model.dart';
import 'package:whisky_hikes/data/repositories/hike_images_repository.dart';
import 'package:whisky_hikes/data/repositories/hike_repository.dart';
import 'package:whisky_hikes/data/repositories/waypoint_repository.dart';
import 'package:whisky_hikes/data/repositories/payment_repository.dart';
import 'package:whisky_hikes/data/providers/cart_provider.dart';

import '../UI/mobile/home/home_view_model.dart';
import '../data/repositories/profile_repository.dart';
import '../data/repositories/user_repository.dart';
import '../data/services/auth/auth_service.dart';
import '../data/services/cache/age_gate_service.dart';
import '../data/services/cache/local_cache_service.dart';
import '../data/services/offline/offline_service.dart';
import '../data/services/database/backend_api.dart';
import '../data/services/admin/order_management_service.dart';
import '../data/providers/order_management_provider.dart';
import '../data/services/whisky/whisky_management_service.dart';
import '../data/providers/whisky_management_provider.dart';
import '../data/services/commission/commission_service.dart';
import '../data/providers/commission_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

List<SingleChildWidget> buildProviders(AgeGateService ageGateService) {
  return [
    // Age gate — pre-initialized before runApp
    ChangeNotifierProvider<AgeGateService>.value(value: ageGateService),

    // Services zuerst bereitstellen
    Provider<AuthService>(create: (_) => AuthService()),
    Provider<BackendApiService>(create: (_) => BackendApiService()),
    Provider<LocalCacheService>(create: (_) => LocalCacheService()),
    Provider<OfflineService>(create: (_) => OfflineService()),
    Provider<OrderManagementService>(create: (_) => OrderManagementService()),
    Provider<WhiskyManagementService>(
      create: (_) => WhiskyManagementService(Supabase.instance.client),
    ),
    Provider<CommissionService>(
      create: (_) => CommissionService(Supabase.instance.client),
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
    Provider<HikeRepository>(
      create: (context) => HikeRepository(context.read<BackendApiService>()),
    ),
    Provider<HikeImagesRepository>(
      create: (context) =>
          HikeImagesRepository(context.read<BackendApiService>()),
    ),
    // WaypointRepository explizit vor den ViewModels registrieren
    Provider<WaypointRepository>(
      create: (context) =>
          WaypointRepository(context.read<BackendApiService>()),
      lazy: false, // Sofort initialisieren, nicht erst bei Bedarf
    ),
    Provider<PaymentRepository>(
      create: (context) => PaymentRepositoryFactory.create(
        supabaseClient: null, // Will use default Supabase.instance.client
        stripeService: null, // Will use StripeService.instance
      ),
    ),
    ChangeNotifierProvider<CartProvider>(
      create: (_) => CartProvider(),
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
        waypointRepository: context.read<WaypointRepository>(),
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

    // HikeMapViewModel wird in HikeMapScreen erstellt
  ];
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:whisky_hikes/UI/mobile/auth/age_gate/age_gate_page.dart';
import 'package:whisky_hikes/UI/mobile/auth/age_gate/age_gate_view_model.dart';
import 'package:whisky_hikes/UI/mobile/auth/login/login_page.dart';
import 'package:whisky_hikes/UI/mobile/auth/magic_link/magic_link_page.dart';
import 'package:whisky_hikes/UI/mobile/auth/magic_link/magic_link_view_model.dart';
import 'package:whisky_hikes/UI/mobile/auth/login/login_page_view_model.dart';
import 'package:whisky_hikes/UI/mobile/auth/signup/signup_page.dart';
import 'package:whisky_hikes/UI/mobile/hike_details/hike_details_page.dart';
import 'package:whisky_hikes/UI/mobile/hike_map/hike_map_page.dart';
import 'package:whisky_hikes/UI/mobile/home/home_page.dart';
import 'package:whisky_hikes/UI/mobile/my_hikes/my_hikes_page.dart';
import 'package:whisky_hikes/UI/mobile/profile/profile_page.dart';
import 'package:whisky_hikes/UI/mobile/profile/profile_view_model.dart';
import 'package:whisky_hikes/UI/mobile/checkout/checkout_page.dart';
import 'package:whisky_hikes/UI/mobile/payment/payment_success_page.dart';
import 'package:whisky_hikes/UI/mobile/payment/payment_failed_page.dart';
import 'package:whisky_hikes/UI/mobile/payment/order_history_page.dart';
import 'package:whisky_hikes/UI/mobile/orders/order_tracking_page.dart';
import 'package:whisky_hikes/config/routing/auth_redirect.dart';
import 'package:whisky_hikes/config/routing/routes.dart';
import 'package:whisky_hikes/data/repositories/user_repository.dart';
import 'package:whisky_hikes/data/services/auth/age_gate_service.dart';
import 'package:whisky_hikes/domain/models/hike.dart';

import '../../UI/mobile/auth/signup/sign_up_page_view_model.dart';
import '../../UI/core/scaffold_with_navigation_bar.dart';
import '../../UI/mobile/hike_details/hike_details_view_model.dart';
import '../../UI/mobile/home/home_view_model.dart';
import '../../UI/mobile/my_hikes/my_hikes_view_model.dart';
import '../../UI/web/admin/admin_router.dart';

GoRouter router(
  UserRepository authRepository,
  AgeGateService ageGateService,
) => GoRouter(
  initialLocation: Routes.home,
  debugLogDiagnostics: true,
  redirect: _redirect,
  // Both must refresh the guard: the age declaration decides whether the user
  // reaches auth at all.
  refreshListenable: Listenable.merge([authRepository, ageGateService]),
  routes: [
    GoRoute(
      path: Routes.ageGate,
      // ChangeNotifierProvider so the ViewModel's listener on AgeGateService
      // is released when the route goes away.
      builder: (context, state) => ChangeNotifierProvider(
        create: (context) => AgeGateViewModel(ageGateService: context.read()),
        child: Consumer<AgeGateViewModel>(
          builder: (context, viewModel, _) => AgeGatePage(viewModel: viewModel),
        ),
      ),
    ),
    GoRoute(
      path: Routes.magicLink,
      builder: (context, state) {
        final viewModel = MagicLinkViewModel(userRepository: context.read());
        return MagicLinkPage(viewModel: viewModel);
      },
    ),
    GoRoute(
      path: Routes.login,
      builder: (context, state) {
        final viewModel = LoginPageViewModel(userRepository: context.read());
        return LoginPage(viewModel: viewModel);
      },
    ),
    GoRoute(
      path: Routes.signUp,
      builder: (context, state) {
        final viewModel = SignUpPageViewModel(
          userRepository: context.read(),
          authService: context.read(),
        );
        return SignupPage(viewModel: viewModel);
      },
    ),
    StatefulShellRoute.indexedStack(
      builder:
          (
            BuildContext context,
            GoRouterState state,
            StatefulNavigationShell navigationShell,
          ) {
            return ScaffoldWithNavigationBar(navigationShell: navigationShell);
          },
      branches: <StatefulShellBranch>[
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: Routes.home,
              builder: (context, state) {
                final viewModel = context.watch<HomePageViewModel>();
                return HomePage(viewModel: viewModel);
              },
              routes: _hikeRoutes(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: Routes.myHikes,
              builder: (context, state) {
                final viewModel = context.watch<MyHikesViewModel>();
                return MyHikesPage(viewModel: viewModel);
              },
              routes: _hikeRoutes(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: Routes.profile,
              builder: (context, state) {
                final viewModel = ProfilePageViewModel(
                  profileRepository: context.read(),
                  userRepository: context.read(),
                );
                return ProfilePage(viewModel: viewModel);
              },
            ),
          ],
        ),
      ],
    ),

    // Payment routes - outside of the shell navigation
    GoRoute(
      path: Routes.checkout,
      name: 'checkout',
      builder: (context, state) {
        final hike = state.extra as Hike?;
        if (hike == null) return const _HikeNotFound();

        return CheckoutPage(hike: hike);
      },
    ),

    GoRoute(
      path: Routes.paymentSuccess,
      name: 'payment-success',
      builder: (context, state) {
        final orderNumber = state.uri.queryParameters['orderNumber'];
        return PaymentSuccessPage(orderNumber: orderNumber);
      },
    ),

    GoRoute(
      path: Routes.paymentFailed,
      name: 'payment-failed',
      builder: (context, state) {
        final errorMessage = state.uri.queryParameters['error'];
        return PaymentFailedPage(errorMessage: errorMessage);
      },
    ),

    GoRoute(
      path: Routes.orderHistory,
      name: 'order-history',
      builder: (context, state) {
        return const OrderHistoryPage();
      },
    ),

    GoRoute(
      path: '${Routes.orderTracking}/:orderId',
      name: 'order-tracking',
      builder: (context, state) {
        final orderIdStr = state.pathParameters['orderId'];
        final orderId = int.tryParse(orderIdStr ?? '');

        if (orderId == null) {
          return const Scaffold(
            body: Center(child: Text('Ungültige Bestell-ID')),
          );
        }

        return OrderTrackingPage(orderId: orderId);
      },
    ),

    // Admin routes (/admin/*) — guarded per-page by AdminGuard.
    ...AdminRouter.getAdminRoutes(),
  ],
);

// Declared once and mounted under both the home and the my-hikes branch —
// the pages behave the same either way, HikeDetailsPage already knows which
// branch it came from via isFromMyHikes.
List<RouteBase> _hikeRoutes() => [
  GoRoute(
    path: Routes.hikeDetails,
    builder: (context, state) {
      final hike = _hikeFrom(state);
      if (hike == null) return const _HikeNotFound();
      return HikeDetailsPage(
        hikeData: hike,
        viewModel: context.watch<HikeDetailsPageViewModel>(),
        isFromMyHikes: _isFromMyHikes(state),
      );
    },
    routes: [
      GoRoute(
        path: Routes.hikeMap,
        builder: (context, state) {
          final hike = _hikeFrom(state);
          if (hike == null) return const _HikeNotFound();
          return HikeMapPage(hikeId: hike.id);
        },
      ),
    ],
  ),
];

// state.extra is null on a deep link, a web reload or a restored route stack,
// so every read has to tolerate its absence.
Map<String, dynamic>? _extra(GoRouterState state) =>
    state.extra is Map<String, dynamic>
    ? state.extra as Map<String, dynamic>
    : null;

Hike? _hikeFrom(GoRouterState state) => _extra(state)?['hike'] as Hike?;

bool _isFromMyHikes(GoRouterState state) =>
    _extra(state)?['isFromMyHikes'] as bool? ?? false;

class _HikeNotFound extends StatelessWidget {
  const _HikeNotFound();

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Wanderung nicht gefunden')));
}

// Decision logic lives in resolveRedirect (auth_redirect.dart) so it can be
// unit-tested without a BuildContext.
Future<String?> _redirect(BuildContext context, GoRouterState state) async {
  return resolveRedirect(
    location: state.matchedLocation,
    ageAllowed: context.read<AgeGateService>().isAllowed,
    loggedIn: context.read<UserRepository>().isUserLoggedIn(),
  );
}

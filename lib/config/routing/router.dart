import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:whisky_hikes/UI/mobile/auth/age_gate/age_blocked_screen.dart';
import 'package:whisky_hikes/UI/mobile/auth/age_gate/age_gate_screen.dart';
import 'package:whisky_hikes/UI/mobile/auth/login/login_page.dart';
import 'package:whisky_hikes/UI/mobile/auth/login/login_page_view_model.dart';
import 'package:whisky_hikes/UI/mobile/auth/magic_link/magic_link_page.dart';
import 'package:whisky_hikes/UI/mobile/auth/magic_link/magic_link_verify_page.dart';
import 'package:whisky_hikes/UI/mobile/auth/signup/signup_page.dart';
import 'package:whisky_hikes/UI/mobile/hike_details/hike_details_page.dart';
import 'package:whisky_hikes/UI/mobile/hike_map/hike_map_page.dart';
import 'package:whisky_hikes/UI/mobile/home/home_page.dart';
import 'package:whisky_hikes/UI/mobile/my_hikes/my_hikes_page.dart';
import 'package:whisky_hikes/UI/mobile/profile/profile_page.dart';
import 'package:whisky_hikes/UI/mobile/profile/profile_view_model.dart';
import 'package:whisky_hikes/UI/mobile/cart/cart_page.dart';
import 'package:whisky_hikes/UI/mobile/checkout/checkout_page.dart';
import 'package:whisky_hikes/UI/mobile/checkout/stub_checkout_page.dart';
import 'package:whisky_hikes/UI/mobile/payment/payment_success_page.dart';
import 'package:whisky_hikes/UI/mobile/payment/payment_failed_page.dart';
import 'package:whisky_hikes/UI/mobile/payment/order_history_page.dart';
import 'package:whisky_hikes/UI/mobile/orders/order_tracking_page.dart';
import 'package:whisky_hikes/config/routing/routes.dart';
import 'package:whisky_hikes/data/repositories/user_repository.dart';
import 'package:whisky_hikes/data/services/cache/age_gate_service.dart';
import 'package:whisky_hikes/domain/models/hike.dart';
import 'package:whisky_hikes/domain/models/basic_order.dart';

import '../../UI/mobile/auth/signup/sign_up_page_view_model.dart';
import '../../UI/core/scaffold_with_navigation_bar.dart';
import '../../UI/mobile/hike_details/hike_details_view_model.dart';
import '../../UI/mobile/home/home_view_model.dart';
import '../../UI/mobile/my_hikes/my_hikes_view_model.dart';

GoRouter router(
  UserRepository authRepository,
  AgeGateService ageGateService,
) => GoRouter(
  initialLocation: Routes.home,
  debugLogDiagnostics: true,
  redirect: _redirect,
  refreshListenable: Listenable.merge([authRepository, ageGateService]),
  routes: [
    // Age gate routes — accessible regardless of auth state
    GoRoute(
      path: Routes.ageGate,
      builder: (context, state) => const AgeGateScreen(),
    ),
    GoRoute(
      path: Routes.ageBlocked,
      builder: (context, state) => const AgeBlockedScreen(),
    ),

    // Auth routes
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
    GoRoute(
      path: Routes.magicLink,
      builder: (context, state) => const MagicLinkPage(),
    ),
    GoRoute(
      path: Routes.magicLinkVerify,
      builder: (context, state) {
        final email = state.extra as String? ?? '';
        return MagicLinkVerifyPage(email: email);
      },
    ),

    // Main app shell
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
              routes: [
                GoRoute(
                  path: Routes.hikeDetails,
                  builder: (context, state) {
                    final Map<String, dynamic> extraData =
                        state.extra as Map<String, dynamic>;
                    final hikeData = extraData['hike'] as Hike;
                    final isFromMyHikes = extraData['isFromMyHikes'] as bool;
                    final viewModel = context.watch<HikeDetailsPageViewModel>();
                    return HikeDetailsPage(
                      hikeData: hikeData,
                      viewModel: viewModel,
                      isFromMyHikes: isFromMyHikes,
                    );
                  },
                  routes: [
                    GoRoute(
                      path: Routes.hikeMap.substring(1),
                      builder: (context, state) {
                        final Map<String, dynamic> extraData =
                            state.extra as Map<String, dynamic>;
                        final hike = extraData['hike'] as Hike;
                        return HikeMapPage(hikeId: hike.id);
                      },
                    ),
                  ],
                ),
              ],
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
              routes: [
                GoRoute(
                  path: Routes.hikeDetails.substring(1),
                  builder: (context, state) {
                    final Map<String, dynamic> extraData =
                        state.extra as Map<String, dynamic>;
                    final hikeData = extraData['hike'] as Hike;
                    final isFromMyHikes = extraData['isFromMyHikes'] as bool;
                    final viewModel = context.watch<HikeDetailsPageViewModel>();
                    return HikeDetailsPage(
                      hikeData: hikeData,
                      viewModel: viewModel,
                      isFromMyHikes: isFromMyHikes,
                    );
                  },
                  routes: [
                    GoRoute(
                      path: Routes.hikeMap.substring(1),
                      builder: (context, state) {
                        final Map<String, dynamic> extraData =
                            state.extra as Map<String, dynamic>;
                        final hike = extraData['hike'] as Hike;
                        return HikeMapPage(hikeId: hike.id);
                      },
                    ),
                  ],
                ),
              ],
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

    // Cart + payment routes — outside of the shell navigation
    GoRoute(
      path: Routes.cart,
      name: 'cart',
      builder: (context, state) => const CartPage(),
    ),
    GoRoute(
      path: Routes.stubCheckout,
      name: 'stub-checkout',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        final deliveryType =
            extra['deliveryType'] as DeliveryType? ??
            DeliveryType.standardShipping;
        final totalAmount = (extra['totalAmount'] as num?)?.toDouble() ?? 0.0;
        return StubCheckoutPage(
          deliveryType: deliveryType,
          totalAmount: totalAmount,
        );
      },
    ),
    GoRoute(
      path: Routes.checkout,
      name: 'checkout',
      builder: (context, state) {
        final order = state.extra as BasicOrder?;
        if (order == null) {
          return const Scaffold(
            body: Center(child: Text('Bestellung nicht gefunden')),
          );
        }
        return CheckoutPage(order: order);
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
      builder: (context, state) => const OrderHistoryPage(),
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
  ],
);

Future<String?> _redirect(BuildContext context, GoRouterState state) async {
  final ageGateService = context.read<AgeGateService>();
  final authRepository = context.read<UserRepository>();
  final loc = state.matchedLocation;

  // Age gate must pass before anything else
  if (!ageGateService.ageGateShown) {
    return loc == Routes.ageGate ? null : Routes.ageGate;
  }
  if (!ageGateService.isAgeConfirmed) {
    return loc == Routes.ageBlocked ? null : Routes.ageBlocked;
  }

  // Auth check — magic link pages are accessible without being logged in
  final bool loggedIn = authRepository.isUserLoggedIn();
  final bool onAuthPage =
      loc == Routes.login ||
      loc == Routes.signUp ||
      loc == Routes.magicLink ||
      loc == Routes.magicLinkVerify;

  if (!loggedIn && !onAuthPage) {
    return Routes.login;
  }

  // Redirect away from login once authenticated
  if (loggedIn && loc == Routes.login) {
    return Routes.home;
  }

  return null;
}

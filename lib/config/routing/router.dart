import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:whisky_hikes/UI/auth/login/login_page.dart';
import 'package:whisky_hikes/UI/auth/login/login_page_view_model.dart';
import 'package:whisky_hikes/UI/auth/signup/signup_page.dart';
import 'package:whisky_hikes/UI/hike_details/hike_details_page.dart';
import 'package:whisky_hikes/UI/hike_map/hike_map_page.dart';
import 'package:whisky_hikes/UI/home/home_page.dart';
import 'package:whisky_hikes/UI/my_hikes/my_hikes_page.dart';
import 'package:whisky_hikes/UI/profile/profile_page.dart';
import 'package:whisky_hikes/UI/profile/profile_view_model.dart';
import 'package:whisky_hikes/UI/checkout/checkout_page.dart';
import 'package:whisky_hikes/UI/payment/payment_success_page.dart';
import 'package:whisky_hikes/UI/payment/payment_failed_page.dart';
import 'package:whisky_hikes/UI/payment/order_history_page.dart';
import 'package:whisky_hikes/UI/orders/order_tracking_page.dart';
import 'package:whisky_hikes/config/routing/routes.dart';
import 'package:whisky_hikes/data/repositories/user_repository.dart';
import 'package:whisky_hikes/domain/models/hike.dart';
import 'package:whisky_hikes/domain/models/basic_order.dart';

import '../../UI/auth/signup/sign_up_page_view_model.dart';
import '../../UI/core/scaffold_with_navigation_bar.dart';
import '../../UI/hike_details/hike_details_view_model.dart';
import '../../UI/home/home_view_model.dart';
import '../../UI/my_hikes/my_hikes_view_model.dart';

GoRouter router(UserRepository authRepository) => GoRouter(
        initialLocation: Routes.home,
        debugLogDiagnostics: true,
        redirect: _redirect,
        refreshListenable: authRepository,
        routes: [
          GoRoute(
              path: Routes.login,
              builder: (context, state) {
                final viewModel =
                    LoginPageViewModel(userRepository: context.read());
                return LoginPage(viewModel: viewModel);
              }),
          GoRoute(
              path: Routes.signUp,
              builder: (context, state) {
                final viewModel = SignUpPageViewModel(
                  userRepository: context.read(),
                  authService: context.read(),
                );
                return SignupPage(viewModel: viewModel);
              }),
          StatefulShellRoute.indexedStack(
              builder: (BuildContext context, GoRouterState state,
                  StatefulNavigationShell navigationShell) {
                return ScaffoldWithNavigationBar(
                    navigationShell: navigationShell);
              },
              branches: <StatefulShellBranch>[
                StatefulShellBranch(routes: <RouteBase>[
                  GoRoute(
                    path: Routes.home,
                    builder: (context, state) {
                      final viewModel = context.watch<HomePageViewModel>();
                      return HomePage(
                        viewModel: viewModel,
                      );
                    },
                    routes: [GoRoute(path: Routes.hikeDetails, builder: (context, state) {
                      final Map<String, dynamic> extraData = state.extra as Map<String, dynamic>;
                      final hikeData = extraData['hike'] as Hike;
                      final isFromMyHikes = extraData['isFromMyHikes'] as bool;
                      final viewModel = context.watch<HikeDetailsPageViewModel>();
                      return HikeDetailsPage(hikeData: hikeData, viewModel: viewModel, isFromMyHikes: isFromMyHikes);
                    },
                    routes: [
                      GoRoute(
                        path: Routes.hikeMap.substring(1), // Entferne den führenden Slash
                        builder: (context, state) {
                          final Map<String, dynamic> extraData = state.extra as Map<String, dynamic>;
                          final hike = extraData['hike'] as Hike;
                          return HikeMapPage(hikeId: hike.id);
                        }
                      )
                    ])],
                  ),
                ]),
                StatefulShellBranch(routes: <RouteBase>[
                  GoRoute(
                      path: Routes.myHikes,
                      builder: (context, state) {
                        final viewModel = context.watch<MyHikesViewModel>();
                        return MyHikesPage(viewModel: viewModel);
                      },
                      routes: [
                        GoRoute(
                          path: Routes.hikeDetails.substring(1), // Entferne den führenden Slash
                          builder: (context, state) {
                            final Map<String, dynamic> extraData = state.extra as Map<String, dynamic>;
                            final hikeData = extraData['hike'] as Hike;
                            final isFromMyHikes = extraData['isFromMyHikes'] as bool;
                            final viewModel = context.watch<HikeDetailsPageViewModel>();
                            return HikeDetailsPage(hikeData: hikeData, viewModel: viewModel, isFromMyHikes: isFromMyHikes);
                          },
                          routes: [
                            GoRoute(
                              path: Routes.hikeMap.substring(1), // Entferne den führenden Slash
                              builder: (context, state) {
                                final Map<String, dynamic> extraData = state.extra as Map<String, dynamic>;
                                final hike = extraData['hike'] as Hike;
                                return HikeMapPage(hikeId: hike.id);
                              }
                            )
                          ]
                        )
                      ]
                  )
                ]),
                StatefulShellBranch(routes: <RouteBase>[
                  GoRoute(
                      path: Routes.profile,
                      builder: (context, state) {
                        final viewModel = ProfilePageViewModel(
                            profileRepository: context.read(),
                            userRepository: context.read());
                        return ProfilePage(viewModel: viewModel);
                      }),
                ]),
              ]),
          
          // Payment routes - outside of the shell navigation
          GoRoute(
            path: Routes.checkout,
            name: 'checkout',
            builder: (context, state) {
              final order = state.extra as BasicOrder?;
              if (order == null) {
                return const Scaffold(
                  body: Center(
                    child: Text('Bestellung nicht gefunden'),
                  ),
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
                  body: Center(
                    child: Text('Ungültige Bestell-ID'),
                  ),
                );
              }
              
              return OrderTrackingPage(orderId: orderId);
            },
          )
        ]);

// From https://github.com/flutter/packages/blob/main/packages/go_router/example/lib/redirection.dart
Future<String?> _redirect(BuildContext context, GoRouterState state) async {
  // if the user is not logged in, they need to login
  final bool loggedIn = context.read<UserRepository>().isUserLoggedIn();
  final bool loggingIn = state.matchedLocation == Routes.login;
  final bool signingUp = state.matchedLocation == Routes.signUp;
  if (!loggedIn && !signingUp) {
    return Routes.login;
  } else if (!loggedIn && signingUp) {
    return Routes.signUp;
  }

  // if the user is logged in but still on the login page, send them to
  // the home page
  if (loggingIn) {
    return Routes.home;
  }

  // no need to redirect at all
  return null;
}

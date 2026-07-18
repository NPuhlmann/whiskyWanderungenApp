import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:whisky_hikes/UI/mobile/hike_details/hike_details_page.dart';
import 'package:whisky_hikes/UI/mobile/hike_details/hike_details_view_model.dart';
import 'package:whisky_hikes/config/l10n/app_localizations.dart';
import 'package:whisky_hikes/config/routing/routes.dart';
import 'package:whisky_hikes/domain/models/hike.dart';

@GenerateMocks([HikeDetailsPageViewModel])
import 'hike_details_page_test.mocks.dart';

void main() {
  late MockHikeDetailsPageViewModel mockViewModel;
  late Hike testHike;

  /// Captures whatever the checkout route was handed as `state.extra`.
  Object? checkoutExtra;

  setUp(() {
    checkoutExtra = null;
    mockViewModel = MockHikeDetailsPageViewModel();
    when(mockViewModel.hikeImages).thenReturn(<String>[]);
    when(mockViewModel.getHikeImages(any)).thenAnswer((_) async {});
    when(
      mockViewModel.isHikeAvailableOffline(any),
    ).thenAnswer((_) async => false);

    testHike = const Hike(
      id: 7,
      name: 'Islay Trail',
      length: 12.0,
      steep: 3.0,
      elevation: 200,
      description: 'A trail',
      difficulty: Difficulty.mid,
      price: 45.0,
      companyId: 'company-1',
    );
  });

  Future<void> pumpDetailsPage(WidgetTester tester) async {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) =>
              HikeDetailsPage(hikeData: testHike, viewModel: mockViewModel),
        ),
        GoRoute(
          path: Routes.checkout,
          builder: (context, state) {
            checkoutExtra = state.extra;
            return const Scaffold(body: Text('checkout-stub'));
          },
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    );
    // Not pumpAndSettle: the image carousel keeps a spinner running while
    // hikeImages is empty, so the tree never settles.
    await tester.pump(const Duration(milliseconds: 100));
  }

  group('HikeDetailsPage buy button', () {
    testWidgets('navigates to checkout carrying the hike', (tester) async {
      await pumpDetailsPage(tester);

      final buyButton = find.widgetWithText(ElevatedButton, 'Buy');
      expect(buyButton, findsOneWidget);

      await tester.ensureVisible(buyButton);
      await tester.pump();
      await tester.tap(buyButton);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('checkout-stub'), findsOneWidget);
      expect(checkoutExtra, isA<Hike>());
      expect((checkoutExtra as Hike).id, testHike.id);
    });
  });
}

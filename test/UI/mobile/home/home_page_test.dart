import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:whisky_hikes/UI/mobile/home/home_page.dart';
import 'package:whisky_hikes/UI/mobile/home/home_view_model.dart';
import 'package:whisky_hikes/config/l10n/app_localizations.dart';
import 'package:whisky_hikes/domain/models/hike.dart';

@GenerateMocks([HomePageViewModel])
import 'home_page_test.mocks.dart';

void main() {
  late MockHomePageViewModel mockViewModel;

  setUp(() {
    mockViewModel = MockHomePageViewModel();
    when(mockViewModel.hikes).thenReturn(<Hike>[]);
    when(mockViewModel.firstName).thenReturn('');
    when(mockViewModel.showFavorites).thenReturn(false);
    when(mockViewModel.isLoading).thenReturn(false);
    when(mockViewModel.loadHikes()).thenAnswer((_) async {});
    when(mockViewModel.getUserFirstName()).thenAnswer((_) async {});
    when(mockViewModel.refresh()).thenAnswer((_) async {});
  });

  Future<void> pumpHomePage(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: HomePage(viewModel: mockViewModel),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('HomePage pull-to-refresh', () {
    testWidgets('renders a RefreshIndicator', (tester) async {
      await pumpHomePage(tester);

      expect(find.byType(RefreshIndicator), findsOneWidget);
    });

    testWidgets('pull-down gesture calls viewModel.refresh()', (tester) async {
      await pumpHomePage(tester);

      await tester.fling(
        find.byType(CustomScrollView),
        const Offset(0, 300),
        1000,
      );
      await tester.pumpAndSettle();

      verify(mockViewModel.refresh()).called(1);
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mockito/mockito.dart';

import 'package:whisky_hikes/UI/home/home_page.dart';
import 'package:whisky_hikes/UI/home/home_view_model.dart';
import 'package:whisky_hikes/domain/models/hike.dart';
import 'package:whisky_hikes/config/l10n/app_localizations.dart';

class MockHomePageViewModel extends Mock implements HomePageViewModel {}

void main() {
  group('HomePage Widget Tests', () {
    late MockHomePageViewModel mockViewModel;

    setUp(() {
      mockViewModel = MockHomePageViewModel();
    });

    Widget createTestWidget(Widget child) {
      return MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', ''),
          Locale('de', ''),
        ],
        home: child,
      );
    }

    testWidgets('should build without crashing', (WidgetTester tester) async {
      // Arrange
      when(mockViewModel.firstName).thenReturn('');
      when(mockViewModel.showFavorites).thenReturn(false);
      when(mockViewModel.hikes).thenReturn([]);

      // Act
      await tester.pumpWidget(createTestWidget(HomePage(viewModel: mockViewModel)));

      // Assert
      expect(find.byType(HomePage), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(CustomScrollView), findsOneWidget);
    });

    testWidgets('should call loadHikes and getUserFirstName in initState', (WidgetTester tester) async {
      // Arrange
      when(mockViewModel.firstName).thenReturn('');
      when(mockViewModel.showFavorites).thenReturn(false);
      when(mockViewModel.hikes).thenReturn([]);

      // Act
      await tester.pumpWidget(createTestWidget(HomePage(viewModel: mockViewModel)));

      // Assert
      verify(mockViewModel.loadHikes()).called(1);
      verify(mockViewModel.getUserFirstName()).called(1);
    });

    testWidgets('should display app title when firstName is empty', (WidgetTester tester) async {
      // Arrange
      when(mockViewModel.firstName).thenReturn('');
      when(mockViewModel.showFavorites).thenReturn(false);
      when(mockViewModel.hikes).thenReturn([]);

      // Act
      await tester.pumpWidget(createTestWidget(HomePage(viewModel: mockViewModel)));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Whisky Hikes'), findsOneWidget);
    });

    testWidgets('should display greeting when firstName is not empty', (WidgetTester tester) async {
      // Arrange
      when(mockViewModel.firstName).thenReturn('John');
      when(mockViewModel.showFavorites).thenReturn(false);
      when(mockViewModel.hikes).thenReturn([]);

      // Act
      await tester.pumpWidget(createTestWidget(HomePage(viewModel: mockViewModel)));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Hi John!'), findsOneWidget);
    });

    testWidgets('should show correct favorite toggle button', (WidgetTester tester) async {
      // Arrange
      when(mockViewModel.firstName).thenReturn('');
      when(mockViewModel.showFavorites).thenReturn(false);
      when(mockViewModel.hikes).thenReturn([]);

      // Act
      await tester.pumpWidget(createTestWidget(HomePage(viewModel: mockViewModel)));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
      expect(find.byIcon(Icons.favorite), findsNothing);
    });

    testWidgets('should show filled heart when showFavorites is true', (WidgetTester tester) async {
      // Arrange
      when(mockViewModel.firstName).thenReturn('');
      when(mockViewModel.showFavorites).thenReturn(true);
      when(mockViewModel.hikes).thenReturn([]);

      // Act
      await tester.pumpWidget(createTestWidget(HomePage(viewModel: mockViewModel)));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byIcon(Icons.favorite), findsOneWidget);
      expect(find.byIcon(Icons.favorite_border), findsNothing);
    });

    testWidgets('should call toggleShowFavorites when favorite button is pressed', (WidgetTester tester) async {
      // Arrange
      when(mockViewModel.firstName).thenReturn('');
      when(mockViewModel.showFavorites).thenReturn(false);
      when(mockViewModel.hikes).thenReturn([]);

      // Act
      await tester.pumpWidget(createTestWidget(HomePage(viewModel: mockViewModel)));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.favorite_border));

      // Assert
      verify(mockViewModel.toggleShowFavorites()).called(1);
    });

    testWidgets('should display hike cards when hikes are available', (WidgetTester tester) async {
      // Arrange
      final testHike = Hike(
        id: 1,
        name: 'Test Hike',
        description: 'Test Description',
        difficulty: Difficulty.easy,
        length: 5.0,
        price: 29.99,
        isFavorite: false,
        thumbnailImageUrl: null,
      );
      when(mockViewModel.firstName).thenReturn('');
      when(mockViewModel.showFavorites).thenReturn(false);
      when(mockViewModel.hikes).thenReturn([testHike]);

      // Act
      await tester.pumpWidget(createTestWidget(HomePage(viewModel: mockViewModel)));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Test Hike'), findsOneWidget);
      expect(find.text('Test Description'), findsOneWidget);
    });

    testWidgets('should handle ViewModel notifications correctly', (WidgetTester tester) async {
      // Arrange
      when(mockViewModel.firstName).thenReturn('');
      when(mockViewModel.showFavorites).thenReturn(false);
      when(mockViewModel.hikes).thenReturn([]);

      // Act
      await tester.pumpWidget(createTestWidget(HomePage(viewModel: mockViewModel)));
      
      // Simulate ViewModel notification
      when(mockViewModel.firstName).thenReturn('Jane');
      mockViewModel.notifyListeners();
      await tester.pump();

      // Assert - Widget should rebuild with new data
      expect(find.byType(ListenableBuilder), findsOneWidget);
    });

    testWidgets('should display correct tooltip for favorite button', (WidgetTester tester) async {
      // Arrange
      when(mockViewModel.firstName).thenReturn('');
      when(mockViewModel.showFavorites).thenReturn(false);
      when(mockViewModel.hikes).thenReturn([]);

      // Act
      await tester.pumpWidget(createTestWidget(HomePage(viewModel: mockViewModel)));
      await tester.pumpAndSettle();

      // Assert
      final favoriteButton = find.byIcon(Icons.favorite_border);
      expect(favoriteButton, findsOneWidget);
      
      final IconButton iconButton = tester.widget(favoriteButton.first) as IconButton;
      expect(iconButton.tooltip, 'Show Favorites');
    });

    testWidgets('should create SliverAppBar with correct properties', (WidgetTester tester) async {
      // Arrange
      when(mockViewModel.firstName).thenReturn('');
      when(mockViewModel.showFavorites).thenReturn(false);
      when(mockViewModel.hikes).thenReturn([]);

      // Act
      await tester.pumpWidget(createTestWidget(HomePage(viewModel: mockViewModel)));

      // Assert
      final sliverAppBar = find.byType(SliverAppBar);
      expect(sliverAppBar, findsOneWidget);
      
      final SliverAppBar appBar = tester.widget(sliverAppBar) as SliverAppBar;
      expect(appBar.pinned, isTrue);
      expect(appBar.expandedHeight, equals(150.0));
    });
  });
}
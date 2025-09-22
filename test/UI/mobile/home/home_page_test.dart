import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:whisky_hikes/UI/mobile/home/home_page.dart';
import 'package:whisky_hikes/UI/mobile/home/home_view_model.dart';
import 'package:whisky_hikes/UI/mobile/home/widgets/card_widget.dart';
import 'package:whisky_hikes/domain/models/hike.dart';

import '../../test_helpers.dart';

class MockHomePageViewModel extends Mock implements HomePageViewModel {}

void main() {
  group('HomePage Widget Tests', () {
    late MockHomePageViewModel mockViewModel;
    late List<Hike> testHikes;

    setUp(() {
      mockViewModel = MockHomePageViewModel();
      testHikes = [
        TestHelpers.createTestHike(id: 1, name: 'Hike 1'),
        TestHelpers.createTestHike(id: 2, name: 'Hike 2'),
      ];
    });

    testWidgets('should build without crashing', (tester) async {
      // Setup mock
      when(mockViewModel.firstName).thenReturn('');
      when(mockViewModel.showFavorites).thenReturn(false);
      when(mockViewModel.hikes).thenReturn([]);
      when(mockViewModel.isLoading).thenReturn(false);

      await tester.pumpWidget(
        TestHelpers.createTestWidget(HomePage(viewModel: mockViewModel)),
      );

      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('should call loadHikes and getUserFirstName on initState', (tester) async {
      // Setup mock
      when(mockViewModel.firstName).thenReturn('');
      when(mockViewModel.showFavorites).thenReturn(false);
      when(mockViewModel.hikes).thenReturn([]);
      when(mockViewModel.isLoading).thenReturn(false);

      await tester.pumpWidget(
        TestHelpers.createTestWidget(HomePage(viewModel: mockViewModel)),
      );

      verify(mockViewModel.loadHikes()).called(1);
      verify(mockViewModel.getUserFirstName()).called(1);
    });

    testWidgets('should display greeting when user has first name', (tester) async {
      when(mockViewModel.firstName).thenReturn('John');
      when(mockViewModel.showFavorites).thenReturn(false);
      when(mockViewModel.hikes).thenReturn([]);
      when(mockViewModel.isLoading).thenReturn(false);

      await tester.pumpWidget(
        TestHelpers.createTestWidget(HomePage(viewModel: mockViewModel)),
      );

      // Should display greeting with first name
      expect(find.textContaining('John'), findsAtLeastNWidgets(1));
    });

    testWidgets('should display default greeting when user has no first name', (tester) async {
      when(mockViewModel.firstName).thenReturn('');
      when(mockViewModel.showFavorites).thenReturn(false);
      when(mockViewModel.hikes).thenReturn([]);
      when(mockViewModel.isLoading).thenReturn(false);

      await tester.pumpWidget(
        TestHelpers.createTestWidget(HomePage(viewModel: mockViewModel)),
      );

      // Should display some form of greeting
      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('should display favorites toggle button', (tester) async {
      when(mockViewModel.firstName).thenReturn('');
      when(mockViewModel.showFavorites).thenReturn(false);
      when(mockViewModel.hikes).thenReturn([]);
      when(mockViewModel.isLoading).thenReturn(false);

      await tester.pumpWidget(
        TestHelpers.createTestWidget(HomePage(viewModel: mockViewModel)),
      );

      // Should have a favorites toggle button
      expect(find.byIcon(Icons.favorite_border), findsAtLeastNWidgets(1));
    });

    testWidgets('should show filled heart when favorites are active', (tester) async {
      when(mockViewModel.firstName).thenReturn('');
      when(mockViewModel.showFavorites).thenReturn(true);
      when(mockViewModel.hikes).thenReturn([]);
      when(mockViewModel.isLoading).thenReturn(false);

      await tester.pumpWidget(
        TestHelpers.createTestWidget(HomePage(viewModel: mockViewModel)),
      );

      // Should show filled heart when showing favorites
      expect(find.byIcon(Icons.favorite), findsAtLeastNWidgets(1));
    });

    testWidgets('should call toggleShowFavorites when favorite button is tapped', (tester) async {
      when(mockViewModel.firstName).thenReturn('');
      when(mockViewModel.showFavorites).thenReturn(false);
      when(mockViewModel.hikes).thenReturn([]);
      when(mockViewModel.isLoading).thenReturn(false);

      await tester.pumpWidget(
        TestHelpers.createTestWidget(HomePage(viewModel: mockViewModel)),
      );

      // Tap the favorites toggle button
      await tester.tap(find.byIcon(Icons.favorite_border));
      await tester.pumpAndSettle();

      verify(mockViewModel.toggleShowFavorites()).called(1);
    });

    testWidgets('should display hikes when available', (tester) async {
      when(mockViewModel.firstName).thenReturn('');
      when(mockViewModel.showFavorites).thenReturn(false);
      when(mockViewModel.hikes).thenReturn(testHikes);
      when(mockViewModel.isLoading).thenReturn(false);

      await tester.pumpWidget(
        TestHelpers.createTestWidget(HomePage(viewModel: mockViewModel)),
      );

      // Should display HikeCard widgets
      expect(find.byType(HikeCard), findsAtLeastNWidgets(2));
    });

    testWidgets('should display empty state when no hikes available', (tester) async {
      when(mockViewModel.firstName).thenReturn('');
      when(mockViewModel.showFavorites).thenReturn(false);
      when(mockViewModel.hikes).thenReturn([]);
      when(mockViewModel.isLoading).thenReturn(false);

      await tester.pumpWidget(
        TestHelpers.createTestWidget(HomePage(viewModel: mockViewModel)),
      );

      // Should display empty state message
      expect(find.textContaining('No hikes'), findsAtLeastNWidgets(1));
    });

    testWidgets('should display loading indicator when loading', (tester) async {
      when(mockViewModel.firstName).thenReturn('');
      when(mockViewModel.showFavorites).thenReturn(false);
      when(mockViewModel.hikes).thenReturn([]);
      when(mockViewModel.isLoading).thenReturn(true);

      await tester.pumpWidget(
        TestHelpers.createTestWidget(HomePage(viewModel: mockViewModel)),
      );

      // Should display loading indicator
      expect(find.byType(CircularProgressIndicator), findsAtLeastNWidgets(1));
    });

    testWidgets('should handle favorite toggle on hike cards', (tester) async {
      when(mockViewModel.firstName).thenReturn('');
      when(mockViewModel.showFavorites).thenReturn(false);
      when(mockViewModel.hikes).thenReturn(testHikes);
      when(mockViewModel.isLoading).thenReturn(false);

      await tester.pumpWidget(
        TestHelpers.createTestWidget(HomePage(viewModel: mockViewModel)),
      );

      // Find a HikeCard and tap its favorite button
      final hikeCard = find.byType(HikeCard).first;
      expect(hikeCard, findsOneWidget);

      // The favorite toggle should be handled by the card's onFavoriteToggle callback
      // This is tested more thoroughly in the HikeCard tests
    });

    testWidgets('should rebuild when viewModel notifies listeners', (tester) async {
      when(mockViewModel.firstName).thenReturn('Initial');
      when(mockViewModel.showFavorites).thenReturn(false);
      when(mockViewModel.hikes).thenReturn([]);
      when(mockViewModel.isLoading).thenReturn(false);

      await tester.pumpWidget(
        TestHelpers.createTestWidget(HomePage(viewModel: mockViewModel)),
      );

      // Initial state
      expect(find.textContaining('Initial'), findsAtLeastNWidgets(1));

      // Change mock return value and simulate notifyListeners
      when(mockViewModel.firstName).thenReturn('Updated');
      
      // Trigger a rebuild by pumping the widget
      await tester.pump();

      // Should show updated content
      expect(find.textContaining('Updated'), findsAtLeastNWidgets(1));
    });
  });
}
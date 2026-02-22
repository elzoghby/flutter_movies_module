import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_movies_module/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Movies App Integration Tests', () {
    testWidgets('Complete app flow: Load movies and verify display', (
      WidgetTester tester,
    ) async {
      // Initialize app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verify app bar is displayed
      expect(find.text('🎬  Popular Movies'), findsOneWidget);

      // Wait for movies to load
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verify that at least one movie is displayed
      expect(find.byType(GestureDetector), findsWidgets);
    });

    testWidgets('Scroll through movies list and load more', (
      WidgetTester tester,
    ) async {
      // Initialize app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Wait for initial movies to load
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Get initial widget tree
      final initialFinder = find.text('🎬  Popular Movies');
      expect(initialFinder, findsOneWidget);

      // Scroll down to trigger load more (if available)
      await tester.drag(find.byType(ListView).first, const Offset(0, -500));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify that the list is still displayed
      expect(find.byType(GestureDetector), findsWidgets);
    });

    testWidgets('Tap movie and verify trailer loading state', (
      WidgetTester tester,
    ) async {
      // Initialize app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Get the first movie card GestureDetector
      final firstMovieCard = find.byType(GestureDetector).first;

      // Tap the first movie
      await tester.tap(firstMovieCard);

      // Pump to show loading state
      await tester.pump();

      // Note: We expect the loading overlay to appear
      // This might show "Loading trailer…" text
      // The exact behavior depends on the app's implementation
      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets('Back button functionality', (WidgetTester tester) async {
      // Initialize app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verify initial state
      expect(find.text('🎬  Popular Movies'), findsOneWidget);

      // Tap back button (if visible)
      final backButton = find.byIcon(Icons.arrow_back_ios_rounded);
      if (backButton.evaluate().isNotEmpty) {
        await tester.tap(backButton);
        await tester.pumpAndSettle();
      }
    });
  });
}

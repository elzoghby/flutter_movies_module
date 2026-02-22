import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_movies_module/data/models/movie_model.dart';
import 'package:flutter_movies_module/presentation/widgets/movie_card.dart';

void main() {
  group('MovieCard Widget Tests', () {
    final tMovieModel = MovieModel(
      id: 1,
      title: 'Test Movie',
      overview: 'This is a test movie overview that should display properly',
      posterPath: '/test_poster.jpg',
      backdropPath: '/test_backdrop.jpg',
      voteAverage: 8.5,
      releaseDate: '2024-01-01',
    );

    late final tMovie = tMovieModel.toEntity();

    testWidgets('MovieCard displays movie title', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MovieCard(movie: tMovie, onTap: () {}),
          ),
        ),
      );

      // Act & Assert
      expect(find.text('Test Movie'), findsOneWidget);
    });

    testWidgets('MovieCard displays vote average', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MovieCard(movie: tMovie, onTap: () {}),
          ),
        ),
      );

      // Act & Assert
      expect(find.text('8.5'), findsOneWidget);
    });

    testWidgets('MovieCard displays release year', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MovieCard(movie: tMovie, onTap: () {}),
          ),
        ),
      );

      // Act & Assert
      expect(find.text('2024'), findsOneWidget);
    });

    testWidgets('MovieCard displays movie overview', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MovieCard(movie: tMovie, onTap: () {}),
          ),
        ),
      );

      // Act & Assert
      expect(
        find.text('This is a test movie overview that should display properly'),
        findsOneWidget,
      );
    });

    testWidgets('MovieCard calls onTap when tapped', (
      WidgetTester tester,
    ) async {
      // Arrange
      bool onTapCalled = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MovieCard(
              movie: tMovie,
              onTap: () {
                onTapCalled = true;
              },
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.byType(GestureDetector));
      await tester.pumpAndSettle();

      // Assert
      expect(onTapCalled, true);
    });

    testWidgets('MovieCard displays star icon for rating', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MovieCard(movie: tMovie, onTap: () {}),
          ),
        ),
      );

      // Act & Assert
      expect(find.byIcon(Icons.star_rounded), findsWidgets);
    });

    testWidgets('MovieCard displays movie icon when poster path is empty', (
      WidgetTester tester,
    ) async {
      // Arrange
      final movieWithoutPosterModel = MovieModel(
        id: 2,
        title: 'No Poster Movie',
        overview: 'Movie without poster',
        posterPath: '',
        backdropPath: '/backdrop.jpg',
        voteAverage: 7.0,
        releaseDate: '2024-01-02',
      );
      final movieWithoutPoster = movieWithoutPosterModel.toEntity();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MovieCard(movie: movieWithoutPoster, onTap: () {}),
          ),
        ),
      );

      // Act & Assert
      expect(find.byIcon(Icons.movie), findsWidgets);
    });
  });
}

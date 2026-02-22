import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_movies_module/data/models/movie_model.dart';
import 'package:flutter_movies_module/presentation/bloc/movie_bloc.dart';
import 'package:flutter_movies_module/presentation/pages/movie_list_page.dart';
import 'package:flutter_movies_module/presentation/services/trailer_navigator.dart';
import 'package:mocktail/mocktail.dart';

class MockMovieBloc extends MockBloc<MovieEvent, MovieState>
    implements MovieBloc {}

class MockTrailerNavigator extends Mock implements TrailerNavigator {}

void main() {
  group('MovieListPage Widget Tests', () {
    late MockMovieBloc mockMovieBloc;

    setUp(() {
      mockMovieBloc = MockMovieBloc();
    });

    testWidgets('displays loading indicator when state is MovieLoading', (
      WidgetTester tester,
    ) async {
      // Arrange
      when(() => mockMovieBloc.state).thenReturn(MovieLoading());

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<MovieBloc>.value(
            value: mockMovieBloc,
            child: MovieListPage(trailerNavigator: MockTrailerNavigator()),
          ),
        ),
      );

      // Act & Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays error message when state is MovieError', (
      WidgetTester tester,
    ) async {
      // Arrange
      when(
        () => mockMovieBloc.state,
      ).thenReturn(const MovieError('Failed to fetch movies'));

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<MovieBloc>.value(
            value: mockMovieBloc,
            child: MovieListPage(trailerNavigator: MockTrailerNavigator()),
          ),
        ),
      );

      // Act & Assert
      expect(find.text('Failed to fetch movies'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
    });

    testWidgets('displays movies when state is MovieLoaded', (
      WidgetTester tester,
    ) async {
      // Arrange
      final movieModels = [
        MovieModel(
          id: 1,
          title: 'Test Movie 1',
          overview: 'Test overview 1',
          posterPath: '/poster1.jpg',
          backdropPath: '/backdrop1.jpg',
          voteAverage: 8.0,
          releaseDate: '2024-01-01',
        ),
        MovieModel(
          id: 2,
          title: 'Test Movie 2',
          overview: 'Test overview 2',
          posterPath: '/poster2.jpg',
          backdropPath: '/backdrop2.jpg',
          voteAverage: 7.5,
          releaseDate: '2024-01-02',
        ),
      ];

      final movies = movieModels.map((m) => m.toEntity()).toList();

      when(() => mockMovieBloc.state).thenReturn(
        MovieLoaded(
          movies: movies,
          currentPage: 1,
          totalPages: 500,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<MovieBloc>.value(
            value: mockMovieBloc,
            child: MovieListPage(trailerNavigator: MockTrailerNavigator()),
          ),
        ),
      );

      // Act & Assert
      expect(find.text('Test Movie 1'), findsOneWidget);
      expect(find.text('Test Movie 2'), findsOneWidget);
    });

    testWidgets('displays empty message when movies list is empty', (
      WidgetTester tester,
    ) async {
      // Arrange
      when(() => mockMovieBloc.state).thenReturn(
        const MovieLoaded(
          movies: [],
          currentPage: 1,
          totalPages: 1,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<MovieBloc>.value(
            value: mockMovieBloc,
            child: MovieListPage(trailerNavigator: MockTrailerNavigator()),
          ),
        ),
      );

      // Act & Assert
      expect(find.text('No movies found.'), findsOneWidget);
    });

    testWidgets('displays loading overlay when state is MovieTrailerLoading', (
      WidgetTester tester,
    ) async {
      // Arrange
      final movieModels = [
        MovieModel(
          id: 1,
          title: 'Test Movie',
          overview: 'Test overview',
          posterPath: '/poster.jpg',
          backdropPath: '/backdrop.jpg',
          voteAverage: 8.0,
          releaseDate: '2024-01-01',
        ),
      ];

      final movies = movieModels.map((m) => m.toEntity()).toList();

      when(() => mockMovieBloc.state).thenReturn(MovieTrailerLoading(movies));

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<MovieBloc>.value(
            value: mockMovieBloc,
            child: MovieListPage(trailerNavigator: MockTrailerNavigator()),
          ),
        ),
      );

      // Act & Assert
      expect(find.byType(CircularProgressIndicator), findsWidgets);
      expect(find.text('Loading trailer…'), findsOneWidget);
    });

    testWidgets('adds FetchMovieTrailer event when movie card is tapped', (
      WidgetTester tester,
    ) async {
      // Arrange
      final movieModels = [
        MovieModel(
          id: 1,
          title: 'Test Movie',
          overview: 'Test overview',
          posterPath: '/poster.jpg',
          backdropPath: '/backdrop.jpg',
          voteAverage: 8.0,
          releaseDate: '2024-01-01',
        ),
      ];

      final movies = movieModels.map((m) => m.toEntity()).toList();

      when(() => mockMovieBloc.state).thenReturn(
        MovieLoaded(
          movies: movies,
          currentPage: 1,
          totalPages: 500,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<MovieBloc>.value(
            value: mockMovieBloc,
            child: MovieListPage(trailerNavigator: MockTrailerNavigator()),
          ),
        ),
      );

      // Act - trigger the card tap (mocking is needed)
      await tester.pumpAndSettle();

      // Find and tap the movie card
      await tester.tap(find.byType(GestureDetector).first);
      await tester.pumpAndSettle();

      // Assert
      verify(
        () => mockMovieBloc.add(
          FetchMovieTrailer(
            movieId: 1,
            movies: movies,
            currentPage: 1,
            totalPages: 500,
          ),
        ),
      ).called(1);
    });

    testWidgets('app bar displays correct title', (WidgetTester tester) async {
      // Arrange
      when(() => mockMovieBloc.state).thenReturn(MovieLoading());

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<MovieBloc>.value(
            value: mockMovieBloc,
            child: MovieListPage(trailerNavigator: MockTrailerNavigator()),
          ),
        ),
      );

      // Act & Assert
      expect(find.text('🎬  Popular Movies'), findsOneWidget);
    });
  });
}

// Mock class for BLoC
class MockBloc<E, S> extends Mock {
  S get state => throw UnimplementedError();

  void add(E event) {}

  Future<void> close() async {}
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_movies_module/core/error/failures.dart';
import 'package:flutter_movies_module/core/result.dart';
import 'package:flutter_movies_module/domain/entities/movie.dart';
import 'package:flutter_movies_module/domain/entities/movies_page.dart';
import 'package:flutter_movies_module/domain/usecases/get_popular_movies_usecase.dart';
import 'package:flutter_movies_module/domain/usecases/get_movie_trailer_usecase.dart';
import 'package:flutter_movies_module/presentation/bloc/movie_bloc.dart';
import 'package:flutter_movies_module/presentation/pages/movie_list_page.dart';
import 'package:flutter_movies_module/presentation/services/trailer_navigator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetPopularMoviesUseCase extends Mock
    implements GetPopularMoviesUseCase {}

class MockGetMovieTrailerUseCase extends Mock
    implements GetMovieTrailerUseCase {}

class MockTrailerNavigator extends Mock implements TrailerNavigator {}

void main() {
  late MockGetPopularMoviesUseCase mockGetPopularMoviesUseCase;
  late MockGetMovieTrailerUseCase mockGetMovieTrailerUseCase;

  setUp(() {
    mockGetPopularMoviesUseCase = MockGetPopularMoviesUseCase();
    mockGetMovieTrailerUseCase = MockGetMovieTrailerUseCase();
  });

  final tMovie = Movie(
    id: 1,
    title: 'Test Movie Title',
    overview: 'This is a test movie overview description.',
    posterPath: '',
    backdropPath: '',
    voteAverage: 8.5,
    releaseDate: '2024-01-15',
  );

  final tMoviesPage = MoviesPage(
    movies: [tMovie],
    currentPage: 1,
    totalPages: 500,
  );

  Widget createTestWidget(MovieBloc bloc) {
    return MaterialApp(
      home: BlocProvider.value(
        value: bloc,
        child: MovieListPage(trailerNavigator: MockTrailerNavigator()),
      ),
    );
  }

  testWidgets('shows loading indicator when state is MovieLoading', (
    tester,
  ) async {
    final completer = Completer<Result<MoviesPage>>();

    when(
      () => mockGetPopularMoviesUseCase(page: 1),
    ).thenAnswer((_) => completer.future);

    final bloc = MovieBloc(
      getPopularMoviesUseCase: mockGetPopularMoviesUseCase,
      getMovieTrailerUseCase: mockGetMovieTrailerUseCase,
    );
    bloc.add(const FetchMovies());

    await tester.pumpWidget(createTestWidget(bloc));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Complete the future to clean up
    completer.complete(Right(tMoviesPage));
    await tester.pumpAndSettle();
    bloc.close();
  });

  testWidgets('shows movie card when state is MovieLoaded', (tester) async {
    when(
      () => mockGetPopularMoviesUseCase(page: 1),
    ).thenAnswer((_) async => Right(tMoviesPage));

    final bloc = MovieBloc(
      getPopularMoviesUseCase: mockGetPopularMoviesUseCase,
      getMovieTrailerUseCase: mockGetMovieTrailerUseCase,
    );
    bloc.add(const FetchMovies());

    await tester.pumpWidget(createTestWidget(bloc));
    await tester.pumpAndSettle();

    expect(find.text('Test Movie Title'), findsOneWidget);
    expect(find.text('8.5'), findsOneWidget);
    expect(find.text('2024'), findsOneWidget);
    bloc.close();
  });

  testWidgets('shows error view with retry button on MovieError', (
    tester,
  ) async {
    when(() => mockGetPopularMoviesUseCase(page: 1)).thenAnswer(
      (_) async => Left(ServerFailure('Something went wrong')),
    );

    final bloc = MovieBloc(
      getPopularMoviesUseCase: mockGetPopularMoviesUseCase,
      getMovieTrailerUseCase: mockGetMovieTrailerUseCase,
    );
    bloc.add(const FetchMovies());

    await tester.pumpWidget(createTestWidget(bloc));
    await tester.pumpAndSettle();

    expect(find.text('Something went wrong'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
    bloc.close();
  });
}

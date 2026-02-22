import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_movies_module/core/error/failures.dart';
import 'package:flutter_movies_module/core/result.dart';
import 'package:flutter_movies_module/domain/entities/movie.dart';
import 'package:flutter_movies_module/domain/entities/movie_video.dart';
import 'package:flutter_movies_module/domain/entities/movies_page.dart';
import 'package:flutter_movies_module/domain/usecases/get_popular_movies_usecase.dart';
import 'package:flutter_movies_module/domain/usecases/get_movie_trailer_usecase.dart';
import 'package:flutter_movies_module/presentation/bloc/movie_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetPopularMoviesUseCase extends Mock
    implements GetPopularMoviesUseCase {}

class MockGetMovieTrailerUseCase extends Mock
    implements GetMovieTrailerUseCase {}

void main() {
  late MovieBloc bloc;
  late MockGetPopularMoviesUseCase mockGetPopularMoviesUseCase;
  late MockGetMovieTrailerUseCase mockGetMovieTrailerUseCase;

  setUp(() {
    mockGetPopularMoviesUseCase = MockGetPopularMoviesUseCase();
    mockGetMovieTrailerUseCase = MockGetMovieTrailerUseCase();
    bloc = MovieBloc(
      getPopularMoviesUseCase: mockGetPopularMoviesUseCase,
      getMovieTrailerUseCase: mockGetMovieTrailerUseCase,
    );
  });

  tearDown(() {
    bloc.close();
  });

  final tMovie = Movie(
    id: 1,
    title: 'Test Movie',
    overview: 'A test movie',
    posterPath: '/test.jpg',
    backdropPath: '/backdrop.jpg',
    voteAverage: 8.0,
    releaseDate: '2024-01-01',
  );

  final tTrailer = MovieVideo(
    id: 'v1',
    key: 'youtube_key',
    name: 'Official Trailer',
    site: 'YouTube',
    type: 'Trailer',
  );

  final tMoviesPage = MoviesPage(
    movies: [tMovie],
    currentPage: 1,
    totalPages: 500,
  );

  test('initial state should be MovieInitial', () {
    expect(bloc.state, MovieInitial());
  });

  group('FetchMovies', () {
    blocTest<MovieBloc, MovieState>(
      'emits [MovieLoading, MovieLoaded] when movies are fetched successfully',
      build: () {
        when(
          () => mockGetPopularMoviesUseCase(page: 1),
        ).thenAnswer((_) async => Right(tMoviesPage));
        return bloc;
      },
      act: (bloc) => bloc.add(const FetchMovies()),
      expect: () => [
        MovieLoading(),
        MovieLoaded(movies: [tMovie], currentPage: 1, totalPages: 500),
      ],
    );

    blocTest<MovieBloc, MovieState>(
      'emits [MovieLoading, MovieError] when fetching movies fails',
      build: () {
        when(
          () => mockGetPopularMoviesUseCase(page: 1),
        ).thenAnswer((_) async => Left(ServerFailure('Server error')));
        return bloc;
      },
      act: (bloc) => bloc.add(const FetchMovies()),
      expect: () => [MovieLoading(), const MovieError('Server error')],
    );
  });

  group('FetchMovieTrailer', () {
    blocTest<MovieBloc, MovieState>(
      'emits [MovieTrailerLoading, MovieTrailerLoaded] when trailer found',
      build: () {
        when(
          () => mockGetMovieTrailerUseCase(movieId: 1),
        ).thenAnswer((_) async => Right(tTrailer));
        return bloc;
      },
      seed: () =>
          MovieLoaded(movies: [tMovie], currentPage: 1, totalPages: 500),
      act: (bloc) => bloc.add(
        FetchMovieTrailer(
          movieId: 1,
          movies: [tMovie],
          currentPage: 1,
          totalPages: 500,
        ),
      ),
      expect: () => [
        MovieTrailerLoading([tMovie]),
        MovieTrailerLoaded(
          movies: [tMovie],
          trailer: tTrailer,
          movieId: 1,
          currentPage: 1,
          totalPages: 500,
        ),
      ],
    );

    blocTest<MovieBloc, MovieState>(
      'emits [MovieTrailerLoading, MovieTrailerError] when no videos found',
      build: () {
        when(() => mockGetMovieTrailerUseCase(movieId: 1)).thenAnswer(
          (_) async =>
              Left(ServerFailure('No trailer available for this movie.')),
        );
        return bloc;
      },
      seed: () =>
          MovieLoaded(movies: [tMovie], currentPage: 1, totalPages: 500),
      act: (bloc) => bloc.add(
        FetchMovieTrailer(
          movieId: 1,
          movies: [tMovie],
          currentPage: 1,
          totalPages: 500,
        ),
      ),
      expect: () => [
        MovieTrailerLoading([tMovie]),
        MovieTrailerError(
          movies: [tMovie],
          message: 'No trailer available for this movie.',
          currentPage: 1,
          totalPages: 500,
        ),
      ],
    );

    blocTest<MovieBloc, MovieState>(
      'emits [MovieTrailerLoading, MovieTrailerError] when fetch fails',
      build: () {
        when(
          () => mockGetMovieTrailerUseCase(movieId: 1),
        ).thenAnswer((_) async => Left(ServerFailure('Server error')));
        return bloc;
      },
      seed: () =>
          MovieLoaded(movies: [tMovie], currentPage: 1, totalPages: 500),
      act: (bloc) => bloc.add(
        FetchMovieTrailer(
          movieId: 1,
          movies: [tMovie],
          currentPage: 1,
          totalPages: 500,
        ),
      ),
      expect: () => [
        MovieTrailerLoading([tMovie]),
        MovieTrailerError(
          movies: [tMovie],
          message: 'Server error',
          currentPage: 1,
          totalPages: 500,
        ),
      ],
    );
  });
}

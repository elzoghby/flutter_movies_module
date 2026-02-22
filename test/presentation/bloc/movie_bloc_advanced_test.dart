import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_movies_module/core/error/failures.dart';
import 'package:flutter_movies_module/core/result.dart';
import 'package:flutter_movies_module/domain/entities/movie.dart';
import 'package:flutter_movies_module/domain/entities/movie_video.dart';
import 'package:flutter_movies_module/domain/entities/movies_page.dart';
import 'package:flutter_movies_module/domain/usecases/usecases.dart';
import 'package:flutter_movies_module/presentation/bloc/movie_bloc.dart';
import 'package:mockito/mockito.dart';

class MockGetPopularMoviesUseCase extends Mock
    implements GetPopularMoviesUseCase {}

class MockGetMovieTrailerUseCase extends Mock
    implements GetMovieTrailerUseCase {}

void main() {
  late MovieBloc movieBloc;
  late MockGetPopularMoviesUseCase mockGetPopularMoviesUseCase;
  late MockGetMovieTrailerUseCase mockGetMovieTrailerUseCase;

  setUp(() {
    mockGetPopularMoviesUseCase = MockGetPopularMoviesUseCase();
    mockGetMovieTrailerUseCase = MockGetMovieTrailerUseCase();
    movieBloc = MovieBloc(
      getPopularMoviesUseCase: mockGetPopularMoviesUseCase,
      getMovieTrailerUseCase: mockGetMovieTrailerUseCase,
    );
  });

  tearDown(() {
    movieBloc.close();
  });

  group('MovieBloc', () {
    group('FetchMovies', () {
      final tMovies = [
        Movie(
          id: 1,
          title: 'Test Movie 1',
          overview: 'Overview 1',
          posterPath: '/poster1.jpg',
          backdropPath: '/backdrop1.jpg',
          voteAverage: 8.0,
          releaseDate: '2024-01-01',
        ),
        Movie(
          id: 2,
          title: 'Test Movie 2',
          overview: 'Overview 2',
          posterPath: '/poster2.jpg',
          backdropPath: '/backdrop2.jpg',
          voteAverage: 7.5,
          releaseDate: '2024-01-02',
        ),
      ];

      final tMoviesPage = MoviesPage(
        movies: tMovies,
        currentPage: 1,
        totalPages: 500,
      );

      blocTest<MovieBloc, MovieState>(
        'emits [MovieLoading, MovieLoaded] when FetchMovies is successful',
        build: () {
          when(
            mockGetPopularMoviesUseCase(page: 1),
          ).thenAnswer((_) async => Right(tMoviesPage));
          return movieBloc;
        },
        act: (bloc) => bloc.add(const FetchMovies()),
        expect: () => [
          MovieLoading(),
          isA<MovieLoaded>()
              .having((state) => state.movies, 'movies', tMovies)
              .having((state) => state.currentPage, 'currentPage', 1)
              .having((state) => state.totalPages, 'totalPages', 500),
        ],
        verify: (_) {
          verify(mockGetPopularMoviesUseCase(page: 1)).called(1);
        },
      );

      blocTest<MovieBloc, MovieState>(
        'emits [MovieLoading, MovieError] when FetchMovies fails',
        build: () {
          when(mockGetPopularMoviesUseCase(page: 1)).thenAnswer(
            (_) async => Left(ServerFailure('Failed to fetch movies')),
          );
          return movieBloc;
        },
        act: (bloc) => bloc.add(const FetchMovies()),
        expect: () => [
          MovieLoading(),
          isA<MovieError>().having(
            (state) => state.message,
            'message',
            'Failed to fetch movies',
          ),
        ],
      );
    });

    group('LoadMoreMovies', () {
      final tInitialMovies = [
        Movie(
          id: 1,
          title: 'Test Movie 1',
          overview: 'Overview 1',
          posterPath: '/poster1.jpg',
          backdropPath: '/backdrop1.jpg',
          voteAverage: 8.0,
          releaseDate: '2024-01-01',
        ),
      ];

      final tNewMovies = [
        Movie(
          id: 2,
          title: 'Test Movie 2',
          overview: 'Overview 2',
          posterPath: '/poster2.jpg',
          backdropPath: '/backdrop2.jpg',
          voteAverage: 7.5,
          releaseDate: '2024-01-02',
        ),
      ];

      final tNewMoviesPage = MoviesPage(
        movies: tNewMovies,
        currentPage: 2,
        totalPages: 500,
      );

      blocTest<MovieBloc, MovieState>(
        'emits [MovieLoadingMore, MovieLoaded] with combined movies',
        build: () {
          when(
            mockGetPopularMoviesUseCase(page: 2),
          ).thenAnswer((_) async => Right(tNewMoviesPage));
          return movieBloc;
        },
        seed: () => MovieLoaded(
          movies: tInitialMovies,
          currentPage: 1,
          totalPages: 500,
        ),
        act: (bloc) => bloc.add(const LoadMoreMovies()),
        expect: () => [
          isA<MovieLoaded>().having(
            (state) => state.isLoadingMore,
            'isLoadingMore',
            true,
          ),
          isA<MovieLoaded>()
              .having((state) => state.movies.length, 'movies length', 2)
              .having((state) => state.currentPage, 'currentPage', 2)
              .having((state) => state.totalPages, 'totalPages', 500),
        ],
      );
    });

    group('FetchMovieTrailer', () {
      const tMovieId = 1;
      final tMovies = [
        Movie(
          id: tMovieId,
          title: 'Test Movie',
          overview: 'Overview',
          posterPath: '/poster.jpg',
          backdropPath: '/backdrop.jpg',
          voteAverage: 8.0,
          releaseDate: '2024-01-01',
        ),
      ];

      final tTrailer = MovieVideo(
        id: '123',
        key: 'videoKey123',
        name: 'Official Trailer',
        site: 'YouTube',
        type: 'Trailer',
      );

      blocTest<MovieBloc, MovieState>(
        'emits [MovieTrailerLoading, MovieTrailerLoaded] when trailer found',
        build: () {
          when(
            mockGetMovieTrailerUseCase(movieId: tMovieId),
          ).thenAnswer((_) async => Right(tTrailer));
          return movieBloc;
        },
        seed: () =>
            MovieLoaded(movies: tMovies, currentPage: 1, totalPages: 500),
        act: (bloc) => bloc.add(
          FetchMovieTrailer(
            movieId: tMovieId,
            movies: tMovies,
            currentPage: 1,
            totalPages: 500,
          ),
        ),
        expect: () => [
          MovieTrailerLoading(tMovies),
          isA<MovieTrailerLoaded>()
              .having((state) => state.movieId, 'movieId', tMovieId)
              .having(
                (state) => state.trailer.key,
                'trailer key',
                'videoKey123',
              ),
        ],
      );

      blocTest<MovieBloc, MovieState>(
        'emits [MovieTrailerLoading, MovieTrailerError] when no trailer',
        build: () {
          when(
            mockGetMovieTrailerUseCase(movieId: tMovieId),
          ).thenAnswer((_) async => Left(ServerFailure('No trailer')));
          return movieBloc;
        },
        seed: () =>
            MovieLoaded(movies: tMovies, currentPage: 1, totalPages: 500),
        act: (bloc) => bloc.add(
          FetchMovieTrailer(
            movieId: tMovieId,
            movies: tMovies,
            currentPage: 1,
            totalPages: 500,
          ),
        ),
        expect: () => [
          MovieTrailerLoading(tMovies),
          isA<MovieTrailerError>().having(
            (state) => state.message,
            'message',
            'No trailer',
          ),
        ],
      );
    });

    group('ResetTrailerState', () {
      final tMovies = [
        Movie(
          id: 1,
          title: 'Test Movie',
          overview: 'Overview',
          posterPath: '/poster.jpg',
          backdropPath: '/backdrop.jpg',
          voteAverage: 8.0,
          releaseDate: '2024-01-01',
        ),
      ];

      blocTest<MovieBloc, MovieState>(
        'emits MovieLoaded when ResetTrailerState is added',
        build: () => movieBloc,
        seed: () => MovieTrailerLoading(tMovies),
        act: (bloc) => bloc.add(const ResetTrailerState()),
        expect: () => [
          isA<MovieLoaded>().having((state) => state.movies, 'movies', tMovies),
        ],
      );
    });
  });
}

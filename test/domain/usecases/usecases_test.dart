import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_movies_module/core/error/failures.dart';
import 'package:flutter_movies_module/core/result.dart';
import 'package:flutter_movies_module/domain/entities/movies_page.dart';
import 'package:flutter_movies_module/domain/repositories/movie_repository.dart';
import 'package:flutter_movies_module/domain/usecases/usecases.dart';
import 'package:mockito/mockito.dart';

class MockMovieRepository extends Mock implements MovieRepository {}

void main() {
  late GetPopularMoviesUseCase getPopularMoviesUseCase;
  late GetMovieTrailerUseCase getMovieTrailerUseCase;
  late MockMovieRepository mockMovieRepository;

  setUp(() {
    mockMovieRepository = MockMovieRepository();
    getPopularMoviesUseCase = GetPopularMoviesUseCase(
      repository: mockMovieRepository,
    );
    getMovieTrailerUseCase = GetMovieTrailerUseCase(
      repository: mockMovieRepository,
    );
  });

  group('GetPopularMoviesUseCase', () {
    final tRawMovieJson = <String, dynamic>{
      'id': 1,
      'title': 'Test Movie',
      'overview': 'Test overview',
      'poster_path': '/poster.jpg',
      'backdrop_path': '/backdrop.jpg',
      'vote_average': 8.0,
      'release_date': '2024-01-01',
    };

    final tRawPageJson = <String, dynamic>{
      'results': [tRawMovieJson],
      'page': 1,
      'total_pages': 500,
    };

    test(
      'should return Right(MoviesPage) when repository call is successful',
      () async {
        // Arrange
        when(
          mockMovieRepository.getPopularMovies(page: 1),
        ).thenAnswer((_) async => Right(tRawPageJson));

        // Act
        final result = await getPopularMoviesUseCase(page: 1);

        // Assert
        result.fold(
          (failure) => fail('Expected Right'),
          (page) => expect(page, isA<MoviesPage>()),
        );
        verify(mockMovieRepository.getPopularMovies(page: 1)).called(1);
        verifyNoMoreInteractions(mockMovieRepository);
      },
    );

    test('should return Left(Failure) when repository call fails', () async {
      // Arrange
      final failure = ServerFailure('Server error');
      when(
        mockMovieRepository.getPopularMovies(page: 1),
      ).thenAnswer((_) async => Left(failure));

      // Act
      final result = await getPopularMoviesUseCase(page: 1);

      // Assert
      result.fold((f) => expect(f, failure), (page) => fail('Expected Left'));
      verify(mockMovieRepository.getPopularMovies(page: 1)).called(1);
    });
  });

  group('GetMovieTrailerUseCase', () {
    const tMovieId = 1;
    final tYoutubeTrailerJson = <String, dynamic>{
      'id': '123',
      'key': 'videoKey123',
      'name': 'Official Trailer',
      'site': 'YouTube',
      'type': 'Trailer',
    };
    final tNonYoutubeTrailerJson = <String, dynamic>{
      'id': '456',
      'key': 'videoKey456',
      'name': 'Clip',
      'site': 'Vimeo',
      'type': 'Clip',
    };

    test(
      'should return YouTube trailer when videos list contains YouTube trailer',
      () async {
        // Arrange
        final videos = [tNonYoutubeTrailerJson, tYoutubeTrailerJson];
        when(
          mockMovieRepository.getMovieVideos(tMovieId),
        ).thenAnswer((_) async => Right(videos));

        // Act
        final result = await getMovieTrailerUseCase(movieId: tMovieId);

        // Assert
        result.fold((failure) => fail('Expected Right'), (trailer) {
          expect(trailer.site, 'YouTube');
          expect(trailer.key, 'videoKey123');
        });
        verify(mockMovieRepository.getMovieVideos(tMovieId)).called(1);
      },
    );

    test(
      'should return first video as fallback when no YouTube trailer exists',
      () async {
        // Arrange
        final videos = [tNonYoutubeTrailerJson];
        when(
          mockMovieRepository.getMovieVideos(tMovieId),
        ).thenAnswer((_) async => Right(videos));

        // Act
        final result = await getMovieTrailerUseCase(movieId: tMovieId);

        // Assert
        result.fold((failure) => fail('Expected Right'), (trailer) {
          expect(trailer.site, 'Vimeo');
          expect(trailer.key, 'videoKey456');
        });
      },
    );

    test('should return Left(Failure) when videos list is empty', () async {
      // Arrange
      when(
        mockMovieRepository.getMovieVideos(tMovieId),
      ).thenAnswer((_) async => Right(const []));

      // Act
      final result = await getMovieTrailerUseCase(movieId: tMovieId);

      // Assert
      expect(result.getErrorOrNull(), isA<ServerFailure>());
    });

    test(
      'should return Left(Failure) when repository returns failure',
      () async {
        // Arrange
        final failure = NetworkFailure('Network error');
        when(
          mockMovieRepository.getMovieVideos(tMovieId),
        ).thenAnswer((_) async => Left(failure));

        // Act
        final result = await getMovieTrailerUseCase(movieId: tMovieId);

        // Assert
        expect(result.getErrorOrNull(), failure);
      },
    );
  });
}

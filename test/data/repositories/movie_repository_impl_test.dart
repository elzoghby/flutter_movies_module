import 'package:flutter_movies_module/core/error/exceptions.dart';
import 'package:flutter_movies_module/core/error/failures.dart';
import 'package:flutter_movies_module/data/datasources/movie_remote_data_source.dart';
import 'package:flutter_movies_module/data/repositories/movie_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockMovieRemoteDataSource extends Mock implements MovieRemoteDataSource {}

void main() {
  late MovieRepositoryImpl repository;
  late MockMovieRemoteDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockMovieRemoteDataSource();
    repository = MovieRepositoryImpl(remoteDataSource: mockDataSource);
  });

  final tRawMovieJson = <String, dynamic>{
    'id': 1,
    'title': 'Test Movie',
    'overview': 'Test overview',
    'poster_path': '/test.jpg',
    'backdrop_path': '/backdrop.jpg',
    'vote_average': 7.5,
    'release_date': '2024-01-01',
  };

  final tRawVideoJson = <String, dynamic>{
    'id': 'v1',
    'key': 'abc123',
    'name': 'Trailer',
    'site': 'YouTube',
    'type': 'Trailer',
  };

  group('getPopularMovies', () {
    test('should return raw JSON when data source succeeds', () async {
      final rawResponse = <String, dynamic>{
        'results': [tRawMovieJson],
        'page': 1,
        'total_pages': 500,
      };

      when(
        () => mockDataSource.getPopularMovies(page: 1),
      ).thenAnswer((_) async => rawResponse);

      final result = await repository.getPopularMovies();

      expect(result.getOrNull(), rawResponse);
      verify(() => mockDataSource.getPopularMovies(page: 1)).called(1);
    });

    test('should return ServerFailure on ServerException', () async {
      when(
        () => mockDataSource.getPopularMovies(page: 1),
      ).thenThrow(const ServerException('Server error'));

      final result = await repository.getPopularMovies();

      expect(result.getErrorOrNull(), isA<ServerFailure>());
    });

    test('should return NetworkFailure on NetworkException', () async {
      when(
        () => mockDataSource.getPopularMovies(page: 1),
      ).thenThrow(const NetworkException('No internet'));

      final result = await repository.getPopularMovies();

      expect(result.getErrorOrNull(), isA<NetworkFailure>());
    });
  });

  group('getMovieVideos', () {
    test('should return raw JSON list when data source succeeds', () async {
      when(
        () => mockDataSource.getMovieVideos(1),
      ).thenAnswer((_) async => [tRawVideoJson]);

      final result = await repository.getMovieVideos(1);

      expect(result.getOrNull(), [tRawVideoJson]);
    });

    test('should return ServerFailure on error', () async {
      when(
        () => mockDataSource.getMovieVideos(1),
      ).thenThrow(const ServerException('error'));

      final result = await repository.getMovieVideos(1);

      expect(result.getErrorOrNull(), isA<ServerFailure>());
    });
  });
}

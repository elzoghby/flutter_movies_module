import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_movies_module/data/datasources/movie_remote_data_source.dart';
import 'package:mockito/mockito.dart';

// Manual mock class for MovieRemoteDataSource
class MockMovieRemoteDataSource extends Mock implements MovieRemoteDataSource {}

void main() {
  group('MovieRepositoryImpl', () {
    late MockMovieRemoteDataSource mockRemoteDataSource;

    setUp(() {
      mockRemoteDataSource = MockMovieRemoteDataSource();
    });

    group('getPopularMovies', () {
      final testPage = 1;
      final testRawMovieJson = <String, dynamic>{
        'id': 1,
        'title': 'Test Movie',
        'overview': 'Test overview',
        'poster_path': '/poster.jpg',
        'backdrop_path': '/backdrop.jpg',
        'vote_average': 8.0,
        'release_date': '2024-01-01',
      };

      test(
        'should return raw JSON response when the call is successful',
        () async {
          // Arrange
          final apiResponse = <String, dynamic>{
            'results': [testRawMovieJson],
            'page': testPage,
            'total_pages': 500,
          };

          when(
            mockRemoteDataSource.getPopularMovies(page: testPage),
          ).thenAnswer((_) async => apiResponse);

          // Act
          final result = await mockRemoteDataSource.getPopularMovies(
            page: testPage,
          );

          // Assert
          expect(result, isA<Map<String, dynamic>>());
          expect(result['page'], testPage);
          verify(mockRemoteDataSource.getPopularMovies(page: testPage));
          verifyNoMoreInteractions(mockRemoteDataSource);
        },
      );
    });
  });
}

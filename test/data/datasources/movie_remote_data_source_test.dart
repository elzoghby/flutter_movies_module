import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_movies_module/core/error/exceptions.dart';
import 'package:flutter_movies_module/data/datasources/movie_remote_data_source.dart';
import 'package:http/http.dart' as http;

// Simple fake implementation for testing
class FakeHttpClient implements http.Client {
  late http.Response Function(Uri) _handler;

  FakeHttpClient.withHandler(this._handler);

  @override
  Future<http.Response> get(Uri url, {Map<String, String>? headers}) async {
    return _handler(url);
  }

  void throwException(Exception e) {
    _handler = (_) => throw e;
  }

  void respondWith(http.Response response) {
    _handler = (_) => response;
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    throw UnimplementedError();
  }

  @override
  noSuchMethod(Invocation invocation) {
    throw UnimplementedError();
  }

  @override
  void close() {}
}

void main() {
  late MovieRemoteDataSourceImpl dataSource;
  late FakeHttpClient fakeHttpClient;

  setUp(() {
    fakeHttpClient = FakeHttpClient.withHandler((_) => http.Response('', 200));
    dataSource = MovieRemoteDataSourceImpl(client: fakeHttpClient);
  });

  group('MovieRemoteDataSourceImpl', () {
    group('getPopularMovies', () {
      const testPage = 1;
      final tResponse = '''
      {
        "page": 1,
        "total_pages": 500,
        "results": [
          {
            "id": 1,
            "title": "Test Movie",
            "overview": "Test overview",
            "poster_path": "/poster.jpg",
            "backdrop_path": "/backdrop.jpg",
            "vote_average": 8.0,
            "release_date": "2024-01-01"
          }
        ]
      }
      ''';

      test(
        'should return raw JSON response map when the response code is 200',
        () async {
          // Arrange
          fakeHttpClient.respondWith(http.Response(tResponse, 200));

          // Act
          final result = await dataSource.getPopularMovies(page: testPage);

          // Assert
          expect(result, isA<Map<String, dynamic>>());
          expect(result['page'], testPage);
          expect(result['results'], isA<List>());
        },
      );

      test(
        'should throw ServerException when the response code is not 200',
        () async {
          // Arrange
          fakeHttpClient.respondWith(http.Response('Server error', 500));

          // Act
          final call = dataSource.getPopularMovies(page: testPage);

          // Assert
          expect(call, throwsA(isA<ServerException>()));
        },
      );

      test(
        'should throw NetworkException when there is a network error',
        () async {
          // Arrange
          fakeHttpClient.throwException(Exception('Network error'));

          // Act
          final call = dataSource.getPopularMovies(page: testPage);

          // Assert
          expect(call, throwsA(isA<NetworkException>()));
        },
      );
    });

    group('getMovieVideos', () {
      const testMovieId = 1;
      final tResponse = '''
      {
        "results": [
          {
            "id": "123",
            "key": "videoKey123",
            "name": "Official Trailer",
            "site": "YouTube",
            "type": "Trailer"
          }
        ]
      }
      ''';

      test(
        'should return a list of video maps when the response is 200',
        () async {
          // Arrange
          fakeHttpClient.respondWith(http.Response(tResponse, 200));

          // Act
          final result = await dataSource.getMovieVideos(testMovieId);

          // Assert
          expect(result, isA<List<Map<String, dynamic>>>());
          expect(result.isNotEmpty, true);
        },
      );
    });
  });
}

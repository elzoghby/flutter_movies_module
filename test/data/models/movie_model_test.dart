import 'package:flutter_movies_module/data/models/movie_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MovieModel', () {
    const tJson = {
      'id': 550,
      'title': 'Fight Club',
      'overview': 'An insomniac office worker...',
      'poster_path': '/pB8BM7pdSp6B6Ih7QI4S2t0POoT.jpg',
      'backdrop_path': '/fCayJrkfRaCRCTh8GqN30f8oyQF.jpg',
      'vote_average': 8.4,
      'release_date': '1999-10-15',
    };

    test('should be a subclass of Movie entity', () {
      final model = MovieModel.fromJson(tJson);
      expect(model.id, 550);
      expect(model.title, 'Fight Club');
    });

    test('should create a valid MovieModel from JSON', () {
      final model = MovieModel.fromJson(tJson);

      expect(model.id, 550);
      expect(model.title, 'Fight Club');
      expect(model.overview, 'An insomniac office worker...');
      expect(model.posterPath, '/pB8BM7pdSp6B6Ih7QI4S2t0POoT.jpg');
      expect(model.backdropPath, '/fCayJrkfRaCRCTh8GqN30f8oyQF.jpg');
      expect(model.voteAverage, 8.4);
      expect(model.releaseDate, '1999-10-15');
    });

    test('should handle null values in JSON gracefully', () {
      const nullJson = {
        'id': 1,
        'title': null,
        'overview': null,
        'poster_path': null,
        'backdrop_path': null,
        'vote_average': null,
        'release_date': null,
      };
      final model = MovieModel.fromJson(nullJson);
      expect(model.title, '');
      expect(model.overview, '');
      expect(model.posterPath, '');
      expect(model.voteAverage, 0.0);
    });

    test('should convert MovieModel to JSON', () {
      final model = MovieModel.fromJson(tJson);
      final result = model.toJson();

      expect(result['id'], 550);
      expect(result['title'], 'Fight Club');
      expect(result['poster_path'], '/pB8BM7pdSp6B6Ih7QI4S2t0POoT.jpg');
    });
  });
}

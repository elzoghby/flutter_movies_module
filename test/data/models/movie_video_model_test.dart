import 'package:flutter_movies_module/data/models/movie_video_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MovieVideoModel', () {
    const tJson = {
      'id': 'abc123',
      'key': 'dQw4w9WgXcQ',
      'name': 'Official Trailer',
      'site': 'YouTube',
      'type': 'Trailer',
    };

    test('should create a valid MovieVideoModel from JSON', () {
      final model = MovieVideoModel.fromJson(tJson);
      expect(model.id, 'abc123');
      expect(model.key, 'dQw4w9WgXcQ');
      expect(model.name, 'Official Trailer');
      expect(model.site, 'YouTube');
      expect(model.type, 'Trailer');
    });

    test('isYouTubeTrailer should return true for YouTube trailers', () {
      final model = MovieVideoModel.fromJson(tJson);
      expect(model.isYouTubeTrailer, true);
    });

    test('isYouTubeTrailer should return false for non-trailers', () {
      final model = MovieVideoModel.fromJson({
        ...tJson,
        'type': 'Featurette',
      });
      expect(model.isYouTubeTrailer, false);
    });

    test('should convert to JSON correctly', () {
      final model = MovieVideoModel.fromJson(tJson);
      final json = model.toJson();
      expect(json['key'], 'dQw4w9WgXcQ');
      expect(json['site'], 'YouTube');
    });
  });
}

import 'package:flutter_movies_module/core/result.dart';


abstract class MovieRepository {

  Future<Result<Map<String, dynamic>>> getPopularMovies({int page = 1});

  Future<Result<List<Map<String, dynamic>>>> getMovieVideos(int movieId);
}

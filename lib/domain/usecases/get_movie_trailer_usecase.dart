import 'package:flutter_movies_module/core/error/failures.dart';
import 'package:flutter_movies_module/core/result.dart';
import 'package:flutter_movies_module/data/models/movie_video_model.dart';
import 'package:flutter_movies_module/domain/entities/movie_video.dart';
import 'package:flutter_movies_module/domain/repositories/movie_repository.dart';

class GetMovieTrailerUseCase {
  final MovieRepository repository;

  const GetMovieTrailerUseCase({required this.repository});

  Future<Result<MovieVideo>> call({required int movieId}) async {
    final result = await repository.getMovieVideos(movieId);

    return result.fold((failure) => Left(failure), (rawJsonList) {
      final models = rawJsonList
          .map((json) => MovieVideoModel.fromJson(json))
          .toList();

      if (models.isEmpty) {
        return Left(ServerFailure('No trailer available for this movie.'));
      }

      final youtubeTrailers = models.where((m) => m.isYouTubeTrailer).toList();

      if (youtubeTrailers.isNotEmpty) {
        return Right(youtubeTrailers.first.toEntity());
      }

      return Right(models.first.toEntity());
    });
  }
}

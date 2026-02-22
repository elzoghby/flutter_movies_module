import 'package:flutter_movies_module/core/result.dart';
import 'package:flutter_movies_module/data/models/movies_page_model.dart';
import 'package:flutter_movies_module/domain/entities/movies_page.dart';
import 'package:flutter_movies_module/domain/repositories/movie_repository.dart';

class GetPopularMoviesUseCase {
  final MovieRepository repository;

  const GetPopularMoviesUseCase({required this.repository});

  Future<Result<MoviesPage>> call({int page = 1}) async {
    final result = await repository.getPopularMovies(page: page);

    return result.fold((failure) => Left(failure), (rawJson) {
      final pageModel = MoviesPageModel.fromJson(rawJson);
      return Right(pageModel.toEntity());
    });
  }
}

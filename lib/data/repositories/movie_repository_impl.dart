import 'package:flutter_movies_module/core/error/exceptions.dart';
import 'package:flutter_movies_module/core/error/failures.dart';
import 'package:flutter_movies_module/core/result.dart';
import 'package:flutter_movies_module/data/datasources/movie_remote_data_source.dart';
import 'package:flutter_movies_module/domain/repositories/movie_repository.dart';

class MovieRepositoryImpl implements MovieRepository {
  final MovieRemoteDataSource remoteDataSource;

  const MovieRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Result<Map<String, dynamic>>> getPopularMovies({int page = 1}) async {
    if (page < 1) {
      return Left(ValidationFailure('Page must be >= 1'));
    }

    try {
      // Raw map: { "results": [...], "page": 1, "total_pages": 500 }
      final rawData = await remoteDataSource.getPopularMovies(page: page);
      return Right(rawData);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(GenericFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Result<List<Map<String, dynamic>>>> getMovieVideos(int movieId) async {
    if (movieId < 1) {
      return Left(ValidationFailure('Movie ID must be > 0'));
    }

    try {
      final rawData = await remoteDataSource.getMovieVideos(movieId);
      return Right(rawData);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(GenericFailure('Unexpected error: ${e.toString()}'));
    }
  }
}

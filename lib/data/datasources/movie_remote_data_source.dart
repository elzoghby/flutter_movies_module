import 'dart:convert';

import 'package:flutter_movies_module/core/constants.dart';
import 'package:flutter_movies_module/core/error/exceptions.dart';
import 'package:http/http.dart' as http;

abstract class MovieRemoteDataSource {

  Future<Map<String, dynamic>> getPopularMovies({int page = 1});

  Future<List<Map<String, dynamic>>> getMovieVideos(int movieId);
}

class MovieRemoteDataSourceImpl implements MovieRemoteDataSource {
  final http.Client client;

  MovieRemoteDataSourceImpl({http.Client? client})
      : client = client ?? http.Client();

  @override
  Future<Map<String, dynamic>> getPopularMovies({int page = 1}) async {
    final uri = Uri.parse(
      '${AppConstants.tmdbBaseUrl}/movie/popular'
          '?api_key=${AppConstants.tmdbApiKey}&page=$page',
    );

    try {
      final response = await client.get(uri);

      if (response.statusCode == 200) {
        // Return the full response map — includes results, page, total_pages
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw ServerException(
          'Failed to fetch movies: HTTP ${response.statusCode}',
        );
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw NetworkException(e.toString());
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getMovieVideos(int movieId) async {
    final uri = Uri.parse(
      '${AppConstants.tmdbBaseUrl}/movie/$movieId/videos'
          '?api_key=${AppConstants.tmdbApiKey}',
    );

    try {
      final response = await client.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final results = data['results'] as List<dynamic>;
        return results.cast<Map<String, dynamic>>();
      } else {
        throw ServerException(
          'Failed to fetch videos: HTTP ${response.statusCode}',
        );
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw NetworkException(e.toString());
    }
  }
}
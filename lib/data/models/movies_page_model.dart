import 'package:flutter_movies_module/data/models/movie_model.dart';
import 'package:flutter_movies_module/domain/entities/movies_page.dart';

class MoviesPageModel {
  final List<MovieModel> movies;
  final int currentPage;
  final int totalPages;

  const MoviesPageModel({
    required this.movies,
    required this.currentPage,
    required this.totalPages,
  });

  factory MoviesPageModel.fromJson(Map<String, dynamic> json) {
    final results = (json['results'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>()
        .map(MovieModel.fromJson)
        .toList();

    return MoviesPageModel(
      movies: results,
      currentPage: (json['page'] as num?)?.toInt() ?? 1,
      totalPages: (json['total_pages'] as num?)?.toInt() ?? 1,
    );
  }

  MoviesPage toEntity() => MoviesPage(
    movies: movies.map((m) => m.toEntity()).toList(),
    currentPage: currentPage,
    totalPages: totalPages,
  );
}
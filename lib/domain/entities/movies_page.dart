import 'package:flutter_movies_module/domain/entities/movie.dart';

class MoviesPage {
  final List<Movie> movies;

  final int currentPage;

  final int totalPages;

  const MoviesPage({
    required this.movies,
    required this.currentPage,
    required this.totalPages,
  });
}
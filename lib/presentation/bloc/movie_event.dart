part of 'movie_bloc.dart';

abstract class MovieEvent extends Equatable {
  const MovieEvent();

  @override
  List<Object?> get props => [];
}

class FetchMovies extends MovieEvent {
  const FetchMovies();

  @override
  List<Object?> get props => [];
}

class LoadMoreMovies extends MovieEvent {
  const LoadMoreMovies();

  @override
  List<Object?> get props => [];
}

class FetchMovieTrailer extends MovieEvent {
  final int movieId;

  final List<Movie> movies;
  final int currentPage;
  final int totalPages;

  const FetchMovieTrailer({
    required this.movieId,
    required this.movies,
    required this.currentPage,
    required this.totalPages,
  });

  @override
  List<Object?> get props => [movieId, movies, currentPage, totalPages];
}

class ResetTrailerState extends MovieEvent {
  const ResetTrailerState();

  @override
  List<Object?> get props => [];
}
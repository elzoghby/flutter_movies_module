part of 'movie_bloc.dart';

abstract class MovieState extends Equatable {
  const MovieState();

  @override
  List<Object?> get props => [];
}

class MovieInitial extends MovieState {
  @override
  List<Object?> get props => [];
}

class MovieLoading extends MovieState {
  @override
  List<Object?> get props => [];
}

class MovieLoaded extends MovieState {
  final List<Movie> movies;
  final int currentPage;
  final int totalPages;
  final bool isLoadingMore;

  const MovieLoaded({
    required this.movies,
    required this.currentPage,
    required this.totalPages,
    this.isLoadingMore = false,
  });

  bool get hasMorePages => currentPage < totalPages;

  MovieLoaded copyWith({
    List<Movie>? movies,
    int? currentPage,
    int? totalPages,
    bool? isLoadingMore,
  }) {
    return MovieLoaded(
      movies: movies ?? this.movies,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [movies, currentPage, totalPages, isLoadingMore];
}

class MovieError extends MovieState {
  final String message;

  const MovieError(this.message);

  @override
  List<Object?> get props => [message];
}

class MovieTrailerLoading extends MovieState {
  final List<Movie> movies;

  const MovieTrailerLoading(this.movies);

  @override
  List<Object?> get props => [movies];
}

class MovieTrailerLoaded extends MovieState {
  final List<Movie> movies;
  final MovieVideo trailer;
  final int movieId;

  final int currentPage;
  final int totalPages;

  const MovieTrailerLoaded({
    required this.movies,
    required this.trailer,
    required this.movieId,
    required this.currentPage,
    required this.totalPages,
  });

  @override
  List<Object?> get props => [
    movies,
    trailer,
    movieId,
    currentPage,
    totalPages,
  ];
}

class MovieTrailerError extends MovieState {
  final List<Movie> movies;
  final String message;

  final int currentPage;
  final int totalPages;

  const MovieTrailerError({
    required this.movies,
    required this.message,
    required this.currentPage,
    required this.totalPages,
  });

  @override
  List<Object?> get props => [movies, message, currentPage, totalPages];
}
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_movies_module/domain/entities/movie.dart';
import 'package:flutter_movies_module/domain/entities/movie_video.dart';
import 'package:flutter_movies_module/domain/usecases/usecases.dart';
import 'package:flutter_movies_module/presentation/bloc/pagination_guard.dart';

part 'movie_event.dart';
part 'movie_state.dart';

class MovieBloc extends Bloc<MovieEvent, MovieState> {
  final GetPopularMoviesUseCase getPopularMoviesUseCase;
  final GetMovieTrailerUseCase getMovieTrailerUseCase;

  final PaginationGuard _guard = PaginationGuard();

  MovieBloc({
    required this.getPopularMoviesUseCase,
    required this.getMovieTrailerUseCase,
  }) : super(MovieInitial()) {
    on<FetchMovies>(_onFetchMovies);
    on<LoadMoreMovies>(_onLoadMoreMovies);
    on<FetchMovieTrailer>(_onFetchMovieTrailer);
    on<ResetTrailerState>(_onResetTrailerState);
  }


  Future<void> _onFetchMovies(
      FetchMovies event,
      Emitter<MovieState> emit,
      ) async {
    _guard.reset();
    _guard.start();
    emit(MovieLoading());

    final result = await getPopularMoviesUseCase(page: 1);

    _guard.finish();
    result.fold(
          (failure) => emit(MovieError(failure.message)),
          (response) => emit(
        MovieLoaded(
          movies: response.movies,
          currentPage: 1,
          totalPages: response.totalPages,
        ),
      ),
    );
  }


  Future<void> _onLoadMoreMovies(
      LoadMoreMovies event,
      Emitter<MovieState> emit,
      ) async {
    final currentState = state;

    if (currentState is! MovieLoaded) return;
    if (!currentState.hasMorePages) return;

    if (!_guard.start()) return;

    final nextPage = currentState.currentPage + 1;
    emit(currentState.copyWith(isLoadingMore: true));

    final result = await getPopularMoviesUseCase(page: nextPage);

    _guard.finish();
    result.fold(
          (failure) => emit(currentState.copyWith(isLoadingMore: false)),
          (response) => emit(
        MovieLoaded(
          movies: [...currentState.movies, ...response.movies],
          currentPage: nextPage,
          totalPages: response.totalPages,
          isLoadingMore: false,
        ),
      ),
    );
  }


  Future<void> _onFetchMovieTrailer(
      FetchMovieTrailer event,
      Emitter<MovieState> emit,
      ) async {

    emit(MovieTrailerLoading(event.movies));

    final result = await getMovieTrailerUseCase(movieId: event.movieId);

    result.fold(
          (failure) => emit(MovieTrailerError(
        movies: event.movies,
        message: failure.message,
        currentPage: event.currentPage,
        totalPages: event.totalPages,
      )),
          (trailer) => emit(MovieTrailerLoaded(
        movies: event.movies,
        trailer: trailer,
        movieId: event.movieId,
        currentPage: event.currentPage,
        totalPages: event.totalPages,
      )),
    );
  }


  Future<void> _onResetTrailerState(
      ResetTrailerState event,
      Emitter<MovieState> emit,
      ) async {
    final s = state;

    final (movies, page, total) = switch (s) {
      MovieTrailerLoaded() => (s.movies, s.currentPage, s.totalPages),
      MovieTrailerError()  => (s.movies, s.currentPage, s.totalPages),
      _                    => (const <Movie>[], 0, 0),
    };

    if (movies.isNotEmpty) {
      emit(MovieLoaded(
        movies: movies,
        currentPage: page,
        totalPages: total,
      ));
    } else {

      emit(MovieInitial());
      add(const FetchMovies());
    }
  }
}
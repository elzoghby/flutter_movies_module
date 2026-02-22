import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_movies_module/domain/entities/movie.dart';
import 'package:flutter_movies_module/presentation/bloc/movie_bloc.dart';
import 'package:flutter_movies_module/presentation/services/trailer_navigator.dart';

class MovieTrailerHandler {
  final TrailerNavigator _trailerNavigator;

  MovieTrailerHandler(this._trailerNavigator);

  Future<void> handleTrailerLoaded(
    MovieTrailerLoaded state,
    BuildContext context,
  ) async {
    final movieTitle = _extractMovieTitle(state.movies, state.movieId);
    final videoKey = state.trailer.key;

    if (videoKey == null || videoKey.isEmpty) {
      if (context.mounted) {
        _showErrorSnackBar(context, 'Invalid trailer key');
      }
      return;
    }

    try {
      await _trailerNavigator.showTrailer(
        videoKey: videoKey,
        movieId: state.movieId,
        movieTitle: movieTitle,
      );
    } catch (error) {
      if (context.mounted) {
        _showErrorSnackBar(context, 'Error launching trailer: $error');
      }
    } finally {
      if (context.mounted) {
        context.read<MovieBloc>().add(const ResetTrailerState());
      }
    }
  }

  void handleTrailerError(BuildContext context, String message) {
    _showErrorSnackBar(context, message);
  }

  String _extractMovieTitle(List<Movie> movies, int movieId) {
    try {
      final movie = movies.firstWhere((m) => m.id == movieId);
      return movie.title ?? 'Movie Trailer';
    } catch (_) {
      return 'Movie Trailer';
    }
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFE53935),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

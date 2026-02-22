import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_movies_module/domain/entities/movie.dart';
import 'package:flutter_movies_module/presentation/bloc/movie_bloc.dart';
import 'package:flutter_movies_module/presentation/widgets/movie_card.dart';


class MovieListView extends StatelessWidget {
  final List<Movie> movies;
  final MovieState state;
  final ScrollController scrollController;

  const MovieListView({
    required this.movies,
    required this.state,
    required this.scrollController,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isLoadingMore =
        state is MovieLoaded && (state as MovieLoaded).isLoadingMore;

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      itemCount: movies.length + (isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        // Last slot → bottom "Loading..." text
        if (index == movies.length) {
          return const _BottomLoadingText();
        }

        final movie = movies[index];
        return MovieCard(
          movie: movie,
          onTap: () {
            if (movie.id == null) return;

      
            final currentPage = state is MovieLoaded
                ? (state as MovieLoaded).currentPage
                : 1;
            final totalPages = state is MovieLoaded
                ? (state as MovieLoaded).totalPages
                : 1;

            context.read<MovieBloc>().add(
              FetchMovieTrailer(
                movieId: movie.id!,
                movies: movies,
                currentPage: currentPage,
                totalPages: totalPages,
              ),
            );
          },
        );
      },
    );
  }
}

class _BottomLoadingText extends StatelessWidget {
  const _BottomLoadingText();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Text(
          'Loading...',
          style: TextStyle(
            color: Colors.white54,
            fontSize: 13,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}
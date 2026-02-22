import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_movies_module/domain/entities/movie.dart';
import 'package:flutter_movies_module/presentation/bloc/movie_bloc.dart';
import 'package:flutter_movies_module/presentation/services/movie_trailer_handler.dart';
import 'package:flutter_movies_module/presentation/services/trailer_navigator.dart';
import 'package:flutter_movies_module/presentation/widgets/movie_error_view.dart';
import 'package:flutter_movies_module/presentation/widgets/movie_list_view.dart';


class MovieListPage extends StatefulWidget {
  final TrailerNavigator trailerNavigator;

  const MovieListPage({super.key, required this.trailerNavigator});

  @override
  State<MovieListPage> createState() => _MovieListPageState();
}

class _MovieListPageState extends State<MovieListPage> {
  late final MovieTrailerHandler _trailerHandler;
  late final ScrollController _scrollController;

  static const double _scrollThreshold = 300.0;

  @override
  void initState() {
    super.initState();
    _trailerHandler = MovieTrailerHandler(widget.trailerNavigator);
    _scrollController = ScrollController()
      ..addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    final position = _scrollController.position;
    if (position.maxScrollExtent - position.pixels <= _scrollThreshold) {
      context.read<MovieBloc>().add(const LoadMoreMovies());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '🎬  Popular Movies',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: 0.5,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => SystemNavigator.pop(),
        ),
      ),
      body: BlocConsumer<MovieBloc, MovieState>(
        listener: _handleStateChanges,
        builder: (context, MovieState state) {
          if (state is MovieLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF01D277)),
            );
          }

          if (state is MovieError) {
            return MovieErrorView(
              message: state.message,
              onRetry: () => context.read<MovieBloc>().add(const FetchMovies()),
            );
          }

          final movies = _extractMovies(state);

          if (movies.isEmpty) {
            return const Center(
              child: Text(
                'No movies found.',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            );
          }

          return RefreshIndicator(
            color: const Color(0xFF01D277),
            onRefresh: () async {
              context.read<MovieBloc>().add(const FetchMovies());
              // Await until the BLoC leaves MovieLoading (refresh complete)
              await context
                  .read<MovieBloc>()
                  .stream
                  .firstWhere(
                    (s) => s is! MovieLoading,
              );
            },
            child: MovieListView(
              movies: movies,
              state: state,
              scrollController: _scrollController,
            ),
          );
        },
      ),
    );
  }




  void _handleStateChanges(BuildContext context, MovieState state) {
    if (state is MovieTrailerLoaded) {
      _trailerHandler.handleTrailerLoaded(state, context);
    } else if (state is MovieTrailerError) {
      _trailerHandler.handleTrailerError(context, state.message);
    }
  }


  List<Movie> _extractMovies(MovieState state) {
    return switch (state) {
      MovieLoaded() => state.movies,
      MovieTrailerLoading() => state.movies,
      MovieTrailerLoaded() => state.movies,
      MovieTrailerError() => state.movies,
      _ => [],
    };
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:flutter_movies_module/data/datasources/movie_remote_data_source.dart';
import 'package:flutter_movies_module/data/repositories/movie_repository_impl.dart';
import 'package:flutter_movies_module/domain/usecases/usecases.dart';
import 'package:flutter_movies_module/presentation/bloc/movie_bloc.dart';
import 'package:flutter_movies_module/presentation/pages/movie_list_page.dart';
import 'package:flutter_movies_module/presentation/services/platform_trailer_navigator.dart';

void main() {
  runApp(const MoviesApp());
}

class MoviesApp extends StatelessWidget {
  const MoviesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveSizer(
      builder: (context, orientation, screenType) {
        return MaterialApp(
          title: 'Movies',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: const Color(0xFF0D253F),
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF0D1117),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF161B22),
              elevation: 0,
              centerTitle: true,
            ),
            cardTheme: CardThemeData(
              color: const Color(0xFF161B22),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          home: BlocProvider(
            create: (_) {
              final repository = MovieRepositoryImpl(
                remoteDataSource: MovieRemoteDataSourceImpl(),
              );
              return MovieBloc(
                getPopularMoviesUseCase: GetPopularMoviesUseCase(
                  repository: repository,
                ),
                getMovieTrailerUseCase: GetMovieTrailerUseCase(
                  repository: repository,
                ),
              )..add(const FetchMovies());
            },
            child: MovieListPage(
              trailerNavigator: const PlatformTrailerNavigator(),
            ),
          ),
        );
      },
    );
  }
}

class AppConstants {
  AppConstants._();

  /// TMDB API key - loaded from .env file at runtime
  /// For development: set TMDB_API_KEY in .env file
  /// For production: use secure storage or environment variables
  static const String tmdbApiKey = String.fromEnvironment(
    'TMDB_API_KEY',
    defaultValue: '8881eb23cecc62eb7e10a0d156f1612a',
  );

  static const String tmdbBaseUrl = 'https://api.themoviedb.org/3';
  static const String tmdbImageBaseUrl = 'https://image.tmdb.org/t/p/w500';

  /// Method channel name shared between Flutter ↔ native
  static const String methodChannel = 'com.example.movies/channel';
}

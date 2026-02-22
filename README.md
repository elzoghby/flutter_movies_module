# Flutter Movies Module

A Flutter module that fetches popular movies from the TMDB API and displays them in a beautiful card-based list. When a user taps a movie, it communicates back to the native host app to play the movie trailer.

## Features

- 🎬 Fetches popular movies from TMDB API
- 🎨 Beautiful dark-themed UI with gradient cards
- ⭐ Shows movie poster, title, rating, year, and description
- 📺 Tapping a movie fetches the trailer and sends it to the native host via Method Channel
- 🧩 BLoC pattern for state management
- ✅ Comprehensive unit, widget, and BLoC tests (23 tests)

## Architecture

```
lib/
├── core/
│   ├── constants.dart              # API keys, URLs, channel names
│   └── error/
│       ├── exceptions.dart         # Data layer exceptions
│       └── failures.dart           # Domain layer failures (Equatable)
├── data/
│   ├── datasources/
│   │   └── movie_remote_data_source.dart  # HTTP calls to TMDB
│   ├── models/
│   │   ├── movie_model.dart        # JSON ↔ Movie entity
│   │   └── movie_video_model.dart  # JSON ↔ MovieVideo entity
│   └── repositories/
│       └── movie_repository_impl.dart  # Exception → Failure mapping
├── domain/
│   ├── entities/
│   │   ├── movie.dart              # Movie value object
│   │   └── movie_video.dart        # Video value object
│   └── repositories/
│       └── movie_repository.dart   # Abstract repository contract
├── presentation/
│   ├── bloc/
│   │   └── movie_bloc.dart         # Events, States, BLoC
│   ├── pages/
│   │   └── movie_list_page.dart    # Main UI page
│   └── widgets/
│       └── movie_card.dart         # Reusable movie card widget
└── main.dart                       # Entry point
```

## State Management (BLoC)

### Events
| Event | Description |
|-------|-------------|
| `FetchMovies` | Fetch popular movies from TMDB |
| `FetchMovieTrailer` | Fetch video/trailer for a specific movie |

### States
| State | Description |
|-------|-------------|
| `MovieInitial` | Initial state |
| `MovieLoading` | Fetching movies |
| `MovieLoaded` | Movies fetched successfully |
| `MovieError` | Error occurred |
| `MovieTrailerLoading` | Fetching trailer (preserves movie list) |
| `MovieTrailerLoaded` | Trailer found (triggers native navigation) |
| `MovieTrailerError` | Trailer not available |

## Method Channel

**Channel name:** `com.example.movies/channel`

| Method | Arguments | Description |
|--------|-----------|-------------|
| `showTrailer` | `{"videoKey": String, "movieId": int}` | Called by Flutter when a movie is tapped and trailer is found |

## Setup

1. **Get a TMDB API key** at https://www.themoviedb.org/settings/api

2. **Set the API key** in `lib/core/constants.dart`:
   ```dart
   static const String tmdbApiKey = 'YOUR_API_KEY_HERE';
   ```

3. **Install dependencies:**
   ```bash
   flutter pub get
   ```

4. **Run tests:**
   ```bash
   flutter test
   ```

## Testing

| Test Type | File | Tests |
|-----------|------|-------|
| Unit (Models) | `test/data/models/movie_model_test.dart` | 4 |
| Unit (Models) | `test/data/models/movie_video_model_test.dart` | 4 |
| Unit (Repository) | `test/data/repositories/movie_repository_impl_test.dart` | 5 |
| BLoC | `test/presentation/bloc/movie_bloc_test.dart` | 6 |
| Widget | `test/presentation/pages/movie_list_page_test.dart` | 3 |
| Widget | `test/widget_test.dart` | 1 |
| **Total** | | **23** |

## Dependencies

| Package | Purpose |
|---------|---------|
| `flutter_bloc` / `bloc` | BLoC state management |
| `equatable` | Value equality for entities and states |
| `http` | HTTP client for TMDB API |
| `dartz` | Functional programming (Either for error handling) |
| `cached_network_image` | Image caching for movie posters |
| `mocktail` | Mocking for tests |
| `bloc_test` | BLoC testing utilities |

## Integration with Native Hosts

This module is designed to be embedded in native Android and iOS apps:

- **Android:** Include as a source dependency via `settings.gradle.kts`
- **iOS:** Include via CocoaPods using `podhelper.rb`

See the [android_movies_host](../android_movies_host) and [ios_movies_host](../ios_movies_host) repositories for integration examples.

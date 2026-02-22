# 🎬 Flutter Movies Module

A **Flutter module** embedded inside native Android and iOS applications. It fetches popular movies from the TMDB API, displays them in a card-based list with infinite scroll, and communicates back to the native host to play trailers natively.

---

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Architecture](#architecture)
- [Project Structure](#project-structure)
- [Clean Architecture Layers](#clean-architecture-layers)
- [State Management — BLoC](#state-management--bloc)
- [Pagination Design](#pagination-design)
- [Method Channel Contract](#method-channel-contract)
- [Setup](#setup)
- [Running Tests](#running-tests)
- [Test Coverage](#test-coverage)
- [Dependencies](#dependencies)
- [Related Repositories](#related-repositories)

---

## Overview

This repository is the **Flutter module** — one of three repositories that make up the full Movies Module project.

| Repository | Role |
|---|---|
| **This repo** | Flutter BLoC + TMDB movies module |
| [ios_movies](https://github.com/elzoghby/ios_movies) | Native Swift iOS host app |
| [android_movies](https://github.com/elzoghby/android_movies) | Native Android host app |

---

## Features

- 🎬 Fetches popular movies from the TMDB API
- 🌑 Dark-themed UI with gradient movie cards
- ⭐ Displays movie poster, title, rating, release year, and description
- ♾️ Infinite scroll pagination with a bottom `"Loading..."` indicator
- 🔄 Pull-to-refresh resets the list back to page 1
- 📺 Tapping a movie fetches its trailer and sends it to the native host via `FlutterMethodChannel`
- 🧩 BLoC pattern for state management (single `MovieLoaded` state design)
- 🛡️ Dedup guard (`PaginationGuard`) prevents double-fetching
- ✅ Unit, widget, BLoC, and integration tests (23 tests)

---

## Architecture

This module follows **Clean Architecture** with strict layer separation:

```
┌──────────────────────────────────────────────┐
│              Presentation Layer               │
│   MovieListPage · MovieListView · MovieCard   │
│   MovieBloc · MovieEvent · MovieState         │
│   PaginationGuard                             │
├──────────────────────────────────────────────┤
│               Domain Layer                    │
│   Movie · MovieVideo · MoviesPage (entities)  │
│   MovieRepository (abstract contract)         │
│   GetPopularMoviesUseCase                     │
│   GetMovieTrailerUseCase                      │
├──────────────────────────────────────────────┤
│                Data Layer                     │
│   MovieRemoteDataSource (abstract + impl)     │
│   MovieModel · MovieVideoModel                │
│   MoviesPageModel                             │
│   MovieRepositoryImpl                         │
└──────────────────────────────────────────────┘
```

**Dependency rule:** arrows point inward only — data → domain ← presentation. No layer imports from the layer above it.

---

## Project Structure

```
lib/
├── core/
│   ├── constants.dart                      # API keys, URLs, channel names
│   └── error/
│       ├── exceptions.dart                 # Data layer exceptions
│       └── failures.dart                   # Domain layer failures
│
├── data/
│   ├── datasources/
│   │   └── movie_remote_data_source.dart   # Abstract + impl — raw TMDB HTTP calls
│   ├── models/
│   │   ├── movie_model.dart                # JSON ↔ Movie entity mapping
│   │   ├── movie_video_model.dart          # JSON ↔ MovieVideo entity mapping
│   │   └── movies_page_model.dart          # Parses full paginated API response
│   └── repositories/
│       └── movie_repository_impl.dart      # Exception → Failure mapping
│
├── domain/
│   ├── entities/
│   │   ├── movie.dart                      # Pure domain movie entity
│   │   ├── movie_video.dart                # Pure domain video entity
│   │   └── movies_page.dart                # Domain entity: movies + totalPages
│   ├── repositories/
│   │   └── movie_repository.dart           # Abstract repository contract
│   └── usecases/
│       ├── get_popular_movies_usecase.dart  # Returns Either<Failure, MoviesPage>
│       ├── get_movie_trailer_usecase.dart
│       └── usecases.dart                   # Barrel export
│
├── presentation/
│   ├── bloc/
│   │   ├── movie_bloc.dart                 # BLoC — events + state transitions
│   │   ├── movie_event.dart                # FetchMovies · LoadMoreMovies · FetchMovieTrailer · ResetTrailerState
│   │   ├── movie_state.dart                # MovieLoaded · MovieError · trailer states
│   │   └── pagination_guard.dart           # Concurrency dedup guard
│   ├── pages/
│   │   └── movie_list_page.dart            # Root page — owns ScrollController
│   ├── services/
│   │   ├── movie_trailer_handler.dart      # Handles trailer channel dispatch
│   │   └── trailer_navigator.dart          # Abstract navigation contract
│   └── widgets/
│       ├── movie_card.dart                 # Individual movie card
│       ├── movie_list_view.dart            # Stateless list renderer
│       └── movie_error_view.dart           # Error + retry UI
│
└── main.dart                               # Entry point + DI wiring
│
integration_test/
└── app_test.dart                           # End-to-end integration tests
│
test/
├── data/
│   ├── models/
│   │   ├── movie_model_test.dart
│   │   └── movie_video_model_test.dart
│   └── repositories/
│       └── movie_repository_impl_test.dart
└── presentation/
    ├── bloc/
    │   └── movie_bloc_test.dart
    └── pages/
        └── movie_list_page_test.dart
```

---

## Clean Architecture Layers

### Data Layer
- `MovieRemoteDataSource` is **abstract** — the repository depends on the contract, not the HTTP implementation. Swap HTTP for Dio or a cache with zero changes elsewhere.
- `getPopularMovies` returns the **full TMDB response map** (`results` + `page` + `total_pages`) — nothing is discarded at the network level.
- `MoviesPageModel.fromJson()` is the single point where JSON is parsed into typed models.

### Domain Layer
- **Zero data-layer imports** — entities (`Movie`, `MovieVideo`, `MoviesPage`) are plain Dart classes.
- `GetPopularMoviesUseCase` returns `Either<Failure, MoviesPage>` — the BLoC consumes only domain types.
- `totalPages` flows from the API response all the way up to the BLoC via `MoviesPage.totalPages` — no hardcoded magic numbers.

### Presentation Layer
- **Single `MovieLoaded` state** drives the entire list UI — no separate `MovieLoadingMore` state.
- `PaginationGuard` owns the concurrency concern — extracted out of the BLoC into its own class.
- `MovieListPage` (StatefulWidget) owns the `ScrollController`. `MovieListView` is fully stateless.
- `FetchMovieTrailer` event carries its own pagination snapshot — the BLoC never reads its own state as a data cache.
- `ResetTrailerState` always recovers — falls back to `MovieInitial` + `FetchMovies()` if context is lost.

---

## State Management — BLoC

### Events

| Event | Payload | Description |
|---|---|---|
| `FetchMovies` | — | Fetches page 1. Also used for pull-to-refresh. |
| `LoadMoreMovies` | — | Appends the next page (infinite scroll). BLoC owns the page counter. |
| `FetchMovieTrailer` | `movieId`, `movies`, `currentPage`, `totalPages` | Fetches trailer. Carries pagination snapshot to avoid BLoC reading its own state. |
| `ResetTrailerState` | — | Returns to `MovieLoaded` after trailer is dismissed. |

### States

| State | Description |
|---|---|
| `MovieInitial` | App hasn't loaded anything yet |
| `MovieLoading` | Full-screen spinner — first page only |
| `MovieLoaded` | Active list state. `isLoadingMore` flag drives bottom indicator. |
| `MovieError` | First-page failure with retry |
| `MovieTrailerLoading` | Trailer fetch in-flight |
| `MovieTrailerLoaded` | Trailer ready — triggers native navigation |
| `MovieTrailerError` | Trailer unavailable — snackbar shown |

---

## Pagination Design

```
User scrolls within 300px of list bottom
              │
              ▼
   MovieListPage._onScroll fires
   context.read<MovieBloc>().add(LoadMoreMovies())
              │
              ▼
   PaginationGuard.start() → returns false if already fetching (dedup)
              │
              ▼
   Emit MovieLoaded(isLoadingMore: true)  ← bottom "Loading..." appears
              │
              ▼
   getPopularMoviesUseCase(page: nextPage)
              │
        ┌─────┴──────┐
      success       error
        │             │
        ▼             ▼
  Append movies   Revert silently
  isLoadingMore: false  (list stays, indicator disappears)
```

- `totalPages` is sourced from the API — `hasMorePages = currentPage < totalPages`
- Pull-to-refresh calls `FetchMovies()` which resets to page 1 and resets the guard

---

## Method Channel Contract

**Channel name:** `com.movies.flutter/trailer`

### Flutter → Native

| Method | Arguments | Description |
|---|---|---|
| `showTrailer` | `{ "videoKey": String, "movieId": int }` | Sent when a movie is tapped and a trailer is found. Native plays it via `AVPlayer` (iOS) or `YouTubePlayer` (Android). |

```dart
// Flutter side — called automatically when MovieTrailerLoaded state is emitted
methodChannel.invokeMethod('showTrailer', {
  'videoKey': trailer.key,
  'movieId': movieId,
});
```

---

## Setup

### 1. Get a TMDB API key

Register at [themoviedb.org](https://www.themoviedb.org/settings/api) and generate a free API key.

### 2. Configure the API key

Copy the example env file and add your key:

```bash
cp .env.example .env
```

Then edit `.env`:

```
TMDB_API_KEY=your_api_key_here
```

### 3. Install dependencies

```bash
flutter pub get
```

### 4. Run the module standalone

```bash
flutter run
```

### 5. Integrate into native host apps

**Android** — add to `settings.gradle.kts`:
```kotlin
include(":flutter_movies_module")
project(":flutter_movies_module").projectDir = File("../flutter_movies_module")
```

**iOS** — add to `Podfile`:
```ruby
flutter_application_path = '../flutter_movies_module'
load File.join(flutter_application_path, '.ios', 'Flutter', 'podhelper.rb')
install_all_flutter_pods(flutter_application_path)
```

---

## Running Tests

```bash
# All unit + widget + BLoC tests
flutter test

# Integration tests (requires connected device or emulator)
flutter test integration_test/app_test.dart

# With coverage report
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

---

## Test Coverage

| Type | File | Tests |
|---|---|---|
| Unit — Model | `test/data/models/movie_model_test.dart` | 4 |
| Unit — Model | `test/data/models/movie_video_model_test.dart` | 4 |
| Unit — Repository | `test/data/repositories/movie_repository_impl_test.dart` | 5 |
| BLoC | `test/presentation/bloc/movie_bloc_test.dart` | 6 |
| Widget | `test/presentation/pages/movie_list_page_test.dart` | 3 |
| Widget | `test/widget_test.dart` | 1 |
| Integration | `integration_test/app_test.dart` | — |
| **Total** | | **23** |

Tests follow **TDD principles** — models, repository, and BLoC tests were written before implementation.

---

## Dependencies

| Package | Purpose |
|---|---|
| `flutter_bloc` / `bloc` | BLoC state management |
| `equatable` | Value equality for entities and states |
| `http` | HTTP client for TMDB API |
| `dartz` | Functional error handling (`Either<Failure, T>`) |
| `cached_network_image` | Efficient image caching for movie posters |
| `flutter_dotenv` | `.env` file support for API key management |
| `mocktail` | Mocking for unit and BLoC tests |
| `bloc_test` | BLoC-specific testing utilities |
| `integration_test` | Flutter integration test runner |

---

## Related Repositories

| Repository | Description |
|---|---|
| [flutter_movies_module](https://github.com/elzoghby/flutter_movies_module) | ← You are here — Flutter BLoC + TMDB module |
| [ios_movies](https://github.com/elzoghby/ios_movies) | Native Swift iOS host app |
| [android_movies](https://github.com/elzoghby/android_movies) | Native Android host app |

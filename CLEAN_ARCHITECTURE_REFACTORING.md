# Clean Architecture Refactoring Guide

## Overview

The `movie_bloc.dart` has been refactored to follow **Clean Architecture** principles by introducing **Use Cases** in the domain layer. This separates business logic from state management, making the code more testable and maintainable.

## Architecture Before (❌ Not Clean)

```
Presentation Layer
       ↓
   MovieBloc
       ↓
   Repository (direct call)
       ↓
   Data Layer
```

**Problems:**
- Business logic mixed in BLoC
- Repository directly injected into BLoC
- Hard to test business logic independently
- Violates Single Responsibility Principle

### Example of Old Code Issues:
```dart
// ❌ Business logic in BLoC
final trailer = videos.where((v) => v.isYouTubeTrailer).toList();
if (trailer.isNotEmpty) {
  emit(MovieTrailerLoaded(...));
} else if (videos.isNotEmpty) {
  emit(MovieTrailerLoaded(...)); // Fallback
} else {
  emit(MovieTrailerError(...));
}
```

## Architecture After (✅ Clean Architecture)

```
┌─────────────────────────────────────┐
│     Presentation Layer (UI)         │
│    (BLoC, Pages, Widgets)           │
├─────────────────────────────────────┤
│     Application/Use Case Layer      │
│  (GetPopularMoviesUseCase,          │
│   GetMovieTrailerUseCase)           │
├─────────────────────────────────────┤
│     Domain Layer (Business Logic)   │
│  (Entities, Repositories, UseCases) │
├─────────────────────────────────────┤
│     Data Layer (External)           │
│  (API, Models, Repository Impl)     │
└─────────────────────────────────────┘
```

## Key Changes

### 1. **Use Cases Created** (Domain Layer)

#### `GetPopularMoviesUseCase`
Handles fetching movies with pagination.

```dart
class GetPopularMoviesUseCase {
  final MovieRepository repository;

  const GetPopularMoviesUseCase({required this.repository});

  Future<Either<Failure, List<Movie>>> call({int page = 1}) async {
    return await repository.getPopularMovies(page: page);
  }
}
```

**Responsibility:** Data fetching only, no business logic (simple passthrough)

#### `GetMovieTrailerUseCase`
Handles all trailer-related business logic.

```dart
class GetMovieTrailerUseCase {
  final MovieRepository repository;

  const GetMovieTrailerUseCase({required this.repository});

  Future<Either<Failure, MovieVideo>> call({required int movieId}) async {
    final result = await repository.getMovieVideos(movieId);

    return result.fold(
      (failure) => Left(failure),
      (videos) {
        if (videos.isEmpty) {
          return Left(ServerFailure('No trailer available'));
        }

        // Business logic: Filter for YouTube trailers
        final youtubeTrailers =
            videos.where((v) => v.isYouTubeTrailer).toList();

        if (youtubeTrailers.isNotEmpty) {
          return Right(youtubeTrailers.first);
        }

        // Fallback: Return first video if no YouTube trailer
        return Right(videos.first);
      },
    );
  }
}
```

**Responsibility:** ALL trailer selection logic (filtering, fallbacks, error handling)

### 2. **BLoC Refactored** (Presentation Layer)

#### Before:
```dart
class MovieBloc extends Bloc<MovieEvent, MovieState> {
  final MovieRepository repository;  // ❌ Direct repository reference
  
  // All business logic scattered here
}
```

#### After:
```dart
class MovieBloc extends Bloc<MovieEvent, MovieState> {
  final GetPopularMoviesUseCase getPopularMoviesUseCase;      // ✅ Use case
  final GetMovieTrailerUseCase getMovieTrailerUseCase;        // ✅ Use case
  
  // Only event handling and state emission
}
```

**Responsibility:** 
- Listen to events
- Call appropriate use cases
- Emit corresponding states
- NO business logic

### 3. **Event and State Separation**

Created separate files for better organization:
- `movie_event.dart` - All events (part of movie_bloc.dart)
- `movie_state.dart` - All states (part of movie_bloc.dart)
- `movie_bloc.dart` - Only BLoC class

### 4. **Dependency Injection Updated**

#### Before:
```dart
// ❌ Repository injected into BLoC
BlocProvider(
  create: (_) => MovieBloc(
    repository: MovieRepositoryImpl(
      remoteDataSource: MovieRemoteDataSourceImpl(),
    ),
  ),
)
```

#### After:
```dart
// ✅ Use cases injected into BLoC
BlocProvider(
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
)
```

## Testing Improvements

### Before: Testing Business Logic

```dart
// ❌ Hard to test - logic is in BLoC
// Need to mock entire repository
when(mockMovieRepository.getMovieVideos(movieId))
    .thenAnswer((_) async => Right(videos));
// Then trigger BLoC event and check state
// Business logic (filtering) is mixed with state management
```

### After: Clean Separation

```dart
// ✅ Easy to test - Use cases have focused tests
test('should return YouTube trailer when available', () async {
  // Test business logic independently
  final videos = [tNonYoutube, tYoutube];
  when(mockMovieRepository.getMovieVideos(movieId))
      .thenAnswer((_) async => Right(videos));
  
  final result = await getMovieTrailerUseCase(movieId: movieId);
  
  expect(result, Right(tYoutube)); // Business logic verified
});

// ✅ BLoC tests are simpler - only test state management
blocTest(
  'emits [MovieTrailerLoading, MovieTrailerLoaded]',
  build: () {
    when(mockGetMovieTrailerUseCase(movieId: movieId))
        .thenAnswer((_) async => Right(trailer));
    return movieBloc;
  },
  act: (bloc) => bloc.add(FetchMovieTrailer(movieId)),
  expect: () => [
    MovieTrailerLoading(movies),
    MovieTrailerLoaded(...),
  ],
);
```

## File Structure

```
lib/domain/
├── entities/
│   ├── movie.dart
│   └── movie_video.dart
├── repositories/
│   └── movie_repository.dart
└── usecases/                          # ✅ NEW
    ├── get_popular_movies_usecase.dart
    ├── get_movie_trailer_usecase.dart
    └── usecases.dart                  # Barrel export

lib/presentation/bloc/
├── movie_bloc.dart                    # Only BLoC class now
├── movie_event.dart                   # ✅ NEW: All events
└── movie_state.dart                   # ✅ NEW: All states

test/domain/usecases/
└── usecases_test.dart                 # ✅ NEW: Use case tests

test/presentation/bloc/
└── movie_bloc_advanced_test.dart      # Updated: Mocks use cases
```

## Benefits

### 1. **Single Responsibility Principle**
- Use Cases: Handle business logic
- BLoC: Handle state management
- Each class has one reason to change

### 2. **Testability**
- Test business logic independently of state management
- Mock only what's needed
- Easier to achieve high test coverage

### 3. **Reusability**
- Use cases can be used by other layers
- Easy to share logic between multiple BLoCs
- One use case, multiple consumers

### 4. **Maintainability**
- Clear separation of concerns
- Easier to understand code flow
- Less code duplication

### 5. **Scalability**
- Easy to add new features without affecting existing code
- New use cases for new domain logic
- Domain layer remains stable

## Code Flow (How It Works)

```
1. User clicks "Watch Trailer"
   ↓
2. MovieListPage calls:
   context.read<MovieBloc>().add(FetchMovieTrailer(movieId))
   ↓
3. BLoC receives event in handler:
   Future<void> _onFetchMovieTrailer(...) async
   ↓
4. BLoC emits loading state:
   emit(MovieTrailerLoading(currentMovies))
   ↓
5. BLoC calls use case:
   final result = await getMovieTrailerUseCase(movieId: event.movieId)
   ↓
6. Use case receives result from repository:
   await repository.getMovieVideos(movieId)
   ↓
7. Use case processes result (business logic):
   - Filter for YouTube trailers ✅
   - Return fallback if needed ✅
   - Handle errors ✅
   ↓
8. Use case returns Either<Failure, MovieVideo>
   ↓
9. BLoC handles the result:
   result.fold(
     (failure) => emit(MovieTrailerError(...)),
     (trailer) => emit(MovieTrailerLoaded(...)),
   )
   ↓
10. UI updates with new state
    - Shows loading overlay
    - Shows trailer or error message
```

## Migration Checklist

- [x] Created `GetPopularMoviesUseCase`
- [x] Created `GetMovieTrailerUseCase`
- [x] Extracted events to `movie_event.dart`
- [x] Extracted states to `movie_state.dart`
- [x] Refactored `MovieBloc` to use use cases
- [x] Updated dependency injection in `main.dart`
- [x] Updated BLoC tests
- [x] Created use case tests
- [x] Added comprehensive documentation

## What's Now Clean Architecture ✅

| Aspect | Status |
|--------|--------|
| Business Logic in Use Cases | ✅ |
| BLoC for State Management Only | ✅ |
| Domain Layer Well-Defined | ✅ |
| Clear Dependency Inversion | ✅ |
| Easily Testable | ✅ |
| Separation of Concerns | ✅ |
| Single Responsibility | ✅ |
| Framework Independent Domain | ✅ |

## Further Reading

- [Clean Architecture: A Craftsman's Guide to Software Structure](https://blog.cleancoder.com/)
- [BLoC Pattern Official Docs](https://bloclibrary.dev/)
- [Architecture Patterns with Python](https://www.oreilly.com/library/view/architecture-patterns-with/9781492052197/)

---

**Version**: 1.0
**Last Updated**: February 2026
**Status**: ✅ Fully Refactored to Clean Architecture

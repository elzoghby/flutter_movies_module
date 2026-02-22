# Flutter Movies Module

A comprehensive Flutter module demonstrating modern mobile development practices with clean architecture, pagination, responsive design, and comprehensive testing.

## Features

✨ **Architecture & Design Patterns**
- Clean Architecture (Domain, Data, Presentation layers)
- BLoC State Management
- Repository pattern for data abstraction
- Fail-safe & Either patterns with Dartz

📱 **UI/UX**
- Responsive design with Responsive Sizer
- Infinite scroll pagination
- Material Design 3
- Dark theme optimized
- Cached network images

🎥 **Movie Features**
- Browse popular movies from TMDB API
- View movie details (title, rating, overview, release date)
- Load and display movie trailers natively
- YouTube video embedding with WebView

🧪 **Testing**
- Unit tests (Repository, Data Source, BLoC)
- Widget tests (UI components)
- Integration tests (Full app flow)
- TDD principles applied
- Mock objects with Mockito/Mocktail

🔒 **Security**
- Environment variables for API keys (.env file)
- Secure API key management
- No hardcoded secrets

## Project Structure

```
lib/
├── main.dart                        # App entry point
├── core/
│   ├── constants.dart              # App-wide constants
│   └── error/
│       ├── exceptions.dart         # Custom exceptions
│       └── failures.dart           # Error handling
├── data/
│   ├── datasources/
│   │   └── movie_remote_data_source.dart  # TMDB API integration
│   ├── models/
│   │   ├── movie_model.dart
│   │   └── movie_video_model.dart
│   └── repositories/
│       └── movie_repository_impl.dart     # Repository implementation
├── domain/
│   ├── entities/
│   │   ├── movie.dart              # Core business logic
│   │   └── movie_video.dart
│   └── repositories/
│       └── movie_repository.dart   # Repository interface
└── presentation/
    ├── bloc/
    │   └── movie_bloc.dart         # State management
    ├── pages/
    │   └── movie_list_page.dart    # Main UI page
    └── widgets/
        └── movie_card.dart         # Reusable UI components

test/
├── data/
│   ├── datasources/
│   │   └── movie_remote_data_source_test.dart
│   ├── models/
│   │   ├── movie_model_test.dart
│   │   └── movie_video_model_test.dart
│   └── repositories/
│       └── movie_repository_impl_advanced_test.dart
└── presentation/
    ├── bloc/
    │   └── movie_bloc_advanced_test.dart
    ├── pages/
    │   └── movie_list_page_widget_test.dart
    └── widgets/
        └── movie_card_widget_test.dart

integration_test/
└── app_test.dart                   # Full app integration tests
```

## Setup Instructions

### 1. Prerequisites
- Flutter 3.10.3 or higher
- Dart 3.10.3 or higher
- TMDB API key (free at https://www.themoviedb.org/settings/api)

### 2. Environment Setup

Create a `.env` file in the project root:

```bash
cp .env.example .env
```

Edit `.env` and add your TMDB API key:

```
TMDB_API_KEY=your_api_key_here
```

### 3. Install Dependencies

```bash
flutter pub get
```

### 4. Run the App

```bash
flutter run
```

### 5. Run Tests

**Run all unit tests:**
```bash
flutter test
```

**Run specific test file:**
```bash
flutter test test/presentation/bloc/movie_bloc_advanced_test.dart
```

**Run widget tests:**
```bash
flutter test test/presentation/widgets/movie_card_widget_test.dart
```

**Run integration tests:**
```bash
flutter drive --target=integration_test/app_test.dart
```

**Generate coverage report:**
```bash
flutter test --coverage
lcov --list coverage/lcov.info
```

## Dependencies

### Core Dependencies
- **flutter_bloc**: State management
- **dartz**: Functional programming utilities
- **http**: HTTP client for API calls
- **flutter_dotenv**: Environment variables management

### UI Dependencies
- **cached_network_image**: Image caching
- **responsive_sizer**: Responsive design
- **material_design_icons**: Icon library

### Testing Dependencies
- **flutter_test**: Unit testing framework
- **bloc_test**: BLoC testing utilities
- **mocktail**: Mocking framework
- **integration_test**: Integration testing

## API Integration

The module integrates with [The Movie Database (TMDB) API](https://www.themoviedb.org/settings/api):

### Endpoints Used

**Get Popular Movies:**
```
GET /movie/popular?api_key={api_key}&page={page}
```

**Get Movie Videos:**
```
GET /movie/{movie_id}/videos?api_key={api_key}
```

## Pagination

The app implements infinite scroll pagination:

1. Initial load fetches page 1 (20 movies)
2. ScrollListener detects when user reaches the end
3. Next page is automatically loaded and appended
4. Loading indicator shown during fetch
5. Hasmore indicator prevents unnecessary requests

**Implementation in BLoC:**
- `FetchMovies` event: Initial load
- `LoadMoreMovies` event: Pagination load
- `MovieLoadingMore` state: Shows loading indicator
- `MovieLoaded` state tracks: currentPage, hasMorePages, accumulated movies

## Responsive Design

Uses Responsive Sizer for device-adaptive sizing:

- **Screen-aware sizes**: `.w` (width), `.h` (height) extensions
- **Font scaling**: `.sp` (scaled pixels) extension
- **Dynamic padding/margins**: Based on screen dimensions
- **Responsive breakpoints**: Automatically adapts to phone/tablet

Example:
```dart
width: 25.w,  // 25% of screen width
fontSize: 16.sp,  // Responsive font size
padding: EdgeInsets.all(2.h),  // 2% of screen height
```

## State Management (BLoC)

### Events
- `FetchMovies(page)`: Load movies for specific page
- `LoadMoreMovies(page)`: Load next page of movies
- `FetchMovieTrailer(movieId)`: Fetch trailer videos
- `ResetTrailerState()`: Reset to loaded state

### States
- `MovieInitial`: Starting state
- `MovieLoading`: Fetching first page
- `MovieLoaded`: Movies loaded successfully
- `MovieLoadingMore`: Loading additional page
- `MovieError`: Error occurred
- `MovieTrailerLoading`: Fetching trailer
- `MovieTrailerLoaded`: Trailer ready to display
- `MovieTrailerError`: Trailer fetch failed

## Video Playback

### YouTube Integration
- Videos embedded via YouTube's no-cookie embed
- Plays in native WebView (no external YouTube app required)
- Supports fullscreen, controls, and inline playback
- Autoplay enabled for seamless experience

### Trailer Selection Logic
1. Fetch all videos for the movie
2. Filter for YouTube trailers specifically
3. Use first trailer found
4. Fallback to first video if no trailer
5. Show error if no videos available

## Testing Strategy

### Unit Tests
- **Repository Tests**: Mock data sources and test error handling
- **Data Source Tests**: Test API calls and JSON parsing
- **BLoC Tests**: Test event handling and state emission
- **Model Tests**: Test JSON serialization

### Widget Tests
- **MovieCard Tests**: Display, interactions, edge cases
- **MovieListPage Tests**: Loading states, error messages, pagination
- **UI Component Tests**: Icons, text, animations

### Integration Tests
- **Full App Flow**: From launch to trailer playback
- **Pagination Flow**: Load and scroll through movies
- **Error Handling**: Network errors, API errors
- **User Interactions**: Tapping, scrolling, navigation

## Code Examples

### Fetching Movies with Pagination

```dart
// Listen to BLoC state
BlocListener<MovieBloc, MovieState>(
  listener: (context, state) {
    // Handle states
  },
  child: BlocBuilder<MovieBloc, MovieState>(
    builder: (context, state) {
      if (state is MovieLoaded) {
        return ListView.builder(
          onEndReached: () {
            context.read<MovieBloc>()
              .add(LoadMoreMovies(state.currentPage + 1));
          },
          itemBuilder: (context, index) {
            return MovieCard(movie: state.movies[index]);
          },
        );
      }
    },
  ),
);
```

### Showing a Trailer

```dart
// In movie_list_page.dart
MovieCard(
  movie: movie,
  onTap: () {
    context.read<MovieBloc>()
      .add(FetchMovieTrailer(movie.id));
  },
)
```

## Performance Optimizations

- **Image Caching**: CachedNetworkImage reduces network calls
- **BLoC Optimization**: Only emits when state changes
- **Pagination**: Lazy loading prevents memory issues
- **Responsive Sizer**: Efficient layout calculations

## Error Handling

- **Server Errors**: User-friendly messages, retry option
- **Network Errors**: Offline detection, retry capability
- **No Trailers**: Fallback message
- **Invalid Data**: Silent failures with fallbacks

## Troubleshooting

### API Key Issues
```
Error: "Failed to fetch movies: HTTP 401"
→ Check .env file has valid TMDB_API_KEY
```

### Pagination Not Working
```
→ Ensure ScrollListener is attached to ListView
→ Check hasMorePages flag in state
```

### Videos Not Loading
```
→ Verify movie has videos on TMDB
→ Check internet connectivity
→ Ensure WebView supports YouTube embed
```

## Best Practices

✅ **code Organization**: Separated layers for maintainability
✅ **State Management**: BLoC for scalable state handling  
✅ **Testing**: High coverage with unit, widget, integration tests
✅ **Error Handling**: Graceful failures with user feedback
✅ **Responsive Design**: Works on all screen sizes
✅ **Security**: API keys in environment variables
✅ **Performance**: Efficient pagination and image caching

## Future Enhancements

- 🔍 Search and filter movies
- ⭐ Favorite movies list
- 💾 Offline data caching
- 🌙 Light/Dark theme toggle
- 📊 Movie recommendations
- 👤 User ratings and reviews

## Contributing

When contributing:
1. Follow clean architecture principles
2. Write tests for new features
3. Use responsive sizing for UI
4. Follow Dart/Flutter conventions
5. Document complex logic

## License

This module is part of the Flutter Movies Integration project.

## Support

For issues or questions:
1. Check existing issues
2. Review test cases for usage examples
3. Check TMDB API documentation
4. Review clean architecture patterns

---

**Last Updated**: February 2026
**Dart Version**: 3.10.3+
**Flutter Version**: 3.10.3+

import 'package:flutter/services.dart';
import 'package:flutter_movies_module/core/constants.dart';
import 'package:flutter_movies_module/presentation/services/trailer_navigator.dart';

class PlatformTrailerNavigator implements TrailerNavigator {
  static const _channel = MethodChannel(AppConstants.methodChannel);

  const PlatformTrailerNavigator();

  @override
  Future<void> showTrailer({
    required String videoKey,
    required int movieId,
    required String movieTitle,
  }) async {
    try {
      await _channel.invokeMethod('showTrailer', {
        'videoKey': videoKey,
        'movieId': movieId,
        'movieTitle': movieTitle,
      });
    } on PlatformException catch (e) {
      throw Exception('Could not open trailer: ${e.message}');
    }
  }
}

import 'package:flutter_movies_module/domain/entities/movie_video.dart';

class MovieVideoModel {
 String? id;
 String? key;
 String? name;
 String? site;
 String? type;

   MovieVideoModel({
    this.id,
    this.key,
    this.name,
    this.site,
    this.type,
  });

  // From API JSON to model
  factory MovieVideoModel.fromJson(Map<String, dynamic> json) {
    return MovieVideoModel(
      id: json['id'] ,
      key: json['key'],
      name: json['name'],
      site: json['site'],
      type: json['type'],
    );
  }

  // Model to JSON (for caching or serialization)
  Map<String, dynamic> toJson() => {
    'id': id,
    'key': key,
    'name': name,
    'site': site,
    'type': type,
  };

  bool get isYouTubeTrailer => site == 'YouTube' && type == 'Trailer';

  MovieVideo toEntity() =>
      MovieVideo(id: id, key: key, name: name, site: site, type: type);

  @override
  String toString() => 'MovieVideoModel(id: $id, key: $key, name: $name)';
}

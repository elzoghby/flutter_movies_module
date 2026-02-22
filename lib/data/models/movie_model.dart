import 'package:flutter_movies_module/domain/entities/movie.dart';

class MovieModel {
 int? id;
 String? title;
 String? overview;
 String? posterPath;
 String? backdropPath;
 double? voteAverage;
 String? releaseDate;

   MovieModel({
     this.id,
     this.title,
     this.overview,
     this.posterPath,
     this.backdropPath,
     this.voteAverage,
     this.releaseDate,
  });

  // From API JSON to model
  factory MovieModel.fromJson(Map<String, dynamic> json) {
    return MovieModel(
      id: json['id'] ,
      title: json['title'] ,
      overview: json['overview'] ,
      posterPath: json['poster_path'] ,
      backdropPath: json['backdrop_path'] ,
      voteAverage: json['vote_average']?.toDouble() ,
      releaseDate: json['release_date'] ,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'overview': overview,
    'poster_path': posterPath,
    'backdrop_path': backdropPath,
    'vote_average': voteAverage,
    'release_date': releaseDate,
  };

  Movie toEntity() => Movie(
    id: id,
    title: title,
    overview: overview,
    posterPath: posterPath,
    backdropPath: backdropPath,
    voteAverage: voteAverage,
    releaseDate: releaseDate,
  );

  @override
  String toString() => 'MovieModel(id: $id, title: $title)';
}

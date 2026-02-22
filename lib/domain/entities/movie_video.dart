class MovieVideo {
  String? id;
  String? key;
  String? name;
  String? site;
  String? type;

  MovieVideo({this.id, this.key, this.name, this.site, this.type});

  bool get isYouTubeTrailer => site == 'YouTube' && type == 'Trailer';
}

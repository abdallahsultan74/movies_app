class FavoriteMovieModel {
  final String movieId;
  final String name;
  final double rating;
  final String imageURL;
  final String year;

  FavoriteMovieModel({
    required this.movieId,
    required this.name,
    required this.rating,
    required this.imageURL,
    required this.year,
  });

  factory FavoriteMovieModel.fromJson(Map<String, dynamic> json) {
    return FavoriteMovieModel(
      movieId: json['movieId']?.toString() ?? '',
      name: json['name'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      imageURL: json['imageURL'] ?? '',
      year: json['year']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'movieId': movieId,
      'name': name,
      'rating': rating,
      'imageURL': imageURL,
      'year': year,
    };
  }
}


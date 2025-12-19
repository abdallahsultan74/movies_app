import 'package:movie/core/api/models/favorite_movie_model.dart';

class FavoritesResponse {
  final String message;
  final List<FavoriteMovieModel> favorites;

  FavoritesResponse({
    required this.message,
    required this.favorites,
  });

  factory FavoritesResponse.fromJson(Map<String, dynamic> json) {
    return FavoritesResponse(
      message: json['message'] ?? '',
      favorites: (json['data'] as List<dynamic>?)
              ?.map((movie) => FavoriteMovieModel.fromJson(movie))
              .toList() ??
          [],
    );
  }
}

class AddFavoriteResponse {
  final int? statusCode;
  final String message;

  AddFavoriteResponse({
    this.statusCode,
    required this.message,
  });

  factory AddFavoriteResponse.fromJson(Map<String, dynamic> json) {
    return AddFavoriteResponse(
      statusCode: json['statusCode'],
      message: json['message'] ?? '',
    );
  }
}

class IsFavoriteResponse {
  final String message;
  final bool isFavorite;

  IsFavoriteResponse({
    required this.message,
    required this.isFavorite,
  });

  factory IsFavoriteResponse.fromJson(Map<String, dynamic> json) {
    return IsFavoriteResponse(
      message: json['message'] ?? '',
      isFavorite: json['data'] ?? false,
    );
  }
}

class RemoveFavoriteResponse {
  final String message;

  RemoveFavoriteResponse({
    required this.message,
  });

  factory RemoveFavoriteResponse.fromJson(Map<String, dynamic> json) {
    return RemoveFavoriteResponse(
      message: json['message'] ?? '',
    );
  }
}


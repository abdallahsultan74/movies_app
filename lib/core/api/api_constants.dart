class ApiConstants {
  static const String baseUrl = 'https://route-movie-apis.vercel.app';
  
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String resetPassword = '/auth/reset-password';
  
  static const String profile = '/profile';
  static const String updateProfile = '/profile';
  static const String deleteProfile = '/profile';
  
  static const String favoritesAll = '/favorites/all';
  static const String addFavorite = '/favorites/add';
  static const String removeFavorite = '/favorites/remove';
  static const String isFavorite = '/favorites/is-favorite';
  
  // YTS Movies API
  static const String ytsBaseUrl = 'https://yts.lt/api/v2';
  static const String listMovies = '/list_movies.json';
  static const String movieDetails = '/movie_details.json';
  static const String movieSuggestions = '/movie_suggestions.json';
}


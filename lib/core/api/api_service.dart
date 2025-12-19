import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:movie/core/api/api_constants.dart';
import 'package:movie/core/api/models/register_request.dart';
import 'package:movie/core/api/models/register_response.dart';
import 'package:movie/core/api/models/login_request.dart';
import 'package:movie/core/api/models/login_response.dart';
import 'package:movie/core/api/models/reset_password_request.dart';
import 'package:movie/core/api/models/reset_password_response.dart';
import 'package:movie/core/api/models/update_profile_request.dart';
import 'package:movie/core/api/models/update_profile_response.dart';
import 'package:movie/core/api/models/get_profile_response.dart';
import 'package:movie/core/api/models/delete_profile_response.dart';
import 'package:movie/core/api/models/movie_model.dart';
import 'package:movie/core/api/models/favorites_response.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String get baseUrl => ApiConstants.baseUrl;

  Future<RegisterResponse> register(RegisterRequest request) async {
    try {
      final url = Uri.parse('$baseUrl${ApiConstants.register}');
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      Map<String, dynamic> responseData;
      try {
        responseData = jsonDecode(response.body);
      } catch (e) {
        throw Exception('Invalid server response. Please try again.');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return RegisterResponse.fromJson(responseData);
      } else {
        String errorMessage = 'Registration failed. Please try again.';
        
        if (responseData.containsKey('message')) {
          if (responseData['message'] is String) {
            errorMessage = responseData['message'];
          } else if (responseData['message'] is List) {
            errorMessage = (responseData['message'] as List).join(', ');
          }
        } else if (responseData.containsKey('error')) {
          if (responseData['error'] is String) {
            errorMessage = responseData['error'];
          } else if (responseData['error'] is Map) {
            final errorMap = responseData['error'] as Map<String, dynamic>;
            if (errorMap.containsKey('message')) {
              errorMessage = errorMap['message'].toString();
            }
          }
        } else if (responseData.containsKey('errors')) {
          if (responseData['errors'] is List) {
            errorMessage = (responseData['errors'] as List).join(', ');
          } else if (responseData['errors'] is Map) {
            final errorsMap = responseData['errors'] as Map<String, dynamic>;
            errorMessage = errorsMap.values.join(', ');
          }
        }
        
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (e is FormatException) {
        throw Exception('Data format error. Please try again.');
      } else if (e.toString().contains('SocketException') || 
                 e.toString().contains('Failed host lookup') ||
                 e.toString().contains('No address associated')) {
        throw Exception('Cannot connect to server. Please check your internet connection.');
      } else if (e is Exception) {
        final errorMessage = e.toString();
        if (errorMessage.contains('Exception: ')) {
          rethrow;
        }
        throw Exception('Error: ${errorMessage.replaceAll('Exception: ', '')}');
      }
      throw Exception('An unexpected error occurred. Please try again.');
    }
  }

  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final url = Uri.parse('$baseUrl${ApiConstants.login}');
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (responseData.containsKey('token') && responseData['token'] != null) {
          if (responseData['data'] != null && responseData['data'] is Map) {
            (responseData['data'] as Map<String, dynamic>)['token'] = responseData['token'];
          }
        }
        
        return LoginResponse.fromJson(responseData);
      } else {
        throw Exception(
          responseData['message'] ?? 'Login failed. Please try again.',
        );
      }
    } catch (e) {
      if (e is FormatException) {
        throw Exception('Data format error. Please try again.');
      } else if (e.toString().contains('SocketException') || 
                 e.toString().contains('Failed host lookup') ||
                 e.toString().contains('No address associated')) {
        throw Exception('Cannot connect to server. Please check your internet connection.');
      } else if (e is Exception) {
        final errorMessage = e.toString();
        if (errorMessage.contains('Exception: ')) {
          rethrow;
        }
        throw Exception('Error: ${errorMessage.replaceAll('Exception: ', '')}');
      }
      throw Exception('An unexpected error occurred. Please try again.');
    }
  }

  Future<ResetPasswordResponse> resetPassword(
    ResetPasswordRequest request,
    String token,
  ) async {
    try {
      final url = Uri.parse('$baseUrl${ApiConstants.resetPassword}');
      
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(request.toJson()),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ResetPasswordResponse.fromJson(responseData);
      } else {
        throw Exception(
          responseData['message'] ?? 'Password reset failed. Please try again.',
        );
      }
    } catch (e) {
      if (e is FormatException) {
        throw Exception('Data format error. Please try again.');
      } else if (e.toString().contains('SocketException') || 
                 e.toString().contains('Failed host lookup') ||
                 e.toString().contains('No address associated')) {
        throw Exception('Cannot connect to server. Please check your internet connection.');
      } else if (e is Exception) {
        final errorMessage = e.toString();
        if (errorMessage.contains('Exception: ')) {
          rethrow;
        }
        throw Exception('Error: ${errorMessage.replaceAll('Exception: ', '')}');
      }
      throw Exception('An unexpected error occurred. Please try again.');
    }
  }

  Future<GetProfileResponse> getProfile(String token) async {
    try {
      final url = Uri.parse('$baseUrl${ApiConstants.profile}');
      
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return GetProfileResponse.fromJson(responseData);
      } else {
        throw Exception(
          responseData['message'] ?? 'Failed to get profile data. Please try again.',
        );
      }
    } catch (e) {
      if (e is FormatException) {
        throw Exception('Data format error. Please try again.');
      } else if (e.toString().contains('SocketException') || 
                 e.toString().contains('Failed host lookup') ||
                 e.toString().contains('No address associated')) {
        throw Exception('Cannot connect to server. Please check your internet connection.');
      } else if (e is Exception) {
        final errorMessage = e.toString();
        if (errorMessage.contains('Exception: ')) {
          rethrow;
        }
        throw Exception('Error: ${errorMessage.replaceAll('Exception: ', '')}');
      }
      throw Exception('An unexpected error occurred. Please try again.');
    }
  }

  Future<UpdateProfileResponse> updateProfile(
    UpdateProfileRequest request,
    String token,
  ) async {
    try {
      final url = Uri.parse('$baseUrl${ApiConstants.updateProfile}');
      
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(request.toJson()),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return UpdateProfileResponse.fromJson(responseData);
      } else {
        throw Exception(
          responseData['message'] ?? 'Failed to update profile. Please try again.',
        );
      }
    } catch (e) {
      if (e is FormatException) {
        throw Exception('Data format error. Please try again.');
      } else if (e.toString().contains('SocketException') || 
                 e.toString().contains('Failed host lookup') ||
                 e.toString().contains('No address associated')) {
        throw Exception('Cannot connect to server. Please check your internet connection.');
      } else if (e is Exception) {
        final errorMessage = e.toString();
        if (errorMessage.contains('Exception: ')) {
          rethrow;
        }
        throw Exception('Error: ${errorMessage.replaceAll('Exception: ', '')}');
      }
      throw Exception('An unexpected error occurred. Please try again.');
    }
  }

  Future<DeleteProfileResponse> deleteProfile(String token) async {
    try {
      final url = Uri.parse('$baseUrl${ApiConstants.deleteProfile}');
      
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return DeleteProfileResponse.fromJson(responseData);
      } else {
        throw Exception(
          responseData['message'] ?? 'Failed to delete account. Please try again.',
        );
      }
    } catch (e) {
      if (e is FormatException) {
        throw Exception('Data format error. Please try again.');
      } else if (e.toString().contains('SocketException') || 
                 e.toString().contains('Failed host lookup') ||
                 e.toString().contains('No address associated')) {
        throw Exception('Cannot connect to server. Please check your internet connection.');
      } else if (e is Exception) {
        final errorMessage = e.toString();
        if (errorMessage.contains('Exception: ')) {
          rethrow;
        }
        throw Exception('Error: ${errorMessage.replaceAll('Exception: ', '')}');
      }
      throw Exception('An unexpected error occurred. Please try again.');
    }
  }

  Future<MoviesListResponse> getMoviesList({
    int? limit,
    int? page,
    String? quality,
    double? minimumRating,
    String? queryTerm,
    String? genre,
    String? sortBy,
  }) async {
    try {
      final uri = Uri.parse('${ApiConstants.ytsBaseUrl}${ApiConstants.listMovies}');
      final queryParams = <String, String>{};
      
      if (limit != null) queryParams['limit'] = limit.toString();
      if (page != null) queryParams['page'] = page.toString();
      if (quality != null) queryParams['quality'] = quality;
      if (minimumRating != null) queryParams['minimum_rating'] = minimumRating.toString();
      if (queryTerm != null) queryParams['query_term'] = queryTerm;
      if (genre != null) queryParams['genre'] = genre;
      if (sortBy != null) queryParams['sort_by'] = sortBy;

      final url = uri.replace(queryParameters: queryParams);
      
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return MoviesListResponse.fromJson(responseData);
      } else {
        throw Exception(
          responseData['status_message'] ?? 'Failed to fetch movies. Please try again.',
        );
      }
    } catch (e) {
      if (e is FormatException) {
        throw Exception('Data format error. Please try again.');
      } else if (e.toString().contains('SocketException') || 
                 e.toString().contains('Failed host lookup') ||
                 e.toString().contains('No address associated')) {
        throw Exception('Cannot connect to server. Please check your internet connection.');
      } else if (e is Exception) {
        final errorMessage = e.toString();
        if (errorMessage.contains('Exception: ')) {
          rethrow;
        }
        throw Exception('Error: ${errorMessage.replaceAll('Exception: ', '')}');
      }
      throw Exception('An unexpected error occurred. Please try again.');
    }
  }

  Future<MovieDetailsResponse> getMovieDetails(int movieId) async {
    try {
      final url = Uri.parse('${ApiConstants.ytsBaseUrl}${ApiConstants.movieDetails}?movie_id=$movieId');
      
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return MovieDetailsResponse.fromJson(responseData);
      } else {
        throw Exception(
          responseData['status_message'] ?? 'Failed to fetch movie details. Please try again.',
        );
      }
    } catch (e) {
      if (e is FormatException) {
        throw Exception('Data format error. Please try again.');
      } else if (e.toString().contains('SocketException') || 
                 e.toString().contains('Failed host lookup') ||
                 e.toString().contains('No address associated')) {
        throw Exception('Cannot connect to server. Please check your internet connection.');
      } else if (e is Exception) {
        final errorMessage = e.toString();
        if (errorMessage.contains('Exception: ')) {
          rethrow;
        }
        throw Exception('Error: ${errorMessage.replaceAll('Exception: ', '')}');
      }
      throw Exception('An unexpected error occurred. Please try again.');
    }
  }

  Future<MovieSuggestionsResponse> getMovieSuggestions(int movieId) async {
    try {
      final url = Uri.parse('${ApiConstants.ytsBaseUrl}${ApiConstants.movieSuggestions}?movie_id=$movieId');
      
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return MovieSuggestionsResponse.fromJson(responseData);
      } else {
        throw Exception(
          responseData['status_message'] ?? 'Failed to fetch movie suggestions. Please try again.',
        );
      }
    } catch (e) {
      if (e is FormatException) {
        throw Exception('Data format error. Please try again.');
      } else if (e.toString().contains('SocketException') || 
                 e.toString().contains('Failed host lookup') ||
                 e.toString().contains('No address associated')) {
        throw Exception('Cannot connect to server. Please check your internet connection.');
      } else if (e is Exception) {
        final errorMessage = e.toString();
        if (errorMessage.contains('Exception: ')) {
          rethrow;
        }
        throw Exception('Error: ${errorMessage.replaceAll('Exception: ', '')}');
      }
      throw Exception('An unexpected error occurred. Please try again.');
    }
  }

  Future<FavoritesResponse> getFavorites(String token) async {
    try {
      final url = Uri.parse('$baseUrl${ApiConstants.favoritesAll}');
      
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      Map<String, dynamic> responseData;
      try {
        responseData = jsonDecode(response.body);
      } catch (e) {
        throw Exception('Invalid server response. Please try again.');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return FavoritesResponse.fromJson(responseData);
      } else {
        throw Exception(
          responseData['message'] ?? 'Failed to get favorites. Please try again.',
        );
      }
    } catch (e) {
      if (e is FormatException) {
        throw Exception('Data format error. Please try again.');
      } else if (e.toString().contains('SocketException') || 
                 e.toString().contains('Failed host lookup') ||
                 e.toString().contains('No address associated')) {
        throw Exception('Cannot connect to server. Please check your internet connection.');
      } else if (e is Exception) {
        final errorMessage = e.toString();
        if (errorMessage.contains('Exception: ')) {
          rethrow;
        }
        throw Exception('Error: ${errorMessage.replaceAll('Exception: ', '')}');
      }
      throw Exception('An unexpected error occurred. Please try again.');
    }
  }

  Future<AddFavoriteResponse> addFavorite(MovieModel movie, String token) async {
    try {
      final url = Uri.parse('$baseUrl${ApiConstants.addFavorite}');
      
      final requestBody = {
        'movieId': movie.id.toString(),
        'name': movie.title,
        'rating': movie.rating,
        'imageURL': movie.mediumCoverImage.isNotEmpty 
            ? movie.mediumCoverImage 
            : (movie.largeCoverImage ?? ''),
        'year': movie.year.toString(),
      };
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );

      Map<String, dynamic> responseData;
      try {
        responseData = jsonDecode(response.body);
      } catch (e) {
        throw Exception('Invalid server response. Please try again.');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return AddFavoriteResponse.fromJson(responseData);
      } else {
        throw Exception(
          responseData['message'] ?? 'Failed to add favorite. Please try again.',
        );
      }
    } catch (e) {
      if (e is FormatException) {
        throw Exception('Data format error. Please try again.');
      } else if (e.toString().contains('SocketException') || 
                 e.toString().contains('Failed host lookup') ||
                 e.toString().contains('No address associated')) {
        throw Exception('Cannot connect to server. Please check your internet connection.');
      } else if (e is Exception) {
        final errorMessage = e.toString();
        if (errorMessage.contains('Exception: ')) {
          rethrow;
        }
        throw Exception('Error: ${errorMessage.replaceAll('Exception: ', '')}');
      }
      throw Exception('An unexpected error occurred. Please try again.');
    }
  }

  Future<RemoveFavoriteResponse> removeFavorite(int movieId, String token) async {
    try {
      final url = Uri.parse('$baseUrl${ApiConstants.removeFavorite}/$movieId');
      
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      Map<String, dynamic> responseData;
      try {
        responseData = jsonDecode(response.body);
      } catch (e) {
        throw Exception('Invalid server response. Please try again.');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return RemoveFavoriteResponse.fromJson(responseData);
      } else {
        throw Exception(
          responseData['message'] ?? 'Failed to remove favorite. Please try again.',
        );
      }
    } catch (e) {
      if (e is FormatException) {
        throw Exception('Data format error. Please try again.');
      } else if (e.toString().contains('SocketException') || 
                 e.toString().contains('Failed host lookup') ||
                 e.toString().contains('No address associated')) {
        throw Exception('Cannot connect to server. Please check your internet connection.');
      } else if (e is Exception) {
        final errorMessage = e.toString();
        if (errorMessage.contains('Exception: ')) {
          rethrow;
        }
        throw Exception('Error: ${errorMessage.replaceAll('Exception: ', '')}');
      }
      throw Exception('An unexpected error occurred. Please try again.');
    }
  }

  Future<IsFavoriteResponse> isFavorite(int movieId, String token) async {
    try {
      final url = Uri.parse('$baseUrl${ApiConstants.isFavorite}/$movieId');
      
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      Map<String, dynamic> responseData;
      try {
        responseData = jsonDecode(response.body);
      } catch (e) {
        throw Exception('Invalid server response. Please try again.');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return IsFavoriteResponse.fromJson(responseData);
      } else {
        throw Exception(
          responseData['message'] ?? 'Failed to check favorite status. Please try again.',
        );
      }
    } catch (e) {
      if (e is FormatException) {
        throw Exception('Data format error. Please try again.');
      } else if (e.toString().contains('SocketException') || 
                 e.toString().contains('Failed host lookup') ||
                 e.toString().contains('No address associated')) {
        throw Exception('Cannot connect to server. Please check your internet connection.');
      } else if (e is Exception) {
        final errorMessage = e.toString();
        if (errorMessage.contains('Exception: ')) {
          rethrow;
        }
        throw Exception('Error: ${errorMessage.replaceAll('Exception: ', '')}');
      }
      throw Exception('An unexpected error occurred. Please try again.');
    }
  }
}


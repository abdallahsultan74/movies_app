import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:movie/core/api/models/movie_model.dart';

class HistoryService {
  static const String _historyKey = 'movie_history';
  static const int _maxHistorySize = 50;

  Future<void> addToHistory(MovieModel movie) async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getStringList(_historyKey) ?? [];
    
    final movieJson = jsonEncode(movie.toJson());
    
    historyJson.remove(movieJson);
    historyJson.insert(0, movieJson);
    
    if (historyJson.length > _maxHistorySize) {
      historyJson.removeRange(_maxHistorySize, historyJson.length);
    }
    
    await prefs.setStringList(_historyKey, historyJson);
  }

  Future<List<MovieModel>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getStringList(_historyKey) ?? [];
    
    return historyJson.map((json) {
      try {
        return MovieModel.fromJson(jsonDecode(json));
      } catch (e) {
        return null;
      }
    }).whereType<MovieModel>().toList();
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }

  Future<void> removeFromHistory(int movieId) async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getStringList(_historyKey) ?? [];
    
    historyJson.removeWhere((json) {
      try {
        final movie = MovieModel.fromJson(jsonDecode(json));
        return movie.id == movieId;
      } catch (e) {
        return false;
      }
    });
    
    await prefs.setStringList(_historyKey, historyJson);
  }
}


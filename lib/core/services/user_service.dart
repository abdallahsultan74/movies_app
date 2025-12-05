import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:movie/core/models/user_model.dart';

class UserService {
  static const String _userKey = 'user_data';
  static const String _isLoggedInKey = 'is_logged_in';

  Future<void> saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
    await prefs.setBool(_isLoggedInKey, true);
  }

  Future<UserModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      return UserModel.fromJson(jsonDecode(userJson));
    }
    return null;
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  Future<void> updateUser(UserModel user) async {
    await saveUser(user);
  }

  Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.remove(_isLoggedInKey);
  }

  Future<String?> getToken() async {
    final user = await getUser();
    return user?.token;
  }
}


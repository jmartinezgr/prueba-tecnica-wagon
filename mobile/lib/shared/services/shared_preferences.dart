import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Provides methods to persist user info as JSON in shared preferences.
class UserInfoService {
  /// Key used to store user info in shared preferences.
  static const _userKey = 'user_info';

  /// Saves the user information as a JSON string in shared preferences.
  Future<void> saveUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = jsonEncode(user);
    await prefs.setString(_userKey, userJson);
  }

  /// Retrieves the user information from shared preferences, or null if not found.
  Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson == null) return null;
    return jsonDecode(userJson);
  }

  /// Deletes the stored user information from shared preferences.
  Future<void> deleteUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }
}

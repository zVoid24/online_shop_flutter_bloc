import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:online_shop/models/user.dart';

class SharedPrefs {
  static const String _userKey = 'user_data';

  // Save user data to SharedPreferences
  static Future<void> saveUserData(UserData user) async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = jsonEncode(user.toJson());
    await prefs.setString(_userKey, userJson);
  }

  // Retrieve user data from SharedPreferences
  static Future<UserData?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      final userMap = jsonDecode(userJson) as Map<String, dynamic>;
      return UserData.fromJson(userMap);
    }
    return null;
  }

  // Clear user data from SharedPreferences
  static Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }
}
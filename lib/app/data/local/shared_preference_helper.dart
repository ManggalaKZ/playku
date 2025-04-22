import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceHelper {
  static const String _keyUserId = "id";
  static const String _keyUserName = "username";
  static const String _keyName = "name";
  static const String _keyUserEmail = "email";
  static const String _keyPoint = "point";
  static const String _keyavatar = "avatar";

  static Future<void> saveUserData({
    required String userId,
    required int point,
    required String userName,
    required String userEmail,
    required String avatar,
    required String name,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserId, userId);
    await prefs.setInt(_keyPoint, point);
    await prefs.setString(_keyUserName, userName);
    await prefs.setString(_keyName, name);
    await prefs.setString(_keyavatar, avatar);
    await prefs.setString(_keyUserEmail, userEmail);
  }

  static Future<Map<String, dynamic>?> getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(_keyUserId)) {
      return {
        "id": prefs.getString(_keyUserId),
        "point": prefs.getInt(_keyPoint),
        "username": prefs.getString(_keyUserName),
        "name": prefs.getString(_keyName),
        "avatar": prefs.getString(_keyavatar),
        "email": prefs.getString(_keyUserEmail),
      };
    }
    return null;
  }

  static Future<void> clearUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyPoint);
    await prefs.remove(_keyUserName);
    await prefs.remove(_keyUserEmail);
    await prefs.remove(_keyName);
    await prefs.remove(_keyavatar);
  }
}

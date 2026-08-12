import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AppStorage {
  static Future<dynamic> get(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final v = prefs.getString(key);
      if (v == null) return null;
      return jsonDecode(v);
    } catch (_) {
      return null;
    }
  }

  static Future<bool> set(String key, dynamic value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.setString(key, jsonEncode(value));
    } catch (_) {
      return false;
    }
  }

  static Future<void> remove(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(key);
    } catch (_) {}
  }
}

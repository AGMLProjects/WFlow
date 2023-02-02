import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppConfig {
  static late SharedPreferences _preferences;

  static Future init() async {
    return _preferences = await SharedPreferences.getInstance();
  }

  static String getBaseUrl() {
    return 'https://49c13ba9-40e6-426b-be3c-21acf8b4f1d4.mock.pstmn.i';
  }

  static Color getDefaultColor() {
    return Colors.lightBlue;
  }

  static Future setUserToken(String token) async {
    return await _preferences.setString('token', token);
  }

  static String? getUserToken() {
    return _preferences.getString('token');
  }

  static Future setHouseColor(String id, Color color) async {
    return await _preferences.setInt('${id}.color', color.value);
  }

  static Color? getHouseColor(String id) {
    if (_preferences.getInt('${id}.color') == null) {
      return AppConfig.getDefaultColor();
    }
    return Color(_preferences.getInt('${id}.color')!);
  }
}

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppConfig {
  static late SharedPreferences _preferences;

  static Future init() async {
    return _preferences = await SharedPreferences.getInstance();
  }

  static String getBaseUrl() {
    return 'wflow.online';
  }

  static String getUsersPath() {
    return '/users';
  }

  static String getLoginPath() {
    return '${getUsersPath()}/login/';
  }

  static String getRegisterPath() {
    return '${getUsersPath()}/register/';
  }

  static String getHousesListPath() {
    return '/API/houses/list';
  }

  static Color getDefaultColor() {
    return Colors.lightBlue;
  }

  static Future setUserKey(String key) async {
    return await _preferences.setString('key', key);
  }

  static String? getUserToken() {
    return _preferences.getString('key');
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

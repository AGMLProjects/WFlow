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
    return '/users/';
  }

  static String getLoginPath() {
    return '${getUsersPath()}login/';
  }

  static String getRegisterPath() {
    return '${getUsersPath()}register/';
  }

  static String getHousesListPath() {
    return '/API/houses/list';
  }

  static String getAddHousePath() {
    return '/API/houses/add';
  }

  static String getEditHousePath() {
    return '/API/houses/{id}';
  }

  static String getAddDevicePath() {
    return '/devices/register/';
  }

  static String getHouseInfoPath() {
    return '/API/houses/specific/{id}';
  }

  static String getDiscoverPath() {
    return '/API/discover';
  }

  static String getPostActuatorPath() {
    return '/sensors/set/{id}';
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

  static Future setHouseColor(int id, Color color) async {
    return await _preferences.setInt('${id}.color', color.value);
  }

  static Color? getHouseColor(int id) {
    if (_preferences.getInt('${id}.color') == null) {
      return AppConfig.getDefaultColor();
    }
    return Color(_preferences.getInt('${id}.color')!);
  }

  static Future setSendPersonalData(bool active) async {
    return await _preferences.setBool('sendPersonalData', active);
  }

  static bool? getSendPersonalData() {
    return _preferences.getBool('sendPersonalData');
  }

  static String getFakeHouseInfo() {
    return "{\"house_id\":1,\"user_id\":2,\"name\":\"Casa1\",\"total_liters\":2346.0,\"total_gas\":6547.0,\"future_total_liters\":345.0,\"future_total_gas\":1000.0,\"address\":\"Via Mar Budapest, 10\",\"city\":\"Modena\",\"house_type\":\"APA\",\"literConsumes\":[{\"x\":\"01/03/2023\",\"y\":5,\"predicted\":false},{\"x\":\"02/03/2023\",\"y\":6,\"predicted\":false},{\"x\":\"03/03/2023\",\"y\":4,\"predicted\":false},{\"x\":\"04/03/2023\",\"y\":9,\"predicted\":false},{\"x\":\"05/03/2023\",\"y\":5,\"predicted\":false},{\"x\":\"06/03/2023\",\"y\":7,\"predicted\":false},{\"x\":\"07/03/2023\",\"y\":5,\"predicted\":false},{\"x\":\"08/03/2023\",\"y\":5,\"predicted\":false},{\"x\":\"09/03/2023\",\"y\":4,\"predicted\":false},{\"x\":\"10/03/2023\",\"y\":4,\"predicted\":true},{\"x\":\"11/03/2023\",\"y\":4,\"predicted\":true},{\"x\":\"12/03/2023\",\"y\":4,\"predicted\":true},{\"x\":\"13/03/2023\",\"y\":4,\"predicted\":true},{\"x\":\"14/03/2023\",\"y\":4,\"predicted\":true},{\"x\":\"15/03/2023\",\"y\":4,\"predicted\":true},{\"x\":\"16/03/2023\",\"y\":4,\"predicted\":true},{\"x\":\"17/03/2023\",\"y\":4,\"predicted\":true},{\"x\":\"18/03/2023\",\"y\":4,\"predicted\":true},{\"x\":\"19/03/2023\",\"y\":4,\"predicted\":true},{\"x\":\"20/03/2023\",\"y\":4,\"predicted\":true},{\"x\":\"21/03/2023\",\"y\":4,\"predicted\":true},{\"x\":\"22/03/2023\",\"y\":4,\"predicted\":true},{\"x\":\"23/03/2023\",\"y\":4,\"predicted\":true},{\"x\":\"24/03/2023\",\"y\":4,\"predicted\":true},{\"x\":\"25/03/2023\",\"y\":4,\"predicted\":true},{\"x\":\"26/03/2023\",\"y\":4,\"predicted\":true},{\"x\":\"27/03/2023\",\"y\":4,\"predicted\":true},{\"x\":\"28/03/2023\",\"y\":4,\"predicted\":true},{\"x\":\"29/03/2023\",\"y\":4,\"predicted\":true},{\"x\":\"30/03/2023\",\"y\":4,\"predicted\":true},{\"x\":\"31/03/2023\",\"y\":4,\"predicted\":true}],\"gasConsumes\":[{\"x\":\"01/03/2023\",\"y\":5,\"predicted\":false},{\"x\":\"02/03/2023\",\"y\":6,\"predicted\":false},{\"x\":\"03/03/2023\",\"y\":4,\"predicted\":false},{\"x\":\"04/03/2023\",\"y\":9,\"predicted\":false},{\"x\":\"05/03/2023\",\"y\":5,\"predicted\":false},{\"x\":\"06/03/2023\",\"y\":7,\"predicted\":false},{\"x\":\"07/03/2023\",\"y\":5,\"predicted\":false},{\"x\":\"08/03/2023\",\"y\":5,\"predicted\":false},{\"x\":\"09/03/2023\",\"y\":4,\"predicted\":false},{\"x\":\"10/03/2023\",\"y\":4,\"predicted\":true},{\"x\":\"11/03/2023\",\"y\":4,\"predicted\":true},{\"x\":\"12/03/2023\",\"y\":4,\"predicted\":true},{\"x\":\"13/03/2023\",\"y\":4,\"predicted\":true},{\"x\":\"14/03/2023\",\"y\":4,\"predicted\":true},{\"x\":\"15/03/2023\",\"y\":4,\"predicted\":true},{\"x\":\"16/03/2023\",\"y\":4,\"predicted\":true},{\"x\":\"17/03/2023\",\"y\":4,\"predicted\":true},{\"x\":\"18/03/2023\",\"y\":4,\"predicted\":true},{\"x\":\"19/03/2023\",\"y\":4,\"predicted\":true},{\"x\":\"20/03/2023\",\"y\":4,\"predicted\":true},{\"x\":\"21/03/2023\",\"y\":4,\"predicted\":true},{\"x\":\"22/03/2023\",\"y\":4,\"predicted\":true},{\"x\":\"23/03/2023\",\"y\":4,\"predicted\":true},{\"x\":\"24/03/2023\",\"y\":4,\"predicted\":true},{\"x\":\"25/03/2023\",\"y\":4,\"predicted\":true},{\"x\":\"26/03/2023\",\"y\":4,\"predicted\":true},{\"x\":\"27/03/2023\",\"y\":4,\"predicted\":true},{\"x\":\"28/03/2023\",\"y\":4,\"predicted\":true},{\"x\":\"29/03/2023\",\"y\":4,\"predicted\":true},{\"x\":\"30/03/2023\",\"y\":4,\"predicted\":true},{\"x\":\"31/03/2023\",\"y\":4,\"predicted\":true}],\"devices\":[]}";
  }
}

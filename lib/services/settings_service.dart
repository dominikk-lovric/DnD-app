import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static final ValueNotifier<int> revision = ValueNotifier(0);
  final SharedPreferences preferences;

  SettingsService(this.preferences);

  static late SharedPreferences _preferences;

  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  static Future<bool> clearSettings() {
    return _preferences.clear();
  }

  static dynamic getSetting(String setting) {
    final set = _preferences.get(setting);
    return set;
  }

  static Set<String> getSettingNames() {
    return _preferences.getKeys();
  }

  static Future<bool> setSetting(String setting, dynamic item) {
    if (item is int) {
      revision.value++;
      return _preferences.setInt(setting, item);
    } else if (item is double) {
      revision.value++;
      return _preferences.setDouble(setting, item);
    } else if (item is String) {
      revision.value++;
      return _preferences.setString(setting, item);
    } else if (item is bool) {
      revision.value++;
      return _preferences.setBool(setting, item);
    } else if (item is Color) {
      revision.value++;
      return _preferences.setInt(setting, item.toARGB32());
    } else if (item is List<String>) {
      revision.value++;
      return _preferences.setStringList(setting, item);
    } else {
      return Future.value(false);
    }
  }

  static Future<bool> initSetting(String setting, dynamic item) {
    if (item is int) {
      return _preferences.setInt(setting, getSetting(setting) ?? item);
    } else if (item is double) {
      return _preferences.setDouble(setting, getSetting(setting) ?? item);
    } else if (item is String) {
      return _preferences.setString(setting, getSetting(setting) ?? item);
    } else if (item is bool) {
      return _preferences.setBool(setting, getSetting(setting) ?? item);
    } else if (item is Color) {
      return _preferences.setInt(
        setting,
        getSetting(setting) ?? item.toARGB32(),
      );
    } else if (item is List<String>) {
      return _preferences.setStringList(setting, getSetting(setting) ?? item);
    } else {
      return Future.value(false);
    }
  }
}

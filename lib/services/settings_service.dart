import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  final SharedPreferences preferences;

  SettingsService(this.preferences);

  static late SharedPreferences _preferences;

  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }



  static dynamic getSetting(String setting){
    return _preferences.get(setting);
  }

  static Future<bool> setSetting(String setting, dynamic item){
    if(item is int){
      return _preferences.setInt(setting, item);
    }else if(item is double){
      return _preferences.setDouble(setting, item);
    }else if(item is String){
      return _preferences.setString(setting, item);
    }else if(item is bool){
      return _preferences.setBool(setting, item);
    }else if(item is Color){
      return _preferences.setInt(setting, item.toARGB32());
    }
    else{
      return Future.value(false);
    }
  }
}
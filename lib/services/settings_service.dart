import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  final SharedPreferences preferences;

  SettingsService(this.preferences);

  static late SharedPreferences _preferences;

  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  static String getTheme() {
    return _preferences.getString("theme") ?? "base";
  }

  static Future<bool> setTheme(String theme) {
    return _preferences.setString("theme", theme);
  }
}
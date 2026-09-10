import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider was not overridden. '
    'Await SharedPreferences.getInstance() in main() and override this '
    'before calling runApp().',
  );
});

final settingsServiceProvider = Provider<SettingsService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SettingsService(prefs);
});

final settingsControllerProvider = NotifierProvider<SettingsController, int>(
  SettingsController.new,
);

class SettingsController extends Notifier<int> {
  @override
  int build() => 0;

  SettingsService get _service => ref.read(settingsServiceProvider);

  dynamic getSetting(String setting) => _service.getSetting(setting);

  Set<String> getSettingNames() => _service.getSettingNames();

  Future<bool> setSetting(String setting, dynamic item) async {
    final ok = await _service.setSetting(setting, item);
    if (ok) state++; // bump revision, same role as revision.value++ before
    return ok;
  }

  Future<bool> initSetting(String setting, dynamic item) {
    return _service.initSetting(setting, item);
  }

  Future<bool> clearSettings() async {
    final ok = await _service.clearSettings();
    if (ok) state++;
    return ok;
  }
}

class SettingsService {
  final SharedPreferences preferences;

  SettingsService(this.preferences);

  Future<bool> clearSettings() {
    return preferences.clear();
  }

  dynamic getSetting(String setting) {
    return preferences.get(setting);
  }

  Set<String> getSettingNames() {
    return preferences.getKeys();
  }

  Future<bool> setSetting(String setting, dynamic item) {
    if (item is int) {
      return preferences.setInt(setting, item);
    } else if (item is double) {
      return preferences.setDouble(setting, item);
    } else if (item is String) {
      return preferences.setString(setting, item);
    } else if (item is bool) {
      return preferences.setBool(setting, item);
    } else if (item is Color) {
      return preferences.setInt(setting, item.toARGB32());
    } else if (item is List<String>) {
      return preferences.setStringList(setting, item);
    } else {
      return Future.value(false);
    }
  }

  Future<bool> initSetting(String setting, dynamic item) {
    if (item is int) {
      return preferences.setInt(setting, getSetting(setting) ?? item);
    } else if (item is double) {
      return preferences.setDouble(setting, getSetting(setting) ?? item);
    } else if (item is String) {
      return preferences.setString(setting, getSetting(setting) ?? item);
    } else if (item is bool) {
      return preferences.setBool(setting, getSetting(setting) ?? item);
    } else if (item is Color) {
      return preferences.setInt(
        setting,
        getSetting(setting) ?? item.toARGB32(),
      );
    } else if (item is List<String>) {
      return preferences.setStringList(setting, getSetting(setting) ?? item);
    } else {
      return Future.value(false);
    }
  }

  static double getHeight(BuildContext context) =>
      MediaQuery.sizeOf(context).height;

  static double getWidth(BuildContext context) =>
      MediaQuery.sizeOf(context).width;
}

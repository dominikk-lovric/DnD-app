import 'package:flutter/material.dart';

import 'package:dnd_app/services/settings_service.dart';

class ColorService {
  static final ChangeNotifier themeNotifier = ChangeNotifier();

  static List<String> colors = [
    "Primary Color",
    "Secondary Color",
    "Backround Color",
    "Accent Color",
    "Text Color",
    "Dark Text Color",
    "Subtitle Color",
  ];
  static List<Color> baseColors = [
    Color(0xff0c52a1),
    Color(0xff1b71d3),
    Color(0xff444444),
    Color(0xff505050),
    Color(0xffffffff),
    Color(0xffdadada),
    Color(0xffa8a8a8),
  ];

  static Color getColor(int color) {
    int? col = SettingsService.getSetting(colors[color]);
    if (col != null) {
      List<int> parts = fromARGB32(col);
      return Color.fromARGB(parts[0], parts[1], parts[2], parts[3]);
    } else {
      return getBasicColor(color);
    }
  }

  static Future<void> setColor(int colorName, Color color) async {
    await SettingsService.setSetting(colors[colorName], color.toARGB32());

    themeNotifier.notifyListeners();
  }

  static Future<void> resetColor(int colorName) async {
    await SettingsService.setSetting(
      colors[colorName],
      getBasicColor(colorName).toARGB32(),
    );

    themeNotifier.notifyListeners();
  }

  static Color getBasicColor(int color) {
    if (color < colors.length) {
      return baseColors[color];
    } else {
      return Color(0xffffffff);
    }
  }

  static List<String> getColorNames() {
    return colors;
  }

  static List<int> fromARGB32(int argb) {
    final int a = (argb >> 24) & 0xFF;
    final int r = (argb >> 16) & 0xFF;
    final int g = (argb >> 8) & 0xFF;
    final int b = argb & 0xFF;

    return [a, r, g, b];
  }
}

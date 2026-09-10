import 'package:flutter/material.dart';

import 'package:dnd_app/services/settings_service.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

final colorControllerProvider = NotifierProvider<ColorController, int>(
  ColorController.new,
);

class ColorController extends Notifier<int> {
  @override
  int build() => 0;

  SettingsController get _settings =>
      ref.read(settingsControllerProvider.notifier);

  static const List<String> colorNames = [
    "Primary Color",
    "Secondary Color",
    "Backround Color",
    "Accent Color",
    "Text Color",
    "Dark Text Color",
    "Subtitle Color",
  ];

  static const List<Color> baseColors = [
    Color(0xff0c52a1),
    Color(0xff1b71d3),
    Color(0xff444444),
    Color(0xff505050),
    Color(0xffffffff),
    Color(0xffdadada),
    Color(0xffa8a8a8),
  ];

  Color getColor(int color) {
    int? col = _settings.getSetting(colorNames[color]);
    if (col != null) {
      final parts = fromARGB32(col);
      return Color.fromARGB(parts[0], parts[1], parts[2], parts[3]);
    } else {
      return getBasicColor(color);
    }
  }

  Future<void> setColor(int colorName, Color color) async {
    await _settings.setSetting(colorNames[colorName], color.toARGB32());
    state++; // triggers rebuild in anything watching colorControllerProvider
  }

  Future<void> resetColor(int colorName) async {
    await _settings.setSetting(
      colorNames[colorName],
      getBasicColor(colorName).toARGB32(),
    );
    state++;
  }

  Color getBasicColor(int color) {
    if (color < colorNames.length) {
      return baseColors[color];
    } else {
      return const Color(0xffffffff);
    }
  }

  List<String> getColorNames() {
    return colorNames;
  }

  List<int> fromARGB32(int argb) {
    final int a = (argb >> 24) & 0xFF;
    final int r = (argb >> 16) & 0xFF;
    final int g = (argb >> 8) & 0xFF;
    final int b = argb & 0xFF;

    return [a, r, g, b];
  }
}

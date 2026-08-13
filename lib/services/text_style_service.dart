import 'package:dnd_app/services/color_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dnd_app/services/settings_service.dart';

class TextStyleService {
  static final ChangeNotifier themeNotifier = ChangeNotifier();

  static List<String> sizes = [
    "Header",
    "SubHeader",
    "Category",
    "SubCategory",
    "text",
    "additional",
  ];
  static List<double> baseSizes = [55, 45, 35, 20, 25, 15];

  static TextStyle getTextStyle(
    int size,
    int color, {
    double? Height,
    TextOverflow Overflow = TextOverflow.visible,
  }) {
    return TextStyle(
      color: ColorService.getColor(color),
      fontSize: getFontSize(size),
      overflow: Overflow,
      height: Height,
    );
  }

  static double getFontSize(int size) {
    double? setting = SettingsService.getSetting(sizes[size]);
    if (setting != null) {
      return setting;
    }
    return baseSizes[size];
  }

  static Future<void> setFontSize(int sizeName, double size) async {
    await SettingsService.setSetting(sizes[sizeName], size);

    themeNotifier.notifyListeners();
  }

  static List<String> getFontSizeNames() {
    return sizes;
  }

  Future<void> resetFontSize(int sizeName) async {
    await SettingsService.setSetting(sizes[sizeName], getBasicSize(sizeName));
  }

  static double getBasicSize(int size) {
    if (size < sizes.length) {
      return baseSizes[size];
    }
    return 0;
  }
}

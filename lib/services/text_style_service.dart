import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dnd_app/services/color_service.dart';
import 'package:dnd_app/services/settings_service.dart';

final textStyleControllerProvider = NotifierProvider<TextStyleController, int>(
  TextStyleController.new,
);

class TextStyleController extends Notifier<int> {
  @override
  int build() => 0;

  SettingsController get _settings =>
      ref.read(settingsControllerProvider.notifier);

  ColorController get _colors => ref.read(colorControllerProvider.notifier);

  static const List<String> sizes = [
    "Header",
    "SubHeader",
    "Category",
    "SubCategory",
    "text",
    "additional",
  ];
  static const List<double> baseSizes = [55, 45, 35, 25, 20, 15];

  TextStyle getTextStyle(
    int size,
    int color, {
    double? Height,
    TextOverflow Overflow = TextOverflow.visible,
  }) {
    return TextStyle(
      color: _colors.getColor(color),
      fontSize: getFontSize(size),
      overflow: Overflow,
      height: Height,
    );
  }

  double getFontSize(int size) {
    double? setting = _settings.getSetting("baseFontSize");
    if (setting != null) {
      return setting * pow((5 / 6), size);
    } else {
      return 55;
    }
  }

  Future<void> setFontSize(int sizeName, double size) async {
    await _settings.setSetting(sizes[sizeName], size);
    state++;
  }

  List<String> getFontSizeNames() {
    return sizes;
  }

  Future<void> resetFontSize(int sizeName) async {
    await _settings.setSetting(sizes[sizeName], getBasicSize(sizeName));
    state++;
  }

  double getBasicSize(int size) {
    if (size < sizes.length) {
      return baseSizes[size];
    }
    return 0;
  }
}

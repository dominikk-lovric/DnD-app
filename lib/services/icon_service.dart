import 'package:flutter/material.dart';

import 'package:dnd_app/services/settings_service.dart';

class IconService {
  static late Set<String> _assets;

  final String icon;

  IconService(this.icon);

  static Image getIcon(String path) {
    if (!path.isNotEmpty) {
      return Image.asset(
        "assets/icons/" + SettingsService.getSetting("theme") + "/default.png",
        fit: BoxFit.cover,
      );
    }

    return Image.asset(
      path,
      cacheWidth: 100,
      cacheHeight: 100,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Image.asset(
          "assets/icons/" +
              SettingsService.getSetting("theme") +
              "/default.png",
          fit: BoxFit.cover,
        );
      },
    );
  }

  static void initAssets(Set<String> assets) {
    _assets = assets;
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dnd_app/services/settings_service.dart';

class IconService {
  static late Set<String> _assets;

  final String icon;

  IconService(this.icon);

  static Image getIcon(WidgetRef ref, String path) {
    final theme = ref
        .read(settingsControllerProvider.notifier)
        .getSetting("theme");

    if (!path.isNotEmpty) {
      return Image.asset(
        "assets/icons/" + theme + "/default.png",
        fit: BoxFit.cover,
      );
    }

    return Image.asset(
      path,
      cacheWidth: 200,
      cacheHeight: 200,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Image.asset(
          "assets/icons/" + theme + "/default.png",
          fit: BoxFit.cover,
        );
      },
    );
  }

  static void initAssets(Set<String> assets) {
    _assets = assets;
  }
}

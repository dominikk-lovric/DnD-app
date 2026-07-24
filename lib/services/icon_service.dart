import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:dnd_app/services/settings_service.dart';
import 'package:shared_preferences/shared_preferences.dart';


class IconService {
    static late Set<String> _assets;

    final String icon;

    IconService(this.icon);

    static Image getIcon(
    String path) {

      if (path == null || !path.isNotEmpty) {
        return Image.asset(
        "assets/icons/"+SettingsService.getTheme()+"/default.png",fit: BoxFit.cover,);
      }

      return Image.asset(
        path,
        cacheWidth: 100,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset("assets/icons/"+SettingsService.getTheme()+"/default.png", fit: BoxFit.cover,);
        }
      );
    }

  static void initAssets(Set<String> assets) {
    _assets = assets;
  }

}
import 'dart:convert';

import 'package:flutter/services.dart';

class JsonService {
  final String jsonFile;

  JsonService(this.jsonFile);

  Future<Map<String, dynamic>> loadData() async {
    String path = jsonFile.startsWith("assets/json/")
        ? '$jsonFile'
        : 'assets/json/$jsonFile';
    path = jsonFile.endsWith('.json') ? '$path' : '$path.json';
    try {
      final jsonString = await rootBundle.loadString(path);
      return json.decode(jsonString) as Map<String, dynamic>;
    } catch (e, stackTrace) {
      print("Error loading $path");
      print(e);
      print(stackTrace);
      return {};
    }
  }

  Future<List<dynamic>> getOptions(String itemKey) async {
    final data = await loadData();
    return data[itemKey] ?? [];
  }

  Future<Map<String, dynamic>?> getOption(
    String itemKey,
    String optionName,
  ) async {
    final options = await getOptions(itemKey);

    for (final option in options) {
      if (option["name"] == optionName) {
        return option;
      }
    }

    return null;
  }

  static Future<Map<String, dynamic>> loadFromPath(String file) async {
    String path = file.startsWith("assets/json/")
        ? '$file'
        : 'assets/json/$file';
    path = file.endsWith('.json') ? '$path' : '$path.json';
    try {
      final jsonString = await rootBundle.loadString(path);
      return json.decode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      return {};
    }
  }
}

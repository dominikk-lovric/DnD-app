import 'dart:convert';
import 'package:dnd_app/services/json_service.dart';
import 'package:dnd_app/services/string_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final formControllerProvider =
    NotifierProvider.family<FormController, Map<String, dynamic>, String>(
      FormController.new,
    );

class FormController extends Notifier<Map<String, dynamic>> {
  FormController(this.formId);
  final String formId;

  @override
  Map<String, dynamic> build() => {};

  String getRelativePath(String path, String currentPath) {
    String choicePath = path;

    if (choicePath.startsWith("./")) {
      String tempPath = currentPath;
      choicePath = tempPath + "/" + choicePath.substring(2);
    } else if (choicePath.startsWith("../")) {
      String tempPath = currentPath;
      tempPath = tempPath.substring(0, tempPath.lastIndexOf("/"));
      choicePath = getRelativePath(choicePath.substring(3), tempPath);
    } else {
      choicePath = currentPath + "/" + choicePath;
    }
    return choicePath;
  }

  Future<dynamic> getItem(
    Map<String, dynamic> schema, [
    Map<String, dynamic>? info,
    String? currentPath,
  ]) async {
    dynamic item;
    item = (schema["path"] != null)
        ? await JsonService.loadFromPath(schema["path"])
        : info;

    if (schema["toChoice"] != null) {
      item = readPath(item, (schema["toChoice"] ?? "").split("/"));
    }

    if (schema["choice"] != null) {
      String choicePath = schema["choice"];
      if (currentPath != null) {
        choicePath = getRelativePath(schema["choice"] ?? "", currentPath);
      }
      dynamic choice = getValue((choicePath).split("/"));
      if (choice == null) {
        choice = item.keys.first;
        setValue((schema["choice"] ?? "").split("/"), choice);
      }

      item = item[choice];
    }
    if (schema["item"] != null) {
      item = readPath(item, (schema["item"] ?? "").split("/"));
    }

    if (schema["open"] == true) {
      item = await JsonService.loadFromPath(
        item["json"] ?? (item["path"] ?? ""),
      );
    }

    if (schema["from"] != null) {
      item = await getItem(schema["from"], item);
    }

    return item;
  }

  dynamic readPath(dynamic cur, List<String> path) {
    if (!path.isEmpty && path[0] != "" && path.length > 0) {
      for (final k in path) {
        if (cur is! Map) return null;
        cur = cur[k];
      }
    }
    return cur;
  }

  void setValue(List<String> path, dynamic value) {
    state = _setIn(state, path, value);
  }

  void initPath(List<String> path, dynamic value) {
    if (getValue(path) == null) setValue(path, value);
  }

  dynamic getValue(List<String> path) {
    dynamic cur = state;

    for (final k in path) {
      if (cur is! Map) return null;
      cur = cur[k];
    }
    return cur;
  }

  void remove(List<String> path) {
    state = _removeIn(state, path);
  }

  Map<String, dynamic> _removeIn(Map<String, dynamic> map, List<String> path) {
    final copy = Map<String, dynamic>.from(map);
    if (path.length == 1) {
      copy.remove(path.first);
    } else {
      final child = copy[path.first];
      if (child is Map) {
        copy[path.first] = _removeIn(
          Map<String, dynamic>.from(child),
          path.sublist(1),
        );
      }
    }
    return copy;
  }

  Map<String, dynamic> _setIn(
    Map<String, dynamic> map,
    List<String> path,
    dynamic value,
  ) {
    final copy = Map<String, dynamic>.from(map);
    if (path.length == 1) {
      copy[path.first] = value;
    } else {
      final child = copy[path.first];
      copy[path.first] = _setIn(
        child is Map ? Map<String, dynamic>.from(child) : <String, dynamic>{},
        path.sublist(1),
        value,
      );
    }
    return copy;
  }

  void reset() => state = {};

  String toJson() => jsonEncode(state);
}

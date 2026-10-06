import 'dart:convert';
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

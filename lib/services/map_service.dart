import 'package:dnd_app/services/settings_service.dart';

class MapService {
  static Map<String, dynamic> sortMap(
    Map<String, dynamic> info,
    dynamic Function(Map<String, dynamic>) selector, {
    dynamic Function(Map<String, dynamic>)? secondarySelector,
  }) {
    final entries = info.entries.toList();

    entries.sort((a, b) {
      final aValue = selector(a.value);
      final bValue = selector(b.value);

      int result = compareValues(aValue, bValue);

      if (result == 0 && secondarySelector != null) {
        final aSecondary = secondarySelector(a.value);
        final bSecondary = secondarySelector(b.value);

        result = compareValues(aSecondary, bSecondary);
      }

      return result;
    });

    return Map.fromEntries(entries);
  }

  static int compareValues(dynamic a, dynamic b) {
    if (a is num && b is num) {
      return a.compareTo(b);
    }

    return a.toString().toLowerCase().compareTo(b.toString().toLowerCase());
  }
}

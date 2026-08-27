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

  static Map<String, dynamic> filterMap(
    Map<String, dynamic> info,
    String field,
    List<dynamic> filter, {
    bool byStart = false,
  }) {
    Map<String, dynamic> items = {};
    List<String> keys = info.keys.toList();
    List<String> selector = field.split(".");
    for (final key in keys) {
      dynamic item = getItem(selector, info[key]);
      if (item is List) {
        for (final el in item) {
          if (filter.contains(el)) {
            items[key] = info[key];
          }
        }
      } else if (item is String) {
        List<dynamic> fl = [];
        for (final fil in filter) {
          if (fil is String) {
            fl.add(fil.toLowerCase());
          } else {
            fl.add(fil);
          }
        }
        if (!byStart) {
          if (fl.contains(item.toLowerCase())) {
            items[key] = info[key];
          }
        } else {
          for (final f in fl) {
            if (item.toLowerCase().startsWith(f)) {
              items[key] = info[key];
            }
          }
        }
      } else {
        if (filter.contains(item)) {
          items[key] = info[key];
        }
      }
    }
    return items;
  }

  static dynamic getItem(List<String> selector, Map<String, dynamic> item) {
    dynamic res = item;
    for (final el in selector) {
      try {
        res = res[el];
      } catch (e) {}
    }
    return res;
  }
}

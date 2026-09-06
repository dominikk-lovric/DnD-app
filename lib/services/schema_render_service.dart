import 'package:dnd_app/services/color_service.dart';
import 'package:dnd_app/services/json_service.dart';
import 'package:dnd_app/services/string_service.dart';
import 'package:dnd_app/services/text_style_service.dart';
import 'package:dnd_app/widgets/checklist.dart';
import 'package:dnd_app/widgets/description_column_widget.dart';
import 'package:dnd_app/widgets/description_widget.dart';
import 'package:dnd_app/widgets/list_widget.dart';
import 'package:dnd_app/widgets/table_widget.dart';
import 'package:flutter/material.dart';

class SchemaRenderService {
  static Widget render({
    required BuildContext context,
    required String category,
    required dynamic data,
    required Map<String, dynamic> schema,
    required Map<String, dynamic> schemata,
    required String title,
    String setting = "",
  }) {
    final String type = schema["type"];

    setting = "${StringService.slugify(title)}${category}DescriptionStyle";

    switch (type) {
      case "text":
        return DescriptionWidget(
          title,
          Text(data.toString(), style: TextStyleService.getTextStyle(4, 4)),
          setting,
        );

      case "list":
        return _renderList(
          context: context,
          category: category,
          data: data,
          schema: schema,
          schemata: schemata,
          title: title,
          setting: setting,
        );

      case "map":
        return _renderMap(
          context: context,
          category: category,
          data: data,
          schema: schema,
          schemata: schemata,
          title: title,
          setting: setting,
        );

      case "path":
        return _renderPath(
          context: context,
          category: category,
          data: data,
          schema: schema,
          schemata: schemata,
          title: title,
          setting: setting,
        );

      case "table":
        return DescriptionWidget(title, TableWidget(data), setting);

      case "checkList":
        return DescriptionWidget(
          title,
          CheckListWidget(data, schema["list"]),
          setting,
        );

      case "icon":
        return _renderIcon(data: data, schema: schema);

      default:
        if (schemata.containsKey(type)) {
          return DescriptionWidget(
            title,
            DescriptionColumnWidget(
              Map<String, dynamic>.from(data),
              schemata,
              category: type,
            ),
            setting,
          );
        }

        return const SizedBox.shrink();
    }
  }

  static Widget _renderList({
    required BuildContext context,
    required String category,
    required dynamic data,
    required Map<String, dynamic> schema,
    required Map<String, dynamic> schemata,
    required String title,
    required String setting,
  }) {
    final List<Widget> children = [];

    final itemSchema = Map<String, dynamic>.from(schema["item"]);

    for (final item in data) {
      children.add(
        render(
          context: context,
          category: category,
          data: item,
          schema: itemSchema,
          schemata: schemata,
          title: title,
          setting: setting,
        ),
      );
    }

    return DescriptionWidget(title, ListWidget(children), setting);
  }

  static Widget _renderMap({
    required BuildContext context,
    required String category,
    required dynamic data,
    required Map<String, dynamic> schema,
    required Map<String, dynamic> schemata,
    required String title,
    required String setting,
  }) {
    final List<Widget> children = [];

    final itemSchema = Map<String, dynamic>.from(schema["item"]);

    for (final entry in data.entries) {
      final String key = entry.key;
      final dynamic value = entry.value;

      Map<String, dynamic>? childSchema;

      if (itemSchema.containsKey(key)) {
        childSchema = Map<String, dynamic>.from(itemSchema[key]);
      } else if (itemSchema.containsKey("default")) {
        childSchema = Map<String, dynamic>.from(itemSchema["default"]);
      }

      if (childSchema == null) {
        continue;
      }

      final childTitle = StringService.titleFromKey(key);

      children.add(
        render(
          context: context,
          category: category,
          data: value,
          schema: childSchema,
          schemata: schemata,
          title: childTitle,
          setting: setting,
        ),
      );
    }

    return DescriptionWidget(title, ListWidget(children), setting);
  }

  static Widget _renderPath({
    required BuildContext context,
    required String category,
    required dynamic data,
    required Map<String, dynamic> schema,
    required Map<String, dynamic> schemata,
    required String title,
    required String setting,
  }) {
    final String? path;

    if (data is String) {
      path = data;
    } else if (data is Map && data["path"] is String) {
      path = data["path"];
    } else {
      path = null;
    }

    if (path == null || path.isEmpty) {
      return const SizedBox.shrink();
    }

    return FutureBuilder<dynamic>(
      future: JsonService.loadFromPath(path),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final dynamic loadedData = snapshot.data;

        final dynamic childSchema = schema["item"];

        if (childSchema == null) {
          if (loadedData is Map) {
            final String? category = loadedData["catId"];

            if (category != null && schemata.containsKey(category)) {
              return DescriptionWidget(
                title,
                DescriptionColumnWidget(
                  Map<String, dynamic>.from(loadedData),
                  schemata,
                  category: category,
                ),
                setting,
                initiallyExpanded: true,
              );
            }
          }

          return const SizedBox.shrink();
        }

        return render(
          context: context,
          category: category,
          data: loadedData,
          schema: Map<String, dynamic>.from(childSchema),
          schemata: schemata,
          title: title,
          setting: setting,
        );
      },
    );
  }

  static Widget _renderIcon({
    required dynamic data,
    required Map<String, dynamic> schema,
  }) {
    Icon icon;

    switch (schema["icon"]) {
      case "heart":
        icon = Icon(
          Icons.favorite,
          color: ColorService.getColor(4),
          size: TextStyleService.getFontSize(0),
        );
        break;

      default:
        icon = Icon(Icons.do_not_disturb, color: ColorService.getColor(4));
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        icon,
        Text(data.toString(), style: TextStyleService.getTextStyle(4, 2)),
      ],
    );
  }
}

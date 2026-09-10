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
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SchemaRenderService {
  static Widget render(
    WidgetRef ref, {
    required BuildContext context,
    required String category,
    required dynamic data,
    required Map<String, dynamic> schema,
    required Map<String, dynamic> schemata,
    required String title,
    String setting = "",
  }) {
    ref.watch(colorControllerProvider);
    ref.watch(textStyleControllerProvider);
    final colorController = ref.read(colorControllerProvider.notifier);
    final textStyleController = ref.read(textStyleControllerProvider.notifier);
    final String type = schema["type"];

    setting = (setting == "")
        ? "${StringService.slugify(title)}${category}DescriptionStyle"
        : setting;

    switch (type) {
      case "text":
        return DescriptionWidget(
          title,
          Text(data.toString(), style: textStyleController.getTextStyle(4, 4)),
          setting,
          optionList: ["popUp", "text", "page", "expand", "sheet", "static"],
        );

      case "list":
        return _renderList(
          ref,
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
          ref,
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
          ref,
          context: context,
          category: category,
          data: data,
          schema: schema,
          schemata: schemata,
          title: title,
          setting: setting,
        );

      case "table":
        return DescriptionWidget(
          title,
          TableWidget(data),
          setting,
          optionList: ["popUp", "page", "expand", "sheet", "static"],
        );

      case "checkList":
        return DescriptionWidget(
          title,
          CheckListWidget(data, schema["list"]),
          setting,
          optionList: ["popUp", "text", "page", "expand", "sheet", "static"],
        );

      case "icon":
        return _renderIcon(
          ref,
          title: title,
          setting: setting,
          data: data,
          schema: schema,
        );

      case "linkList":
        return _renderLinkList(
          ref,
          context: context,
          category: category,
          data: data,
          schema: schema,
          schemata: schemata,
          title: title,
          setting: setting,
        );

      case "bool":
        return DescriptionWidget(
          title,
          Checkbox(
            value: data,
            checkColor: colorController.getColor(4),
            activeColor: colorController.getColor(1),
            side: BorderSide(color: colorController.getColor(4), width: 1.5),
            onChanged: (_) {},
          ),
          setting,
          optionList: ["popUp", "text", "page", "expand", "sheet", "static"],
        );

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
            optionList: ["popUp", "text", "page", "expand", "sheet", "static"],
          );
        }

        return const SizedBox.shrink();
    }
  }

  static Widget _renderList(
    WidgetRef ref, {
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
          ref,
          context: context,
          category: category,
          data: item,
          schema: itemSchema,
          schemata: schemata,
          title: title,
          setting: "listEntry" + setting,
        ),
      );
    }

    return DescriptionWidget(
      title,
      ListWidget(children),
      setting,
      optionList: ["popUp", "page", "expand", "sheet", "static"],
    );
  }

  static Widget _renderMap(
    WidgetRef ref, {
    required BuildContext context,
    required String category,
    required dynamic data,
    required Map<String, dynamic> schema,
    required Map<String, dynamic> schemata,
    required String title,
    required String setting,
    void Function(void Function())? resetFunction,
  }) {
    final List<Widget> children = [];

    final itemSchema = Map<String, dynamic>.from(schema["item"]);

    for (final entry in data.entries) {
      final String key = entry.key;
      final dynamic value = entry.value;

      Map<String, dynamic>? childSchema;

      String name = "";

      if (itemSchema.containsKey(key)) {
        childSchema = Map<String, dynamic>.from(itemSchema[key]);
        name = key;
      } else if (itemSchema.containsKey("default")) {
        childSchema = Map<String, dynamic>.from(itemSchema["default"]);
        name = "default";
      }

      if (childSchema == null) {
        continue;
      }

      final childTitle = StringService.titleFromKey(key);

      children.add(
        render(
          ref,
          context: context,
          category: category,
          data: value,
          schema: childSchema,
          schemata: schemata,
          title: childTitle,
          setting: "mapItem" + name + setting,
        ),
      );
    }

    return DescriptionWidget(
      title,
      ListWidget(children),
      setting,
      optionList: ["popUp", "page", "expand", "sheet", "static"],
    );
  }

  static Widget _renderPath(
    WidgetRef ref, {
    required BuildContext context,
    required String category,
    required dynamic data,
    required Map<String, dynamic> schema,
    required Map<String, dynamic> schemata,
    required String title,
    required String setting,
    void Function(void Function())? resetFunction,
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

                optionList: ["popUp", "page", "expand", "sheet", "static"],
              );
            }
          }

          return const SizedBox.shrink();
        }
        return SizedBox.shrink();
      },
    );
  }

  static Widget _renderLinkList(
    WidgetRef ref, {
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
      future: JsonService.loadFromPath(data),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final dynamic loadedData = snapshot.data;

        return Column(
          children: [
            ...loadedData.keys.toList().map((el) {
              if (loadedData[el].containsKey("path")) {
                return _renderPath(
                  ref,
                  context: context,
                  category: category,
                  data: loadedData[el]["path"],
                  schema: schema["item"],
                  schemata: schemata,
                  title: StringService.titleFromKey(el),
                  setting: setting,
                );
              } else {
                return render(
                  ref,
                  context: context,
                  category: "features",
                  data: loadedData[el],
                  schema: {"type": "features"},
                  schemata: schemata,
                  title: StringService.titleFromKey(el),
                  setting: setting,
                );
              }
            }),
          ],
        );
      },
    );
  }

  static Widget _renderIcon(
    WidgetRef ref, {
    required String title,
    required String setting,
    void Function(void Function())? resetFunction,
    required dynamic data,
    required Map<String, dynamic> schema,
  }) {
    ref.watch(colorControllerProvider);
    ref.watch(textStyleControllerProvider);
    final colorController = ref.read(colorControllerProvider.notifier);
    final textStyleController = ref.read(textStyleControllerProvider.notifier);
    Icon icon;

    switch (schema["icon"]) {
      case "heart":
        icon = Icon(
          Icons.favorite,
          color: colorController.getColor(4),
          size: textStyleController.getFontSize(0) * 2,
        );
        break;

      default:
        icon = Icon(Icons.do_not_disturb, color: colorController.getColor(4));
    }

    return DescriptionWidget(
      title,
      Stack(
        alignment: Alignment.center,
        children: [
          icon,
          Text(data.toString(), style: textStyleController.getTextStyle(4, 2)),
        ],
      ),
      setting,
      initiallyExpanded: true,
      optionList: ["popUp", "text", "page", "expand", "sheet", "static"],
    );
  }
}

import 'package:dnd_app/services/color_service.dart';
import 'package:dnd_app/services/form_service.dart';
import 'package:dnd_app/services/json_service.dart';
import 'package:dnd_app/services/string_service.dart';
import 'package:dnd_app/services/text_style_service.dart';
import 'package:dnd_app/widgets/checklist.dart';
import 'package:dnd_app/widgets/description_column_widget.dart';
import 'package:dnd_app/widgets/description_widget.dart';
import 'package:dnd_app/widgets/form_text_field.dart';
import 'package:dnd_app/widgets/list_widget.dart';
import 'package:dnd_app/widgets/multiple_choice_field.dart';
import 'package:dnd_app/widgets/multiple_field.dart';
import 'package:dnd_app/widgets/radio_field.dart';
import 'package:dnd_app/widgets/selector_field.dart';
import 'package:dnd_app/widgets/table_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dnd_app/services/schema_render_service.dart';

class ConditionalField extends ConsumerStatefulWidget {
  const ConditionalField({
    super.key,
    this.title = "Input",
    required this.schema,
    required this.schemata,
    required this.path,
    this.formId = "form",
    this.setting = "DescriptionStyle",
    this.clickWidget,
    this.color = 3,
  });
  final String title;
  final Map<String, dynamic> schema;
  final Map<String, dynamic> schemata;
  final String path;
  final String formId;
  final String setting;
  final Widget? clickWidget;
  final int color;

  @override
  ConsumerState<ConditionalField> createState() {
    return _ConditionalFieldState();
  }
}

class _ConditionalFieldState extends ConsumerState<ConditionalField> {
  Widget conditionalWidget = SizedBox.shrink();
  String path = "";
  late final ColorController colorController;
  late final TextStyleController textStyleController;
  late final FormController formController;
  bool buildBool = true;
  @override
  void initState() {
    path = getPath();
    colorController = ref.read(colorControllerProvider.notifier);
    textStyleController = ref.read(textStyleControllerProvider.notifier);
    formController = ref.read(formControllerProvider(widget.formId).notifier);
  }

  String getPath() {
    String tempPath = "";
    if (widget.schema["field"].toString().startsWith("/.")) {
      tempPath = widget.path.toString();
      tempPath = tempPath.substring(0, tempPath.lastIndexOf("."));
      tempPath =
          tempPath + "." + widget.schema["field"].toString().substring(2);
    } else {
      tempPath = widget.schema["field"];
    }
    return tempPath;
  }

  dynamic readPath(dynamic cur, List<String> path) {
    for (final k in path) {
      if (cur is! Map) return null;
      cur = cur[k];
    }
    return cur;
  }

  @override
  Widget build(BuildContext context) {
    dynamic watch = ref.watch(
      formControllerProvider(
        widget.formId,
      ).select((m) => readPath(m, path.split("."))),
    );
    switch (widget.schema["operator"]) {
      case ">":
        buildBool =
            (int.tryParse(formController.getValue(path.split(".")) ?? "0") ??
                0) >
            widget.schema["value"];
      case "<":
        buildBool =
            (int.tryParse(formController.getValue(path.split(".")) ?? "0") ??
                0) <
            widget.schema["value"];
      case ">=":
        buildBool =
            (int.tryParse(formController.getValue(path.split(".")) ?? "0") ??
                0) >=
            widget.schema["value"];
      case "<=":
        buildBool =
            (int.tryParse(formController.getValue(path.split(".")) ?? "0") ??
                0) <=
            widget.schema["value"];
      case "=" || "==":
        buildBool =
            (int.tryParse(formController.getValue(path.split(".")) ?? "0") ??
                0) ==
            widget.schema["value"];
      case "in":
        if (formController.getValue(path.split(".")) is Map) {
          List<String> keys = formController
              .getValue(path.split("."))
              .keys
              .toList();
          buildBool = keys.contains(widget.schema["value"]);
        } else if (formController.getValue(path.split(".")) is List) {
          buildBool = formController
              .getValue(path.split("."))
              .contains(widget.schema["value"]);
        }
    }
    if (buildBool) {
      return SchemaRenderService.renderItem(
        ref,
        context,
        schema: widget.schema["item"],
        schemata: widget.schemata,
        title: widget.title,
        path: widget.path,
        setting: widget.title + widget.setting,
        color: widget.color,
      );
    } else {
      return SizedBox.shrink();
    }
  }
}

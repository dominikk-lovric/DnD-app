import 'package:dnd_app/services/color_service.dart';
import 'package:dnd_app/services/form_service.dart';
import 'package:dnd_app/services/json_service.dart';
import 'package:dnd_app/services/schema_render_service.dart';
import 'package:dnd_app/services/string_service.dart';
import 'package:dnd_app/services/text_style_service.dart';
import 'package:dnd_app/widgets/checklist.dart';
import 'package:dnd_app/widgets/description_column_widget.dart';
import 'package:dnd_app/widgets/description_widget.dart';
import 'package:dnd_app/widgets/list_widget.dart';
import 'package:dnd_app/widgets/multiple_choice_field.dart';
import 'package:dnd_app/widgets/radio_field.dart';
import 'package:dnd_app/widgets/selector_field.dart';
import 'package:dnd_app/widgets/table_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MultipleField extends ConsumerStatefulWidget {
  const MultipleField({
    super.key,
    required this.title,
    required this.schema,
    required this.schemata,
    required this.formId,
    required this.path,
    this.setting = "DescriptionStyle",
    this.color = 3,
  });
  final String title;
  final Map<String, dynamic> schema;
  final Map<String, dynamic> schemata;
  final String formId;
  final String path;
  final String setting;
  final int color;

  @override
  ConsumerState<MultipleField> createState() => _MultipleFieldState();
}

class _MultipleFieldState extends ConsumerState<MultipleField> {
  late final FormController formController;
  late final List<String> path;
  late final List<int> rowIds;
  late int nextId;

  @override
  void initState() {
    super.initState();
    formController = ref.read(formControllerProvider(widget.formId).notifier);
    path = widget.path.split(".");
    final existing = formController.getValue(path);
    if (existing is Map && existing.isNotEmpty) {
      rowIds = existing.keys.map((k) => int.parse(k.toString())).toList()
        ..sort();
    } else {
      final int start = widget.schema["startAmount"] ?? 1;
      rowIds = List.generate(start, (i) => i);
    }
    nextId = rowIds.isEmpty ? 0 : rowIds.last + 1;
    Future.microtask(() {
      if (!mounted) return;
      formController.initPath(path, <String, dynamic>{});
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(colorControllerProvider);
    ref.watch(textStyleControllerProvider);
    final colorController = ref.read(colorControllerProvider.notifier);
    final textStyleController = ref.read(textStyleControllerProvider.notifier);
    final unit = MediaQuery.sizeOf(context).height;
    return DescriptionWidget(
      widget.title,
      Column(
        spacing: MediaQuery.sizeOf(context).height / 72,
        children: [
          for (int i = 0; i < rowIds.length; i++)
            Container(
              key: ValueKey(rowIds[i]),
              padding: EdgeInsets.symmetric(
                horizontal: unit / 144,
                vertical: 0,
              ),
              decoration: BoxDecoration(
                color: colorController.getColor(widget.color == 2 ? 3 : 2),
                borderRadius: BorderRadius.circular(unit / 72),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (i != 0)
                    IconButton(
                      onPressed: () {
                        final id = rowIds[i];
                        formController.remove([...path, "$id"]);
                        setState(() => rowIds.removeAt(i));
                      },
                      icon: Icon(
                        Icons.cancel_outlined,
                        color: colorController.getColor(4),
                      ),
                    ),
                  Flexible(
                    child: SchemaRenderService.renderItem(
                      ref,
                      context,
                      schema: widget.schema["item"],
                      schemata: widget.schemata,
                      formId: widget.formId,
                      path: StringService.joinPath(widget.path, "${rowIds[i]}"),
                      color: widget.color,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      widget.title + "Multiple" + widget.setting,
      titleWidget: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.title, style: textStyleController.getTextStyle(5, 4)),
          IconButton(
            icon: Icon(
              Icons.add_box_outlined,
              color: colorController.getColor(4),
            ),
            onPressed: () => setState(() => rowIds.add(nextId++)),
          ),
        ],
      ),
    );
  }
}

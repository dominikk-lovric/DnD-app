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
import 'package:dnd_app/widgets/table_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';

class SelectorField extends ConsumerStatefulWidget {
  SelectorField({
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
  String setting;
  final Widget? clickWidget;
  final int color;

  @override
  ConsumerState<SelectorField> createState() => _SelectorFieldState();
}

class _SelectorFieldState extends ConsumerState<SelectorField> {
  late final ColorController colorController;
  late final TextStyleController textStyleController;
  late final FormController formController;
  late final List<String> valuePath;

  bool loaded = false;
  Map<String, dynamic> items = {};
  String current = "";
  List<dynamic> lastSources = [];
  final _eq = const DeepCollectionEquality();

  @override
  void initState() {
    super.initState();
    colorController = ref.read(colorControllerProvider.notifier);
    textStyleController = ref.read(textStyleControllerProvider.notifier);
    formController = ref.read(formControllerProvider(widget.formId).notifier);
    valuePath = [...widget.path.split("/"), "value"];
    loadItems();
  }

  Future<void> loadItems() async {
    Map<String, dynamic> item = {};
    item = await getItems();
    if (!mounted) return;
    final saved = formController.getValue(valuePath);
    final start = (saved is String && item.containsKey(saved))
        ? saved
        : item.keys.first;

    setState(() {
      items = item;
      current = start;
      loaded = true;
    });
    Future.microtask(() {
      if (!mounted) return;
      formController.setValue(valuePath, start);
    });
  }

  Future<Map<String, dynamic>> getItems() async {
    Map<String, dynamic> item = {};
    if (widget.schema["from"]["choices"] != null) {
      item = Map<String, dynamic>.from(
        widget.schema["from"]["choices"] ?? {"null": "null"},
      );
    } else {
      item =
          await (formController.getItem(widget.schema["from"])) ??
          {"null": "null"};
    }

    return item;
  }

  List<dynamic> getSources(dynamic form) {
    dynamic source;
    if (form["choice"] != null) {
      final sp = formController
          .getRelativePath(form["choice"], widget.path)
          .split("/");
      source = ref.watch(
        formControllerProvider(
          widget.formId,
        ).select((m) => formController.readPath(m, sp)),
      );
      print(sp);
      print(source);
      print("\n");
    }
    List<dynamic> selected = [];
    if (form["from"] != null) {
      selected = getSources(form["from"]);
    }
    return [source, ...selected];
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> sources = getSources(widget.schema["from"]);

    if (!_eq.equals(sources, lastSources)) {
      lastSources = List.of(sources);
      print("yess");

      Future.microtask(() async {
        if (!mounted) return;
        await getItems();
      });
    }

    widget.setting = widget.path + widget.setting;
    if (!loaded) {
      return Center(child: CircularProgressIndicator());
    }
    print(items);
    double unit = MediaQuery.sizeOf(context).height;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: unit / 72, vertical: unit / 72),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(unit / 72),
        color: colorController.getColor(widget.color == 2 ? 3 : 2),
      ),
      child: Row(
        spacing: unit / 72,
        children: [
          ...(widget.schema["item"] ?? {}).keys.toList().map((el) {
            return Flexible(
              child: SchemaRenderService.renderItem(
                ref,
                context,
                title: el,
                path: widget.path,
                schema: widget.schema["item"][el],
                schemata: widget.schemata,
                formId: widget.formId,
                color: widget.color,
              ),
            );
          }),
          Flexible(
            flex: 4,
            child: DropdownButtonFormField(
              icon: const SizedBox.shrink(),
              dropdownColor: colorController.getColor(widget.color),
              initialValue: current,
              decoration: InputDecoration(
                suffixIcon: null,
                filled: true,
                fillColor: colorController.getColor(widget.color),
                border: ShapedInputBorder(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.circular(
                      MediaQuery.sizeOf(context).height / 72,
                    ),
                  ),
                  borderSide: BorderSide.none,
                ),
              ),
              items: items.keys.toList().map((item) {
                String i = item;
                return DropdownMenuItem(
                  value: i,
                  child: Text(
                    items[item]["name"] != null
                        ? items[item]["name"].toString()
                        : item.toString(),
                    style: textStyleController.getTextStyle(6, 4),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value == null) return;
                formController.setValue(valuePath, value);
                setState(() => current = value.toString());
              },
            ),
          ),
          if (widget.schema["openItem"] != null)
            DescriptionWidget(
              items[current]["name"] != null
                  ? items[current]["name"].toString()
                  : current.toString(),
              FutureBuilder<dynamic>(
                future: JsonService.loadFromPath(
                  items[current]["json"] ?? items[current]["path"] ?? "",
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Text("Error loading data: ${snapshot.error}");
                  }
                  if (!snapshot.hasData) {
                    return const SizedBox.shrink();
                  }
                  final infoData = Map<String, dynamic>.from(
                    snapshot.data as Map,
                  );
                  return DescriptionColumnWidget(infoData, widget.schemata);
                },
              ),
              widget.schema["category"] ?? "" + "DescriptionStyle",
              clickWidget: Icon(
                Icons.open_in_new,
                color: colorController.getColor(4),
              ),
            ),
        ],
      ),
    );
  }
}

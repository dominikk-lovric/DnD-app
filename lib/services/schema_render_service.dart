import 'package:dnd_app/services/color_service.dart';
import 'package:dnd_app/services/form_service.dart';
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
    Widget? clickWidget,
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
          clickWidget: clickWidget,
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
          clickWidget: clickWidget,
        );

      case "checkList":
        return DescriptionWidget(
          title,
          CheckListWidget(data, schema["list"]),
          setting,
          optionList: ["popUp", "text", "page", "expand", "sheet", "static"],
          clickWidget: clickWidget,
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
          clickWidget: clickWidget,
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
            clickWidget: clickWidget,
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

  static Widget renderForm(
    ref,
    context, {
    String title = "Form",
    String path = "",
    required Map<String, dynamic> schema,
    required Map<String, dynamic> schemata,
    String setting = "DescriptionStyle",
    Widget? clickWidget,
    String formId = "form",
  }) {
    ref.watch(colorControllerProvider);
    ref.watch(textStyleControllerProvider);
    final colorController = ref.read(colorControllerProvider.notifier);
    final formController = ref.read(formControllerProvider(formId).notifier);
    return DescriptionWidget(
      title,
      Form(
        child: Column(
          children: [
            ...schema["item"].keys.toList().map((el) {
              return renderItem(
                ref,
                context,
                schema: schema["item"][el],
                schemata: schemata,
                title: el,
                path: path,
                formId: formId,
              );
            }),
            Row(
              spacing: MediaQuery.sizeOf(context).height / 72,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    formController.reset();
                    Navigator.pop(context);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: colorController.getColor(4),
                    backgroundColor: colorController.getColor(0),
                  ),
                  child: Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: colorController.getColor(4),
                    backgroundColor: colorController.getColor(0),
                  ),
                  child: Text("Submit"),
                ),
              ],
            ),
          ],
        ),
      ),
      title + setting,
      clickWidget: clickWidget,
      optionList: ["page", "popUp"],
      backgroundChoice: false,
      closeButton: false,
    );
  }

  static Widget renderItem(
    ref,
    context, {
    String title = "",
    String path = "",
    required Map<String, dynamic> schema,
    required Map<String, dynamic> schemata,
    String formId = "form",
    String setting = "DescriptionStyle",
    Widget? clickWidget,
    int color = 3,
  }) {
    final here = StringService.joinPath(path, title);
    switch (schema["type"]) {
      case "form":
        return renderForm(
          ref,
          context,
          title: title,
          path: here,
          schema: schema,
          schemata: schemata,
          clickWidget: clickWidget,
          setting: title + "." + setting,
          formId: formId,
        );
      case "textInput":
        return renderTextInput(
          ref,
          context,
          title: title,
          schema: schema,
          schemata: schemata,
          setting: title + setting,
          color: color,
          path: here,
          formId: formId,
        );
      case "column":
        return DescriptionWidget(
          title,
          Column(
            children: [
              ...schema["item"].keys.toList().map((el) {
                return renderItem(
                  ref,
                  context,
                  title: el,
                  path: here,
                  schema: schema["item"][el],
                  schemata: schemata,
                  formId: formId,
                );
              }),
            ],
          ),
          "Column" + setting,
          titleLevel: 5,
        );
      case "wrap":
        return DescriptionWidget(
          title,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            spacing: MediaQuery.sizeOf(context).height / 144,
            children: [
              ...schema["item"].keys.toList().map((el) {
                return Expanded(
                  child: renderItem(
                    ref,
                    context,
                    title: el,
                    path: here,
                    schema: schema["item"][el],
                    schemata: schemata,
                    setting: "Wrap" + setting,
                    color: 2,
                    formId: formId,
                  ),
                );
              }),
            ],
          ),
          title + setting,
          titleLevel: 5,
        );
      case "multipleSelect":
        return renderMultipleSelecor(
          ref,
          context,
          title: title,
          path: here,
          schema: schema,
          schemata: schemata,
          setting: "Multiple" + setting,
          formId: formId,
          color: 2,
        );
      case "selector":
        return DescriptionWidget(
          title,
          SelectorField(
            title: title,
            path: here,
            schema: schema,
            schemata: schemata,
            setting: "Selector" + setting,
            formId: formId,
          ),
          title + "Selector" + setting,
          titleLevel: 5,
        );
      case "radio":
        return RadioField(
          schema: schema,
          schemata: schemata,
          formId: formId,
          setting: title + setting,
          title: title,
          path: here,
        );
      default:
        return Text(title);
    }
  }

  static Widget renderMultipleSelecor(
    ref,
    context, {
    String title = "Input",
    required Map<String, dynamic> schema,
    required Map<String, dynamic> schemata,
    String formId = "form",
    String setting = "DescriptionStyle",
    Widget? clickWidget,
    String path = "",
    int color = 3,
  }) {
    return MultipleSelectField(
      title: title,
      schema: schema,
      schemata: schemata,
      formId: formId,
      path: path,
      setting: setting,
      color: color,
    );
  }

  static Widget renderTextInput(
    ref,
    context, {
    String title = "Input",
    required Map<String, dynamic> schema,
    required Map<String, dynamic> schemata,
    String path = "",
    String formId = "form",
    String setting = "DescriptionStyle",
    Widget? clickWidget,
    int color = 2,
  }) {
    return DescriptionWidget(
      title,
      FormTextField(
        title: title,
        formId: formId,
        path: path,
        initialValue: (schema["initialValue"] ?? "").toString(),
        color: color,
      ),
      title + setting,
    );
  }
}

class FormTextField extends ConsumerStatefulWidget {
  const FormTextField({
    super.key,
    required this.title,
    required this.formId,
    required this.path,
    this.initialValue = "",
    this.color = 2,
  });
  final String title;
  final String formId;
  final String path;
  final String initialValue;
  final int color;

  @override
  ConsumerState<FormTextField> createState() => _FormTextFieldState();
}

class _FormTextFieldState extends ConsumerState<FormTextField> {
  late final FormController formController;
  late final List<String> path;
  late final String startText;

  @override
  void initState() {
    super.initState();
    formController = ref.read(formControllerProvider(widget.formId).notifier);
    path = widget.path.split(".");
    final saved = formController.getValue(path);
    startText = saved is String ? saved : widget.initialValue;
    Future.microtask(() {
      if (!mounted) return;
      formController.initPath(path, widget.initialValue);
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(colorControllerProvider);
    ref.watch(textStyleControllerProvider);
    final colorController = ref.read(colorControllerProvider.notifier);
    final textStyleController = ref.read(textStyleControllerProvider.notifier);
    return TextFormField(
      scrollPadding: EdgeInsets.all(0),
      style: textStyleController.getTextStyle(6, 4),
      initialValue: startText,
      decoration: InputDecoration(
        label: Text(
          widget.title,
          style: textStyleController.getTextStyle(6, 5),
        ),
        filled: true,
        fillColor: colorController.getColor(widget.color),
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.all(
            Radius.circular(MediaQuery.sizeOf(context).height / 72),
          ),
        ),
      ),
      cursorColor: colorController.getColor(1),
      onChanged: (value) => formController.setValue(path, value),
    );
  }
}

class MultipleSelectField extends ConsumerStatefulWidget {
  const MultipleSelectField({
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
  ConsumerState<MultipleSelectField> createState() =>
      _MultipleSelectFieldState();
}

class _MultipleSelectFieldState extends ConsumerState<MultipleSelectField> {
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
        children: [
          for (int i = 0; i < rowIds.length; i++)
            Container(
              key: ValueKey(rowIds[i]),
              padding: EdgeInsets.symmetric(
                horizontal: unit / 144,
                vertical: 0,
              ),
              decoration: BoxDecoration(
                color: colorController.getColor(widget.color),
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
                    child: SelectorField(
                      schema: widget.schema["item"],
                      schemata: widget.schemata,
                      formId: widget.formId,
                      path: StringService.joinPath(widget.path, "${rowIds[i]}"),
                      color: 3,
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

class SelectorField extends ConsumerStatefulWidget {
  const SelectorField({
    super.key,
    this.title = "Input",
    required this.schema,
    required this.schemata,
    required this.path,
    this.formId = "form",
    this.setting = "DescriptionStyle",
    this.clickWidget,
    this.color = 2,
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

  @override
  void initState() {
    super.initState();
    colorController = ref.read(colorControllerProvider.notifier);
    textStyleController = ref.read(textStyleControllerProvider.notifier);
    formController = ref.read(formControllerProvider(widget.formId).notifier);
    valuePath = [...widget.path.split("."), "value"];
    loadItems();
  }

  Future<void> loadItems() async {
    Map<String, dynamic> item = {};
    if (widget.schema["path"] != null) {
      item = await JsonService.loadFromPath(widget.schema["path"]);
    } else {
      item = Map<String, dynamic>.from(
        widget.schema["choices"] ?? {"null": "null"},
      );
    }
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

  @override
  Widget build(BuildContext context) {
    if (!loaded) {
      return Center(child: CircularProgressIndicator());
    }
    return Row(
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
                  items[item]["name"],
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
            items[current]["name"].toString(),
            FutureBuilder<dynamic>(
              future: JsonService.loadFromPath(items[current]["json"]),
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
    );
  }
}

class RadioField extends ConsumerStatefulWidget {
  RadioField({
    super.key,
    this.title = "Radio",
    required this.schema,
    required this.schemata,
    this.formId = "form",
    this.setting = "DescriptionStyle",
    this.clickWidget,
    this.path = "",
    this.color = 2,
  });
  final String title;
  final Map<String, dynamic> schema;
  final Map<String, dynamic> schemata;
  final String formId;
  final String setting;
  final Widget? clickWidget;
  String path;
  final int color;

  @override
  ConsumerState<RadioField> createState() => _RadioFieldState();
}

class _RadioFieldState extends ConsumerState<RadioField> {
  List<dynamic> options = [];
  bool loaded = false;
  late final ColorController colorController;
  late final TextStyleController textStyleController;
  late final FormController formController;

  List<String>? sourcePath;
  dynamic lastSource;
  bool first = true;
  int loadId = 0;

  dynamic readPath(dynamic cur, List<String> path) {
    for (final k in path) {
      if (cur is! Map) return null;
      cur = cur[k];
    }
    return cur;
  }

  @override
  initState() {
    super.initState();
    colorController = ref.read(colorControllerProvider.notifier);
    textStyleController = ref.read(textStyleControllerProvider.notifier);
    formController = ref.read(formControllerProvider(widget.formId).notifier);

    final src = widget.schema["from"]["source"];
    if (src != null) {
      final sp = src is String ? src.split(".") : List<String>.from(src);
      final root = widget.path.split(".").first;
      sourcePath = sp.first == root ? sp : [root, ...sp];
    }
  }

  Future<void> getOptions(dynamic source) async {
    final id = ++loadId;
    Map<String, dynamic> from = widget.schema["from"];
    List<dynamic> temp = [];
    if (from["options"] != null) {
      temp = from["options"];
    } else {
      Map<String, dynamic> path = await JsonService.loadFromPath(from["path"]);
      if (from["source"] != null) {
        if (source is Map) source = source["value"];
        source ??= path.keys.first;
        path = await JsonService.loadFromPath(path[source]["json"]);
        if (from["item"] != null) {
          temp = path[from["item"]];
        }
      } else {
        temp = path.entries.toList();
      }
    }
    if (!mounted || id != loadId) return;
    setState(() {
      options = temp;
      loaded = true;
    });

    Future.microtask(() {
      if (!mounted || options.isEmpty) return;
      final labels = options.map((e) => e.toString()).toList();
      final valuePath = widget.path.split(".");
      if (!labels.contains(formController.getValue(valuePath))) {
        formController.setValue(valuePath, labels.first);
      }
    });
  }

  @override
  @override
  Widget build(BuildContext context) {
    final sp = sourcePath;
    final dynamic source = sp == null
        ? null
        : ref.watch(
            formControllerProvider(
              widget.formId,
            ).select((m) => readPath(m, sp)),
          );

    if (first || source != lastSource) {
      first = false;
      lastSource = source;
      Future.microtask(() => getOptions(source));
    }
    if (!loaded) {
      return const Center(child: CircularProgressIndicator());
    }

    final valuePath = widget.path.split(".");

    final selected = ref.watch(
      formControllerProvider(widget.formId).select((m) {
        dynamic cur = m;
        for (final k in valuePath) {
          if (cur is! Map) return null;
          cur = cur[k];
        }
        return cur;
      }),
    );

    final unit = MediaQuery.sizeOf(context).height;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: unit / 144,
        vertical: unit / 72,
      ),
      decoration: BoxDecoration(
        color: colorController.getColor(widget.color),
        borderRadius: BorderRadius.circular(unit / 72),
      ),
      child: Column(
        spacing: unit / 72,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "From " + widget.title,
            style: textStyleController.getTextStyle(5, 4),
          ),
          ...options.map((el) {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: unit / 144),
              decoration: BoxDecoration(
                color: colorController.getColor((widget.color == 2) ? 3 : 2),
                borderRadius: BorderRadius.circular(unit / 72),
              ),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  formController.setValue(valuePath, el.toString());
                },
                child: Row(
                  children: [
                    Icon(
                      el.toString() == selected
                          ? Icons.radio_button_on
                          : Icons.radio_button_off,
                      color: colorController.getColor(4),
                    ),
                    Expanded(
                      child: Text(
                        elToString(el),
                        style: textStyleController.getTextStyle(5, 4),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  String elToString(dynamic item) {
    if (item is List) {
      return StringService.choicesFromString(item, "and");
    } else {
      return item.toString();
    }
  }
}

import 'package:dnd_app/services/color_service.dart';
import 'package:dnd_app/services/form_service.dart';
import 'package:dnd_app/services/json_service.dart';
import 'package:dnd_app/services/string_service.dart';
import 'package:dnd_app/services/text_style_service.dart';
import 'package:dnd_app/widgets/description_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MultipleChoiceField extends ConsumerStatefulWidget {
  MultipleChoiceField({
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
  ConsumerState<MultipleChoiceField> createState() =>
      _MultipleChoiceFieldState();
}

class _MultipleChoiceFieldState extends ConsumerState<MultipleChoiceField> {
  List<dynamic> options = [];
  List<dynamic> baseSelected = [];
  bool loaded = false;
  late final ColorController colorController;
  late final TextStyleController textStyleController;
  late final FormController formController;
  int numOfOptions = 0;

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

  Future<void> getOptions() async {
    List<dynamic> selectedTmp = [];
    final id = ++loadId;
    List<dynamic> temp = [];
    int num = 0;
    temp = await loadItems(widget.schema["from"]);
    num = await loadNumOfOptions(widget.schema["from"]);
    for (final key in widget.schema["selected"].keys.toList()) {
      selectedTmp.addAll(await loadItems(widget.schema["selected"][key]));
    }

    if (!mounted || id != loadId) return;
    setState(() {
      options = temp;
      loaded = true;
      numOfOptions = num;
      baseSelected = selectedTmp;
    });
  }

  @override
  @override
  Widget build(BuildContext context) {
    final sp = sourcePath;
    final dynamic source = sp == null
        ? null
        : ref.watch(formControllerProvider(widget.formId).select((m) => m));

    if (first || source != lastSource) {
      first = false;
      lastSource = source;
      Future.microtask(() => getOptions());
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

    return DescriptionWidget(
      widget.title,
      Container(
        padding: EdgeInsets.symmetric(
          horizontal: unit / 72,
          vertical: unit / 72,
        ),
        decoration: BoxDecoration(
          color: colorController.getColor(widget.color),
          borderRadius: BorderRadius.circular(unit / 72),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Choose " + numOfOptions.toString() + ":",
              style: textStyleController.getTextStyle(5, 4),
            ),
            ...options.map((el) {
              return Material(
                color: Colors.transparent,
                child: GestureDetector(
                  onTap: baseSelected.contains(el)
                      ? () {}
                      : (() {
                          _toggleCheckbox(el);
                          setState(() {});
                        }),
                  child: ListTile(
                    leading: Checkbox(
                      splashRadius: 0,
                      value:
                          (formController.getValue(
                            (widget.path + "." + el).split("."),
                          ) ??
                          false || baseSelected.contains(el)),
                      checkColor: colorController.getColor(widget.color),
                      activeColor: baseSelected.contains(el)
                          ? colorController.getColor(6)
                          : colorController.getColor(4),
                      side: BorderSide(
                        color: baseSelected.contains(el)
                            ? colorController.getColor(6)
                            : colorController.getColor(4),
                        width: 1.5,
                      ),
                      onChanged: (_) {
                        _toggleCheckbox(el);
                      },
                    ),
                    title: Text(
                      elToString(el),
                      style: textStyleController.getTextStyle(
                        5,
                        baseSelected.contains(el) ? 6 : 4,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
      widget.setting,
      titleLevel: 5,
    );
  }

  void _toggleCheckbox(String el) {
    final path = (widget.path + "." + el).split(".");
    final value = formController.getValue(path);

    final isChecked = value == true || value == "true";

    if (isChecked) {
      formController.remove(path);
    } else {
      if ((formController.getValue(widget.path.split(".")) ?? {}).keys
              .toList()
              .length <
          numOfOptions) {
        formController.setValue(path, true);
      }
    }
  }

  Future<dynamic> loadItems(Map<String, dynamic> from) async {
    List<dynamic> temp = [];
    if (from["options"] != null) {
      temp = from["options"];
    } else {
      Map<String, dynamic> path = await JsonService.loadFromPath(from["path"]);
      dynamic source = formController.getValue(from["source"].split("."));
      if (from["source"] != null) {
        if (source is Map) source = source["value"];
        source ??= path.keys.first;
        path = await JsonService.loadFromPath(path[source]["json"]);
        if (from["item"] != null) {
          temp = readPath(path, from["item"].split("."));
        }
      } else {
        temp = path.entries.toList();
      }
    }
    return temp;
  }

  Future<int> loadNumOfOptions(Map<String, dynamic> from) async {
    int num = 0;
    Map<String, dynamic> path = await JsonService.loadFromPath(from["path"]);
    if (from["source"] != null) {
      dynamic source = formController.getValue(from["source"].split("."));
      if (source is Map) source = source["value"];
      source ??= path.keys.first;
      path = await JsonService.loadFromPath(path[source]["json"]);
      if (from["numOfOptions"] != null) {
        num = readPath(path, from["numOfOptions"].split("."));
      }
    }
    return num;
  }

  String elToString(dynamic item) {
    if (item is List) {
      return StringService.choicesFromString(item, "and");
    } else {
      return item.toString();
    }
  }
}

import 'package:dnd_app/services/color_service.dart';
import 'package:dnd_app/services/form_service.dart';
import 'package:dnd_app/services/json_service.dart';
import 'package:dnd_app/services/string_service.dart';
import 'package:dnd_app/services/text_style_service.dart';
import 'package:dnd_app/widgets/description_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';

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
  List<dynamic> lastSources = [];
  bool first = true;
  int loadId = 0;

  final _eq = const DeepCollectionEquality();

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
    getOptions();
  }

  Future<void> getOptions() async {
    List<dynamic> selectedTmp = [];
    final id = ++loadId;
    List<dynamic> temp = [];
    int num = 0;
    temp = await formController.getItem(widget.schema["from"]);
    if (widget.schema["numOfOptions"] is Map) {
      num = await formController.getItem(widget.schema["numOfOptions"]);
    } else {
      num = widget.schema["numOfOptions"] ?? 0;
    }
    for (final key in widget.schema["selected"].keys.toList()) {
      selectedTmp.addAll(
        await formController.getItem(widget.schema["selected"][key]),
      );
    }

    if (!mounted || id != loadId) return;
    setState(() {
      options = temp;
      loaded = true;
      numOfOptions = num;
      baseSelected = selectedTmp;
    });
  }

  List<dynamic> getSources(dynamic form, int j) {
    dynamic source;
    if (form["choice"] != null) {
      final sp = form["choice"] != null ? form["choice"].split("/") : [];
      source = ref.watch(
        formControllerProvider(widget.formId).select((m) => readPath(m, sp)),
      );
    }
    List<dynamic> selected = [];
    if (form["from"] != null) {
      selected = getSources(form["from"], j + 1);
    }
    return [source, ...selected];
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> sources = getSources(widget.schema["from"], 0);

    for (final k in widget.schema["selected"].keys.toList()) {
      sources.addAll(getSources(widget.schema["selected"][k], 0));
    }

    if (!_eq.equals(sources, lastSources)) {
      final isFirst = first;
      first = false;

      final oldOptions = List<dynamic>.of(options);
      lastSources = List.of(sources);

      Future.microtask(() async {
        if (!mounted) return;

        if (!isFirst) {
          for (final el in oldOptions) {
            final removePath = [...widget.path.split("/"), el.toString()];
            if (formController.getValue(removePath) != null) {
              formController.remove(removePath);
            }
          }
        }

        await getOptions();
      });
    }

    if (!loaded) {
      return const Center(child: CircularProgressIndicator());
    }

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
                            (widget.path + "/" + el).split("/"),
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
    final path = (widget.path + "/" + el).split("/");
    final value = formController.getValue(path);

    final isChecked = value == true || value == "true";

    if (isChecked) {
      formController.remove(path);
    } else {
      if ((formController.getValue(widget.path.split("/")) ?? {}).keys
              .toList()
              .length <
          numOfOptions) {
        formController.setValue(path, true);
      }
    }
  }

  String elToString(dynamic item) {
    if (item is List) {
      return StringService.choicesFromString(item, "and");
    } else {
      return item.toString();
    }
  }
}

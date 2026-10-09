import 'package:dnd_app/services/color_service.dart';
import 'package:dnd_app/services/form_service.dart';
import 'package:dnd_app/services/json_service.dart';
import 'package:dnd_app/services/string_service.dart';
import 'package:dnd_app/services/text_style_service.dart';
import 'package:dnd_app/widgets/description_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';

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
    this.row = false,
  });
  final String title;
  final Map<String, dynamic> schema;
  final Map<String, dynamic> schemata;
  final String formId;
  final String setting;
  final Widget? clickWidget;
  String path;
  final int color;
  bool row;

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

  List<dynamic> lastSources = [];
  bool first = true;
  int loadId = 0;

  final _eq = const DeepCollectionEquality();

  @override
  initState() {
    super.initState();
    colorController = ref.read(colorControllerProvider.notifier);
    textStyleController = ref.read(textStyleControllerProvider.notifier);
    formController = ref.read(formControllerProvider(widget.formId).notifier);

    if (widget.schema["row"] == true) {
      widget.row = true;
    }
    getOptions();
  }

  Future<void> getOptions() async {
    final id = ++loadId;
    Map<String, dynamic> from = widget.schema["from"];
    List<dynamic> temp = [];
    if (from["options"] != null) {
      temp = from["options"];
    } else {
      temp = await formController.getItem(from);
    }
    if (!mounted || id != loadId) return;
    setState(() {
      options = temp;
      loaded = true;
    });

    Future.microtask(() {
      if (!mounted || options.isEmpty) return;
      final labels = options.map((e) => e.toString()).toList();
      final valuePath = widget.path.split("/");
      if (!labels.contains(formController.getValue(valuePath))) {
        formController.setValue(valuePath, labels.first);
      }
    });
  }

  List<dynamic> getSources(dynamic form, int j) {
    dynamic source;
    if (form["choice"] != null) {
      final sp = form["choice"] != null ? form["choice"].split("/") : [];
      source = ref.watch(
        formControllerProvider(
          widget.formId,
        ).select((m) => formController.readPath(m, sp)),
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

    if (!_eq.equals(sources, lastSources)) {
      lastSources = List.of(sources);
      Future.microtask(() async {
        formController.remove(widget.path.split("/"));
        await getOptions();
      });
    }
    if (!loaded) {
      return const Center(child: CircularProgressIndicator());
    }

    final valuePath = widget.path.split("/");

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
      key: Key(widget.setting),
      "From " + widget.title,
      Column(
        spacing: unit / 72,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          widget.row
              ? Wrap(
                  alignment: WrapAlignment.center,
                  spacing: unit / 72,
                  children: [
                    ...options.map((el) {
                      return Container(
                        width:
                            el.toString().length *
                                textStyleController.getFontSize(5) +
                            unit / 30 +
                            unit / 72 * 5,
                        padding: EdgeInsets.symmetric(horizontal: unit / 144),
                        decoration: BoxDecoration(
                          color: (el.toString() == selected)
                              ? colorController.getColor(
                                  (widget.color == 2) ? 3 : 2,
                                )
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(unit / 72),
                        ),
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            formController.setValue(valuePath, el.toString());
                          },

                          child: ListTile(
                            leading: Padding(
                              padding: EdgeInsetsGeometry.directional(
                                end: unit / 72,
                              ),
                              child: Icon(
                                size: unit / 30,
                                el.toString() == selected
                                    ? Icons.radio_button_on
                                    : Icons.radio_button_off,
                                color: colorController.getColor(4),
                              ),
                            ),
                            title: Text(
                              elToString(el),
                              style: textStyleController.getTextStyle(5, 4),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                )
              : Column(
                  spacing: unit / 72,
                  children: [
                    ...options.map((el) {
                      return Container(
                        padding: EdgeInsets.symmetric(horizontal: unit / 144),
                        decoration: BoxDecoration(
                          color: (el.toString() == selected)
                              ? colorController.getColor(
                                  (widget.color == 2) ? 3 : 2,
                                )
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(unit / 72),
                        ),
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            formController.setValue(valuePath, el.toString());
                          },
                          child: ListTile(
                            leading: Padding(
                              padding: EdgeInsetsGeometry.directional(
                                end: unit / 72,
                              ),
                              child: Icon(
                                size: unit / 30,
                                el.toString() == selected
                                    ? Icons.radio_button_on
                                    : Icons.radio_button_off,
                                color: colorController.getColor(4),
                              ),
                            ),
                            title: Text(
                              elToString(el),
                              style: textStyleController.getTextStyle(5, 4),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
        ],
      ),
      widget.setting,
      titleLevel: 5,
      bgColor: widget.color,
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

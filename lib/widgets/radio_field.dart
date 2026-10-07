import 'package:dnd_app/services/color_service.dart';
import 'package:dnd_app/services/form_service.dart';
import 'package:dnd_app/services/json_service.dart';
import 'package:dnd_app/services/string_service.dart';
import 'package:dnd_app/services/text_style_service.dart';
import 'package:dnd_app/widgets/description_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

    if (widget.schema["from"]["row"] == true) {
      widget.row = true;
    }

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
          temp = readPath(path, from["item"].split("."));
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

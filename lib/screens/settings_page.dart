import 'package:dnd_app/services/json_service.dart';
import 'package:dnd_app/services/string_service.dart';
import 'package:dnd_app/services/text_style_service.dart';
import 'package:dnd_app/widgets/color_selector_widget.dart';
import 'package:dnd_app/widgets/description_widget.dart';
import 'package:flutter/material.dart';

import 'package:dnd_app/services/settings_service.dart';
import 'package:dnd_app/services/color_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() {
    return SettingsPageState();
  }
}

class SettingsPageState extends ConsumerState<SettingsPage> {
  late final SettingsController settingsController;
  late final ColorController colorController;
  late final TextStyleController textStyleController;
  Map<String, dynamic>? schemata;
  List<String>? categories;
  List<String> options = ["popUp", "expand", "page", "text", "sheet", "static"];

  @override
  initState() {
    super.initState();

    settingsController = ref.read(settingsControllerProvider.notifier);
    colorController = ref.read(colorControllerProvider.notifier);
    textStyleController = ref.read(textStyleControllerProvider.notifier);
    loadSchemata();
  }

  Future<void> loadSchemata() async {
    final json = JsonService("schemata");
    Map<String, dynamic> items = await json.loadData();
    setState(() {
      schemata = items;
      categories = items.keys.toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (categories == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    List<String> colorList = colorController.getColorNames();
    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.escape) {
          Navigator.pop(context);
          return KeyEventResult.handled;
        }

        return KeyEventResult.ignored;
      },
      child: Scaffold(
        backgroundColor: colorController.getColor(2),
        appBar: AppBar(
          backgroundColor: colorController.getColor(0),
          toolbarHeight: settingsController.getSetting("headerHeight"),
        ),
        body: Padding(
          padding: EdgeInsetsGeometry.directional(
            bottom: settingsController.getSetting("bottomPadding"),
          ),
          child: Padding(
            padding: EdgeInsetsGeometry.symmetric(vertical: 20, horizontal: 30),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Wrap(
                    direction: Axis.horizontal,

                    spacing: 10,
                    runSpacing: 20,
                    children: [
                      ...colorList.map((el) {
                        return Container(
                          child: Padding(
                            padding: EdgeInsetsGeometry.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            child: ColorSelectorWidget(colorList.indexOf(el)),
                          ),
                        );
                      }),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

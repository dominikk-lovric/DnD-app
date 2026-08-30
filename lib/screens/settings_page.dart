import 'package:dnd_app/services/json_service.dart';
import 'package:dnd_app/widgets/color_selector_widget.dart';
import 'package:dnd_app/widgets/description_style_selector_widget.dart';
import 'package:dnd_app/widgets/description_widget.dart';
import 'package:flutter/material.dart';

import 'package:dnd_app/services/settings_service.dart';
import 'package:dnd_app/services/color_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return SettingsPageState();
  }
}

class SettingsPageState extends State<SettingsPage> {
  Map<String, dynamic>? categoryData;
  List<String>? categories;

  @override
  initState() {
    super.initState();

    loadCategories();
  }

  Future<void> loadCategories() async {
    final json = JsonService("categories");
    Map<String, dynamic> items = await json.loadData();
    setState(() {
      categoryData = items;
      categories = items.keys.toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (categories == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    List<String> colorList = ColorService.getColorNames();
    return AnimatedBuilder(
      animation: ColorService.themeNotifier,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: ColorService.getColor(2),
          appBar: AppBar(
            backgroundColor: ColorService.getColor(0),
            toolbarHeight: SettingsService.getSetting("headerHeight"),
          ),
          body: Padding(
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
                  Column(
                    children: [
                      ...(categories ?? []).map((el) {
                        Map<String, dynamic> data =
                            (categoryData ?? {"el": ""})[el];
                        return DescriptionWidget(
                          el,
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ...data["items"].map((e) {
                                return DescriptionStyleSelectorWidget(e, el);
                              }),
                            ],
                          ),
                          "expand",
                        );
                      }),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

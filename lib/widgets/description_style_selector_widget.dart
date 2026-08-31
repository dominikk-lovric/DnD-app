import 'package:dnd_app/services/color_service.dart';
import 'package:dnd_app/services/json_service.dart';
import 'package:dnd_app/services/settings_service.dart';
import 'package:dnd_app/services/string_service.dart';
import 'package:dnd_app/services/text_style_service.dart';
import 'package:dnd_app/widgets/description_widget.dart';
import 'package:flutter/material.dart';

class DescriptionStyleSelectorWidget extends StatefulWidget {
  String category;
  Map<String, dynamic> data;
  DescriptionStyleSelectorWidget(this.category, this.data, {super.key});

  @override
  State<StatefulWidget> createState() {
    return DescriptionStyleSelectorWidgetState();
  }
}

class DescriptionStyleSelectorWidgetState
    extends State<DescriptionStyleSelectorWidget> {
  final List<String> options = [
    "popUp",
    "expand",
    "page",
    "text",
    "sheet",
    "static",
  ];

  late List<GlobalKey<DescriptionWidgetState>> keyList;

  @override
  void initState() {
    super.initState();

    keyList = List.generate(
      widget.data["items"].length + 1,
      (_) => GlobalKey<DescriptionWidgetState>(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DescriptionWidget(
      StringService.titleFromKey(widget.category),
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DescriptionWidget(
            key: keyList[0],
            titleLevel: 3,
            StringService.titleFromKey(widget.category),
            Column(
              children: [
                ...options.map((option) {
                  final String setting =
                      SettingsService.getSetting(
                        StringService.slugify(widget.category) +
                            StringService.slugify(widget.category) +
                            "DescriptionStyle".toString(),
                      ) ??
                      SettingsService.getSetting("globalDescriptionStyle");
                  return GestureDetector(
                    onTap: () async {
                      await keyList[0].currentState?.close();

                      print(
                        StringService.slugify(widget.category) +
                            "DescriptionStyle".toString(),
                      );
                      await SettingsService.setSetting(
                        StringService.slugify(widget.category) +
                            "DescriptionStyle".toString(),
                        option,
                      );

                      if (mounted) {
                        setState(() {});
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: setting == option
                            ? ColorService.getColor(1)
                            : Colors.transparent,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      child: Text(
                        StringService.titleFromKey(option),
                        style: TextStyleService.getTextStyle(3, 4),
                      ),
                    ),
                  );
                }),
              ],
            ),
            "expand",
            initiallyExpanded: false,
          ),
          ...widget.data["items"].asMap().entries.map((entry) {
            final int index = (entry.key) + 1;
            final String e = entry.value;

            return DescriptionWidget(
              key: keyList[index],
              titleLevel: 3,
              StringService.titleFromKey(e),
              Column(
                children: [
                  ...options.map((option) {
                    final String setting =
                        SettingsService.getSetting(
                          StringService.slugify(e) +
                              StringService.slugify(widget.category) +
                              "DescriptionStyle".toString(),
                        ) ??
                        SettingsService.getSetting("globalDescriptionStyle");
                    return GestureDetector(
                      onTap: () async {
                        await keyList[index].currentState?.close();

                        print(
                          StringService.slugify(e) +
                              StringService.slugify(widget.category) +
                              "DescriptionStyle".toString(),
                        );
                        await SettingsService.setSetting(
                          StringService.slugify(e) +
                              StringService.slugify(widget.category) +
                              "DescriptionStyle".toString(),
                          option,
                        );

                        if (mounted) {
                          setState(() {});
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: setting == option
                              ? ColorService.getColor(1)
                              : Colors.transparent,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        child: Text(
                          StringService.titleFromKey(option),
                          style: TextStyleService.getTextStyle(3, 4),
                        ),
                      ),
                    );
                  }),
                ],
              ),
              "expand",
              initiallyExpanded: false,
            );
          }),
        ],
      ),
      "expand",
      initiallyExpanded: false,
    );
  }
}

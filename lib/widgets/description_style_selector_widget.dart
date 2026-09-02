import 'package:dnd_app/services/color_service.dart';
import 'package:dnd_app/services/json_service.dart';
import 'package:dnd_app/services/settings_service.dart';
import 'package:dnd_app/services/string_service.dart';
import 'package:dnd_app/services/text_style_service.dart';
import 'package:dnd_app/widgets/description_widget.dart';
import 'package:flutter/foundation.dart';
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

  late List<GlobalKey<DescriptionWidgetState>> keyList = [];
  late Map<String, int> keyIndex;

  @override
  void initState() {
    super.initState();

    final items = getItems(widget.data["schema"]);

    keyList = List.generate(
      items.length,
      (_) => GlobalKey<DescriptionWidgetState>(),
    );

    keyIndex = {for (int i = 0; i < items.length; i++) items[i]: i};
  }

  @override
  Widget build(BuildContext context) {
    return DescriptionWidget(
      StringService.titleFromKey(widget.category),
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DescriptionWidget(
            StringService.titleFromKey(widget.category),
            Column(
              children: [
                ...options.map((option) {
                  return GestureDetector(
                    onTap: () async {
                      await SettingsService.setSetting(
                        widget.category + "DescriptionStyle",
                        option,
                      );

                      if (mounted) {
                        setState(() {});
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color:
                            SettingsService.getSetting(
                                  widget.category + "DescriptionStyle",
                                ) ==
                                option
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
          ...widget.data["schema"].entries.map<Widget>((entry) {
            return getSelector(entry.key, entry.value);
          }),
        ],
      ),
      "expand",
      initiallyExpanded: false,
    );
  }

  Widget getSelector(String item, Map<String, dynamic> schema) {
    final index = keyIndex[item]!;

    final setting =
        StringService.slugify(StringService.titleFromKey(item)) +
        StringService.slugify(widget.category) +
        "DescriptionStyle";

    final type = schema["type"];

    return schema["noTitle"] == true
        ? SizedBox.shrink()
        : DescriptionWidget(
            StringService.titleFromKey(item),
            Column(
              children: [
                if (type == "list") getSelector("${item}Entry", schema["item"]),

                if (type == "map")
                  ...schema["item"].entries.map<Widget>((entry) {
                    final childName = StringService.CapitalizeWord(entry.key);

                    return getSelector(childName, entry.value);
                  }),

                ...options.map((option) {
                  return GestureDetector(
                    onTap: () async {
                      await keyList[index].currentState?.close();

                      await SettingsService.setSetting(setting, option);
                      print(
                        "Setting (" +
                            setting +
                            ") set, item: " +
                            SettingsService.getSetting(setting),
                      );
                      if (mounted) {
                        setState(() {});
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: SettingsService.getSetting(setting) == option
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
            key: keyList[index],
            titleLevel: 3,
          );
  }

  List<String> getItems(Map<String, dynamic> schema) {
    List<String> items = [];
    for (String key in schema.keys.toList()) {
      String type = schema[key]["type"];
      items.addAll(parseItem(key, schema[key]));
    }
    return items;
  }

  List<String> parseItem(String key, Map<String, dynamic> item) {
    List<String> items = [];
    String type = item["type"];

    if (type == "list") {
      items.add(key);
      items.addAll(parseItem(key + "Entry".toString(), item["item"]));
      return items;
    } else if (type == "map") {
      items.add(key);
      for (String k in item["item"].keys.toList()) {
        items.addAll(
          parseItem(StringService.CapitalizeWord(k), item["item"][k]),
        );
      }
      return items;
    }

    items.add(key);

    return items;
  }
}

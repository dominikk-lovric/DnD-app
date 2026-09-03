import 'package:dnd_app/services/color_service.dart';
import 'package:dnd_app/services/json_service.dart';
import 'package:dnd_app/services/settings_service.dart';
import 'package:dnd_app/services/string_service.dart';
import 'package:dnd_app/services/text_style_service.dart';
import 'package:dnd_app/widgets/description_widget.dart';
import 'package:dnd_app/widgets/feature_description_widget.dart';
import 'package:dnd_app/widgets/list_widget.dart';
import 'package:dnd_app/widgets/saving_throws_widget.dart';
import 'package:dnd_app/widgets/table_widget.dart';
import 'package:flutter/material.dart';

class DescriptionColumnWidget extends StatefulWidget {
  Map<String, dynamic> info;
  Map<String, dynamic> categoryData;
  int sectionLevel;
  int subtitleLevel;
  int descriptionLevel;
  final bool scrollable;
  String category;
  DescriptionColumnWidget(
    this.info,
    this.categoryData, {
    super.key,
    this.sectionLevel = 1,
    this.subtitleLevel = 2,
    this.descriptionLevel = 3,
    this.scrollable = true,
    this.category = "",
  });

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return DescriptionColumnWidgetState();
  }
}

class DescriptionColumnWidgetState extends State<DescriptionColumnWidget> {
  late bool loaded;
  String category = "";
  List<Widget> widgets = [];
  DescriptionColumnWidgetState();

  Map<String, dynamic> featureSchema = {
    "level": {"type": "text"},
    "description": {"type": "text"},
    "uses": {
      "type": "map",
      "item": {
        "amountPerLevel": {"type": "table"},
        "amount": {"type": "text"},
        "replenish": {
          "type": "map",
          "item": {
            "default": {
              "type": "map",
              "item": {
                "amountPerLevel": {"type": "table"},
                "amount": {"type": "text"},
              },
            },
          },
        },
      },
    },
    "options": {
      "type": "map",
      "item": {
        "amountPerLevel": {"type": "table"},
        "amount": {"type": "text"},
        "change": {
          "type": "map",
          "item": {
            "default": {
              "type": "map",
              "item": {
                "amountPerLevel": {"type": "table"},
                "amount": {"type": "text"},
              },
            },
          },
        },
      },
    },
  };
  @override
  initState() {
    category = (widget.category == "") ? widget.info["catId"] : widget.category;
    loaded = false;
    getItems();
    super.initState();
  }

  String getLevel(int level) {
    switch (level) {
      case 0:
        return "Cantrip";
      case 1:
        return "1st";
      case 2:
        return "2nd";
      case 3:
        return "3rd";
      default:
        return "${level}th";
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    if (!loaded) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!widget.scrollable) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widgets,
      );
    }

    return ListView.builder(
      itemCount: widgets.length,
      itemBuilder: (context, index) {
        return widgets[index];
      },
    );
  }

  Future<void> getItems() async {
    final List<Widget> res = [];

    final Map<String, dynamic> schema = (category != "feature")
        ? Map<String, dynamic>.from(widget.categoryData[category]["schema"])
        : featureSchema;

    for (final key in widget.info.keys.toList()) {
      if (!schema.containsKey(key) && !schema.containsKey("default")) {
        continue;
      }

      if (category == "feature") {
        print("\n\n");
        print(key);
        print("\n");
        print(schema);
        print("\n\n");
        print(widget.info);
        print("\n\nAAAA///////////////////////////////////////////");
      }

      if (schema.containsKey(key)) {
        res.add(
          getItem(
            widget.info[key],
            schema[key],
            StringService.titleFromKey(key),
          ),
        );
      } else {
        res.add(
          getItem(
            widget.info[key],
            schema["default"],
            StringService.titleFromKey(key),
          ),
        );
      }
    }

    setState(() {
      widgets = res;
      loaded = true;
    });
  }

  Widget getItem(
    dynamic itemInfo,
    Map<String, dynamic> schemaItem,
    String title, {
    String setting = "",
  }) {
    final String type = schemaItem["type"];
    if (category == "feature") {
      print("\n\n");
      print(schemaItem);
      print("\n");
      print(itemInfo);
      print("\n\n///////////////////////////////////////////");
    }
    if (setting == "") {
      setting =
          "${StringService.slugify(title)}${widget.info["catId"]}DescriptionStyle";
    }
    final String newTitle = SettingsService.getSetting(setting) == "static"
        ? ""
        : title;
    switch (type) {
      case "text":
        return DescriptionWidget(
          newTitle,
          Text(itemInfo.toString(), style: TextStyleService.getTextStyle(4, 4)),
          setting,
        );

      case "list":
        final List<Widget> children = [];

        for (final item in itemInfo) {
          children.add(getItem(item, schemaItem["item"], title + "-entry"));
        }
        return DescriptionWidget(newTitle, ListWidget(children), setting);

      case "map":
        final List<Widget> children = [];

        for (final key in itemInfo.keys.toList()) {
          if (schemaItem["item"].keys.toList().contains(key)) {
            children.add(
              getItem(
                itemInfo[key],
                schemaItem["item"][key],
                StringService.titleFromKey(key),
              ),
            );
          } else if (schemaItem["item"].keys.toList().contains("default")) {
            children.add(
              getItem(
                itemInfo[key],
                schemaItem["item"]["default"],
                StringService.titleFromKey(key),
                setting: "default" + category + "DescriptionStyle",
              ),
            );
          }
        }

        return DescriptionWidget(newTitle, ListWidget(children), setting);

      case "feature":
        return DescriptionWidget(
          title,
          DescriptionColumnWidget(
            itemInfo,
            featureSchema,
            scrollable: false,
            category: "feature",
          ),
          setting,
        );

      case "icon":
        Icon icon;

        switch (schemaItem["icon"]) {
          case "heart":
            icon = const Icon(Icons.favorite, color: Colors.red);
            break;

          default:
            icon = Icon(Icons.do_not_disturb, color: ColorService.getColor(4));
        }

        return Stack(
          children: [
            icon,
            Text(
              itemInfo.toString(),
              style: TextStyleService.getTextStyle(3, 4),
            ),
          ],
        );

      case "checkList":
        return DescriptionWidget(
          title,
          CheckListWidget(itemInfo, schemaItem["list"]),
          setting,
        );

      case "table":
        return DescriptionWidget(title, TableWidget(itemInfo), setting);

      case "path":
        return FutureBuilder<Map<String, dynamic>>(
          future: JsonService.loadFromPath(itemInfo["path"]),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const CircularProgressIndicator();
            }

            return DescriptionWidget(
              itemInfo["name"],
              DescriptionColumnWidget(
                snapshot.data!,
                widget.categoryData,
                scrollable: false,
              ),
              setting,
              initiallyExpanded: true,
            );
          },
        );

      default:
        return const SizedBox.shrink();
    }
  }

  dynamic getInfo(String key) {
    List<String> selectors = key.split(".");
    dynamic item = widget.info;
    for (final selector in selectors) {
      item = item[selector];
    }
    return item;
  }

  dynamic getSchemaItem(String key) {
    List<String> selectors = key.split(".");
    dynamic item = widget.categoryData[category]["schema"];
    for (final selector in selectors) {
      item = item[selector];
    }
    return item;
  }

  Widget getFeature(Map<String, dynamic> feature) {
    List<Widget> items = [];
    return Column(children: items);
  }
}

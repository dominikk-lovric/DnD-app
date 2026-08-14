import 'package:dnd_app/services/json_service.dart';
import 'package:dnd_app/services/parser_service.dart';
import 'package:dnd_app/services/settings_service.dart';
import 'package:dnd_app/services/text_style_service.dart';
import 'package:dnd_app/widgets/description_widget.dart';
import 'package:dnd_app/widgets/table_widget.dart';
import 'package:flutter/material.dart';

class FeatureDescriptionWidget extends StatefulWidget {
  Map<String, dynamic> info;
  String settingName;

  int titleLevel;
  int subtitleLevel;
  int descriptionLevel;
  int clickLevel;
  String clickTitle;
  bool levelTitle;

  FeatureDescriptionWidget(
    this.info,
    this.settingName, {
    this.titleLevel = 3,
    this.subtitleLevel = 3,
    this.descriptionLevel = 4,
    this.clickLevel = 2,
    this.clickTitle = "",
    this.levelTitle = false,
    super.key,
  });

  @override
  State<FeatureDescriptionWidget> createState() =>
      FeatureDescriptionWidgetState(
        info,
        settingName,
        this.titleLevel,
        this.subtitleLevel,
        this.descriptionLevel,
        this.clickLevel,
        this.clickTitle,
        this.levelTitle,
      );
}

class FeatureDescriptionWidgetState extends State<FeatureDescriptionWidget> {
  Map<String, dynamic> info;
  String settingName;
  List<dynamic> options = [];

  int titleLevel;
  int subtitleLevel;
  int descriptionLevel;
  int clickLevel;
  String clickTitle;
  bool levelTitle;

  FeatureDescriptionWidgetState(
    this.info,
    this.settingName,
    this.titleLevel,
    this.subtitleLevel,
    this.descriptionLevel,
    this.clickLevel,
    this.clickTitle,
    this.levelTitle,
  );

  @override
  void initState() {
    super.initState();

    if (info.containsKey("options")) {
      if (info["options"]["features"] is String) {
        loadFile(info["options"]["features"]);
      } else {
        options = info["options"]["features"];
      }
    }
  }

  Future<void> loadFile(String fileName) async {
    final json = await JsonService.loadFromPath(fileName);
    setState(() {
      options = json["features"] ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    String setting = SettingsService.getSetting(settingName);
    List<Widget> items = [];
    items.add(
      Text(
        info["description"],
        style: TextStyleService.getTextStyle(descriptionLevel, 4),
      ),
    );
    if (info.containsKey("uses")) {
      items.add(
        Text("Uses:", style: TextStyleService.getTextStyle(subtitleLevel, 4)),
      );
      items.add(
        Text(
          "Number of uses:",
          style: TextStyleService.getTextStyle(subtitleLevel, 4),
        ),
      );
      items.add(
        getAmount((el) => el["uses"]["amount"], info, descriptionLevel),
      );
      items.add(
        Text("Regain:", style: TextStyleService.getTextStyle(subtitleLevel, 4)),
      );
      for (final item in info["uses"]["replenish"]) {
        items.add(getCondition(item["condition"], descriptionLevel));
        items.add(getAmount((el) => el["amount"], item, descriptionLevel));
      }
    }
    if (info.containsKey("options")) {
      items.add(
        Text(
          "Options:",
          style: TextStyleService.getTextStyle(subtitleLevel, 4),
        ),
      );
      items.add(
        Text(
          "Choose: ",
          style: TextStyleService.getTextStyle(descriptionLevel, 4),
        ),
      );
      items.add(
        getAmount((el) => el["options"]["amount"], info, descriptionLevel),
      );
      for (final item in options) {
        items.add(FeatureDescriptionWidget(item, settingName));
      }
      if (info["options"].containsKey("change")) {
        items.add(
          Text(
            "Change " + info["options"]["change"]["amount"].toString(),
            style: TextStyleService.getTextStyle(descriptionLevel, 4),
          ),
        );
        items.add(
          getCondition(info["options"]["change"]["event"], descriptionLevel),
        );
      }
    }
    return DescriptionWidget(
      info["name"],
      (info["level"] == null) ? "" : "Level:" + info["level"].toString(),
      Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items,
      ),
      settingName,
      titleLevel: titleLevel,
      subtitleLevel: subtitleLevel,
      clickLevel: clickLevel,
      clickTitle: (clickTitle != "")
          ? ((levelTitle) ? "[" + info["level"].toString() + "] " : "") +
                clickTitle
          : ((levelTitle) ? "[" + info["level"].toString() + "] " : "") +
                info["name"],
    );
  }

  Widget getCondition(item, int description) {
    String text = "";
    if (item is String) {
      text = ("On " + ParserService.getCondition(item + ": "));
    } else if (item is List) {
      String base = "On ";
      for (int i = 0; i < item.length; i++) {
        if (i != 0) {
          base = base + "or ";
        }
        base = base + ParserService.getCondition(item[i]);
      }
      text = base;
    }
    return Text(text, style: TextStyleService.getTextStyle(description, 4));
  }

  Widget getAmount(
    dynamic Function(Map<String, dynamic>) selector,
    final info,
    int description,
  ) {
    final item = selector(info);
    if (item is List) {
      Map<String, List<dynamic>> table = {
        "Level": List.generate(20, (i) => i + 1),
        "Amount": item,
      };
      return (TableWidget(table, 3, "horizontal"));
    } else if (info is String) {
      return (Text(
        ParserService.getModifier(info),
        style: TextStyleService.getTextStyle(description, 4),
      ));
    } else {
      return (Text(
        item.toString(),
        style: TextStyleService.getTextStyle(description, 4),
      ));
    }
  }
}

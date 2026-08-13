import 'package:dnd_app/services/parser_service.dart';
import 'package:dnd_app/services/settings_service.dart';
import 'package:dnd_app/services/text_style_service.dart';
import 'package:dnd_app/widgets/description_widget.dart';
import 'package:dnd_app/widgets/table_widget.dart';
import 'package:flutter/material.dart';

class FeatureDescriptionWidget extends StatelessWidget {
  Map<String, dynamic> info;
  String settingName;
  FeatureDescriptionWidget(this.info, this.settingName, {super.key});

  @override
  Widget build(BuildContext context) {
    String setting = SettingsService.getSetting(settingName);
    int title;
    int subtitle;
    int description;
    int click;
    if (setting == "popUp") {
      title = 0;
      subtitle = 2;
      description = 3;
      click = 2;
    } else if (setting == "expand") {
      title = 1;
      subtitle = 2;
      description = 3;
      click = 0;
    } else if (setting == "sheet") {
      title = 0;
      subtitle = 2;
      description = 3;
      click = 2;
    } else {
      title = 1;
      subtitle = 2;
      description = 3;
      click = 0;
    }
    List<Widget> items = [];
    items.add(
      Text(
        info["description"],
        style: TextStyleService.getTextStyle(description, 4),
      ),
    );
    if (info.containsKey("uses")) {
      items.add(
        Text("Uses:", style: TextStyleService.getTextStyle(subtitle, 4)),
      );
      items.add(
        Text(
          "Number of uses:",
          style: TextStyleService.getTextStyle(subtitle, 4),
        ),
      );
      items.add(getAmount((el) => el["uses"]["amount"], info, description));
      items.add(
        Text("Regain:", style: TextStyleService.getTextStyle(subtitle, 4)),
      );
      for (final item in info["uses"]["replenish"]) {
        items.add(getCondition(item["condition"], description));
        items.add(getAmount((el) => el["amount"], item, description));
      }
    }
    return DescriptionWidget(
      info["name"],
      "Level:" + info["level"].toString(),
      Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items,
      ),
      settingName,
      titleLevel: title,
      subtitleLevel: subtitle,
      clickLevel: click,
    );
  }

  Widget getUses(Map<String, dynamic> info, int description) {
    String base = "Number of uses:";
    if (info["uses"]["amount"] is List) {
      Map<String, List<dynamic>> table = {
        "Level": List.generate(20, (i) => i + 1),
        "Amount": info["uses"]["amount"],
      };
      return (TableWidget(table, "horizontal"));
    } else if (info["uses"]["amount"] is String) {
      return (Text(
        ParserService.getModifier(info["uses"]["amount"]),
        style: TextStyleService.getTextStyle(description, 4),
      ));
    } else {
      return (Text(
        info["uses"]["amount"].toString(),
        style: TextStyleService.getTextStyle(description, 4),
      ));
    }
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
      text = base + ": ";
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
      return (TableWidget(table, "horizontal"));
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

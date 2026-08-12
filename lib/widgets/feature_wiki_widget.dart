import 'package:dnd_app/services/settings_service.dart';
import 'package:dnd_app/services/text_style_service.dart';
import 'package:dnd_app/widgets/description_widget.dart';
import 'package:dnd_app/widgets/table_widget.dart';
import 'package:flutter/material.dart';

class FeatureWikiWidget extends StatelessWidget {
  Map<String, dynamic> info;
  String settingName;
  FeatureWikiWidget(this.info, this.settingName, {super.key});

  String getCondition(String conditionName) {
    String result = "";
    int i = 0;
    while (conditionName.length > 0) {
      print(conditionName);
      if (conditionName[i] == conditionName[i].toUpperCase() &&
          conditionName[i] != conditionName[i].toLowerCase()) {
        String part = conditionName.substring(0, i);
        result = result + " " + part[0].toUpperCase() + part.substring(1);
        conditionName = conditionName.substring(i);
        i = 0;
      }
      if (conditionName.length - 1 == i) {
        String part = conditionName.substring(0, i + 1);
        result = result + " " + part[0].toUpperCase() + part.substring(1);
        conditionName = "";
      }
      i++;
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    String setting = SettingsService.getSetting(settingName);
    int title;
    int subtitle;
    int description;
    if (setting == "popUo") {
      title = 0;
      subtitle = 1;
      description = 3;
    } else if (setting == "expand") {
      title = 1;
      subtitle = 2;
      description = 3;
    } else if (setting == "sheet") {
      title = 1;
      subtitle = 2;
      description = 3;
    } else {
      title = 1;
      subtitle = 2;
      description = 3;
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
      String base = "Number of uses:";
      if (info["uses"]["amount"] is int) {
        items.add(
          Text(base, style: TextStyleService.getTextStyle(subtitle, 4)),
        );
        items.add(
          Text(
            info["uses"]["amount"].toString(),
            style: TextStyleService.getTextStyle(description, 4),
          ),
        );
      } else if (info["uses"]["amount"] is String) {
        items.add(
          Text(base, style: TextStyleService.getTextStyle(subtitle, 4)),
        );
        items.add(
          Text(
            getModifier(info["uses"]["amount"]),
            style: TextStyleService.getTextStyle(description, 4),
          ),
        );
      } else if (info["uses"]["amount"] is List) {
        Map<String, List<dynamic>> table = {
          "Level": [
            1,
            2,
            3,
            4,
            5,
            6,
            7,
            8,
            9,
            10,
            11,
            12,
            13,
            14,
            15,
            16,
            17,
            18,
            19,
            20,
          ],
          "Amount": info["uses"]["amount"],
        };
        items.add(TableWidget(table, "horizontal"));
      }
      items.add(
        Text("Regain:", style: TextStyleService.getTextStyle(subtitle, 4)),
      );
      for (final item in info["uses"]["replenish"]) {
        String text = "";
        if (item["condition"] is String) {
          text = ("On " + getCondition(item["condition"] + ": "));
        } else if (item["condition"] is List) {
          String base = "On ";
          for (int i = 0; i < item["condition"].length; i++) {
            if (i != 0) {
              base = base + "or ";
            }
            base = base + getCondition(item["condition"][i]);
          }
          base = base + ": ";
          text = base;
        }
        if (item["amount"] is int) {
          items.add(
            Text(text, style: TextStyleService.getTextStyle(description, 4)),
          );
          items.add(
            Text(
              item["amount"].toString(),
              style: TextStyleService.getTextStyle(description, 4),
            ),
          );
        } else if (item["amount"] is String) {
          items.add(
            Text(text, style: TextStyleService.getTextStyle(description, 4)),
          );
          items.add(
            Text(
              item["amount"],
              style: TextStyleService.getTextStyle(description, 4),
            ),
          );
        } else if (item["amount"] is List) {
          items.add(
            Text(text, style: TextStyleService.getTextStyle(description, 4)),
          );
          Map<String, List<dynamic>> table = {
            "Level": [
              1,
              2,
              3,
              4,
              5,
              6,
              7,
              8,
              9,
              10,
              11,
              12,
              13,
              14,
              15,
              16,
              17,
              18,
              19,
              20,
            ],
            "Amount": item["amount"],
          };
          items.add(TableWidget(table, "horizontal"));
        }
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
    );
  }

  String getModifier(String text) {
    print(text);
    String result;
    switch (text) {
      case "strMod":
        result = ("Strength modifier");
        break;
      case "dexMod":
        result = ("Dexterity modifier");
        break;
      case "conMod":
        result = ("Constitution modifier");
        break;
      case "intMod":
        result = ("Inteligence modifier");
        break;
      case "wisMod":
        result = ("Wisdom modifier");
        break;
      case "chaMod":
        result = ("Charisma modifier");
        break;
      case "proficiencyBonus":
        result = ("Proficiency bonus");
        break;
      case "all":
        result = "All";
      default:
        result = "";
        break;
    }
    return result;
  }
}

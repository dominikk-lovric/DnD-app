import 'package:dnd_app/services/color_service.dart';
import 'package:dnd_app/services/settings_service.dart';
import 'package:dnd_app/services/string_service.dart';
import 'package:dnd_app/services/text_style_service.dart';
import 'package:dnd_app/widgets/description_widget.dart';
import 'package:dnd_app/widgets/feature_description_widget.dart';
import 'package:dnd_app/widgets/list_widget.dart';
import 'package:dnd_app/widgets/saving_throws_widget.dart';
import 'package:dnd_app/widgets/table_widget.dart';
import 'package:flutter/material.dart';

class DescriptionColumnWidget extends StatelessWidget {
  Map<String, dynamic> info;
  int sectionLevel;
  int subtitleLevel;
  int descriptionLevel;
  bool showFalse;
  DescriptionColumnWidget(
    this.info, {
    super.key,
    this.sectionLevel = 1,
    this.subtitleLevel = 2,
    this.descriptionLevel = 3,
    this.showFalse = false,
  });

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
  Widget build(BuildContext context) {
    List<Widget> widgets = [];
    List<dynamic> keys = info.keys.toList();
    List<String> notShown = ["name", "catId", "id", "icon", "source"];
    for (final key in keys) {
      if (!notShown.contains(key) &&
          !notShown.contains(StringService.slugify(key))) {
        String setting =
            StringService.slugify(key) +
            StringService.slugify(info["catId"]) +
            "sDescriptionStyle".toString();
        String title = StringService.titleFromKey(key);
        Widget? content;

        if (key == "description") {
          widgets.add(
            Text(
              info["description"],
              style: TextStyleService.getTextStyle(descriptionLevel, 4),
            ),
          );
        } else if (key == "savingThrows" || key == "abilities") {
          print(info[key]);
          print(info[key] is List);
          content = CheckListWidget(
            info[key],
            ["Str", "Dex", "Con", "Int", "Wis", "Cha"].toList(),
          );
          widgets.add(DescriptionWidget(title, content, setting));
        } else if (key == "hitDie") {
          content = Stack(
            alignment: AlignmentGeometry.center,
            children: [
              Container(
                child: Icon(Icons.favorite, color: Colors.red, size: 80),
              ),
              Container(
                child: Text(
                  info["hitDie"],
                  style: TextStyleService.getTextStyle(3, 4),
                ),
              ),
            ],
          );
          widgets.add(DescriptionWidget("Hit die", content, setting));
        } else if (key == "features") {
          content = Column(
            children: [
              ...info["features"].map((item) {
                return FeatureDescriptionWidget(
                  item,
                  "featureDescriptionStyle",
                );
              }),
            ],
          );
          widgets.add(DescriptionWidget(title, content, setting));
        } else {
          final item = info[key];
          if (item is List) {
            print(item);
            if (item.length > 1) {
              content = ListWidget(item, size: descriptionLevel);
              widgets.add(DescriptionWidget(title, content, setting));
            } else if (item.isNotEmpty) {
              print(item[0]);
              content = Text(
                item[0].toString(),
                style: TextStyleService.getTextStyle(subtitleLevel, 4),
              );
              widgets.add(DescriptionWidget(title, content, setting));
            }
          } else if (item is Map<String, dynamic>) {
            content = TableWidget(item, descriptionLevel);
            widgets.add(DescriptionWidget(title, content, setting));
          } else if (item.toString() == "true" || item.toString() == "false") {
            if (item.toString() == "true" ||
                (item.toString() == "false" && showFalse == true)) {
              content = Checkbox(
                value: item,
                onChanged: (_) {},
                activeColor: ColorService.getColor(0),
                checkColor: ColorService.getColor(4),
                side: BorderSide(color: ColorService.getColor(4)),
              );
              widgets.add(DescriptionWidget(title, content, setting));
            }
            continue;
          } else {
            if (item != "") {
              content = Text(
                item.toString(),
                style: TextStyleService.getTextStyle(subtitleLevel, 4),
              );
              widgets.add(DescriptionWidget(title, content, setting));
            }
          }
        }
      }
    }

    return Column(children: widgets);
  }
}

import 'dart:convert';

import 'package:dnd_app/services/string_service.dart';
import 'package:dnd_app/services/text_style_service.dart';
import 'package:flutter/material.dart';

import 'package:dnd_app/services/settings_service.dart';
import 'package:dnd_app/services/color_service.dart';

import 'package:dnd_app/widgets/optional_image_widget.dart';

class ItemWidget extends StatelessWidget {
  Map<String, String> shorthands = {
    "Player's Handbook": "PHB",
    "Forgotten Realms - Heroes of Faerun": "FRHF",
    "Astarion's Book of Hungers": "ABH",
    "Lorwyn - First Light": "LFL",
    "Eberron - Forge of the Artificer": "EFA",
    "D&D Beyond Drops - May 2026": "DBD-MAY26",
    "D&D Beyond Drops - July 2026": "DBD-JUL26",
    "Ravenloft - The Horrors Within": "RTHW",
    "D&D Beyond Drops - August 2026": "DBD-AUG26",
  };
  ItemWidget(
    this.id,
    this.classData,
    this.category, {
    super.key,
    this.subtitle = null,
  });
  final String id;
  final String category;
  final Map<String, dynamic> classData;
  Widget? subtitle;

  @override
  Widget build(BuildContext context) {
    final basics = Map<String, dynamic>.from(classData["Basics"]);
    final names = basics.keys.toList() as List<dynamic>;
    final items = basics.values.toList();
    final String icon = classData["Icon"][SettingsService.getSetting("theme")];
    final height = SettingsService.getSetting("listItemHeight");

    List<Widget> subtitleList = [];
    if (subtitle != null) {
      subtitleList.add(subtitle ?? SizedBox.shrink());
    } else {
      if (names.contains("source") || names.contains("source")) {
        subtitleList.add(
          Container(
            decoration: BoxDecoration(
              color: ColorService.getColor(5),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: EdgeInsetsGeometry.symmetric(
                vertical: 0,
                horizontal: 10,
              ),
              child: Text(
                shorthands[basics["source"]] ?? "",
                style: TextStyleService.getTextStyle(5, 3),
              ),
            ),
          ),
        );
      }
      for (var i = 0; i < items.length; i++) {
        String text = "• ${StringService.titleFromKey(names[i])}";
        if (items[i].toString() != "false" && names[i].toString() != "source") {
          if (items[i].toString() != "true") {
            text += ": ";
            if (items[i] is List) {
              if (names[i].toLowerCase() == "primary") {
                text = text + (items[i] as List).join(" or ");
              } else {
                text = text + (items[i] as List).join(", ");
              }
            } else {
              text = text + items[i].toString();
            }
          }
          subtitleList.add(
            Text(text, style: TextStyleService.getTextStyle(5, 6)),
          );
        }
      }
    }
    return Container(
      child: Card(
        color: ColorService.getColor(3),
        child: Padding(
          padding: EdgeInsetsGeometry.directional(start: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              (icon != "none")
                  ? Padding(
                      padding: EdgeInsetsGeometry.directional(
                        top: 10,
                        bottom: 10,
                        end: 10,
                      ),
                      child: OptionalImageWidget(
                        height * (8 / 10),
                        icon,
                        key: ValueKey(classData["name"]),
                      ),
                    )
                  : SizedBox(height: 100),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      classData["name"],
                      style: TextStyleService.getTextStyle(
                        1,
                        5,
                        Overflow: TextOverflow.clip,
                      ),
                      maxLines: 1,
                    ),
                    Wrap(spacing: 10, children: subtitleList),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

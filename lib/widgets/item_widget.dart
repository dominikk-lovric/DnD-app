import 'dart:convert';

import 'package:dnd_app/services/text_style_service.dart';
import 'package:flutter/material.dart';

import 'package:dnd_app/services/settings_service.dart';
import 'package:dnd_app/services/color_service.dart';

import 'package:dnd_app/widgets/optional_image_widget.dart';

class ItemWidget extends StatelessWidget {
  const ItemWidget(this.id, this.classData, this.category, {super.key});
  final String id;
  final String category;
  final Map<String, dynamic> classData;

  @override
  Widget build(BuildContext context) {
    final basics = Map<String, dynamic>.from(classData["Basics"]);
    final names = basics.keys.toList() as List<dynamic>;
    final items = basics.values.toList();
    final String icon = classData["Icon"][SettingsService.getSetting("theme")];
    final height = SettingsService.getSetting("headerHeight");

    List<Widget> subtitle = [];
    for (var i = 0; i < items.length; i++) {
      String text = "• " + names[i];
      if (items[i].toString() != "false") {
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
        subtitle.add(Text(text, style: TextStyleService.getTextStyle(5, 6)));
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
                    Wrap(spacing: 10, children: subtitle),
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

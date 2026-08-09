

import 'package:dnd_app/services/color_service.dart';
import 'package:dnd_app/services/settings_service.dart';
import 'package:dnd_app/services/text_style_service.dart';
import 'package:dnd_app/widgets/description_widget.dart';
import 'package:dnd_app/widgets/list_widget.dart';
import 'package:dnd_app/widgets/table_widget.dart';
import 'package:flutter/material.dart';

import 'package:dnd_app/widgets/table_widget.dart';
import 'package:dnd_app/widgets/saving_throws_widget.dart';


class SectionWidget extends StatelessWidget {
  List<dynamic> items;
  String title;
  String style;
  SectionWidget(this.title, this.items, this.style, {super.key});

  @override
  Widget build(BuildContext context) {
    Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...items.map((item) {
          final lastKey = item.keys.toList().last;
          final lastValue = item[lastKey];

          final String subtitle = item.containsKey("options")
              ? "Choose ${item["options"]} from:"
              : "";

          final String displayTitle = item.containsKey("level")
              ? "[${item["level"]}] ${item["name"]}"
              : item["name"];

          final Widget body = (lastValue is List)
              ? ListWidget(lastValue)
              : Text(
                  lastValue?.toString() ?? "",
                  style: TextStyleService.getTextStyle((SettingsService.getSetting(style)=="sheet" || SettingsService.getSetting(style)=="popUp")?3:4, 4),
          );

          return DescriptionWidget(displayTitle, subtitle, body, style, titleLevel: (SettingsService.getSetting(style)=="popUp")?3:2, subtitleLevel: 3,);
        }),
      ],
    );

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 300),
      child: Theme(
        data: ThemeData(dividerColor: Colors.transparent),
        child: DescriptionWidget(title, null, content, "sectionDescriptionType", titleLevel: 2, subtitleLevel: 3,),
      ),
    );
  }
}
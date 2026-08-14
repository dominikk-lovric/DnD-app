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
  List<Widget> items;
  String title;
  String style;
  SectionWidget(this.title, this.items, this.style, {super.key});

  @override
  Widget build(BuildContext context) {
    print(style);
    String setting = SettingsService.getSetting(style);
    return Theme(
      data: ThemeData(dividerColor: Colors.transparent),
      child: DescriptionWidget(
        title,
        null,
        IntrinsicWidth(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: items,
          ),
        ),
        style,
      ),
    );
  }
}



import 'package:dnd_app/services/color_service.dart';
import 'package:dnd_app/services/settings_service.dart';
import 'package:dnd_app/services/text_style_service.dart';
import 'package:dnd_app/widgets/draggable_sheet_widget.dart';
import 'package:flutter/material.dart';

class DescriptionWidget extends StatelessWidget {
  String title;
  Widget descrption;
  String descriptionType;
  String? subtitle;
  int titleLevel;    
  int subtitleLevel; 

  DescriptionWidget(
    this.title,
    this.subtitle,
    this.descrption,
    this.descriptionType, {
    super.key,
    this.titleLevel = 3,
    this.subtitleLevel = 3,
  });

  @override
  Widget build(BuildContext context) {
    String setting = SettingsService.getSetting(descriptionType);
    if (setting == "popUp") {
      return GestureDetector(
        onTap: () => {
          showDialog(
            context: context,
            builder: (context) => Theme(
              data: Theme.of(context).copyWith(
                dialogTheme: DialogThemeData(
                  backgroundColor: ColorService.getColor(2)
                ),
              ),
              child: Dialog(
                insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: TextStyleService.getTextStyle(0, 4)),
                        const Divider(indent: 10, endIndent: 10),
                        if (subtitle != null && subtitle!="")
                          Text(subtitle.toString(), style: TextStyleService.getTextStyle(2, 4)),
                        Flexible(child: SingleChildScrollView(child: descrption)),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Close"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
        },
        child: Text(title, style: TextStyleService.getTextStyle(titleLevel, 1)),
      );
    } else if (setting == "expand") {
      return IntrinsicWidth(
        child: ExpansionTile(
        initiallyExpanded: true,
        showTrailingIcon: false,
        title: Text(title, style: TextStyleService.getTextStyle(titleLevel, 4)),
        children: [
          Divider(indent: 15, endIndent: 15, color: ColorService.getColor(4)),
          Padding(
            padding: EdgeInsetsGeometry.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (subtitle != null)
                  Text(
                    subtitle.toString(),
                    style: TextStyleService.getTextStyle(subtitleLevel, 4),
                  ),
                descrption,
              ],
            ),
          )
        ],
      ),
      );
    } else if (setting == "sheet") {
      return DraggableSheetWidget(title, subtitle, descrption);
    } else {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: TextStyleService.getTextStyle(titleLevel, 4)),
          descrption,
        ],
      );
    }
  }
}
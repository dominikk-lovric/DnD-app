import 'package:dnd_app/services/settings_service.dart';
import 'package:dnd_app/services/color_service.dart';
import 'package:dnd_app/services/text_style_service.dart';

import 'package:flutter/material.dart';

class SavingThrowWidget extends StatelessWidget {
  final List<String> allStats = ["Str", "Dex", "Con", "Int", "Wis", "Cha"];
  final List<dynamic> stats;

  SavingThrowWidget(this.stats, {super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    List<Widget> items = [];
    int k = 0;
    for (int i = 0; i < 2; i++) {
      List<Widget> tmp = [];
      for (int j = 0; j < 3; j++) {
        tmp.add(
          Column(
            mainAxisSize: .min,
            children: [
              Text(allStats[k], style: TextStyleService.getTextStyle(2, 4)),
              Checkbox(
                value: stats.contains(allStats[k]),
                onChanged: (_) {},
                activeColor: ColorService.getColor(0),
                checkColor: ColorService.getColor(4),
                side: BorderSide(color: ColorService.getColor(4)),
              ),
            ],
          ),
        );
        k++;
      }
      items.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: width / 100,
          mainAxisSize: MainAxisSize.min,
          children: tmp,
        ),
      );
    }
    return Wrap(
      alignment: WrapAlignment.center,
      runAlignment: WrapAlignment.center,
      runSpacing: SettingsService.getSetting("listItemHeight") / 10,
      spacing: width / 100,
      children: items,
    );
  }
}

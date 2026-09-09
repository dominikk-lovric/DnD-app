import 'package:dnd_app/services/settings_service.dart';
import 'package:dnd_app/services/color_service.dart';
import 'package:dnd_app/services/text_style_service.dart';

import 'package:flutter/material.dart';

class CheckListWidget extends StatelessWidget {
  final List<dynamic> options;
  final List<dynamic> stats;

  const CheckListWidget(this.options, this.stats, {super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    List<Widget> items = [];
    for (int i = 0; i < stats.length; i++) {
      items.add(
        Column(
          mainAxisSize: .min,
          children: [
            Text(
              stats[i].toString(),
              style: TextStyleService.getTextStyle(2, 4),
            ),
            Checkbox(
              value: options.contains(stats[i]),
              onChanged: (_) {},
              activeColor: ColorService.getColor(0),
              checkColor: ColorService.getColor(4),
              side: BorderSide(color: ColorService.getColor(4)),
            ),
          ],
        ),
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          child: Wrap(
            spacing: MediaQuery.sizeOf(context).width / 72,
            runSpacing: MediaQuery.sizeOf(context).width / 72,
            children: items.map((item) {
              return SizedBox(child: item);
            }).toList(),
          ),
        );
      },
    );
  }
}

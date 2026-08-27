import 'package:dnd_app/services/settings_service.dart';
import 'package:dnd_app/services/color_service.dart';
import 'package:dnd_app/services/text_style_service.dart';

import 'package:flutter/material.dart';

class CheckListWidget extends StatelessWidget {
  final List<String> options;
  final List<dynamic> stats;

  const CheckListWidget(this.options, this.stats, {super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    List<Widget> items = [];
    for (int i = 0; i < 6; i++) {
      items.add(
        Column(
          mainAxisSize: .min,
          children: [
            Text(options[i], style: TextStyleService.getTextStyle(2, 4)),
            Checkbox(
              value: stats.contains(options[i]),
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
        int columns;

        if (constraints.maxWidth > 500) {
          columns = 6;
        } else if (constraints.maxWidth > 300) {
          columns = 2;
        } else {
          columns = 1;
        }

        final itemWidth = 65.0;
        final spacing = 10.0;

        return SizedBox(
          width: columns * itemWidth + (columns - 1) * spacing,
          child: Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: items.map((item) {
              return SizedBox(width: itemWidth, child: item);
            }).toList(),
          ),
        );
      },
    );
  }
}

import 'package:dnd_app/services/settings_service.dart';
import 'package:dnd_app/services/color_service.dart';
import 'package:dnd_app/services/text_style_service.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CheckListWidget extends ConsumerWidget {
  final List<dynamic> options;
  final List<dynamic> stats;

  const CheckListWidget(this.options, this.stats, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(settingsControllerProvider);
    ref.watch(colorControllerProvider);
    ref.watch(textStyleControllerProvider);
    final controller = ref.read(settingsControllerProvider.notifier);
    final colorController = ref.read(colorControllerProvider.notifier);
    final textStyleController = ref.read(textStyleControllerProvider.notifier);
    double width = MediaQuery.of(context).size.width;
    List<Widget> items = [];
    for (int i = 0; i < stats.length; i++) {
      items.add(
        Column(
          mainAxisSize: .min,
          children: [
            Text(
              stats[i].toString(),
              style: textStyleController.getTextStyle(2, 4),
            ),
            Checkbox(
              value: options.contains(stats[i]),
              onChanged: (_) {},
              activeColor: colorController.getColor(0),
              checkColor: colorController.getColor(4),
              side: BorderSide(color: colorController.getColor(4)),
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

import 'package:dnd_app/services/color_service.dart';
import 'package:dnd_app/services/settings_service.dart';
import 'package:dnd_app/services/text_style_service.dart';
import 'package:dnd_app/widgets/table_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ListWidget extends ConsumerWidget {
  List<dynamic> items;
  int size;
  ListWidget(this.items, {super.key, this.size = 4});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(settingsControllerProvider);
    ref.watch(colorControllerProvider);
    ref.watch(textStyleControllerProvider);
    final settingsController = ref.read(settingsControllerProvider.notifier);
    final colorController = ref.read(colorControllerProvider.notifier);
    final textStyleController = ref.read(textStyleControllerProvider.notifier);
    return IntrinsicHeight(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: MediaQuery.sizeOf(context).width / 72),
          Container(color: colorController.getColor(5), width: 1),
          Container(width: MediaQuery.sizeOf(context).width / 144),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: MediaQuery.sizeOf(context).width / 72,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...items.map((item) {
                  if (item is Widget) {
                    return item;
                  } else if (item is List) {
                    if (item.isNotEmpty && item.every((x) => x is Widget)) {
                      return Column(children: List<Widget>.from(item));
                    } else {
                      return ListWidget(item, size: size);
                    }
                  } else if (item is Map<String, dynamic>) {
                    return TableWidget(item);
                  } else {
                    return Text(
                      item.toString(),
                      style: textStyleController.getTextStyle(
                        size,
                        4,
                        Overflow: TextOverflow.clip,
                      ),
                    );
                  }
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

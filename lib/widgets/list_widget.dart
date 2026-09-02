import 'package:dnd_app/services/color_service.dart';
import 'package:dnd_app/services/settings_service.dart';
import 'package:dnd_app/services/text_style_service.dart';
import 'package:dnd_app/widgets/table_widget.dart';
import 'package:flutter/material.dart';

class ListWidget extends StatelessWidget {
  List<dynamic> items;
  int size;
  ListWidget(this.items, {super.key, this.size = 4});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 10),
          Container(color: ColorService.getColor(5), width: 1),
          Container(width: 5),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 10,
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
                    print("MAP");
                    return TableWidget(item);
                  } else {
                    print("ELSE");
                    return Text(
                      item.toString(),
                      style: TextStyleService.getTextStyle(
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

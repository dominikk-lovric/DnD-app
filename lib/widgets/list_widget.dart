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
    return SingleChildScrollView(
      child: Column(
        spacing: 10,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          IntrinsicHeight(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 10),
                Container(color: ColorService.getColor(5), width: 1),
                Container(width: 5),
                Expanded(
                  child: Column(
                    spacing: 10,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...items.map((item) {
                        if (item is List) {
                          return ListWidget(item, size: size);
                        } else if (item is Map<String, dynamic>) {
                          return TableWidget(item, size);
                        } else {
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
          ),
        ],
      ),
    );
  }
}

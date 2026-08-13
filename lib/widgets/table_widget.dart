import 'package:dnd_app/services/color_service.dart';
import 'package:dnd_app/services/icon_service.dart';
import 'package:dnd_app/services/settings_service.dart';
import 'package:dnd_app/services/text_style_service.dart';
import 'package:flutter/material.dart';

class TableWidget extends StatelessWidget {
  Map<String, dynamic> info;
  String type;
  TableWidget(this.info, [this.type = "vertical"]);

  @override
  Widget build(BuildContext context) {
    List<String> names = info.keys.toList();
    List<TableRow> rows = [];
    if (type == "vertical") {
      rows.add(
        TableRow(
          children: [
            ...names.map(
              (name) => Center(
                child: Padding(
                  padding: EdgeInsetsGeometry.all(10),
                  child: Text(
                    name.toString(),
                    style: TextStyleService.getTextStyle(4, 4),
                    maxLines: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
      for (int i = 0; i < info[names[0]].length; i++) {
        rows.add(
          TableRow(
            children: [
              ...names.map(
                (name) => Center(
                  child: Text(
                    info[name][i].toString(),
                    style: TextStyleService.getTextStyle(4, 4),
                  ),
                ),
              ),
            ],
          ),
        );
      }
    } else if (type == "horizontal") {
      for (int i = 0; i < names.length; i++) {
        List<dynamic> myList = [names[i]];
        myList.addAll(info[names[i]]);
        rows.add(
          TableRow(
            children: [
              ...myList.map((item) {
                return Center(
                  child: Padding(
                    padding: EdgeInsetsGeometry.all(10),
                    child: Text(
                      item.toString(),
                      style: TextStyleService.getTextStyle(4, 4),
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      }
    }
    return SingleChildScrollView(
      scrollDirection: (type == "horizontal") ? Axis.horizontal : Axis.vertical,
      child: Table(
        border: TableBorder(
          verticalInside: BorderSide(color: ColorService.getColor(4), width: 1),
          horizontalInside: BorderSide(
            color: ColorService.getColor(4),
            width: 1,
          ),
        ),
        defaultColumnWidth: IntrinsicColumnWidth(),
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: rows,
      ),
    );
  }
}

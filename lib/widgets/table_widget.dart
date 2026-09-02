import 'package:dnd_app/services/color_service.dart';
import 'package:dnd_app/services/string_service.dart';
import 'package:dnd_app/services/text_style_service.dart';
import 'package:dnd_app/widgets/list_widget.dart';
import 'package:flutter/material.dart';

class TableWidget extends StatelessWidget {
  Map<String, dynamic> info;
  String type;
  int nameSize;
  int textSize;
  TableWidget(
    this.info, [
    this.type = "vertical",
    this.nameSize = 4,
    this.textSize = 4,
  ]);

  @override
  Widget build(BuildContext context) {
    List<String> names = info.keys.toList();
    List<TableRow> rows = [];
    if (type == "horizontal") {
      names.map((name) {
        rows.add(
          TableRow(
            children: [
              Padding(
                padding: EdgeInsetsGeometry.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                child: Center(
                  child: Text(
                    StringService.titleFromKey(name),
                    style: TextStyleService.getTextStyle(nameSize, 4),
                  ),
                ),
              ),
              ...info[name].map((el) {
                return Padding(
                  padding: EdgeInsetsGeometry.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  child: Center(
                    child: Text(
                      el.toString(),
                      style: TextStyleService.getTextStyle(textSize, 4),
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      });
    } else {
      rows.add(
        TableRow(
          children: [
            ...names.map(
              (name) => Padding(
                padding: EdgeInsetsGeometry.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                child: Center(
                  child: Text(
                    StringService.titleFromKey(name),
                    style: TextStyleService.getTextStyle(nameSize, 4),
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
                (name) => Padding(
                  padding: EdgeInsetsGeometry.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  child: Center(
                    child: Text(
                      info[name][i].toString(),
                      style: TextStyleService.getTextStyle(textSize, 4),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }
    }
    return SingleChildScrollView(
      scrollDirection: type == "vertical" ? Axis.vertical : Axis.horizontal,
      child: Table(
        border: TableBorder.symmetric(
          inside: BorderSide(color: ColorService.getColor(4)),
        ),
        defaultColumnWidth: IntrinsicColumnWidth(),
        children: rows,
      ),
    );
  }
}

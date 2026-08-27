import 'package:dnd_app/services/color_service.dart';
import 'package:dnd_app/services/text_style_service.dart';
import 'package:dnd_app/widgets/list_widget.dart';
import 'package:flutter/material.dart';

class TableWidget extends StatelessWidget {
  Map<String, dynamic> info;
  String type;
  int size;
  bool noListing;
  TableWidget(
    this.info,
    this.size, [
    this.type = "vertical",
    this.noListing = false,
  ]);

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
                    style: TextStyleService.getTextStyle(size, 4),
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
                    style: TextStyleService.getTextStyle(size, 4),
                  ),
                ),
              ),
            ],
          ),
        );
      }
    } else if (type == "horizontal") {
      for (int i = 0; i < names.length; i++) {
        List<Widget> myList = [
          Text(names[i], style: TextStyleService.getTextStyle(size, 4)),
        ];
        if (noListing) {
          myList.addAll([
            ...info[names[i]].map((el) {
              return Text(
                el.toString(),
                style: TextStyleService.getTextStyle(size, 4),
              );
            }),
          ]);
        } else {
          if (info[names[i]] is List) {
            if (info[names[i]].length > 1) {
              myList.add(ListWidget(info[names[i]]));
            } else {
              myList.add(
                Text(
                  info[names[i]][0],
                  style: TextStyleService.getTextStyle(size, 4),
                ),
              );
            }
          } else {
            myList.add(
              Text(
                info[names[i]],
                style: TextStyleService.getTextStyle(size, 4),
              ),
            );
          }
        }
        rows.add(
          TableRow(
            children: [
              ...myList.map((item) {
                return Center(
                  child: Padding(
                    padding: EdgeInsetsGeometry.all(10),
                    child: item,
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

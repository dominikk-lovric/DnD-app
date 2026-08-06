import 'package:dnd_app/services/color_service.dart';
import 'package:dnd_app/services/icon_service.dart';
import 'package:dnd_app/services/settings_service.dart';
import 'package:dnd_app/services/text_style_service.dart';
import 'package:flutter/material.dart';

class TableWidget extends StatelessWidget{
  
  Map<String,dynamic> info;
  TableWidget(this.info,{super.key});
  
  @override
  Widget build(BuildContext context) {
    List<String> names=info.keys.toList();
    List<TableRow> rows=[];
    rows.add(
      TableRow(
        children: [
          ...names.map(
            (name)=>Center(
              child: Padding(
                padding: EdgeInsetsGeometry.all(10),
                child:Text(
                  name.toString(),
                  style: TextStyleService.getTextStyle(3, 4),
                  maxLines: 1,
                ),
              ),
            )
          )
        ]
      )
    );
    for(int i=0;i<info[names[0]].length;i++){
      rows.add(
        TableRow(
          children: [
            ...names.map(
              (name)=>Center(
                child: Text(
                  info[name][i].toString(),
                  style: TextStyleService.getTextStyle(3, 4),
                ),
              )
            )
          ]
        )
      );
    };
    return Table(
                border: TableBorder(
                  verticalInside: BorderSide(color: ColorService.getColor(4), width: 1),
                  horizontalInside: BorderSide(color: ColorService.getColor(4), width: 1),
                ),
                defaultColumnWidth: IntrinsicColumnWidth(),
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: rows,
              );
  }
}
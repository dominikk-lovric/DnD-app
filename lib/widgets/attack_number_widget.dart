import 'package:dnd_app/services/color_service.dart';
import 'package:dnd_app/services/icon_service.dart';
import 'package:dnd_app/services/settings_service.dart';
import 'package:flutter/material.dart';

class AttackNumberWidget extends StatelessWidget{
  
  Map<String,dynamic> attackInfo;

  AttackNumberWidget(this.attackInfo,{super.key});
  
  @override
  Widget build(BuildContext context) {
    List<String> levels=attackInfo.keys.toList();
    List<TableRow> rows=[];
    
    for (final level in levels){
      rows.add(
        TableRow(
          children: [
            Center(
              child:Text(
                level,
                style: TextStyle(color: ColorService.getColor(4), fontSize: 20),
)            ),
            Center(
              child:Text(
                attackInfo[level].toString(),
                style: TextStyle(color: ColorService.getColor(4), fontSize: 20),
              )
            )
          ]
        )
      );
    }
    return Container(
      decoration: BoxDecoration(
        border: BoxBorder.all(color: ColorService.getColor(4)),
        borderRadius: BorderRadius.circular(4)
      ),
      width: MediaQuery.of(context).size.width/2,
      child: ExpansionTile(
        title: Text(
          "Attacks per level",
          style: TextStyle(color:ColorService.getColor(4),fontSize: 30),
        ),
        children: [
          Divider(
            indent: 10,
            endIndent: 10,
            color: ColorService.getColor(5),
          ),
          Padding(
            padding: EdgeInsetsGeometry.all(10),
            child: Table(
              border: TableBorder(
                verticalInside: BorderSide(color: ColorService.getColor(4), width: 1),
                horizontalInside: BorderSide(color: ColorService.getColor(4), width: 1),
              ),
              columnWidths: <int,TableColumnWidth>{
                0:FlexColumnWidth(),
                1:FlexColumnWidth(),
              },
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: rows,
            ),
          )
        ]
      ),
    );
  }
}
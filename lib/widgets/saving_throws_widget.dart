import 'package:dnd_app/services/settings_service.dart';
import 'package:dnd_app/services/color_service.dart';

  import 'package:flutter/material.dart';

  class SavingThrowWidget extends StatelessWidget{
  
    final List<String>allStats=["Str","Dex","Con","Int","Wis","Cha"];
    final List<dynamic> stats;

    SavingThrowWidget( this.stats);

    @override
    Widget build(BuildContext context) {
      double width=MediaQuery.of(context).size.width;
      List<Widget> items=[];
      for(int i=0;i<6;i++){
        items.add(
          Column(
            children: [
              Text(allStats[i], style: TextStyle(fontSize:20,color: ColorService.getColor(4)),),
              Checkbox(
                value: stats.contains(allStats[i]),
                onChanged: (_){},
                activeColor: ColorService.getColor(0),
                checkColor: ColorService.getColor(4),
                side: BorderSide(color: ColorService.getColor(4)),
              )
            ],
          )
        );
        if(i<5){
          items.add(
            Container(
              width: 1,
              height: 50,
              color: ColorService.getColor(4),
            )
          );
        }
      }
      return SizedBox(
        width: width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: width/30,
          children: 
            items
        ),
      );
    }
  }
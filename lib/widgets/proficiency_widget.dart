import 'package:dnd_app/services/color_service.dart';
import 'package:flutter/material.dart';

class ProficiencyWidget extends StatelessWidget{

  Map<String,dynamic> info;
  String name;
  ProficiencyWidget(this.info, this.name, {super.key});

  @override
  Widget build(BuildContext context) {
    List<dynamic> proficiencies=info["proficiencies"];
    return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              name, 
              style: TextStyle(
                color: ColorService.getColor(4),
                fontSize: 25,
              ),
            ),
            if(info["options"]!=null)
              Text(
                "Choose "+info["options"].toString()+" from:",
                style: TextStyle(
                  color: ColorService.getColor(5),
                  fontSize: 20
                ),
              ),
            IntrinsicHeight(
              child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                  Container(
                    color: ColorService.getColor(5),
                    width: 3,
                  ),
                  Container(
                    width: 5,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...proficiencies.map((item)=>Text(
                        item.toString(),
                        style: TextStyle(
                          color: ColorService.getColor(5),
                          fontSize: 15
                        ),
                      )),
                    ],
                  )
                ],
              ),
            )   
          ]
        );
  }
}
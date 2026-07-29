

import 'package:dnd_app/services/color_service.dart';
import 'package:dnd_app/services/settings_service.dart';
import 'package:flutter/material.dart';

class ProficiencyWidget extends StatelessWidget{

  Map<String,dynamic> info;
  ProficiencyWidget(this.info, {super.key});

  @override
  Widget build(BuildContext context) {
    List<dynamic> proficiencies=info["proficiencies"];
    String descriptionSetting=SettingsService.getSetting("descriptionStyle");
    return SingleChildScrollView(
      child: Column(
          spacing: 10,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if(info["options"]!=null)
              Text(
                "Choose "+info["options"].toString()+" from:",
                style: TextStyle(
                  color: ColorService.getColor(4),
                  fontSize: 20
                ),
              ),
            IntrinsicHeight(
              child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                  Container(
                    width: 10,
                  ),
                  Container(
                    color: ColorService.getColor(5),
                    width: 1,
                  ),
                  Container(
                    width: 5,
                  ),
                  Expanded(
                    child: Column(
                    spacing:10,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...proficiencies.map((item)=>Text(
                        item.toString(),
                        style: TextStyle(
                          color: ColorService.getColor(5),
                          fontSize: 20
                        ),
                        overflow: TextOverflow.clip,
                      )),
                    ],
                  ),
                  )
                ],
              ),
            )   
          ]
        ),
    );  
  }

  Widget proficiencyWidget(List<dynamic> profs, String? name, double itemSize){
    return SingleChildScrollView(
      child: Column(
          spacing: 10,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if(name!=null)Text(
              name, 
              style: TextStyle(
                color: ColorService.getColor(4),
                fontSize: itemSize*1.5,
              ),
            ),
            if(name!=null)
              Divider(
                color: ColorService.getColor(4),
                indent: 10,
                endIndent: 10,
              ),
            if(info["options"]!=null)
              Text(
                "Choose "+info["options"].toString()+" from:",
                style: TextStyle(
                  color: ColorService.getColor(4),
                  fontSize: itemSize
                ),
              ),
            IntrinsicHeight(
              child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                  Container(
                    width: 10,
                  ),
                  Container(
                    color: ColorService.getColor(5),
                    width: 1,
                  ),
                  Container(
                    width: 5,
                  ),
                  Expanded(
                    child: Column(
                    spacing:10,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...profs.map((item)=>Text(
                        item.toString(),
                        style: TextStyle(
                          color: ColorService.getColor(5),
                          fontSize: itemSize
                        ),
                        overflow: TextOverflow.clip,
                      )),
                    ],
                  ),
                  )
                ],
              ),
            )   
          ]
        ),
    );  
  }
}
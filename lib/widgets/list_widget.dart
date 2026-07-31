

import 'package:dnd_app/services/color_service.dart';
import 'package:dnd_app/services/settings_service.dart';
import 'package:flutter/material.dart';

class ProficiencyWidget extends StatelessWidget{

  List<dynamic> items;
  ProficiencyWidget(this.items, {super.key});

  @override
  Widget build(BuildContext context) {
    String descriptionSetting=SettingsService.getSetting("descriptionStyle");
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
                      ...items.map((item)=>Text(
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
}
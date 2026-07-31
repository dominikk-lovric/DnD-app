

import 'package:dnd_app/services/color_service.dart';
import 'package:dnd_app/services/settings_service.dart';
import 'package:dnd_app/widgets/draggable_sheet_widget.dart';
import 'package:flutter/material.dart';

class DescriptionWidget extends StatelessWidget{

  String title;
  Widget descrption;
  String descriptionType;
  String? subtitle;
  DescriptionWidget( this.title, this.subtitle , this.descrption, this.descriptionType, {super.key});

  @override
  Widget build(BuildContext context) {
    String setting=SettingsService.getSetting(descriptionType);
    if(setting=="popUp"){
      return GestureDetector(
              onTap: () => {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: ColorService.getColor(2),
                  title: Text(
                    title, 
                    style: TextStyle(
                      color: ColorService.getColor(4),
                      fontSize: 35,
                    )
                  ),
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if(subtitle!=null)Text(
                        subtitle.toString(),
                        style: TextStyle(
                          color: ColorService.getColor(4),
                          fontSize: 25,
                        ),
                      ),
                      descrption,
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Close"),
                    ),
                  ],
                ),
              )
            },
              child: Text(
                title, 
                style: TextStyle(
                  color: ColorService.getColor(1),
                  fontSize: 25,
                ),
              ),
            );
    }else if(setting=="expand"){
      return ExpansionTile(
        initiallyExpanded: true,
        showTrailingIcon: false,
        title: Text(
          title, 
          style: TextStyle(
            color: ColorService.getColor(4),
            fontSize: 25,
          )
        ),
        children: [
          Divider(
            indent: 15,
            endIndent: 15,
            color: ColorService.getColor(4),
          ),
          Padding(
            padding: EdgeInsetsGeometry.all(10),
            child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if(subtitle!=null)Text(
                        subtitle.toString(),
                        style: TextStyle(
                          color: ColorService.getColor(4),
                          fontSize: 25,
                        ),
                      ),
                      descrption,
                    ],
                  ),
          )
        ],
      );
    }else if(setting=="sheet"){
      return DraggableSheetWidget(title, subtitle, descrption);
    } else {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [Text(
          title, 
          style: TextStyle(
            color: ColorService.getColor(4),
            fontSize: 25,
          )
        ),
        descrption
        ]
      );
    }
  }
}
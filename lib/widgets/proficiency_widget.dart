import 'package:dnd_app/services/color_service.dart';
import 'package:dnd_app/services/settings_service.dart';
import 'package:flutter/material.dart';

class ProficiencyWidget extends StatelessWidget{

  Map<String,dynamic> info;
  String name;
  ProficiencyWidget(this.info, this.name, {super.key});

  @override
  Widget build(BuildContext context) {
    List<dynamic> proficiencies=info["proficiencies"];
    String descriptionSetting=SettingsService.getSetting("descriptionStyle");
    if (descriptionSetting=="popUp"){
      return GestureDetector(
        onTap: () => {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: ColorService.getColor(2),
            title: Text(
              name, 
              style: TextStyle(
                color: ColorService.getColor(4),
                fontSize: 35,
              )
            ),
            content: proficiencyWidget(
              List<dynamic>.from(info["proficiencies"]),null,20
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
          name, 
          style: TextStyle(
            color: ColorService.getColor(4),
            fontSize: 25,
          ),
        ),
      );
    }else if(descriptionSetting=="expand"){
      return ExpansionTile(
        initiallyExpanded: true,
        showTrailingIcon: false,
        title: Text(
          name, 
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
            child: proficiencyWidget(
              List<dynamic>.from(info["proficiencies"]),null,20
            ),
          )
        ],
      );
    }else{
      return proficiencyWidget(
              List<dynamic>.from(info["proficiencies"]),name,20);
    }
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

import 'package:dnd_app/services/color_service.dart';
import 'package:dnd_app/widgets/proficiency_widget.dart';
import 'package:flutter/material.dart';

import 'package:dnd_app/widgets/attack_number_widget.dart';
import 'package:dnd_app/widgets/saving_throws_widget.dart';

class ClassInfoWidget extends StatelessWidget{

  Map<String,dynamic> info;
  ClassInfoWidget(this.info,{super.key});

  @override
  Widget build(BuildContext context) {
    List<dynamic> proficiencies=info["skillProficiencies"]["proficiencies"];
    return Column(
      spacing: 20,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SavingThrowWidget(info["savingThrows"]),
        //spellcasting
        if(info["attacksPerLevel"].keys.toList().length>1)
          AttackNumberWidget(info["attacksPerLevel"]),
        ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 300
          ),
          child: Theme(
            data: ThemeData(
              dividerColor: Colors.transparent
            ),
            child: ExpansionTile(
              initiallyExpanded: true,
              showTrailingIcon: false,
              title: Text(
                "Proficiencies",
                style: TextStyle(
                  color: ColorService.getColor(4),
                  fontSize: 30
                ),
              ),
              children: [
                Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children:[
                    Divider(
                      color: ColorService.getColor(4),
                    ),
                    ProficiencyWidget(info["skillProficiencies"],"Skill"),
                    ProficiencyWidget(info["armorProficiencies"],"Armor"),
                    ProficiencyWidget(info["weaponProficiencies"],"Weapon"),
                  ]
                ),
              ],
            ),
          )
        )
      ],
    );
  }
}
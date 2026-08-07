
import 'package:dnd_app/services/color_service.dart';
import 'package:dnd_app/services/settings_service.dart';
import 'package:dnd_app/services/text_style_service.dart';
import 'package:dnd_app/widgets/description_widget.dart';
import 'package:dnd_app/widgets/list_widget.dart';
import 'package:dnd_app/widgets/table_widget.dart';
import 'package:flutter/material.dart';

import 'package:dnd_app/widgets/table_widget.dart';
import 'package:dnd_app/widgets/saving_throws_widget.dart';

class SectionWidget extends StatelessWidget {
  List<dynamic> items;
  String title;
  String style;
  SectionWidget(this.title, this.items, this.style, {super.key});

  @override
  Widget build(BuildContext context) {
    Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...items.map((item) {
          final lastKey = item.keys.toList().last;
          final lastValue = item[lastKey];

          final String? subtitle = item.containsKey("options")
              ? "Choose ${item["options"]} from:"
              : "";

          final String displayTitle = item.containsKey("level")
              ? "[${item["level"]}] ${item["name"]}"
              : item["name"];

          final Widget body = (lastValue is List)
              ? ListWidget(lastValue)
              : Text(
                  lastValue?.toString() ?? "",
                  style: TextStyleService.getTextStyle((SettingsService.getSetting(style)=="sheet" || SettingsService.getSetting(style)=="popUp")?3:4, 4),
          );

          return DescriptionWidget(displayTitle, subtitle, body, style, titleLevel: (SettingsService.getSetting(style)=="popUp")?3:2, subtitleLevel: 3,);
        }),
      ],
    );

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 300),
      child: Theme(
        data: ThemeData(dividerColor: Colors.transparent),
        child: DescriptionWidget(title, null, content, "sectionDescriptionType", titleLevel: 2, subtitleLevel: 3,),
      ),
    );
  }
}


class ClassInfoWidget extends StatelessWidget{

  Map<String,dynamic> info;
  ClassInfoWidget(this.info,{super.key});

  @override
  Widget build(BuildContext context) {
    List<dynamic> proficiencies=info["proficiencies"];

    List<dynamic> features = info["features"];

    List<dynamic> archetypes = info["archetypes"];

    Map<String, dynamic> attacks= {};

    Map<String,dynamic> spells={};

    if(info["attacksPerLevel"][19].toString()!="1"){
      List<dynamic> atts=info["attacksPerLevel"].toSet().toList();
      List<dynamic> attackLevels=[];
      int lastnum=0;
      for(int i=0;i<20;i++){
        if (lastnum!=info["attacksPerLevel"][i]){
          attackLevels.add(i+1);
          lastnum=info["attacksPerLevel"][i];
        }
      }

      attacks= {
        "Level":attackLevels,
        "Attacks":atts
      };
    }

    if(info["spells"]["casterLevel"]!=0){
      List<dynamic> keys=info["spells"].keys.toList();
      spells["level"]=[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20];
      for (int i=0;i<keys.length;i++){
        if(keys[i].toString().toLowerCase()!="casterlevel"&&keys[i].toString().toLowerCase()!="spellcastingability"){
          spells[keys[i]]=info["spells"][keys[i]];
        }
      }
    }

    return Column(
      spacing: 20,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SavingThrowWidget(info["savingThrows"]),
        if(info["spells"]["casterLevel"]!=0)
          DescriptionWidget("Spellcasting", null, TableWidget(spells), "sectionDescriptionType"),
        if(info["attacksPerLevel"][19].toString()!="1")
          DescriptionWidget("Attacks per level",null,TableWidget(attacks),"sectionDescriptionType"),
        SectionWidget("Proficiencies", proficiencies, "proficiencyDisplayStyle"),
        SectionWidget("Features", features, "featureDisplayStyle"),
        SectionWidget("Archetypes", archetypes, "archetypeDisplayStyle"),
      ],
    );
  }
} 



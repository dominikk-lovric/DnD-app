import 'package:dnd_app/services/string_service.dart';
import 'package:dnd_app/services/text_style_service.dart';
import 'package:dnd_app/widgets/description_widget.dart';
import 'package:dnd_app/widgets/list_widget.dart';
import 'package:dnd_app/widgets/saving_throws_widget.dart';
import 'package:flutter/material.dart';

class BackgroundInfoWidget extends StatefulWidget {
  Map<String, dynamic> info;
  int sectionLevel;
  int subtitleLevel;
  int descriptionLevel;
  BackgroundInfoWidget(
    this.info, {
    super.key,
    this.sectionLevel = 1,
    this.subtitleLevel = 2,
    this.descriptionLevel = 3,
  });

  @override
  State<StatefulWidget> createState() => BackgroundInfoWidgetState();
}

class BackgroundInfoWidgetState extends State<BackgroundInfoWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<String> equipmentList = [];
    for (final list in widget.info["equipment"]) {
      equipmentList.add(StringService.choicesFromString(list, "and"));
    }
    return Column(
      children: [
        Text(
          widget.info["description"],
          style: TextStyleService.getTextStyle(4, 4),
        ),
        DescriptionWidget(
          "Ability Scores",
          CheckListWidget([
            "Str",
            "Dex",
            "Con",
            "Int",
            "Wis",
            "Cha",
          ], widget.info["abilities"]),
          "abilityScoresDescriptionStyle",
        ),
        DescriptionWidget(
          "Skills",
          ListWidget(widget.info["skills"]),
          "skillDescriptionType",
        ),
        DescriptionWidget(
          "Tools",
          Text(
            widget.info["tools"].toString(),
            style: TextStyleService.getTextStyle(4, 4),
          ),
          "toolDescriptionStyle",
        ),

        DescriptionWidget(
          "Equipment",
          ListWidget(equipmentList),
          "equipmentDescriptionStyle",
        ),
      ],
    );
  }
}

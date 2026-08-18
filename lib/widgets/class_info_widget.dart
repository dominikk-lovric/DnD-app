import 'package:dnd_app/services/color_service.dart';
import 'package:dnd_app/services/json_service.dart';
import 'package:dnd_app/services/settings_service.dart';
import 'package:dnd_app/services/string_service.dart';
import 'package:dnd_app/services/text_style_service.dart';
import 'package:dnd_app/widgets/description_widget.dart';
import 'package:dnd_app/widgets/feature_description_widget.dart';
import 'package:dnd_app/widgets/list_widget.dart';
import 'package:dnd_app/widgets/table_widget.dart';
import 'package:flutter/material.dart';

import 'package:dnd_app/widgets/table_widget.dart';
import 'package:dnd_app/widgets/saving_throws_widget.dart';

class ClassInfoWidget extends StatefulWidget {
  Map<String, dynamic> info;
  int sectionLevel;
  int subtitleLevel;
  int descriptionLevel;
  ClassInfoWidget(
    this.info, {
    super.key,
    this.sectionLevel = 1,
    this.subtitleLevel = 2,
    this.descriptionLevel = 3,
  });

  @override
  createState() => ClassInfoWidgetState(info);
}

class ClassInfoWidgetState extends State<ClassInfoWidget> {
  Map<String, dynamic> info;
  ClassInfoWidgetState(this.info);

  List<Map<String, dynamic>> subclasses = [];

  @override
  void initState() {
    super.initState();

    subclasses = [];

    if (info["archetypes"][0]["features"] is String) {
      print("string");
      for (final item in info["archetypes"]) {
        loadFileAndAdd(item["features"]);
      }
    } else {
      print("list");
      for (final item in info["archetypes"]) {
        subclasses.add(item);
      }
    }
  }

  Future<void> loadFileAndAdd(String fileName) async {
    final json = await JsonService.loadFromPath(fileName);
    setState(() {
      subclasses.add(json);
    });
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> proficiencies = info["proficiencies"];

    List<dynamic> features = info["features"];

    List<dynamic> archetypes = info["archetypes"];

    Map<String, dynamic> attacks = {};

    Map<String, dynamic> spells = {};

    if (info["attacksPerLevel"][19].toString() != "1") {
      List<dynamic> atts = info["attacksPerLevel"].toSet().toList();
      List<dynamic> attackLevels = [];
      int lastnum = 0;
      for (int i = 0; i < 20; i++) {
        if (lastnum != info["attacksPerLevel"][i]) {
          attackLevels.add(i + 1);
          lastnum = info["attacksPerLevel"][i];
        }
      }

      attacks = {"Level": attackLevels, "Attacks": atts};
    }

    if (info["spells"]["casterLevel"] != 0) {
      List<dynamic> keys = info["spells"].keys.toList();
      spells["level"] = List.generate(20, (i) => i + 1);
      for (int i = 0; i < keys.length; i++) {
        if (keys[i].toString().toLowerCase() != "casterlevel" &&
            keys[i].toString().toLowerCase() != "spellcastingability" &&
            keys[i].toString().toLowerCase() != "addedSpells") {
          spells[keys[i]] = info["spells"][keys[i]];
        }
      }
    }
    List<String> equipmentList = [];
    for (final list in info["startingEquipment"]) {
      equipmentList.add(StringService.choicesFromString(list, "and"));
    }
    return Column(
      spacing: 20,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          alignment: AlignmentGeometry.center,
          children: [
            Container(child: Icon(Icons.favorite, color: Colors.red, size: 80)),
            Container(
              child: Text(
                info["hitDie"],
                style: TextStyleService.getTextStyle(3, 4),
              ),
            ),
          ],
        ),
        SavingThrowWidget(info["savingThrows"]),

        if (info["spells"]["casterLevel"] != 0)
          DescriptionWidget(
            "Spellcasting",
            TableWidget(spells, 3),
            "sectionDescriptionStyle",
            clickLevel: widget.sectionLevel,
            titleLevel: widget.sectionLevel,
          ),
        if (info["attacksPerLevel"][19].toString() != "1")
          DescriptionWidget(
            "Attacks per level",
            TableWidget(attacks, 3, "horizontal", true),
            "sectionDescriptionStyle",
            clickLevel: widget.sectionLevel,
            titleLevel: widget.sectionLevel,
          ),
        DescriptionWidget(
          "Proficiencies",
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ...proficiencies.map((e) {
                return DescriptionWidget(
                  e["name"],
                  ListWidget(e["proficiencies"], size: widget.descriptionLevel),
                  "proficiencyDescriptionStyle",
                  titleLevel: widget.subtitleLevel,
                );
              }),
            ],
          ),
          "sectionDescriptionStyle",
          titleLevel: widget.sectionLevel,
        ),
        DescriptionWidget(
          "Equipment",
          ListWidget(equipmentList),
          "equipmentDescriptionStyle",
          clickLevel: widget.sectionLevel,
          titleLevel: widget.sectionLevel,
        ),
        DescriptionWidget(
          "Features",
          Padding(
            padding: EdgeInsetsGeometry.directional(start: 20),
            child: Column(
              spacing: 10,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...features.map((element) {
                  return FeatureDescriptionWidget(
                    element,
                    "featureDescriptionStyle",
                    clickLevel: widget.subtitleLevel,
                    levelTitle: true,
                  );
                }),
              ],
            ),
          ),
          "sectionDescriptionStyle",
          titleLevel: widget.sectionLevel,
        ),

        DescriptionWidget(
          "Archetypes",
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ...subclasses.map((el) {
                return DescriptionWidget(
                  el["name"],
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ...el["features"].map((feature) {
                        return FeatureDescriptionWidget(
                          feature,
                          "featureDescriptionStyle",
                          levelTitle: true,
                        );
                      }),
                    ],
                  ),
                  "archetypeDescriptionStyle",
                  titleLevel: 1,
                  clickLevel: widget.subtitleLevel,
                );
              }),
            ],
          ),
          "sectionDescriptionStyle",
          titleLevel: widget.sectionLevel,
        ),
      ],
    );
  }
}


/*





*/
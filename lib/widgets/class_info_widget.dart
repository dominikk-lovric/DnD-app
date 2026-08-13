import 'package:dnd_app/services/color_service.dart';
import 'package:dnd_app/services/settings_service.dart';
import 'package:dnd_app/services/text_style_service.dart';
import 'package:dnd_app/widgets/description_widget.dart';
import 'package:dnd_app/widgets/feature_description_widget.dart';
import 'package:dnd_app/widgets/list_widget.dart';
import 'package:dnd_app/widgets/table_widget.dart';
import 'package:flutter/material.dart';

import 'package:dnd_app/widgets/table_widget.dart';
import 'package:dnd_app/widgets/saving_throws_widget.dart';

import 'package:dnd_app/widgets/section_widget.dart';

class ClassInfoWidget extends StatelessWidget {
  Map<String, dynamic> info;
  ClassInfoWidget(this.info, {super.key});

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
            keys[i].toString().toLowerCase() != "spellcastingability") {
          spells[keys[i]] = info["spells"][keys[i]];
        }
      }
    }
    return Column(
      spacing: 20,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SavingThrowWidget(info["savingThrows"]),
        if (info["spells"]["casterLevel"] != 0)
          DescriptionWidget(
            "Spellcasting",
            null,
            TableWidget(spells),
            "sectionDescriptionType",
          ),
        if (info["attacksPerLevel"][19].toString() != "1")
          DescriptionWidget(
            "Attacks per level",
            null,
            TableWidget(attacks, "horizontal"),
            "sectionDescriptionType",
          ),
        SectionWidget(
          "Proficiencies",
          proficiencies,
          "proficiencyDisplayStyle",
        ),

        DescriptionWidget(
          "Features",
          null,
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
                  );
                }),
              ],
            ),
          ),
          "tableDescriptionStyle",
          titleLevel: 1,
        ),

        SectionWidget("Archetypes", archetypes, "archetypeDisplayStyle"),
      ],
    );
  }
}

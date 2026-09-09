import 'dart:math';

import 'package:dnd_app/services/text_style_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:dnd_app/screens/home_page.dart';
import 'package:dnd_app/services/settings_service.dart';
import 'package:dnd_app/services/icon_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);

  IconService.initAssets(manifest.listAssets().toSet());

  await SettingsService.init();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<StatefulWidget> createState() => _MyApp();
}

class _MyApp extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await initSettings();
    });
  }

  Future<void> initSettings() async {
    final height = MediaQuery.sizeOf(context).height;
    final width = MediaQuery.sizeOf(context).width;
    await SettingsService.setSetting("theme", "base");
    await SettingsService.setSetting("headerHeight", height * 0.14);
    await SettingsService.setSetting("listItemHeight", height * 0.10);
    await SettingsService.setSetting("globalDescriptionStyle", "popUp");
    await SettingsService.setSetting("groupItemsWiki", true);
    await setFontHeight(height, width);
    if (SettingsService.getSetting("init") == null ||
        SettingsService.getSetting("init") == false) {
      await initWikiSettings();
    }
  }

  Future<void> setFontHeight(double height, double width) async {
    await SettingsService.setSetting("baseFontSize", sqrt(width / height) * 40);
  }

  Future<void> initWikiSettings() async {
    await SettingsService.initSetting("classesDescriptionStylebgColor", false);
    await SettingsService.initSetting(
      "hit-dieclassesDescriptionStylebgColor",
      true,
    );
    await SettingsService.initSetting(
      "saving-throwsclassesDescriptionStylebgColor",
      true,
    );
    await SettingsService.initSetting(
      "attacks-per-levelclassesDescriptionStylebgColor",
      true,
    );
    await SettingsService.initSetting(
      "proficienciesclassesDescriptionStylebgColor",
      true,
    );
    await SettingsService.initSetting(
      "starting-equipmentclassesDescriptionStylebgColor",
      true,
    );
    await SettingsService.initSetting(
      "featuresclassesDescriptionStylebgColor",
      true,
    );
    await SettingsService.initSetting(
      "archetypesclassesDescriptionStylebgColor",
      true,
    );
    await SettingsService.initSetting("hit-dieclassesDescriptionStyle", "text");
    await SettingsService.initSetting(
      "saving-throwsclassesDescriptionStyle",
      "expand",
    );
    await SettingsService.initSetting(
      "attacks-per-levelclassesDescriptionStyle",
      "expand",
    );
    await SettingsService.initSetting(
      "proficienciesclassesDescriptionStyle",
      "expand",
    );
    await SettingsService.initSetting(
      "mapItemSkillproficienciesclassesDescriptionStyle",
      "expand",
    );
    await SettingsService.initSetting(
      "mapItemoptionsmapItemSkillproficienciesclassesDescriptionStyle",
      "text",
    );
    await SettingsService.initSetting(
      "mapItemproficienciesmapItemSkillproficienciesclassesDescriptionStyle",
      "static",
    );
    await SettingsService.initSetting(
      "listEntrymapItemproficienciesmapItemSkillproficienciesclassesDescriptionStyle",
      "static",
    );
    await SettingsService.initSetting(
      "mapItemArmorproficienciesclassesDescriptionStyle",
      "expand",
    );
    await SettingsService.initSetting(
      "mapItemproficienciesmapItemArmorproficienciesclassesDescriptionStyle",
      "static",
    );
    await SettingsService.initSetting(
      "listEntrymapItemproficienciesmapItemArmorproficienciesclassesDescriptionStyle",
      "static",
    );
    await SettingsService.initSetting(
      "mapItemWeaponproficienciesclassesDescriptionStyle",
      "expand",
    );
    await SettingsService.initSetting(
      "mapItemproficienciesmapItemWeaponproficienciesclassesDescriptionStyle",
      "static",
    );
    await SettingsService.initSetting(
      "listEntrymapItemproficienciesmapItemWeaponproficienciesclassesDescriptionStyle",
      "static",
    );
    await SettingsService.initSetting(
      "starting-equipmentclassesDescriptionStyle",
      "expand",
    );
    await SettingsService.initSetting(
      "listEntrystarting-equipmentclassesDescriptionStyle",
      "static",
    );
    await SettingsService.initSetting(
      "listEntrylistEntrystarting-equipmentclassesDescriptionStyle",
      "static",
    );
    await SettingsService.initSetting(
      "featuresclassesDescriptionStyle",
      "expand",
    );
    await SettingsService.initSetting(
      "mapItemdefaultfeaturesclassesDescriptionStyle",
      "popUp",
    );
    await SettingsService.initSetting(
      "usesfeaturesDescriptionStylebgColor",
      false,
    );
    await SettingsService.initSetting("levelfeaturesDescriptionStyle", "text");
    await SettingsService.initSetting(
      "descriptionfeaturesDescriptionStyle",
      "static",
    );
    await SettingsService.initSetting("usesfeaturesDescriptionStyle", "expand");
    await SettingsService.initSetting(
      "mapItemamountPerLevelusesfeaturesDescriptionStyle",
      "expand",
    );
    await SettingsService.initSetting(
      "mapItemreplenishusesfeaturesDescriptionStyle",
      "expand",
    );
    await SettingsService.initSetting(
      "mapItemdefaultmapItemreplenishusesfeaturesDescriptionStyle",
      "expand",
    );
    await SettingsService.initSetting(
      "mapItemamountmapItemdefaultmapItemreplenishusesfeaturesDescriptionStyle",
      "text",
    );
    await SettingsService.initSetting(
      "mapItemamountPerLevelmapItemdefaultmapItemreplenishusesfeaturesDescriptionStyle",
      "expand",
    );
    await SettingsService.initSetting(
      "optionsfeaturesDescriptionStyle",
      "expand",
    );
    await SettingsService.initSetting(
      "mapItemamountoptionsfeaturesDescriptionStyle",
      "text",
    );
    await SettingsService.initSetting(
      "mapItemamountPerLeveloptionsfeaturesDescriptionStyle",
      "expand",
    );
    await SettingsService.initSetting(
      "archetypesclassesDescriptionStyle",
      "expand",
    );
    await SettingsService.initSetting(
      "mapItemdefaultarchetypesclassesDescriptionStyle",
      "sheet",
    );
    await SettingsService.initSetting(
      "creature-typespeciesDescriptionStylebgColor",
      true,
    );
    await SettingsService.initSetting(
      "sizespeciesDescriptionStylebgColor",
      true,
    );
    await SettingsService.initSetting(
      "speedspeciesDescriptionStylebgColor",
      true,
    );
    await SettingsService.initSetting(
      "featuresspeciesDescriptionStylebgColor",
      true,
    );
    await SettingsService.initSetting(
      "creature-typespeciesDescriptionStyle",
      "text",
    );
    await SettingsService.initSetting("sizespeciesDescriptionStyle", "expand");
    await SettingsService.initSetting(
      "listEntrysizespeciesDescriptionStyle",
      "static",
    );
    await SettingsService.initSetting("speedspeciesDescriptionStyle", "text");
    await SettingsService.initSetting(
      "featuresspeciesDescriptionStyle",
      "expand",
    );
    await SettingsService.initSetting(
      "subspeciesspeciesDescriptionStylebgColor",
      true,
    );
    await SettingsService.initSetting(
      "subspeciesspeciesDescriptionStyle",
      "expand",
    );
    await SettingsService.initSetting(
      "mapItemdefaultsubspeciesspeciesDescriptionStyle",
      "sheet",
    );
    await SettingsService.initSetting(
      "spellsspeciesDescriptionStylebgColor",
      true,
    );
    await SettingsService.initSetting(
      "spellsspeciesDescriptionStyle",
      "expand",
    );
    await SettingsService.initSetting(
      "mapItemaddedSpellsspellsspeciesDescriptionStyle",
      "expand",
    );
    await SettingsService.initSetting(
      "levelspellsDescriptionStylebgColor",
      true,
    );
    await SettingsService.initSetting(
      "schoolspellsDescriptionStylebgColor",
      true,
    );
    await SettingsService.initSetting(
      "spell-listspellsDescriptionStylebgColor",
      true,
    );
    await SettingsService.initSetting(
      "casting-timespellsDescriptionStylebgColor",
      true,
    );
    await SettingsService.initSetting(
      "rangespellsDescriptionStylebgColor",
      true,
    );
    await SettingsService.initSetting(
      "componentsspellsDescriptionStylebgColor",
      true,
    );
    await SettingsService.initSetting(
      "materialsspellsDescriptionStylebgColor",
      true,
    );
    await SettingsService.initSetting(
      "durationspellsDescriptionStylebgColor",
      true,
    );
    await SettingsService.initSetting(
      "concentrationspellsDescriptionStylebgColor",
      true,
    );
    await SettingsService.initSetting(
      "descriptionspellsDescriptionStylebgColor",
      true,
    );
    await SettingsService.initSetting("classesDescriptionStyle", "sheet");
    await SettingsService.initSetting("spellsDescriptionStyle", "sheet");
    await SettingsService.initSetting("levelspellsDescriptionStyle", "text");
    await SettingsService.initSetting("schoolspellsDescriptionStyle", "text");
    await SettingsService.initSetting(
      "spell-listspellsDescriptionStyle",
      "expand",
    );
    await SettingsService.initSetting(
      "listEntryspell-listspellsDescriptionStyle",
      "static",
    );
    await SettingsService.initSetting(
      "casting-timespellsDescriptionStyle",
      "expand",
    );
    await SettingsService.initSetting(
      "listEntrycasting-timespellsDescriptionStyle",
      "static",
    );
    await SettingsService.initSetting("rangespellsDescriptionStyle", "text");
    await SettingsService.initSetting(
      "componentsspellsDescriptionStyle",
      "expand",
    );
    await SettingsService.initSetting(
      "listEntrycomponentsspellsDescriptionStyle",
      "static",
    );
    await SettingsService.initSetting(
      "materialsspellsDescriptionStyle",
      "text",
    );
    await SettingsService.initSetting(
      "durationspellsDescriptionStyle",
      "expand",
    );
    await SettingsService.initSetting(
      "listEntrydurationspellsDescriptionStyle",
      "static",
    );
    await SettingsService.initSetting(
      "concentrationspellsDescriptionStyle",
      "text",
    );
    await SettingsService.initSetting(
      "descriptionspellsDescriptionStyle",
      "static",
    );
    await SettingsService.initSetting("featsDescriptionStyle", "sheet");
    await SettingsService.initSetting("typefeatsDescriptionStylebgColor", true);
    await SettingsService.initSetting(
      "descriptionfeatsDescriptionStylebgColor",
      true,
    );
    await SettingsService.initSetting(
      "featuresfeatsDescriptionStylebgColor",
      true,
    );
    await SettingsService.initSetting("typefeatsDescriptionStyle", "text");
    await SettingsService.initSetting(
      "descriptionfeatsDescriptionStyle",
      "static",
    );
    await SettingsService.initSetting(
      "featuresfeatsDescriptionStyle",
      "expand",
    );
    await SettingsService.initSetting("backgroundsDescriptionStyle", "sheet");
    await SettingsService.initSetting(
      "descriptionbackgroundsDescriptionStylebgColor",
      true,
    );
    await SettingsService.initSetting(
      "abilitiesbackgroundsDescriptionStylebgColor",
      true,
    );
    await SettingsService.initSetting(
      "featbackgroundsDescriptionStylebgColor",
      true,
    );
    await SettingsService.initSetting(
      "skillsbackgroundsDescriptionStylebgColor",
      true,
    );
    await SettingsService.initSetting(
      "toolsbackgroundsDescriptionStylebgColor",
      true,
    );
    await SettingsService.initSetting(
      "equipmentbackgroundsDescriptionStylebgColor",
      true,
    );
    await SettingsService.initSetting(
      "descriptionbackgroundsDescriptionStyle",
      "static",
    );
    await SettingsService.initSetting(
      "abilitiesbackgroundsDescriptionStyle",
      "expand",
    );
    await SettingsService.initSetting(
      "listEntryabilitiesbackgroundsDescriptionStyle",
      "static",
    );
    await SettingsService.initSetting(
      "featbackgroundsDescriptionStyle",
      "expand",
    );
    await SettingsService.initSetting(
      "listEntryfeatbackgroundsDescriptionStyle",
      "popUp",
    );
    await SettingsService.initSetting(
      "skillsbackgroundsDescriptionStyle",
      "expand",
    );
    await SettingsService.initSetting(
      "listEntryskillsbackgroundsDescriptionStyle",
      "static",
    );
    await SettingsService.initSetting(
      "toolsbackgroundsDescriptionStyle",
      "text",
    );
    await SettingsService.initSetting(
      "equipmentbackgroundsDescriptionStyle",
      "expand",
    );
    await SettingsService.initSetting(
      "listEntryequipmentbackgroundsDescriptionStyle",
      "expand",
    );
    await SettingsService.initSetting(
      "listEntrylistEntryequipmentbackgroundsDescriptionStyle",
      "static",
    );

    await SettingsService.setSetting("wikiSorting", [
      "primary",
      "speed",
      "level",
      "featType",
      "source",
    ]);

    await SettingsService.setSetting("wikiGrouping", [
      "true",
      "true",
      "true",
      "true",
      "true",
    ]);

    await SettingsService.setSetting("primarySubSort", [
      "Str",
      "Dex",
      "Con",
      "Int",
      "Wis",
      "Cha",
    ]);

    await SettingsService.setSetting("featTypeSubSort", [
      "Origin Feat",
      "General Feat",
      "Fighting Style Feat",
      "Epic Boon Feat",
      "Dragonmark Feat",
      "Planar Pact Feat",
      "Dark Gift Feat",
    ]);
    await SettingsService.setSetting("sourceSubSort", [
      "Player's Handbook",
      "Forgotten Realms - Heroes of Faerun",
      "Astarion's Book of Hungers",
      "Lorwyn - First Light",
      "Eberron - Forge of the Artificer",
      "D&D Beyond Drops - May 2026",
      "D&D Beyond Drops - July 2026",
      "Ravenloft - The Horrors Within",
      "D&D Beyond Drops - August 2026",
    ]);

    await SettingsService.setSetting("primarySubSortStandard", [
      "Str",
      "Dex",
      "Con",
      "Int",
      "Wis",
      "Cha",
    ]);

    await SettingsService.setSetting("featTypeSubSortStandard", [
      "Origin Feat",
      "General Feat",
      "Fighting Style Feat",
      "Epic Boon Feat",
      "Dragonmark Feat",
      "Planar Pact Feat",
      "Dark Gift Feat",
    ]);
    await SettingsService.setSetting("sourceSubSortStandard", [
      "Player's Handbook",
      "Forgotten Realms - Heroes of Faerun",
      "Astarion's Book of Hungers",
      "Lorwyn - First Light",
      "Eberron - Forge of the Artificer",
      "D&D Beyond Drops - May 2026",
      "D&D Beyond Drops - July 2026",
      "Ravenloft - The Horrors Within",
      "D&D Beyond Drops - August 2026",
    ]);
    await SettingsService.setSetting("init", true);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JSON Demo',
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}

/*
           |\
___________| \
              \
________       \
   o    |      |
________|      |
               |__
    _____         |
   |__|__|      __|
   |__|__|      |
              /
__________   /
          | /
--O       |/
*/

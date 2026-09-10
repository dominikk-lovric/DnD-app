import 'dart:io';
import 'dart:math';

import 'package:dnd_app/services/text_style_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:device_info_plus/device_info_plus.dart';

import 'package:dnd_app/screens/home_page.dart';
import 'package:dnd_app/services/settings_service.dart';
import 'package:dnd_app/services/icon_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);

  IconService.initAssets(manifest.listAssets().toSet());

  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyApp();
}

class _MyApp extends ConsumerState<MyApp> {
  late final SettingsController controller;
  @override
  void initState() {
    super.initState();
    controller = ref.read(settingsControllerProvider.notifier);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await initSettings();
    });
  }

  Future<void> initSettings() async {
    switch (Platform.operatingSystem) {
      case "android":
        await controller.setSetting("bottomPadding", 48.0);
        break;
      case "fuchsia":
        await controller.setSetting("bottomPadding", 0.0);
        break;
      case "ios":
        await controller.setSetting("bottomPadding", 48.0);
        break;
      case "linux":
        await controller.setSetting("bottomPadding", 0.0);
        break;
      case "macos":
        await controller.setSetting("bottomPadding", 0.0);
        break;
      case "windows":
        await controller.setSetting("bottomPadding", 0.0);
        break;
    }

    final height = MediaQuery.sizeOf(context).height;
    final width = MediaQuery.sizeOf(context).width;
    await controller.setSetting("height", height);
    await controller.setSetting("width", width);
    await controller.setSetting("theme", "base");
    await controller.setSetting("headerHeight", 0.07);
    await controller.setSetting("listItemHeight", 0.10);
    await controller.setSetting("globalDescriptionStyle", "popUp");
    await controller.setSetting("groupItemsWiki", true);
    await setFontHeight(height, width);
    if (controller.getSetting("init") == null ||
        controller.getSetting("init") == false) {
      await initWikiSettings();
    }
  }

  Future<void> setFontHeight(double height, double width) async {
    await controller.setSetting("baseFontSize", sqrt(width / height) * 40);
  }

  Future<void> initWikiSettings() async {
    await controller.initSetting("classesDescriptionStylebgColor", false);
    await controller.initSetting("hit-dieclassesDescriptionStylebgColor", true);
    await controller.initSetting(
      "saving-throwsclassesDescriptionStylebgColor",
      true,
    );
    await controller.initSetting(
      "attacks-per-levelclassesDescriptionStylebgColor",
      true,
    );
    await controller.initSetting(
      "proficienciesclassesDescriptionStylebgColor",
      true,
    );
    await controller.initSetting(
      "starting-equipmentclassesDescriptionStylebgColor",
      true,
    );
    await controller.initSetting(
      "featuresclassesDescriptionStylebgColor",
      true,
    );
    await controller.initSetting(
      "archetypesclassesDescriptionStylebgColor",
      true,
    );
    await controller.initSetting("hit-dieclassesDescriptionStyle", "text");
    await controller.initSetting(
      "saving-throwsclassesDescriptionStyle",
      "expand",
    );
    await controller.initSetting(
      "attacks-per-levelclassesDescriptionStyle",
      "expand",
    );
    await controller.initSetting(
      "proficienciesclassesDescriptionStyle",
      "expand",
    );
    await controller.initSetting(
      "mapItemSkillproficienciesclassesDescriptionStyle",
      "expand",
    );
    await controller.initSetting(
      "mapItemoptionsmapItemSkillproficienciesclassesDescriptionStyle",
      "text",
    );
    await controller.initSetting(
      "mapItemproficienciesmapItemSkillproficienciesclassesDescriptionStyle",
      "static",
    );
    await controller.initSetting(
      "listEntrymapItemproficienciesmapItemSkillproficienciesclassesDescriptionStyle",
      "static",
    );
    await controller.initSetting(
      "mapItemArmorproficienciesclassesDescriptionStyle",
      "expand",
    );
    await controller.initSetting(
      "mapItemproficienciesmapItemArmorproficienciesclassesDescriptionStyle",
      "static",
    );
    await controller.initSetting(
      "listEntrymapItemproficienciesmapItemArmorproficienciesclassesDescriptionStyle",
      "static",
    );
    await controller.initSetting(
      "mapItemWeaponproficienciesclassesDescriptionStyle",
      "expand",
    );
    await controller.initSetting(
      "mapItemproficienciesmapItemWeaponproficienciesclassesDescriptionStyle",
      "static",
    );
    await controller.initSetting(
      "listEntrymapItemproficienciesmapItemWeaponproficienciesclassesDescriptionStyle",
      "static",
    );
    await controller.initSetting(
      "starting-equipmentclassesDescriptionStyle",
      "expand",
    );
    await controller.initSetting(
      "listEntrystarting-equipmentclassesDescriptionStyle",
      "static",
    );
    await controller.initSetting(
      "listEntrylistEntrystarting-equipmentclassesDescriptionStyle",
      "static",
    );
    await controller.initSetting("featuresclassesDescriptionStyle", "expand");
    await controller.initSetting(
      "mapItemdefaultfeaturesclassesDescriptionStyle",
      "popUp",
    );
    await controller.initSetting("usesfeaturesDescriptionStylebgColor", false);
    await controller.initSetting("levelfeaturesDescriptionStyle", "text");
    await controller.initSetting(
      "descriptionfeaturesDescriptionStyle",
      "static",
    );
    await controller.initSetting("usesfeaturesDescriptionStyle", "expand");
    await controller.initSetting(
      "mapItemamountPerLevelusesfeaturesDescriptionStyle",
      "expand",
    );
    await controller.initSetting(
      "mapItemreplenishusesfeaturesDescriptionStyle",
      "expand",
    );
    await controller.initSetting(
      "mapItemdefaultmapItemreplenishusesfeaturesDescriptionStyle",
      "expand",
    );
    await controller.initSetting(
      "mapItemamountmapItemdefaultmapItemreplenishusesfeaturesDescriptionStyle",
      "text",
    );
    await controller.initSetting(
      "mapItemamountPerLevelmapItemdefaultmapItemreplenishusesfeaturesDescriptionStyle",
      "expand",
    );
    await controller.initSetting("optionsfeaturesDescriptionStyle", "expand");
    await controller.initSetting(
      "mapItemamountoptionsfeaturesDescriptionStyle",
      "text",
    );
    await controller.initSetting(
      "mapItemamountPerLeveloptionsfeaturesDescriptionStyle",
      "expand",
    );
    await controller.initSetting("archetypesclassesDescriptionStyle", "expand");
    await controller.initSetting(
      "mapItemdefaultarchetypesclassesDescriptionStyle",
      "sheet",
    );
    await controller.initSetting(
      "creature-typespeciesDescriptionStylebgColor",
      true,
    );
    await controller.initSetting("sizespeciesDescriptionStylebgColor", true);
    await controller.initSetting("speedspeciesDescriptionStylebgColor", true);
    await controller.initSetting(
      "featuresspeciesDescriptionStylebgColor",
      true,
    );
    await controller.initSetting(
      "creature-typespeciesDescriptionStyle",
      "text",
    );
    await controller.initSetting("sizespeciesDescriptionStyle", "expand");
    await controller.initSetting(
      "listEntrysizespeciesDescriptionStyle",
      "static",
    );
    await controller.initSetting("speedspeciesDescriptionStyle", "text");
    await controller.initSetting("featuresspeciesDescriptionStyle", "expand");
    await controller.initSetting(
      "subspeciesspeciesDescriptionStylebgColor",
      true,
    );
    await controller.initSetting("subspeciesspeciesDescriptionStyle", "expand");
    await controller.initSetting(
      "mapItemdefaultsubspeciesspeciesDescriptionStyle",
      "sheet",
    );
    await controller.initSetting("spellsspeciesDescriptionStylebgColor", true);
    await controller.initSetting("spellsspeciesDescriptionStyle", "expand");
    await controller.initSetting(
      "mapItemaddedSpellsspellsspeciesDescriptionStyle",
      "expand",
    );
    await controller.initSetting("levelspellsDescriptionStylebgColor", true);
    await controller.initSetting("schoolspellsDescriptionStylebgColor", true);
    await controller.initSetting(
      "spell-listspellsDescriptionStylebgColor",
      true,
    );
    await controller.initSetting(
      "casting-timespellsDescriptionStylebgColor",
      true,
    );
    await controller.initSetting("rangespellsDescriptionStylebgColor", true);
    await controller.initSetting(
      "componentsspellsDescriptionStylebgColor",
      true,
    );
    await controller.initSetting(
      "materialsspellsDescriptionStylebgColor",
      true,
    );
    await controller.initSetting("durationspellsDescriptionStylebgColor", true);
    await controller.initSetting(
      "concentrationspellsDescriptionStylebgColor",
      true,
    );
    await controller.initSetting(
      "descriptionspellsDescriptionStylebgColor",
      true,
    );
    await controller.initSetting("classesDescriptionStyle", "sheet");
    await controller.initSetting("spellsDescriptionStyle", "sheet");
    await controller.initSetting("levelspellsDescriptionStyle", "text");
    await controller.initSetting("schoolspellsDescriptionStyle", "text");
    await controller.initSetting("spell-listspellsDescriptionStyle", "expand");
    await controller.initSetting(
      "listEntryspell-listspellsDescriptionStyle",
      "static",
    );
    await controller.initSetting(
      "casting-timespellsDescriptionStyle",
      "expand",
    );
    await controller.initSetting(
      "listEntrycasting-timespellsDescriptionStyle",
      "static",
    );
    await controller.initSetting("rangespellsDescriptionStyle", "text");
    await controller.initSetting("componentsspellsDescriptionStyle", "expand");
    await controller.initSetting(
      "listEntrycomponentsspellsDescriptionStyle",
      "static",
    );
    await controller.initSetting("materialsspellsDescriptionStyle", "text");
    await controller.initSetting("durationspellsDescriptionStyle", "expand");
    await controller.initSetting(
      "listEntrydurationspellsDescriptionStyle",
      "static",
    );
    await controller.initSetting("concentrationspellsDescriptionStyle", "text");
    await controller.initSetting("descriptionspellsDescriptionStyle", "static");
    await controller.initSetting("featsDescriptionStyle", "sheet");
    await controller.initSetting("typefeatsDescriptionStylebgColor", true);
    await controller.initSetting(
      "descriptionfeatsDescriptionStylebgColor",
      true,
    );
    await controller.initSetting("featuresfeatsDescriptionStylebgColor", true);
    await controller.initSetting("typefeatsDescriptionStyle", "text");
    await controller.initSetting("descriptionfeatsDescriptionStyle", "static");
    await controller.initSetting("featuresfeatsDescriptionStyle", "expand");
    await controller.initSetting("backgroundsDescriptionStyle", "sheet");
    await controller.initSetting(
      "descriptionbackgroundsDescriptionStylebgColor",
      true,
    );
    await controller.initSetting(
      "abilitiesbackgroundsDescriptionStylebgColor",
      true,
    );
    await controller.initSetting(
      "featbackgroundsDescriptionStylebgColor",
      true,
    );
    await controller.initSetting(
      "skillsbackgroundsDescriptionStylebgColor",
      true,
    );
    await controller.initSetting(
      "toolsbackgroundsDescriptionStylebgColor",
      true,
    );
    await controller.initSetting(
      "equipmentbackgroundsDescriptionStylebgColor",
      true,
    );
    await controller.initSetting(
      "descriptionbackgroundsDescriptionStyle",
      "static",
    );
    await controller.initSetting(
      "abilitiesbackgroundsDescriptionStyle",
      "expand",
    );
    await controller.initSetting(
      "listEntryabilitiesbackgroundsDescriptionStyle",
      "static",
    );
    await controller.initSetting("featbackgroundsDescriptionStyle", "expand");
    await controller.initSetting(
      "listEntryfeatbackgroundsDescriptionStyle",
      "popUp",
    );
    await controller.initSetting("skillsbackgroundsDescriptionStyle", "expand");
    await controller.initSetting(
      "listEntryskillsbackgroundsDescriptionStyle",
      "static",
    );
    await controller.initSetting("toolsbackgroundsDescriptionStyle", "text");
    await controller.initSetting(
      "equipmentbackgroundsDescriptionStyle",
      "expand",
    );
    await controller.initSetting(
      "listEntryequipmentbackgroundsDescriptionStyle",
      "expand",
    );
    await controller.initSetting(
      "listEntrylistEntryequipmentbackgroundsDescriptionStyle",
      "static",
    );

    await controller.setSetting("wikiSorting", [
      "primary",
      "speed",
      "level",
      "featType",
      "source",
    ]);

    await controller.setSetting("wikiGrouping", [
      "true",
      "true",
      "true",
      "true",
      "true",
    ]);

    await controller.setSetting("primarySubSort", [
      "Str",
      "Dex",
      "Con",
      "Int",
      "Wis",
      "Cha",
    ]);

    await controller.setSetting("featTypeSubSort", [
      "Origin Feat",
      "General Feat",
      "Fighting Style Feat",
      "Epic Boon Feat",
      "Dragonmark Feat",
      "Planar Pact Feat",
      "Dark Gift Feat",
    ]);
    await controller.setSetting("sourceSubSort", [
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

    await controller.setSetting("primarySubSortStandard", [
      "Str",
      "Dex",
      "Con",
      "Int",
      "Wis",
      "Cha",
    ]);

    await controller.setSetting("featTypeSubSortStandard", [
      "Origin Feat",
      "General Feat",
      "Fighting Style Feat",
      "Epic Boon Feat",
      "Dragonmark Feat",
      "Planar Pact Feat",
      "Dark Gift Feat",
    ]);
    await controller.setSetting("sourceSubSortStandard", [
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
    await controller.setSetting("init", true);
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

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
      final height = MediaQuery.sizeOf(context).height;

      await SettingsService.setSetting("theme", "base");

      await SettingsService.setSetting("tableDescriptionStyle", "expand");

      await SettingsService.setSetting("proficiencyDescriptionStyle", "sheet");
      await SettingsService.setSetting("featureDescriptionStyle", "sheet");
      await SettingsService.setSetting("proficiencyDescriptionStyle", "expand");
      await SettingsService.setSetting("archetypeDescriptionStyle", "sheet");
      await SettingsService.setSetting("sectionDescriptionStyle", "expand");

      await SettingsService.setSetting("sizeDescriptionStyle", "expand");
      await SettingsService.setSetting("subspeciesDescriptionType", "sheet");
      await SettingsService.setSetting("skillDescriptionType", "expand");
      await SettingsService.setSetting("equipmentDescriptionStyle", "expand");
      await SettingsService.setSetting("toolDescriptionStyle", "expand");

      await SettingsService.setSetting(
        "abilityScoresDescriptionStyle",
        "expand",
      );

      await SettingsService.setSetting("wikiSorting", [
        "primary",
        "speed",
        "alphabetical",
        "featType",
        "source",
      ]);

      await SettingsService.setSetting("abilitySubSort", [
        "Str",
        "Dex",
        "Con",
        "Int",
        "Wis",
        "Cha",
      ]);

      await SettingsService.setSetting("featSubSort", [
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
        "DND Beyond Drops - July 2026",
        "Ravenloft - The Horrors Within",
        "D&D Beyond Drops - August 2026",
      ]);

      await SettingsService.setSetting("groupItemsWiki", true);
      await SettingsService.setSetting("headerHeight", height * 0.14);
      await SettingsService.setSetting("listItemHeight", height * 0.10);
    });
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

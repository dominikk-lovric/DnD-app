
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


import 'package:dnd_app/screens/home_page.dart';
import 'package:dnd_app/services/settings_service.dart';
import 'package:dnd_app/services/icon_service.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);

  IconService.initAssets(
    manifest.listAssets().toSet(),
  );


  await SettingsService.init();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<StatefulWidget> createState() => _MyApp();

  
}

class _MyApp extends State<MyApp>{

  @override
  void initState(){
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final height = MediaQuery.sizeOf(context).height;

      await SettingsService.setSetting("theme", "base");
      await SettingsService.setSetting("proficiencyDescriptionStyle", "sheet");
      await SettingsService.setSetting("featureDescriptionStyle", "sheet");
      await SettingsService.setSetting("proficiencyDisplayStyle", "expand");
      await SettingsService.setSetting("featureDisplayStyle", "popUp");
      await SettingsService.setSetting("archetypeDisplayStyle", "sheet");
      await SettingsService.setSetting("sectionDescriptionType", "expand");
      await SettingsService.setSetting("wikiSorting", ["Primary", "alphabetical", "alphabetical", "alphabetical", "alphabetical"]);
      await SettingsService.setSetting("groupItemsWiki", true);
      await SettingsService.setSetting("headerHeight",height * 0.14);
      await SettingsService.setSetting("listItemHeight",height * 0.10);


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




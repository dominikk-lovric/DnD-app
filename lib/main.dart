import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:dnd_app/services/color_service.dart';
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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JSON Demo',
      debugShowCheckedModeBanner: false,
      home: const HomePage(10),
    );
  }
}




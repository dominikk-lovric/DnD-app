import 'package:dnd_app/screens/character_selection_page.dart';
import 'package:flutter/material.dart';

import 'package:dnd_app/services/settings_service.dart';
import 'package:dnd_app/services/color_service.dart';
import 'package:dnd_app/services/text_style_service.dart';

import 'package:dnd_app/screens/wiki_page.dart';
import 'package:dnd_app/screens/settings_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(settingsControllerProvider);
    ref.watch(colorControllerProvider);
    ref.watch(textStyleControllerProvider);
    final controller = ref.read(settingsControllerProvider.notifier);
    final colorController = ref.read(colorControllerProvider.notifier);
    final textStyleController = ref.read(textStyleControllerProvider.notifier);
    return Scaffold(
      backgroundColor: colorController.getColor(2),
      appBar: AppBar(
        title: Text("Main Page", style: textStyleController.getTextStyle(0, 4)),
        backgroundColor: colorController.getColor(0),
        foregroundColor: colorController.getColor(4),
        centerTitle: true,
        toolbarHeight:
            controller.getSetting("headerHeight") *
            MediaQuery.sizeOf(context).height,
        actions: [
          Padding(
            padding: EdgeInsetsGeometry.directional(end: 10),
            child: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(builder: (context) => SettingsPage()),
                );
              },
              icon: Icon(Icons.settings),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsetsGeometry.directional(
          bottom: controller.getSetting("bottomPadding"),
        ),
        child: Center(
          child: Column(
            spacing: MediaQuery.sizeOf(context).height / 72,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: colorController.getColor(4),
                  backgroundColor: colorController.getColor(0),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (context) => (CharacterSelectionPage()),
                    ),
                  );
                },
                child: Text(
                  'Characters',
                  style: textStyleController.getTextStyle(2, 4),
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: colorController.getColor(4),
                  backgroundColor: colorController.getColor(0),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(builder: (context) => WikiPage()),
                  );
                },
                child: Text(
                  'Wiki',
                  style: textStyleController.getTextStyle(2, 4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

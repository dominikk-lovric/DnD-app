import 'dart:io';

import 'package:dnd_app/services/color_service.dart';
import 'package:dnd_app/services/json_service.dart';
import 'package:dnd_app/services/schema_render_service.dart';
import 'package:dnd_app/services/settings_service.dart';
import 'package:dnd_app/services/text_style_service.dart';
import 'package:dnd_app/widgets/character_creator_widget.dart';
import 'package:dnd_app/widgets/description_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CharacterSelectionPage extends ConsumerStatefulWidget {
  @override
  ConsumerState<CharacterSelectionPage> createState() {
    // TODO: implement createState
    return _CharacterSelectionPageState();
  }
}

class _CharacterSelectionPageState
    extends ConsumerState<CharacterSelectionPage> {
  late final SettingsController settingsController;
  late final ColorController colorController;
  late final TextStyleController textStyleController;

  @override
  void initState() {
    super.initState();

    settingsController = ref.read(settingsControllerProvider.notifier);
    colorController = ref.read(colorControllerProvider.notifier);
    textStyleController = ref.read(textStyleControllerProvider.notifier);
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.escape) {
          Navigator.pop(context);
          return KeyEventResult.handled;
        }

        return KeyEventResult.ignored;
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            "Characters",
            style: textStyleController.getTextStyle(0, 4),
          ),
          backgroundColor: colorController.getColor(0),
          foregroundColor: colorController.getColor(4),
          toolbarHeight:
              settingsController.getSetting("headerHeight") *
              MediaQuery.sizeOf(context).height,
        ),
        backgroundColor: colorController.getColor(2),
        body: Padding(
          padding: EdgeInsetsGeometry.directional(
            bottom: settingsController.getSetting("bottomPadding"),
          ),
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsetsGeometry.symmetric(
                  horizontal: settingsController.getSetting("height") / 72,
                  vertical: settingsController.getSetting("height") / 36,
                ),
                child: Container(),
              ),
              Positioned(
                bottom: settingsController.getSetting("height") / 36,
                right: settingsController.getSetting("height") / 36,
                child: GestureDetector(
                  onLongPressStart: (details) {
                    getCharacterCreatorSelector(details);
                  },
                  onTap: () {},
                  child: FutureBuilder(
                    future: JsonService.loadFromPath("schemata.json"),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Text("Error loading data: ${snapshot.error}");
                      }

                      if (!snapshot.hasData) {
                        return const SizedBox.shrink();
                      }

                      final infoData = Map<String, dynamic>.from(
                        snapshot.data as Map,
                      );

                      return SchemaRenderService.renderItem(
                        ref,
                        context,
                        title: "Character Creator",
                        schemata: infoData,
                        schema:
                            infoData["characterCreator"]["Character Creator"],
                        clickWidget: CircleAvatar(
                          backgroundColor: colorController.getBasicColor(3),
                          radius:
                              textStyleController.getFontSize(1) *
                              ((settingsController.getSetting("height") /
                                      settingsController.getSetting("width")) +
                                  (settingsController.getSetting("width") /
                                      settingsController.getSetting(
                                        "height",
                                      ))) /
                              2,
                          child: Center(
                            child: Icon(
                              Icons.add,
                              size: textStyleController.getFontSize(1),
                              color: colorController.getColor(4),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> getCharacterCreatorSelector(
    LongPressStartDetails details,
  ) async {
    String current =
        settingsController.getSetting("characterCreationType") ?? "page";
    final result = await showMenu<String>(
      context: context,
      elevation: 8,
      color: colorController.getColor(3),
      shadowColor: colorController.getColor(3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          MediaQuery.sizeOf(context).width / 72,
        ),
      ),
      menuPadding: EdgeInsets.zero,
      position: RelativeRect.fromLTRB(
        details.globalPosition.dx,
        details.globalPosition.dy,
        MediaQuery.of(context).size.width - details.globalPosition.dx,
        MediaQuery.of(context).size.height - details.globalPosition.dy,
      ),
      items: [
        PopupMenuItem<String>(
          padding: EdgeInsets.zero,
          enabled: false,
          child: StatefulBuilder(
            builder: (context, menuSetState) => ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    color: colorController.getColor(1),
                    padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.sizeOf(context).width / 72,
                      vertical: MediaQuery.sizeOf(context).width / 144,
                    ),
                    child: Text(
                      "Set style:",
                      style: textStyleController.getTextStyle(3, 4),
                    ),
                  ),

                  Container(height: 1, color: colorController.getColor(3)),
                  InkWell(
                    onTap: () async {
                      Navigator.pop(context, "page");
                      await settingsController.setSetting(
                        "characterCreationType",
                        "page",
                      );
                    },
                    child: Container(
                      color: current == "page"
                          ? colorController.getColor(0)
                          : colorController.getColor(3),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      child: Text(
                        "Page",
                        style: textStyleController.getTextStyle(4, 4),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      Navigator.pop(context, "popUp");
                      await settingsController.setSetting(
                        "characterCreationType",
                        "popUp",
                      );
                    },
                    child: Container(
                      color: current == "popUp"
                          ? colorController.getColor(0)
                          : colorController.getColor(3),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      child: Text(
                        "Pop Up",
                        style: textStyleController.getTextStyle(4, 4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );

    if (!mounted || result == null) return;

    if (!mounted) return;

    setState(() {});
  }
}

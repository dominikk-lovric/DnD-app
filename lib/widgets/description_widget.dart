import 'dart:async';

import 'package:dnd_app/services/color_service.dart';
import 'package:dnd_app/services/settings_service.dart';
import 'package:dnd_app/services/text_style_service.dart';
import 'package:dnd_app/widgets/draggable_sheet_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DescriptionWidget extends StatefulWidget {
  String title;
  Widget descrption;
  String? descriptionType;
  String subtitle;
  int titleLevel;
  int subtitleLevel;
  int clickLevel;
  String clickTitle;
  Widget? clickWidget;
  Widget? titleWidget;
  bool initiallyExpanded;

  DescriptionWidget(
    this.title,
    this.descrption,
    this.descriptionType, {
    super.key,
    this.initiallyExpanded = true,
    this.subtitle = "",
    this.titleLevel = 2,
    this.subtitleLevel = 2,
    this.clickLevel = 1,
    this.clickTitle = "",
    this.clickWidget,
    this.titleWidget,
  });

  @override
  State<StatefulWidget> createState() => DescriptionWidgetState();
}

class DescriptionWidgetState extends State<DescriptionWidget> {
  final ExpansibleController _expansibleController = ExpansibleController();

  @override
  initState() {
    super.initState();
  }

  @override
  dispose() {
    _expansibleController.dispose();
    super.dispose();
  }

  String getSetting() {
    if (types.contains(widget.descriptionType)) {
      return widget.descriptionType!;
    }

    return SettingsService.getSetting(
          widget.descriptionType ?? "globalDescriptionStyle",
        ) ??
        SettingsService.getSetting("globalDescriptionStyle");
  }

  Future<void> close() async {
    switch (getSetting()) {
      case "popUp":
      case "page":
        if (mounted) {
          Navigator.of(context).pop();
        }
        break;

      case "expand":
        if (!_expansibleController.isExpanded) {
          return;
        }

        final completer = Completer<void>();

        void listener() {
          if (!_expansibleController.isExpanded) {
            _expansibleController.removeListener(listener);

            if (!completer.isCompleted) {
              completer.complete();
            }
          }
        }

        _expansibleController.addListener(listener);
        _expansibleController.collapse();

        await completer.future;
        break;

      case "sheet":
        // TODO
        break;

      case "text":
      default:
        break;
    }
  }

  List<String> types = ["popUp", "expand", "text", "sheet", "page"];

  Widget getClickWidget() {
    return widget.clickWidget ??
        Text(
          widget.clickTitle == "" ? widget.title : widget.clickTitle,
          style: TextStyleService.getTextStyle(widget.clickLevel, 4),
        );
  }

  Widget getTitleWidget() {
    return widget.titleWidget ??
        Text(
          widget.clickTitle == "" ? widget.title : widget.clickTitle,
          style: TextStyleService.getTextStyle(widget.titleLevel, 4),
        );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.title == "") {
      return widget.descrption;
    }
    String setting;
    if (types.contains(widget.descriptionType)) {
      setting =
          widget.descriptionType ??
          SettingsService.getSetting(
            widget.descriptionType ?? "globalDescriptionStyle",
          );
    } else {
      String? sett = SettingsService.getSetting(
        widget.descriptionType ?? "globalDescriptionStyle",
      );
      if (sett == null) {
        setting = SettingsService.getSetting("globalDescriptionStyle");
      } else {
        setting = sett;
      }
    }

    if (setting == "popUp") {
      return GestureDetector(
        onTap: () => {
          showDialog(
            context: context,
            builder: (context) => Theme(
              data: Theme.of(context).copyWith(
                dialogTheme: DialogThemeData(
                  backgroundColor: ColorService.getColor(2),
                ),
              ),
              child: Dialog(
                insetPadding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 24,
                ),
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          getTitleWidget(),
                          const Divider(indent: 10, endIndent: 10),
                          if (widget.subtitle != "")
                            Text(
                              widget.subtitle.toString(),
                              style: TextStyleService.getTextStyle(
                                widget.subtitleLevel,
                                4,
                              ),
                            ),
                          Flexible(
                            child: SingleChildScrollView(
                              child: widget.descrption,
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Close"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        },
        child: getClickWidget(),
      );
    } else if (setting == "text") {
      return Row(
        spacing: 10,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            widget.title + ":",
            style: TextStyleService.getTextStyle(widget.subtitleLevel, 4),
          ),
          widget.descrption,
        ],
      );
    } else if (setting == "page") {
      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Focus(
                autofocus: true,
                onKeyEvent: (node, event) {
                  if (event is KeyDownEvent &&
                      event.logicalKey == LogicalKeyboardKey.escape) {
                    Navigator.of(context).pop();
                    return KeyEventResult.handled;
                  }

                  return KeyEventResult.ignored;
                },
                child: Scaffold(
                  appBar: AppBar(
                    backgroundColor: ColorService.getColor(0),
                    foregroundColor: ColorService.getColor(4),
                    toolbarHeight: SettingsService.getSetting("headerHeight"),
                    title: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        getTitleWidget(),
                        (widget.subtitle != "")
                            ? Text(
                                widget.subtitle,
                                style: TextStyleService.getTextStyle(
                                  widget.subtitleLevel,
                                  4,
                                ),
                              )
                            : SizedBox.shrink(),
                      ],
                    ),
                  ),
                  backgroundColor: ColorService.getBasicColor(2),
                  body: SafeArea(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsetsGeometry.all(20),
                        child: widget.descrption,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
        child: getClickWidget(),
      );
    } else if (setting == "expand") {
      return Material(
        color: Colors.transparent,
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            controller: _expansibleController,
            initiallyExpanded: widget.initiallyExpanded,
            showTrailingIcon: false,
            tilePadding: EdgeInsets.zero,
            title: getTitleWidget(),
            expansionAnimationStyle: AnimationStyle(
              duration: const Duration(milliseconds: 300),
              reverseDuration: const Duration(milliseconds: 300),
            ),
            children: [
              Divider(
                indent: 15,
                endIndent: 15,
                color: ColorService.getColor(4),
              ),
              Padding(
                padding: const EdgeInsetsGeometry.directional(
                  start: 10,
                  end: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.subtitle != "")
                      Text(
                        widget.subtitle.toString(),
                        style: TextStyleService.getTextStyle(
                          widget.subtitleLevel,
                          4,
                        ),
                      ),
                    widget.descrption,
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    } else if (setting == "sheet") {
      return DraggableSheetWidget(
        widget.title,
        widget.subtitle,
        widget.descrption,
        titleLevel: widget.titleLevel,
        subtitleLevel: widget.subtitleLevel,
        clickLevel: widget.clickLevel,
        clickTitle: (widget.clickTitle == "")
            ? widget.title
            : widget.clickTitle,
        clickWidget: widget.clickWidget,
        titleWidget: widget.titleWidget,
      );
    } else {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            (widget.clickTitle == "") ? widget.title : widget.clickTitle,
            style: TextStyleService.getTextStyle(widget.titleLevel, 4),
          ),
          widget.descrption,
        ],
      );
    }
  }
}

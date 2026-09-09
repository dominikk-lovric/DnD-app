import 'dart:async';
import 'dart:ui';

import 'package:dnd_app/services/color_service.dart';
import 'package:dnd_app/services/settings_service.dart';
import 'package:dnd_app/services/string_service.dart';
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
  List<String>? optionList;
  Function(void Function())? resetFunction;

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
    this.resetFunction = null,
    this.optionList = null,
  });

  @override
  State<StatefulWidget> createState() => DescriptionWidgetState();
}

class DescriptionWidgetState extends State<DescriptionWidget> {
  final ExpansibleController _expansibleController = ExpansibleController();

  bool bgColor = false;

  final OverlayPortalController _settingMenuController =
      OverlayPortalController();

  final LayerLink _settingMenuLink = LayerLink();

  final Object _settingMenuGroupId = Object();

  Offset? _settingMenuPosition;

  static const double _settingMenuWidth = 180;

  @override
  initState() {
    super.initState();
    initSettings();
    SettingsService.revision.addListener(_onSettingsChanged);
  }

  Future<void> initSettings() async {
    await SettingsService.initSetting(
      widget.descriptionType.toString() + "bgColor",
      false,
    );
    bgColor = SettingsService.getSetting(
      widget.descriptionType.toString() + "bgColor",
    );
    setState(() {});
  }

  @override
  dispose() {
    SettingsService.revision.removeListener(_onSettingsChanged);
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
    return GestureDetector(
      onLongPressStart: (details) async {
        getSettingSelector(
          details,
          widget.descriptionType ?? "globalDescriptionStyle",
        );
      },
      child: (widget.clickWidget == null)
          ? Card(
              color: bgColor ? ColorService.getColor(3) : Colors.transparent,
              shadowColor: bgColor ? null : Colors.transparent,
              child: Padding(
                padding: EdgeInsetsDirectional.symmetric(
                  vertical: 8,
                  horizontal: 8,
                ),
                child: Text(
                  widget.clickTitle == "" ? widget.title : widget.clickTitle,
                  style: TextStyleService.getTextStyle(widget.clickLevel, 4),
                ),
              ),
            )
          : widget.clickWidget,
    );
  }

  Widget getTitleWidget() {
    return GestureDetector(
      onLongPressStart: (details) async {
        getSettingSelector(
          details,
          widget.descriptionType ?? "globalDescriptionStyle",
        );
      },
      child:
          widget.titleWidget ??
          Text(
            widget.clickTitle == "" ? widget.title : widget.clickTitle,
            style: TextStyleService.getTextStyle(widget.titleLevel, 4),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                insetPadding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.sizeOf(context).width / 36,
                  vertical: MediaQuery.sizeOf(context).width / 24,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.sizeOf(context).height / 36,
                      vertical: MediaQuery.sizeOf(context).height / 72,
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          getTitleWidget(),
                          Divider(
                            indent: MediaQuery.sizeOf(context).width / 72,
                            endIndent: MediaQuery.sizeOf(context).width / 72,
                          ),
                          if (widget.subtitle != "")
                            Text(
                              widget.subtitle.toString(),
                              style: TextStyleService.getTextStyle(
                                widget.subtitleLevel,
                                4,
                              ),
                            ),
                          Flexible(child: widget.descrption),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => Navigator.pop(context),
                              style: TextButton.styleFrom(
                                foregroundColor: ColorService.getColor(4),
                                backgroundColor: ColorService.getColor(0),
                              ),
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
      return GestureDetector(
        onLongPressStart: (details) async {
          getSettingSelector(
            details,
            widget.descriptionType ?? "globalDescriptionStyle",
          );
        },
        child: Card(
          color: bgColor ? ColorService.getColor(3) : Colors.transparent,
          shadowColor: bgColor ? null : Colors.transparent,
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: MediaQuery.sizeOf(context).width / 72,
              horizontal: MediaQuery.sizeOf(context).width / 72,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "${widget.title}:",
                  style: TextStyleService.getTextStyle(widget.subtitleLevel, 4),
                ),
                SizedBox(width: MediaQuery.sizeOf(context).width / 72),
                Expanded(child: widget.descrption),
              ],
            ),
          ),
        ),
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
                  body: SingleChildScrollView(
                    child: SafeArea(
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
      return Card(
        color: bgColor ? ColorService.getColor(3) : Colors.transparent,
        shadowColor: bgColor ? null : Colors.transparent,
        child: Padding(
          padding: EdgeInsetsGeometry.symmetric(
            vertical: MediaQuery.sizeOf(context).width / 72,
            horizontal: MediaQuery.sizeOf(context).width / 72,
          ),
          child: GestureDetector(
            onLongPressStart: (details) async {
              getSettingSelector(
                details,
                widget.descriptionType ?? "globalDescriptionStyle",
              );
            },
            child: Theme(
              data: Theme.of(context).copyWith(
                splashFactory: NoSplash.splashFactory,
                dividerColor: Colors.transparent,
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                hoverColor: Colors.transparent,
              ),
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
                    indent: MediaQuery.sizeOf(context).width / 72,
                    endIndent: MediaQuery.sizeOf(context).width / 72,
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
                      children: [widget.descrption],
                    ),
                  ),
                ],
              ),
            ),
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
        clickWidget: getClickWidget(),
        titleWidget: getTitleWidget(),
      );
    } else if (setting == "static") {
      return GestureDetector(
        onLongPressStart: (details) async {
          getSettingSelector(
            details,
            widget.descriptionType ?? "globalDescriptionStyle",
          );
        },
        child: Card(
          color: bgColor ? ColorService.getColor(3) : Colors.transparent,
          shadowColor: bgColor ? null : Colors.transparent,
          child: Padding(
            padding: EdgeInsetsDirectional.symmetric(
              vertical: MediaQuery.sizeOf(context).width / 72,
              horizontal: MediaQuery.sizeOf(context).width / 72,
            ),
            child: widget.descrption,
          ),
        ),
      );
    } else {
      return GestureDetector(
        onLongPressStart: (details) async {
          getSettingSelector(
            details,
            widget.descriptionType ?? "globalDescriptionStyle",
          );
        },
        child: widget.descrption,
      );
    }
  }

  Future<void> getSettingSelector(
    LongPressStartDetails details,
    String setting,
  ) async {
    final result = await showMenu<String>(
      context: context,
      elevation: 8,
      color: ColorService.getColor(3),
      shadowColor: ColorService.getColor(3),
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
            builder: (context, menuSetState) =>
                _buildSettingMenu(setting, menuSetState),
          ),
        ),
      ],
    );

    if (!mounted || result == null) return;

    await SettingsService.setSetting(setting, result);

    if (!mounted) return;

    setState(() {});
  }

  Widget _buildSettingMenu(String setting, StateSetter menuSetState) {
    List<String> options =
        widget.optionList ??
        ["popUp", "text", "page", "expand", "sheet", "static"];

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: ColorService.getColor(1),
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.sizeOf(context).width / 36,
              vertical: MediaQuery.sizeOf(context).width / 72,
            ),
            child: Text(
              "Set style:",
              style: TextStyleService.getTextStyle(1, 4),
            ),
          ),

          Container(height: 1, color: ColorService.getColor(3)),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Background", style: TextStyleService.getTextStyle(4, 4)),
              Checkbox(
                value: bgColor,
                checkColor: ColorService.getColor(4),
                activeColor: ColorService.getColor(1),
                side: BorderSide(color: ColorService.getColor(4), width: 1.5),
                onChanged: (value) async {
                  final newValue = value ?? true;
                  menuSetState(() => bgColor = newValue);
                  await SettingsService.setSetting(
                    widget.descriptionType.toString() + "bgColor",
                    newValue,
                  );
                  setState(() {});
                },
              ),
            ],
          ),
          ...options.map((option) {
            final selected = getSetting() == option;

            return InkWell(
              onTap: () async {
                Navigator.pop(context, option);
                await SettingsService.setSetting(setting, option);
              },
              child: Container(
                color: selected
                    ? ColorService.getColor(0)
                    : ColorService.getColor(3),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Text(
                  StringService.titleFromKey(option),
                  style: TextStyleService.getTextStyle(4, 4),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  void _onSettingsChanged() {
    setState(() {});
  }
}

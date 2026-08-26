import 'package:dnd_app/services/color_service.dart';
import 'package:dnd_app/services/settings_service.dart';
import 'package:dnd_app/services/text_style_service.dart';
import 'package:dnd_app/widgets/draggable_sheet_widget.dart';
import 'package:flutter/material.dart';

class DescriptionWidget extends StatelessWidget {
  String title;
  Widget descrption;
  String descriptionType;
  String subtitle;
  int titleLevel;
  int subtitleLevel;
  int clickLevel;
  String clickTitle;
  Widget? clickWidget;
  Widget? titleWidget;

  DescriptionWidget(
    this.title,
    this.descrption,
    this.descriptionType, {
    super.key,
    this.subtitle = "",
    this.titleLevel = 2,
    this.subtitleLevel = 2,
    this.clickLevel = 1,
    this.clickTitle = "",
    this.clickWidget,
    this.titleWidget,
  });

  List<String> types = ["popUp", "expand", "text", "sheet", "page"];

  Widget getClickWidget() {
    return clickWidget ??
        Text(
          clickTitle == "" ? title : clickTitle,
          style: TextStyleService.getTextStyle(clickLevel, 4),
        );
  }

  Widget getTitleWidget() {
    return titleWidget ??
        Text(
          clickTitle == "" ? title : clickTitle,
          style: TextStyleService.getTextStyle(titleLevel, 4),
        );
  }

  @override
  Widget build(BuildContext context) {
    String setting;
    if (types.contains(descriptionType)) {
      setting = descriptionType;
    } else {
      String? sett = SettingsService.getSetting(descriptionType);
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
                        if (subtitle != null && subtitle != "")
                          Text(
                            subtitle.toString(),
                            style: TextStyleService.getTextStyle(
                              subtitleLevel,
                              4,
                            ),
                          ),
                        Flexible(
                          child: SingleChildScrollView(child: descrption),
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
            title + ":",
            style: TextStyleService.getTextStyle(subtitleLevel, 4),
          ),
          descrption,
        ],
      );
    } else if (setting == "page") {
      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Scaffold(
                appBar: AppBar(
                  backgroundColor: ColorService.getColor(0),
                  foregroundColor: ColorService.getColor(4),
                  toolbarHeight: SettingsService.getSetting("headerHeight"),
                  title: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      getTitleWidget(),
                      (subtitle != null && subtitle != "")
                          ? Text(
                              subtitle,
                              style: TextStyleService.getTextStyle(
                                subtitleLevel,
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
                      child: descrption,
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
            initiallyExpanded: true,
            showTrailingIcon: false,
            tilePadding: EdgeInsets.zero,
            title: getTitleWidget(),
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
                    if (subtitle != null && subtitle != "")
                      Text(
                        subtitle.toString(),
                        style: TextStyleService.getTextStyle(subtitleLevel, 4),
                      ),
                    descrption,
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    } else if (setting == "sheet") {
      return DraggableSheetWidget(
        title,
        subtitle,
        descrption,
        titleLevel: titleLevel,
        subtitleLevel: subtitleLevel,
        clickLevel: clickLevel,
        clickTitle: (clickTitle == "") ? title : clickTitle,
        clickWidget: clickWidget,
        titleWidget: titleWidget,
      );
    } else {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            (clickTitle == "") ? title : clickTitle,
            style: TextStyleService.getTextStyle(titleLevel, 4),
          ),
          descrption,
        ],
      );
    }
  }
}

import 'package:dnd_app/services/color_service.dart';
import 'package:dnd_app/services/settings_service.dart';
import 'package:dnd_app/services/text_style_service.dart';
import 'package:flutter/material.dart';

class SortingMenuWidget extends StatelessWidget {
  final Future<void> Function(dynamic) function1;
  final Future<void> Function(dynamic) function2;
  final Future<void> Function(dynamic) function3;
  final Future<void> Function(dynamic) function4;
  final Future<void> Function(dynamic) function5;
  int index;
  List<String> sorts;
  List<String>? subsort;

  SortingMenuWidget(
    this.function1,
    this.function2,
    this.function3,
    this.function4,
    this.function5,
    this.index,
    this.sorts, {
    this.subsort = null,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return PopupMenuButton<String>(
      color: ColorService.getColor(2),
      iconColor: ColorService.getColor(4),
      icon: const Icon(Icons.tune),
      onSelected: (value) async {
        if (value == "group_yes") {
          await function1(true);
        } else if (value == "group_no") {
          await function2(false);
        } else if (value == "subsortAlphabetical") {
          await function3(false);
        } else if (value == "subsortStandard") {
          await function4(true);
        } else {
          await function5(value);
        }
      },
      itemBuilder: (context) {
        final currentSorting = SettingsService.getSetting("wikiSorting")[index];

        return [
          PopupMenuItem<String>(
            enabled: false,
            child: Text("Grouping", style: TextStyleService.getTextStyle(3, 4)),
          ),

          PopupMenuItem<String>(
            value: "group_yes",
            child: Row(
              children: [
                Icon(
                  SettingsService.getSetting("wikiGrouping")[index] == "true"
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: ColorService.getColor(4),
                ),
                const SizedBox(width: 8),
                Text("Yes", style: TextStyleService.getTextStyle(4, 4)),
              ],
            ),
          ),

          PopupMenuItem<String>(
            value: "group_no",
            child: Row(
              children: [
                Icon(
                  SettingsService.getSetting("wikiGrouping")[index] == "false"
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: ColorService.getColor(4),
                ),
                const SizedBox(width: 8),
                Text("No", style: TextStyleService.getTextStyle(4, 4)),
              ],
            ),
          ),

          const PopupMenuDivider(),

          PopupMenuItem<String>(
            enabled: false,
            child: Text("Sort by", style: TextStyleService.getTextStyle(3, 4)),
          ),

          ...sorts.map(
            (sort) => PopupMenuItem<String>(
              value: sort,
              child: Row(
                children: [
                  Icon(
                    currentSorting == sort
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: ColorService.getColor(4),
                  ),
                  const SizedBox(width: 8),
                  Text(sort, style: TextStyleService.getTextStyle(4, 4)),
                ],
              ),
            ),
          ),

          if (currentSorting == "primary" ||
              currentSorting == "featType" ||
              currentSorting == "source") ...[
            const PopupMenuDivider(),

            PopupMenuItem<String>(
              enabled: false,
              child: Text(
                "Secondary sorting",
                style: TextStyleService.getTextStyle(3, 4),
              ),
            ),

            PopupMenuItem<String>(
              value: "subsortAlphabetical",
              child: Row(
                children: [
                  Icon(
                    (SettingsService.getSetting(currentSorting + "SubSort")
                            is List)
                        ? Icons.radio_button_unchecked
                        : Icons.radio_button_checked,
                    color: ColorService.getColor(4),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Alphabetical",
                    style: TextStyleService.getTextStyle(4, 4),
                  ),
                ],
              ),
            ),

            PopupMenuItem<String>(
              value: "subsortStandard",
              child: Row(
                children: [
                  Icon(
                    (SettingsService.getSetting(currentSorting + "SubSort")
                            is List)
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: ColorService.getColor(4),
                  ),
                  const SizedBox(width: 8),
                  Text("Standard", style: TextStyleService.getTextStyle(4, 4)),
                ],
              ),
            ),
          ],

          if (subsort != null) ...[
            const PopupMenuDivider(),

            PopupMenuItem<String>(
              enabled: false,
              child: Text(
                "Secondary sorting order",
                style: TextStyleService.getTextStyle(3, 4),
              ),
            ),

            ...subsort!.map(
              (value) => PopupMenuItem<String>(
                enabled: false,
                value: "secondary_$value",
                child: Text(value, style: TextStyleService.getTextStyle(4, 4)),
              ),
            ),
          ],
        ];
      },
    );
  }
}

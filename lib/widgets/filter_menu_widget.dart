import 'package:dnd_app/services/color_service.dart';
import 'package:dnd_app/services/settings_service.dart';
import 'package:dnd_app/services/string_service.dart';
import 'package:dnd_app/services/text_style_service.dart';
import 'package:flutter/material.dart';

class FilterMenuWidget extends StatelessWidget {
  Map<String, dynamic> categoryData;
  String currentCategory;
  List<dynamic> filters;
  Future<void> Function() function1;
  Future<void> Function() load;
  FilterMenuWidget(
    this.categoryData,
    this.currentCategory,
    this.filters,
    this.function1,
    this.load, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return IconButton(
      icon: const Icon(Icons.filter_alt),
      color: ColorService.getColor(4),
      onPressed: () async {
        final RenderBox overlay =
            Overlay.of(context).context.findRenderObject() as RenderBox;

        final double screenWidth = overlay.size.width;

        const double menuWidth = 280;
        const double menuGap = 0;

        final double firstMenuLeft = screenWidth - menuWidth - 10;

        List<dynamic> filtersList =
            categoryData[currentCategory]["filters"] as List<dynamic>;

        await showMenu<void>(
          context: context,
          color: ColorService.getColor(3),
          position: RelativeRect.fromLTRB(
            firstMenuLeft,
            SettingsService.getSetting("headerHeight"),
            screenWidth - firstMenuLeft - menuWidth,
            0,
          ),
          items: [
            PopupMenuItem<void>(
              enabled: false,
              child: SizedBox(
                width: menuWidth,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text("Filters", style: TextStyleService.getTextStyle(1, 4)),
                    IconButton(
                      icon: Icon(Icons.rotate_left),
                      color: ColorService.getColor(4),
                      onPressed: () async {
                        await load();
                        filtersList =
                            categoryData[currentCategory]["filters"]
                                as List<dynamic>;
                        for (var i = 0; i < filtersList.length; i++) {
                          final availableOptions =
                              filtersList[i]["options"] as List<dynamic>;
                          filters[i]["options"] = List<dynamic>.from(
                            availableOptions,
                          );
                        }
                        await function1();
                      },
                    ),
                  ],
                ),
              ),
            ),

            ...List.generate(filtersList.length, (i) {
              return PopupMenuItem<void>(
                enabled: false,

                child: Builder(
                  builder: (itemContext) {
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () async {
                        final RenderBox itemBox =
                            itemContext.findRenderObject() as RenderBox;

                        final Offset itemPosition = itemBox.localToGlobal(
                          Offset.zero,
                          ancestor: overlay,
                        );

                        final double firstMenuRight = firstMenuLeft + menuWidth;

                        final bool hasRoomOnRight =
                            firstMenuRight + menuGap + menuWidth <= screenWidth;

                        final double secondMenuLeft = hasRoomOnRight
                            ? firstMenuRight + menuGap
                            : firstMenuLeft - menuGap - menuWidth;

                        final options =
                            filtersList[i]["options"] as List<dynamic>;

                        await showMenu<void>(
                          context: context,
                          color: ColorService.getColor(3),
                          position: RelativeRect.fromLTRB(
                            secondMenuLeft,
                            itemPosition.dy,
                            screenWidth - secondMenuLeft - menuWidth,
                            0,
                          ),
                          items: [
                            PopupMenuItem<void>(
                              enabled: false,
                              child: StatefulBuilder(
                                builder: (context, setOptionState) {
                                  return SizedBox(
                                    child: SingleChildScrollView(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            StringService.titleFromKey(
                                              filtersList[i]["id"],
                                            ),
                                            style:
                                                TextStyleService.getTextStyle(
                                                  3,
                                                  4,
                                                ),
                                          ),
                                          Divider(),
                                          ...options.map<Widget>((e) {
                                            final bool isSelected =
                                                filters[i]["options"].contains(
                                                  e,
                                                );

                                            void toggleOption() async {
                                              setOptionState(() {
                                                if (filters[i]["options"]
                                                    .contains(e)) {
                                                  filters[i]["options"].remove(
                                                    e,
                                                  );
                                                } else {
                                                  filters[i]["options"].add(e);
                                                }
                                              });

                                              await function1();
                                            }

                                            return GestureDetector(
                                              behavior: HitTestBehavior.opaque,
                                              onTap: toggleOption,
                                              child: Row(
                                                children: [
                                                  Checkbox(
                                                    value: isSelected,
                                                    checkColor:
                                                        ColorService.getColor(
                                                          4,
                                                        ),
                                                    activeColor:
                                                        ColorService.getColor(
                                                          0,
                                                        ),

                                                    onChanged: (_) async {
                                                      toggleOption();
                                                    },
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      e.toString(),
                                                      style:
                                                          TextStyleService.getTextStyle(
                                                            4,
                                                            4,
                                                          ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      },

                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Divider(),
                          SizedBox(
                            width: menuWidth,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  StringService.titleFromKey(
                                    filtersList[i]["id"],
                                  ),
                                  style: TextStyleService.getTextStyle(3, 4),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 14,
                                  color: ColorService.getColor(4),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            }),
          ],
        );

        await function1();
      },
    );
  }
}

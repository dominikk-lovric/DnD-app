import 'package:dnd_app/services/map_service.dart';
import 'package:dnd_app/services/text_style_service.dart';
import 'package:dnd_app/widgets/background_info_widget.dart';
import 'package:dnd_app/widgets/class_info_widget.dart';
import 'package:dnd_app/widgets/description_widget.dart';
import 'package:dnd_app/widgets/feat_info_widget.dart';
import 'package:dnd_app/widgets/optional_image_widget.dart';
import 'package:dnd_app/widgets/sorting_menu_widget.dart';
import 'package:dnd_app/widgets/species_info_widget.dart';
import 'package:dnd_app/widgets/spell_info_widget.dart';
import 'package:flutter/material.dart';

import 'package:dnd_app/services/json_service.dart';
import 'package:dnd_app/services/settings_service.dart';
import 'package:dnd_app/services/color_service.dart';

import 'package:dnd_app/widgets/item_widget.dart';
import 'package:dnd_app/widgets/category_selector_widget.dart';

class WikiPage extends StatefulWidget {
  const WikiPage(this.categoryNum, {super.key});

  final int categoryNum;

  @override
  State<WikiPage> createState() => _WikiState();
}

class _WikiState extends State<WikiPage> with SingleTickerProviderStateMixin {
  late dynamic Function(Map<String, dynamic>) selector;

  final PageController _pageController = PageController();
  late List<dynamic> categories = [];
  late Map<String, dynamic> categoryData = {};
  late String currentState = "classes";

  Map<String, dynamic> data = {};

  late double headerHeight;
  late int categoryNum;

  final GlobalKey<CategorySelectorWidgetState> categoryKey =
      GlobalKey<CategorySelectorWidgetState>();

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    await loadCategories();
    getSelector(categories[0]);
    await loadOptions(categories[0]);
    sortData();
  }

  void getSelector(String category) {
    int index = categories.indexOf(category);
    List<String> settings = SettingsService.getSetting("wikiSorting");
    dynamic Function(Map<String, dynamic>) ss;
    if ((categoryData[categories[index]]["sorting"]).contains(
          settings[index].toLowerCase(),
        ) ||
        (categoryData[categories[index]]["sorting"]).contains(
          settings[index],
        )) {
      if (settings[index] == "alphabetical") {
        ss = (el) => el["name"];
      } else if (settings[index] == "primary") {
        if (SettingsService.getSetting("primarySubSort") is List) {
          ss = (el) {
            final source = el["Basics"]["Primary"][0];
            final List<String> sourceList = SettingsService.getSetting(
              "primarySubSort",
            );
            return sourceList.indexOf(source);
          };
        } else {
          ss = (el) => el["Basics"]["Primary"][0];
        }
      } else if (settings[index] == "source") {
        if (SettingsService.getSetting("sourceSubSort") is List) {
          ss = (el) {
            final source = el["Basics"]["source"];
            final List<String> sourceList = SettingsService.getSetting(
              "sourceSubSort",
            );
            return sourceList.indexOf(source);
          };
        } else {
          ss = (el) => el["Basics"]["source"];
        }
      } else if (settings[index] == "featType") {
        if (SettingsService.getSetting("featTypeSubSort") is List) {
          ss = (el) {
            final source = el["Basics"]["type"];
            final List<String> typeOrder = SettingsService.getSetting(
              "featTypeSubSort",
            );
            return typeOrder.indexOf(source);
          };
        } else {
          ss = (el) => el["Basics"]["type"];
        }
      } else if (settings[index] == "speed") {
        ss = (el) {
          return el["Basics"]["Speed"];
        };
      } else if (settings[index] == "level") {
        ss = (el) {
          return el["level"];
        };
      } else if (settings[index] == "school") {
        ss = (el) {
          return el["Basics"]["School"];
        };
      } else {
        ss = (el) => el["name"];
      }
    } else {
      ss = (el) => el["name"];
    }
    setState(() {
      selector = ss;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> loadCategories() async {
    final json = JsonService("categories");
    Map<String, dynamic> items = await json.loadData();
    setState(() {
      categoryData = items;
      categories = items.keys.toList();
    });
  }

  Future<void> loadOptions(String file) async {
    final json = JsonService(file);
    Map<String, dynamic> items = await json.loadData();

    setState(() {
      data = items;
      currentState = file;
    });
  }

  void sortData() {
    if (data.isEmpty) return;

    final sorted = MapService.sortMap(
      data,
      selector,
      secondarySelector: (el) => el["name"],
    );

    setState(() {
      data = sorted;
    });
  }

  String get currentCategory {
    return currentState;
  }

  int get currentCategoryIndex {
    return categories.indexOf(currentCategory);
  }

  List<String> get availableSorts {
    final index = currentCategoryIndex;

    if (index == -1) return [];

    final sorting = categoryData[categories[index]]["sorting"];

    if (sorting is List) {
      return List<String>.from(sorting);
    }

    return [];
  }

  List<String>? get secondarySort {
    final settings = SettingsService.getSetting("wikiSorting");
    final index = currentCategoryIndex;

    if (index == -1 || index >= settings.length) {
      return null;
    }

    if (settings[index] == "primary" ||
        settings[index] == "source" ||
        settings[index] == "featType") {
      final value = SettingsService.getSetting(settings[index] + "SubSort");
      return value is List ? List<String>.from(value) : null;
    }
    return null;
  }

  Future<void> changeSorting(String value) async {
    final settings = List<String>.from(
      SettingsService.getSetting("wikiSorting"),
    );

    final index = currentCategoryIndex;

    settings[index] = value;

    await SettingsService.setSetting("wikiSorting", settings);

    getSelector(currentCategory);
    sortData();

    setState(() {});
  }

  Future<void> changeGrouping(bool value) async {
    List<String> grouping = SettingsService.getSetting("wikiGrouping");
    grouping[currentCategoryIndex] = value.toString();
    await SettingsService.setSetting("wikiGrouping", grouping);

    setState(() {});
  }

  Future<void> changeSecondarySorting(bool standard) async {
    final sortingSettings = List<String>.from(
      SettingsService.getSetting("wikiSorting"),
    );

    final index = currentCategoryIndex;
    final sorting = sortingSettings[index];

    if (standard) {
      final standardSort = SettingsService.getSetting(
        "${sorting}SubSortStandard",
      );

      if (standardSort is! List) {
        debugPrint(
          "ERROR: ${sorting}SubSortStandard is not a List: $standardSort",
        );
        return;
      }

      await SettingsService.setSetting(
        "${sorting}SubSort",
        List<String>.from(standardSort),
      );
    } else {
      await SettingsService.setSetting("${sorting}SubSort", "alphabetical");
    }

    getSelector(currentCategory);

    sortData();

    if (mounted) {
      setState(() {});
    }
  }

  String getTitle(String category, Map<String, dynamic> currentItem) {
    if (category == "level") {
      return currentItem["Basics"]["Level"];
    } else if (category == "featType" &&
        SettingsService.getSetting("featTypeSubSort") is List) {
      return currentItem["Basics"]["type"].toString();
    } else if (category == "source" &&
        SettingsService.getSetting("sourceSubSort") is List) {
      return currentItem["Basics"]["source"].toString();
    } else if (category == "primary" &&
        SettingsService.getSetting("primarySubSort") is List) {
      return currentItem["Basics"]["Primary"][0].toString();
    } else {
      return selector(currentItem).toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    headerHeight = SettingsService.getSetting("headerHeight") / 2;
    categoryNum = widget.categoryNum;
    return AnimatedBuilder(
      animation: ColorService.themeNotifier,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: ColorService.getColor(2),

          appBar: AppBar(
            toolbarHeight: headerHeight,
            backgroundColor: ColorService.getColor(0),
            foregroundColor: ColorService.getColor(4),
            centerTitle: true,
            actions: [
              SortingMenuWidget(
                (value) => changeGrouping(value),
                (value) => changeGrouping(value),
                (value) => changeSecondarySorting(value),
                (value) => changeSecondarySorting(value),
                (value) => changeSorting(value),
                currentCategoryIndex,
                availableSorts,
                subsort: secondarySort,
              ),
            ],
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(headerHeight),
              child: CategorySelectorWdget(
                height: headerHeight,
                categoryNumber: categoryNum,
                categories: categoryData.keys.toList(),
                currentState: currentState,
                onCategorySelected: (category) {
                  final index = categories.indexOf(category);

                  if (index != -1) {
                    _pageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
                key: categoryKey,
              ),
            ),
          ),
          body: PageView.builder(
            controller: _pageController,
            itemCount: categories.length,

            onPageChanged: (index) async {
              await loadOptions(categories[index]);
              getSelector(categories[index]);
              sortData();
              categoryKey.currentState?.focusCategory(categories[index]);
            },

            itemBuilder: (context, index) {
              final category = categories[index];

              if (category != currentState.toLowerCase()) {
                return const Center(child: CircularProgressIndicator());
              }

              final items = data.keys.toList();

              int catIndex = categories.indexOf(category);
              List<String> settings = SettingsService.getSetting("wikiSorting");

              return ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, itemIndex) {
                  final String icon =
                      data[items[itemIndex]]["Icon"][SettingsService.getSetting(
                        "theme",
                      )];
                  final item = data[items[itemIndex]];
                  Widget infoWidget = buildInfoWidget(category, item["json"]);

                  bool showSeparator = false;
                  String title = "";

                  if (SettingsService.getSetting(
                        "wikiGrouping",
                      )[currentCategoryIndex] ==
                      "true") {
                    if (settings[catIndex] != "alphabetical" &&
                        SettingsService.getSetting("groupItemsWiki")) {
                      final currentItem = data[items[itemIndex]];

                      // Get the group title for this item.
                      title = getTitle(settings[catIndex], currentItem);

                      if (itemIndex == 0) {
                        showSeparator = true;
                      } else {
                        final previousItem = data[items[itemIndex - 1]];

                        String previousTitle = getTitle(
                          settings[catIndex],
                          previousItem,
                        );

                        showSeparator = title != previousTitle;
                      }
                    }
                  }

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (showSeparator)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsetsDirectional.only(
                                start: 15,
                              ),
                              child: Text(
                                title,
                                style: TextStyleService.getTextStyle(2, 4),
                              ),
                            ),
                            Divider(
                              indent: 5,
                              endIndent: 5,
                              color: ColorService.getColor(4),
                            ),
                          ],
                        ),
                      DescriptionWidget(
                        data[items[itemIndex]]["name"],
                        infoWidget,
                        "itemDescriptionStyle",
                        clickWidget: ItemWidget(
                          items[itemIndex],
                          data[items[itemIndex]],
                          category,
                        ),
                        titleWidget: Padding(
                          padding: EdgeInsetsGeometry.directional(start: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            spacing: (icon != "none") ? 10 : 0.0,
                            children: [
                              (icon != "none")
                                  ? OptionalImageWidget(
                                      SettingsService.getSetting(
                                            "headerHeight",
                                          ) *
                                          (8 / 10),
                                      icon,
                                      key: ValueKey(
                                        data[items[itemIndex]]["name"],
                                      ),
                                    )
                                  : SizedBox.shrink(),
                              Expanded(
                                child: Text(
                                  data[items[itemIndex]]["name"],
                                  style: TextStyleService.getTextStyle(
                                    0,
                                    4,
                                    Overflow: TextOverflow.fade,
                                  ),
                                  maxLines: 1,
                                  softWrap: false,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget buildInfoWidget(String category, String item) {
    return FutureBuilder<Map<String, dynamic>>(
      future: JsonService.loadFromPath(item),
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

        final infoData = snapshot.data!;

        if (category == "classes") {
          return ClassInfoWidget(infoData);
        } else if (category == "species") {
          return SpeciesInfoWidget(infoData);
        } else if (category == "backgrounds") {
          return BackgroundInfoWidget(infoData);
        } else if (category == "feats") {
          return FeatInfoWidget(infoData);
        } else if (category == "spells") {
          return SpellInfoWidget(infoData);
        }

        return const SizedBox.shrink();
      },
    );
  }
}

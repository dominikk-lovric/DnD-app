import 'package:dnd_app/services/map_service.dart';
import 'package:dnd_app/services/string_service.dart';
import 'package:dnd_app/services/text_style_service.dart';
import 'package:dnd_app/widgets/description_column_widget.dart';
import 'package:dnd_app/widgets/description_widget.dart';
import 'package:dnd_app/widgets/filter_menu_widget.dart';
import 'package:dnd_app/widgets/optional_image_widget.dart';
import 'package:dnd_app/widgets/sorting_menu_widget.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:dnd_app/services/json_service.dart';
import 'package:dnd_app/services/settings_service.dart';
import 'package:dnd_app/services/color_service.dart';
import 'package:flutter/services.dart';
import 'package:dnd_app/widgets/item_widget.dart';
import 'package:dnd_app/widgets/category_selector_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WikiPage extends ConsumerStatefulWidget {
  const WikiPage({super.key});

  final int categoryNum = 0;

  @override
  ConsumerState<WikiPage> createState() => _WikiState();
}

class _WikiState extends ConsumerState<WikiPage>
    with SingleTickerProviderStateMixin {
  late final SettingsController settingsController;
  late final ColorController colorController;
  late final TextStyleController textStyleController;

  late dynamic Function(Map<String, dynamic>) selector;

  final sortingKey = GlobalKey<SortingMenuWidgetState>();
  final filterKey = GlobalKey<FilterMenuWidgetState>();
  Map<String, dynamic> schemata = {};

  final PageController _pageController = PageController();
  late List<dynamic> categories = [];
  late Map<String, dynamic> categoryData = {};
  late String currentState = "classes";
  List<dynamic> filters = [];

  String searchWord = "";

  Map<String, dynamic> data = {};

  late double headerHeight;
  int categoryNum = 1;

  final GlobalKey<CategorySelectorWidgetState> categoryKey =
      GlobalKey<CategorySelectorWidgetState>();

  @override
  void initState() {
    settingsController = ref.read(settingsControllerProvider.notifier);
    colorController = ref.read(colorControllerProvider.notifier);
    textStyleController = ref.read(textStyleControllerProvider.notifier);
    super.initState();
    init();
  }

  @override
  void dispose() {
    _pageController.dispose();

    super.dispose();
  }

  Future<void> init() async {
    searchWord = "";
    await loadCategories();
    await loadItems(categories[0]);
    await loadSchemata();
  }

  void getSelector(String category) {
    int index = categories.indexOf(category);
    List<dynamic> settings = settingsController.getSetting("wikiSorting");
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
        if (settingsController.getSetting("primarySubSort") is List) {
          ss = (el) {
            final source = el["Basics"]["Primary"][0];
            final List<String> sourceList = List<String>.from(
              settingsController.getSetting("primarySubSort"),
            );
            return sourceList.indexOf(source);
          };
        } else {
          ss = (el) => el["Basics"]["Primary"][0];
        }
      } else if (settings[index] == "source") {
        if (settingsController.getSetting("sourceSubSort") is List) {
          ss = (el) {
            final source = el["Basics"]["source"];
            final List<String> sourceList = List<String>.from(
              settingsController.getSetting("sourceSubSort"),
            );
            return sourceList.indexOf(source);
          };
        } else {
          ss = (el) => el["Basics"]["source"];
        }
      } else if (settings[index] == "featType") {
        if (settingsController.getSetting("featTypeSubSort") is List) {
          ss = (el) {
            final source = el["Basics"]["type"];
            final List<String> typeOrder = List<String>.from(
              settingsController.getSetting("featTypeSubSort"),
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
      currentState = file;
      data = filterData(items);
    });
  }

  Future<void> loadSchemata() async {
    final schemas = await JsonService.loadFromPath("schemata.json");
    setState(() {
      schemata = schemas;
    });
  }

  void loadFilters(String file) {
    setState(() {
      filters = jsonDecode(jsonEncode(categoryData[file]["filters"]));
    });
  }

  Future<void> loadItems(String file) async {
    getSelector(file);
    loadFilters(file);
    await loadOptions(file);
    sortData();
    if (searchWord != "") {
      data = MapService.filterMap(data, "name", [
        searchWord.toString().toLowerCase(),
      ], byStart: false);
    }
  }

  Map<String, dynamic> filterData(final items) {
    Map<String, dynamic> result = jsonDecode(jsonEncode(items));
    for (final filter in filters) {
      result = MapService.filterMap(result, filter["field"], filter["options"]);
    }

    return result;
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
    final settings = settingsController.getSetting("wikiSorting");
    final index = currentCategoryIndex;

    if (index == -1 || index >= settings.length) {
      return null;
    }

    if (settings[index] == "primary" ||
        settings[index] == "source" ||
        settings[index] == "featType") {
      final value = settingsController.getSetting(settings[index] + "SubSort");
      return value is List ? List<String>.from(value) : null;
    }
    return null;
  }

  Future<void> changeSorting(String value) async {
    final settings = List<String>.from(
      settingsController.getSetting("wikiSorting"),
    );

    final index = currentCategoryIndex;

    settings[index] = value;

    await settingsController.setSetting("wikiSorting", settings);

    getSelector(currentCategory);
    sortData();

    setState(() {});
  }

  Future<void> changeGrouping(bool value) async {
    List<String> grouping = List<String>.from(
      settingsController.getSetting("wikiGrouping"),
    );
    grouping[currentCategoryIndex] = value.toString();
    await settingsController.setSetting("wikiGrouping", grouping);

    setState(() {});
  }

  Future<void> changeSecondarySorting(bool standard) async {
    final sortingSettings = List<String>.from(
      settingsController.getSetting("wikiSorting"),
    );

    final index = currentCategoryIndex;
    final sorting = sortingSettings[index];

    if (standard) {
      final standardSort = settingsController.getSetting(
        "${sorting}SubSortStandard",
      );

      await settingsController.setSetting(
        "${sorting}SubSort",
        List<String>.from(standardSort),
      );
    } else {
      await settingsController.setSetting("${sorting}SubSort", "alphabetical");
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
        settingsController.getSetting("featTypeSubSort") is List) {
      return currentItem["Basics"]["type"].toString();
    } else if (category == "source" &&
        settingsController.getSetting("sourceSubSort") is List) {
      return currentItem["Basics"]["source"].toString();
    } else if (category == "primary" &&
        settingsController.getSetting("primarySubSort") is List) {
      return currentItem["Basics"]["Primary"][0].toString();
    } else {
      return selector(currentItem).toString();
    }
  }

  Future<void> applyFilters() async {
    final json = JsonService(currentCategory);
    Map<String, dynamic> items = await json.loadData();

    if (searchWord != "") {
      items = MapService.filterMap(items, "name", [
        searchWord.toString().toLowerCase(),
      ], byStart: false);
    }

    setState(() {
      data = filterData(items);
    });
    sortData();
  }

  Future<void> resetFilters() async {
    filters = jsonDecode(jsonEncode(categoryData[currentCategory]["filters"]));

    final json = JsonService(currentCategory);
    final items = await json.loadData();

    if (!mounted) return;

    setState(() {
      data = filterData(items);
    });

    sortData();
  }

  @override
  Widget build(BuildContext context) {
    int categoryNumLen = 1;
    for (final item in categories) {
      if (item.length > categoryNumLen) {
        categoryNumLen = item.length;
      }
    }
    categoryNum =
        (MediaQuery.sizeOf(context).width /
                (categoryNumLen * textStyleController.getFontSize(5)))
            .floor();

    headerHeight = settingsController.getSetting("headerHeight") / 2;

    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.escape) {
          if (sortingKey.currentState?.isOpen == true) {
            sortingKey.currentState?.close();
            return KeyEventResult.handled;
          }
          if (filterKey.currentState?.submenuOpen == true) {
            filterKey.currentState?.closeSubmenu();
            return KeyEventResult.handled;
          }
          if (filterKey.currentState?.menuOpen == true) {
            filterKey.currentState?.closeMenu();
            return KeyEventResult.handled;
          }
          Navigator.pop(context);
          return KeyEventResult.handled;
        }

        return KeyEventResult.ignored;
      },
      child: Scaffold(
        backgroundColor: colorController.getColor(2),

        appBar: AppBar(
          toolbarHeight: headerHeight * 2 * MediaQuery.sizeOf(context).height,
          backgroundColor: colorController.getColor(0),
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          foregroundColor: colorController.getColor(4),
          centerTitle: true,
          title: SizedBox(
            width: 1000,
            height: 40,
            child: TextField(
              autofocus: true,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                prefixIconColor: colorController.getColor(4),
                labelText: 'Search',
                floatingLabelBehavior: FloatingLabelBehavior.never,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                  borderSide: BorderSide(color: Colors.transparent, width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                  borderSide: BorderSide(color: Colors.transparent, width: 2),
                ),
                labelStyle: textStyleController.getTextStyle(4, 4),
                filled: true,
                fillColor: colorController.getColor(1),
                contentPadding: EdgeInsets.zero,
              ),
              cursorHeight: 22,
              textAlignVertical: TextAlignVertical.center,
              cursorColor: colorController.getColor(4),
              style: textStyleController.getTextStyle(4, 4),
              onChanged: (value) {
                searchWord = value.toLowerCase();

                final json = JsonService(currentCategory);

                json.loadData().then((items) {
                  if (!mounted || searchWord != value.toLowerCase()) return;

                  var filtered = filterData(items);

                  if (searchWord.isNotEmpty) {
                    filtered = MapService.filterMap(filtered, "name", [
                      searchWord,
                    ], byStart: false);
                  }

                  final sorted = MapService.sortMap(
                    filtered,
                    selector,
                    secondarySelector: (el) => el["name"],
                  );

                  setState(() {
                    data = sorted;
                  });
                });
              },
            ),
          ),
          actions: [
            SortingMenuWidget(
              (value) => changeGrouping(value),
              (value) => changeSecondarySorting(value),
              (value) => changeSorting(value),
              currentCategoryIndex,
              availableSorts,
              key: sortingKey,
              subsort: secondarySort,
            ),
            FilterMenuWidget(
              categoryData,
              currentCategory,
              filters,
              () => applyFilters(),
              () => resetFilters(),
              key: filterKey,
            ),
          ],
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(
              headerHeight * 2 * MediaQuery.sizeOf(context).height,
            ),
            child: CategorySelectorWdget(
              height: headerHeight * 2 * MediaQuery.sizeOf(context).height,
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
        body: Padding(
          padding: EdgeInsetsGeometry.directional(
            bottom: settingsController.getSetting("bottomPadding"),
          ),
          child: PageView.builder(
            controller: _pageController,
            itemCount: categories.length,

            onPageChanged: (index) async {
              await loadItems(categories[index]);
              categoryKey.currentState?.focusCategory(categories[index]);
            },

            itemBuilder: (context, index) {
              final category = categories[index];

              if (category != currentState.toLowerCase()) {
                return const Center(child: CircularProgressIndicator());
              }

              final items = data.keys.toList();

              if (items.length < 1) {
                return Center(
                  child: Text(
                    "Nothing here :(",
                    style: textStyleController.getTextStyle(1, 4),
                  ),
                );
              }

              int catIndex = categories.indexOf(category);
              List<dynamic> settings = settingsController.getSetting(
                "wikiSorting",
              );

              return ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, itemIndex) {
                  final String icon =
                      data[items[itemIndex]]["Icon"][settingsController
                          .getSetting("theme")];
                  final item = data[items[itemIndex]];
                  Widget infoWidget = buildInfoWidget(category, item["json"]);

                  bool showSeparator = false;
                  String title = "";

                  if (settingsController.getSetting(
                        "wikiGrouping",
                      )[currentCategoryIndex] ==
                      "true") {
                    if (settings[catIndex] != "alphabetical" &&
                        settingsController.getSetting("groupItemsWiki")) {
                      final currentItem = data[items[itemIndex]];

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
                                style: textStyleController.getTextStyle(2, 4),
                              ),
                            ),
                            Divider(
                              indent: 5,
                              endIndent: 5,
                              color: colorController.getColor(4),
                            ),
                          ],
                        ),
                      DescriptionWidget(
                        data[items[itemIndex]]["name"],
                        infoWidget,
                        currentCategory + "DescriptionStyle".toString(),
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
                                      textStyleController.getFontSize(1) * 1.5,
                                      icon,
                                      key: ValueKey(
                                        data[items[itemIndex]]["name"],
                                      ),
                                    )
                                  : SizedBox.shrink(),
                              Expanded(
                                child: Text(
                                  data[items[itemIndex]]["name"],
                                  style: textStyleController.getTextStyle(
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
        ),
      ),
    );
  }

  Widget buildInfoWidget(String category, String item) {
    return FutureBuilder<dynamic>(
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

        final infoData = Map<String, dynamic>.from(snapshot.data as Map);
        return DescriptionColumnWidget(
          infoData,
          schemata,
          scrollable:
              settingsController.getSetting(
                currentCategory + "DescriptionStyle",
              ) !=
              "sheet",
        );
      },
    );
  }
}

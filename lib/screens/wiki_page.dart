import 'package:dnd_app/services/map_service.dart';
import 'package:dnd_app/services/text_style_service.dart';
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
  bool? goruping;

  final PageController _pageController = PageController();
  late List<dynamic> categories = [];
  late Map<String, dynamic> categoryData = {};
  late String currentState = "classes";

  Map<String, dynamic> data = {};

  late double headerHeight;
  late double listElementHeight;
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
        print("primary");
        if (SettingsService.getSetting("abilitySubSort") is List) {
          ss = (el) {
            final source = el["Basics"]["Primary"][0];
            print(source);
            final List<String> sourceList = SettingsService.getSetting(
              "abilitySubSort",
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
        if (SettingsService.getSetting("featSubSort") is List) {
          ss = (el) {
            final source = el["Basics"]["type"];
            final List<String> typeOrder = SettingsService.getSetting(
              "featSubSort",
            );
            return typeOrder.indexOf(source);
          };
        } else {
          ss = (el) => el["Basics"]["type"];
        }
      } else if (settings[index] == "speed") {
        ss = (el) => el["Basics"]["speed"];
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

  @override
  Widget build(BuildContext context) {
    headerHeight = SettingsService.getSetting("headerHeight") / 2;
    listElementHeight = SettingsService.getSetting("listItemHeight");
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
            actions: [],
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

              // only show data if this is the currently loaded category
              if (category != currentState.toLowerCase()) {
                return const Center(child: CircularProgressIndicator());
              }

              final items = data.keys.toList();

              return ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, itemIndex) {
                  dynamic name = selector(data[items[itemIndex]]);
                  String firstLetter = "";
                  bool showSeparator = false;
                  String title = "";
                  if (name is String) {
                    firstLetter = name[0].toUpperCase();
                    showSeparator =
                        itemIndex == 0 ||
                        firstLetter !=
                            selector(
                              data[items[itemIndex - 1]],
                            )[0].toUpperCase();
                    if (categoryData[category]["sorting"].contains("primary") &&
                        name ==
                            data[items[itemIndex]]["Basics"]["Primary"][0]) {
                      switch (name) {
                        case "Str":
                          title = "Strength";
                          break;
                        case "Dex":
                          title = "Dexterity";
                          break;
                        case "Con":
                          title = "Constitution";
                          break;
                        case "Int":
                          title = "Inteligence";
                          break;
                        case "Wis":
                          title = "Wisdom";
                          break;
                        case "Cha":
                          title = "Charisma";
                          break;
                        default:
                          title = "";
                          break;
                      }
                    } else {
                      title = firstLetter;
                    }
                  }

                  if (!SettingsService.getSetting("groupItemsWiki")) {
                    showSeparator = false;
                  }
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (showSeparator)
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsetsGeometry.directional(
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
                      ItemWidget(
                        items[itemIndex],
                        data[items[itemIndex]],
                        category,
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

  /*
    MenuAnchor menu= MenuAnchor(
      builder: (context, controller, child) {
        return IconButton(
          icon: const Icon(Icons.tune),
          onPressed: () {
            controller.isOpen ? controller.close() : controller.open();
          },
        );
      },
      menuChildren: [
        Padding(
          padding: EdgeInsetsGeometry.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10,
            children: [
              DropdownMenu(
                label: Text("Sorting type"),
                initialSelection: "alphabetical",
                requestFocusOnTap: true,
                dropdownMenuEntries: [
                  DropdownMenuEntry(value: "alphabetical", label: "Alphabetical"),
                ],
                onSelected: (value){

                },
              ),
              DropdownMenu(
                label: Text("Sort by"),
                requestFocusOnTap: true,
                dropdownMenuEntries:[
                  DropdownMenuEntry(value: (el)=>el["name"], label: "Name"),
                  DropdownMenuEntry(value: (el)=>el["Basics"]["Primary"], label: "Primary Ability")
                ],
              ),
              RadioGroup<bool?>(
                groupValue: goruping,
                onChanged: (bool? value) async{
                  await SettingsService.setSetting("groupItemsWiki", value);
                },
                child: Row(
                  children: [
                    RadioListTile(
                      title: Text("yes"),
                      value: true,
                    ),
                    RadioListTile(
                      title: Text("no"),
                      value: false,
                    )
                  ],
                )
              )
            ],
          ),
        )
      ],
    );
    */
}

  import 'package:dnd_app/services/map_service.dart';
import 'package:dnd_app/services/text_style_service.dart';
import 'package:flutter/material.dart';

  import 'package:dnd_app/services/json_service.dart';
  import 'package:dnd_app/services/settings_service.dart';
  import 'package:dnd_app/services/color_service.dart';

  import 'package:dnd_app/widgets/item_widget.dart';
  import 'package:dnd_app/widgets/category_selector_widget.dart';


  class WikiPage extends StatefulWidget{
    const WikiPage(this.categoryNum, this.sortKey,{super.key});

    final int categoryNum;
    final String sortKey;

    @override
    State<WikiPage> createState() => _WikiState();
  }

  class _WikiState extends State<WikiPage> with SingleTickerProviderStateMixin {

    final PageController _pageController = PageController();  
    List<dynamic> categories=["classes", "spells", "feats", "species", "a", "b", "c"];
    late String currentState="classes";

    Map<String, dynamic> data={};

    late double headerHeight;
    late double listElementHeight;
    late int categoryNum;

    final GlobalKey<CategorySelectorWidgetState> categoryKey =
      GlobalKey<CategorySelectorWidgetState>();


    @override
    void initState() {
      super.initState();
      loadOptions(categories[0], widget.sortKey);
    }

    @override
    void dispose() {
      _pageController.dispose();
      super.dispose();
    }

    Future<void> loadOptions(String file, String sortKey) async {
      final json = JsonService(file);
      Map<String, dynamic> items = await json.loadData(); 

      final keys = items.keys.toList()..sort();


      Map<String, dynamic> sorted=MapService.sortMap("sort",items, sortKey);
      
      setState(() {
        data=sorted;
        currentState=file;
      });
    }


    @override
    Widget build(BuildContext context) {
      headerHeight=SettingsService.getSetting("headerHeight")/2;
      listElementHeight=SettingsService.getSetting("listItemHeight");
      categoryNum=widget.categoryNum;
      List<dynamic> items= (data.keys.toList());

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
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(headerHeight),
                  child: CategorySelectorWdget(
                    height: headerHeight,
                    categoryNumber: categoryNum,
                    categories: categories,
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
                  )
              ),
            ),
            body: PageView.builder(
              controller: _pageController,
              itemCount: categories.length,

              onPageChanged: (index) {
                loadOptions(categories[index], widget.sortKey);
                categoryKey.currentState?.focusCategory(categories[index]);
              },

              itemBuilder: (context, index) {
                final category = categories[index];

                // only show data if this is the currently loaded category
                if (category != currentState.toLowerCase()) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final items = data.keys.toList();

                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, itemIndex) {
                    String name=data[items[itemIndex]][widget.sortKey];
                    final firstLetter= name[0].toUpperCase();

                    final showSeparator = itemIndex==0||firstLetter!=data[items[itemIndex-1]][widget.sortKey][0].toUpperCase();

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if(showSeparator)
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsetsGeometry.directional(start: 30),
                                child: Text(
                                  firstLetter,
                                  style: TextStyleService.getTextStyle(1, 4),
                                ),  
                              ),
                              Divider(
                                indent: 20,
                                endIndent: 20,
                                color: ColorService.getColor(4),
                              )
                            ],
                          ),
                        ItemWidget(
                          items[itemIndex],
                          data[items[itemIndex]],
                          category,
                        )
                      ],
                    );
                  },
                );
              },
            ),      
          );
        }
      );
    }
  }

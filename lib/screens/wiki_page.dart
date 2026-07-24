  import 'package:flutter/material.dart';
  import 'package:flutter/services.dart';

  import 'package:dnd_app/services/color_service.dart';
  import 'package:dnd_app/services/json_service.dart';

  import 'package:dnd_app/widgets/item_widget.dart';
  import 'package:dnd_app/widgets/category_selector_widget.dart';

  class WikiPage extends StatefulWidget{
    const WikiPage(this.headerHeight,this.listElementHeight,this.categoryNum, {super.key});

    final double headerHeight;
    final double listElementHeight;
    final int categoryNum;

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
      loadOptions(categories[0]);
    }

    @override
    void dispose() {
      _pageController.dispose();
      super.dispose();
    }

    Future<void> loadOptions(String file) async {
      final json = JsonService(file);
      Map<String, dynamic> items = await json.loadData(); 

      final keys = items.keys.toList()..sort();

      Map<String, dynamic> sorted={};

      for (final key in keys) {
      sorted[key] = items[key];
      }
      
      setState(() {
        data=sorted;
        currentState=file;
      });
    }


    @override
    Widget build(BuildContext context) {
      headerHeight=(widget.headerHeight/100)*MediaQuery.of(context).size.height;
      listElementHeight=(widget.listElementHeight/100)*MediaQuery.of(context).size.height;
      categoryNum=widget.categoryNum;
      List<dynamic> items= (data.keys.toList());


      return Scaffold(
        backgroundColor: MyColor.background,

        appBar: AppBar(
          toolbarHeight: headerHeight,
          backgroundColor: MyColor.primary,
          foregroundColor: MyColor.text,
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
            loadOptions(categories[index]);
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
                return ItemWidget(
                  items[itemIndex],
                  data[items[itemIndex]],
                  category,
                  listElementHeight,
                );
              },
            );
          },
        ),      
      );
    }
  }

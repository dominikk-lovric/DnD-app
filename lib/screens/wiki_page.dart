  import 'package:flutter/material.dart';
  import 'package:flutter/services.dart';

  import 'package:dnd_app/services/color_service.dart';
  import 'package:dnd_app/services/json_service.dart';

  import 'package:dnd_app/widgets/Class_widget.dart';

  class WikiPage extends StatefulWidget{
    const WikiPage({super.key});

    @override
    State<WikiPage> createState() => _WikiState();
  }

  class _WikiState extends State<WikiPage> with SingleTickerProviderStateMixin {


    List<dynamic> categories=["classes", "spells", "feats", "species", "a", "b", "c"];
    late String currentState="Classes";

    Map<String, dynamic> data={};

    @override
    void initState() {
      super.initState();

      loadOptions(categories[0]);
    }

    void dispose() {
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
      
      print(sorted);      

      setState(() {
        data=sorted;
        currentState=file;
      });
    }


    @override
    Widget build(BuildContext context) {
      

      List<dynamic> items= (data.keys.toList());


      return Scaffold(
        backgroundColor: MyColor.background,

        appBar: AppBar(
          toolbarHeight: 60,
          backgroundColor: MyColor.primary,
          foregroundColor: MyColor.text,
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(60),
            child: SizedBox(
              height: 60,
              child: ListView.builder(scrollDirection: Axis.horizontal,
              itemCount: categories.length,
                itemBuilder: (BuildContext context, int index){
                  final itemWidth = MediaQuery.of(context).size.width / 4;
                  return SizedBox(
                    width: itemWidth,
                    height: 60,
                    child: Container(                    
                      decoration: currentState == categories[index]?BoxDecoration(
                        color: MyColor.primary,
                        border: Border(bottom: BorderSide(
                          color: MyColor.secondary,
                            width: 10,))
                      ):null,
                      child: TextButton(
                        style: TextButton.styleFrom(foregroundColor: MyColor.text, 
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero, )),
                        onPressed: () => loadOptions(categories[index]),
                        child: Text(categories[index]),
                      ),
                    )
                  );                  
                },
              ),
            ),
          ),
        ),

        body: ListView.builder(
          itemCount:data.length, 
          itemBuilder: (BuildContext context, int index){
            return ClassWidget(items[index], data[items[index]]);
          } 
        )
      );
    }
  }

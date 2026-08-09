  import 'package:dnd_app/services/settings_service.dart';
import 'package:dnd_app/services/text_style_service.dart';
import 'package:dnd_app/widgets/table_widget.dart';
import 'package:dnd_app/widgets/class_info_widget.dart';
  import 'package:flutter/material.dart';

  import 'package:dnd_app/services/json_service.dart';
  import 'package:dnd_app/services/color_service.dart';

  import 'package:dnd_app/widgets/optional_image_widget.dart';
  import 'package:dnd_app/widgets/saving_throws_widget.dart';

  class ItemPage extends StatefulWidget {
    final String jsonPath;
    final String id;

    const ItemPage(this.jsonPath,this.id, {super.key});

    @override
    State<ItemPage> createState()=>_ItemPageState();
  }

  class _ItemPageState extends State<ItemPage>{

    String type="";
    String name="";
    String icon="";
    Map<String, dynamic> items={}; 

    @override
    void initState() {
      super.initState();
      loadOptions(widget.jsonPath);
    }

    Future<void> loadOptions(String path) async {
      items=await JsonService.loadFromPath(path);
      setState(() {
        type=items["catId"];
        name=items["name"];
        if(items.containsKey("icon")){
          icon=items["icon"][SettingsService.getSetting("theme")];
        }else{
          icon="none";
        } 
      });
    }

    @override
    Widget build(BuildContext context) {
      if (items.isEmpty) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      return AnimatedBuilder(
        animation: ColorService.themeNotifier,
        builder: (context, child) {
          return Scaffold(
            backgroundColor: ColorService.getColor(2),
            appBar: 
            AppBar(
              backgroundColor: ColorService.getColor(0),
              toolbarHeight: SettingsService.getSetting("headerHeight"),
              title: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: (icon!="none")?MediaQuery.of(context).size.width*(1/60):0.0,
                  children: [
                    (icon!="none")?OptionalImageWidget(
                    SettingsService.getSetting("headerHeight")*(8/10),
                    icon,
                    key: ValueKey(name),)
                    :SizedBox.shrink(),
                    Expanded(
                      child: Text(
                        name,
                        style: TextStyleService.getTextStyle(0, 4, Overflow:TextOverflow.fade),
                        maxLines: 1,
                        softWrap: false,
                      ), 
                    ),
                  ],
              ),
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsetsGeometry.all(20),
                child: ClassInfoWidget(items)
              ),
            )
            
          );
        }
      );
    }
  }


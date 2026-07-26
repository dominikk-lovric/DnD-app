  import 'package:dnd_app/services/settings_service.dart';
import 'package:dnd_app/widgets/attack_number_widget.dart';
  import 'package:flutter/material.dart';

  import 'package:dnd_app/services/json_service.dart';
  import 'package:dnd_app/services/color_service.dart';

  import 'package:dnd_app/widgets/optional_image_widget.dart';
  import 'package:dnd_app/widgets/saving_throws_widget.dart';

  class ItemPage extends StatefulWidget {
    final String jsonPath;


    ItemPage(this.jsonPath);

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
        icon=items["icon"][SettingsService.getSetting("theme")];
      });
    }

    @override
    Widget build(BuildContext context) {

      List<Widget> info=[];

      switch(type){
        case "class":
          info.add(SavingThrowWidget(items["savingThrows"]));
          if(items["casterLevel"]>0){

          }
          info.add(AttackNumberWidget(items["attacksPerLevel"]));
          break;
        case "species":
          break;
        case "spell":
          break;
        case "feat":
          break;
        default:
          info.add(SizedBox.shrink());
          break;
          
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
                        style: TextStyle(
                          color: ColorService.getColor(5),
                          fontSize: SettingsService.getSetting("headerHeight")*0.8,
                          overflow: TextOverflow.fade
                          
                        ),
                        maxLines: 1,
                        softWrap: false,
                      ), 
                    ),
                  ],
              ),
            ),
            body: SingleChildScrollView(
              child: Column(
                children: info,
              ),
            )
            
          );
        }
      );
    }
  }


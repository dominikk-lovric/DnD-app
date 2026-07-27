import 'package:flutter/material.dart';

import 'package:dnd_app/services/settings_service.dart';
import 'package:dnd_app/services/color_service.dart';

import 'package:dnd_app/widgets/optional_image_widget.dart';

import 'package:dnd_app/screens/item_page.dart';

class ItemWidget extends StatelessWidget{
  const ItemWidget(this.id, this.classData, this.category, {super.key});
  final String id;
  final String category;
  final Map<String, dynamic> classData;


  @override
  Widget build(BuildContext context){
    final basics = Map<String, dynamic>.from(classData["Basics"]);
    final names = basics.keys.toList() as List<dynamic>;
    final items = basics.values.toList();
    final String icon=classData["Icon"][SettingsService.getSetting("theme")];
    final height=SettingsService.getSetting("headerHeight");

    String subtitle="";
    for(var i=0;i<items.length;i++){
      subtitle=subtitle+"   • "+names[i]+": ";
      if(items[i] is List){
        subtitle=subtitle+(items[i] as List).join(", ");
        }else{
          subtitle=subtitle+items[i];
        }
    }
    
    subtitle=subtitle.trimLeft();
      
    return GestureDetector(
      onTap: () => {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (BuildContext context)=>ItemPage(classData["json"],id))
        ),
      },
      child: Container(
        height: height,
        child: Card(
        color:ColorService.getColor(3),
        child: 
          Padding(
            padding:EdgeInsets.only(left: MediaQuery.of(context).size.width*(1/100)),
            child: 
              Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: (icon!="none")?MediaQuery.of(context).size.width*(1/60):0.0,
              children: [
                (icon!="none")?OptionalImageWidget(
                height*(8/10),
                icon,
                key: ValueKey(classData["name"]),):SizedBox.shrink(),
                Expanded(child: 
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(classData["name"], style: TextStyle(color: ColorService.getColor(5), fontSize: height*(2.5/5), height: 0.8), overflow: TextOverflow.fade, maxLines: 1,),
                      Text(subtitle, style: TextStyle(color: ColorService.getColor(6), fontSize: height*(1.5/10), height: 0.8),overflow: TextOverflow.fade,)
                    ],                  
                  ),
                ),
              ],
            ),            
          )
        ),
      ),
    );
  }
}
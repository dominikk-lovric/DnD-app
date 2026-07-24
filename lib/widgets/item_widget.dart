import 'package:dnd_app/services/color_service.dart';
import 'package:dnd_app/services/icon_service.dart';
import 'package:dnd_app/services/settings_service.dart';
import 'package:flutter/material.dart';

import 'package:dnd_app/widgets/optional_image_widget.dart';

class ItemWidget extends StatelessWidget{
  const ItemWidget(this.name, this.classData, this.category, this.height, {super.key});
    
  final String category;
  final String name;
  final Map<String, dynamic> classData;
  final double height;


  @override
  Widget build(BuildContext context){
    final basics = Map<String, dynamic>.from(classData["Basics"]);
    final names = basics.keys.toList() as List<dynamic>;
    final items = basics.values.toList() as List<dynamic>;
    final String icon=classData["Icon"][SettingsService.getTheme()];


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
      child: Container(
        height: this.height,
        child: Card(
        color:MyColor.accent,
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
                key: ValueKey(name),):SizedBox.shrink(),
                Expanded(child: 
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Hero(tag:name+"-hero-rectangle",child:Text(name, style: TextStyle(color: MyColor.textDark, fontSize: height*(2.5/5), height: 0.8), overflow: TextOverflow.fade, maxLines: 1,)),
                      Text(subtitle, style: TextStyle(color: MyColor.textDarkSubtitle, fontSize: height*(1.5/10), height: 0.8),overflow: TextOverflow.fade,)
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
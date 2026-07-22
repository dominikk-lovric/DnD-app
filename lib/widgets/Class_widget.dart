import 'package:dnd_app/services/color_service.dart';
import 'package:flutter/material.dart';

class ClassWidget extends StatelessWidget{
    const ClassWidget(this.name, this.classData, {super.key});
    
    final String name;
    final Map<String, dynamic> classData;

    @override
    Widget build(BuildContext context){
        final basics = Map<String, dynamic>.from(classData["Basics"]);
        final names = basics.keys.toList() as List<dynamic>;
        final items = basics.values.toList() as List<dynamic>;
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
        return Card(
            color:MyColor.accent,
            child: ListTile(
                title: Text(name, style: TextStyle(color: MyColor.textDark),),
                subtitle: Text(subtitle, style: TextStyle(color: MyColor.textDarkSubtitle),)
            )
        );
    }
}
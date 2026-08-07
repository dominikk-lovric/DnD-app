import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:dnd_app/services/settings_service.dart';
import 'package:dnd_app/services/color_service.dart';
import 'package:dnd_app/services/text_style_service.dart';

import 'package:dnd_app/screens/wiki_page.dart';
import 'package:dnd_app/screens/settings_page.dart';


class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ColorService.themeNotifier, 
      builder: (context, child){
        return Scaffold(
          backgroundColor: ColorService.getColor(2),
          appBar: AppBar(
            title:  Text("Main Page", style: TextStyleService.getTextStyle(0, 4),),
            backgroundColor: ColorService.getColor(0), 
            foregroundColor: ColorService.getColor(4), 
            centerTitle: true,
            toolbarHeight: SettingsService.getSetting("headerHeight"),
            actions: [
              Padding(
                padding: EdgeInsetsGeometry.directional(end: 10), 
                child: IconButton(
                  onPressed: (){Navigator.push(context, MaterialPageRoute<void>(builder: (context)=>SettingsPage()),);},
                  icon: Icon(Icons.settings),
                )
              )
            ],
          ),
          body: Center(
            child: 
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: ColorService.getColor(4),
                    backgroundColor: ColorService.getColor(0),
                  ),
                  onPressed: (){Navigator.push(context,MaterialPageRoute<void>(builder: (context) =>  WikiPage(4),),);}, 
                  child: Text('Wiki',style: TextStyleService.getTextStyle(2, 4)),),
              ],
            )        
          )
        );
      }
    );
  }
}
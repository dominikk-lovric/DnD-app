import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:dnd_app/services/color_service.dart';

import 'package:dnd_app/screens/wiki_page.dart';

class HomePage extends StatelessWidget {
  final double headerHeight;
  const HomePage(this.headerHeight, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColor.background,
      appBar: AppBar(title: const Text("Main Page"), backgroundColor: MyColor.primary, foregroundColor: MyColor.text, centerTitle: true,toolbarHeight: (headerHeight/100)*MediaQuery.of(context).size.height,),
      body: Center(
        child: 
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: MyColor.text,
                backgroundColor: MyColor.primary
              ),
              onPressed: (){Navigator.push(context,MaterialPageRoute(builder: (context) =>  WikiPage(headerHeight/2,10,4),),);}, child: Text('Wiki'))
          ],
        )        
      )
    );
  }
}
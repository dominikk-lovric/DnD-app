import 'package:dnd_app/widgets/color_selector_widget.dart';
import 'package:flutter/material.dart';

import 'package:dnd_app/services/settings_service.dart';
import 'package:dnd_app/services/color_service.dart';

class SettingsPage extends StatelessWidget{
  const SettingsPage({super.key});


  @override
  Widget build(BuildContext context) {
    
    return AnimatedBuilder(
      animation: ColorService.themeNotifier,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: ColorService.getColor(2),
          appBar: AppBar(
            backgroundColor: ColorService.getColor(0),
            toolbarHeight: SettingsService.getSetting("headerHeight"),
          ),
          body: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: ColorService.getColorNames().length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              return Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: ColorSelectorWidget(index),
                ),
              );
            },
          ),
        );
      }
    );
  }
}
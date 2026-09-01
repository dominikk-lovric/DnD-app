import 'package:dnd_app/services/color_service.dart';
import 'package:dnd_app/services/json_service.dart';
import 'package:dnd_app/services/settings_service.dart';
import 'package:dnd_app/services/string_service.dart';
import 'package:dnd_app/services/text_style_service.dart';
import 'package:dnd_app/widgets/description_widget.dart';
import 'package:dnd_app/widgets/feature_description_widget.dart';
import 'package:dnd_app/widgets/list_widget.dart';
import 'package:dnd_app/widgets/saving_throws_widget.dart';
import 'package:dnd_app/widgets/table_widget.dart';
import 'package:flutter/material.dart';

class DescriptionColumnWidget extends StatefulWidget {
  Map<String, dynamic> info;
  Map<String, dynamic> categoryData;
  int sectionLevel;
  int subtitleLevel;
  int descriptionLevel;
  DescriptionColumnWidget(
    this.info,
    this.categoryData, {
    super.key,
    this.sectionLevel = 1,
    this.subtitleLevel = 2,
    this.descriptionLevel = 3,
  });

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return DescriptionColumnWidgetState();
  }
}

class DescriptionColumnWidgetState extends State<DescriptionColumnWidget> {
  late bool loaded;
  String category = "";
  List<Widget> widgets = [];
  DescriptionColumnWidgetState();

  @override
  initState() {
    category = widget.info["catId"];
    loaded = false;
    super.initState();
  }

  String getLevel(int level) {
    switch (level) {
      case 0:
        return "Cantrip";
      case 1:
        return "1st";
      case 2:
        return "2nd";
      case 3:
        return "3rd";
      default:
        return "${level}th";
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!loaded) {
      return Center(child: CircularProgressIndicator());
    }

    return Column(children: widgets);
  }

  Future<void> getItems() async {
    List<Widget> res = [];
    for (String key in widget.info.keys.toList()) {
      res.add(getItem(key));
    }
    setState(() {
      widgets = res;
      loaded = true;
    });
  }

  Widget getItem(String key, String title) {
    Map<String, dynamic> schema = widget.categoryData[category]["schema"];
    String type = schema[key]["type"];
    String newTitle = (schema[key]["noTitle"] == true) ? "" : title;
    String setting = title + widget.info["catId"] + "DescriptionType";
    switch (type) {
      case "text":
        return DescriptionWidget(
          title,
          Text(
            widget.info[key].toString(),
            style: TextStyleService.getTextStyle(4, 4),
          ),
          setting,
        );
        break;
      case "list":
        List<Widget> widgets=[];
        
        return DescriptionWidget(newTitle, , setting);
        break;
      case "map":
        break;
      case "icon":
        break;
      case "bool":
        break;
      case "table":
        break;
      default:
        if (widget.categoryData.keys.toList().contains(key)) {
          break;
        } else {
          break;
        }
    }
    return SizedBox.shrink();
  }

  dynamic getInfo(String key){
    List<String> selectors=key.split(".");
    dynamic item=widget.info;
    for (final selector in selectors){
      item=item[selector];
    }
    return item;
  }
}

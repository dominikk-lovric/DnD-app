import 'package:dnd_app/services/text_style_service.dart';
import 'package:dnd_app/widgets/description_column_widget.dart';
import 'package:dnd_app/widgets/description_widget.dart';
import 'package:dnd_app/widgets/feature_description_widget.dart';
import 'package:flutter/material.dart';

class FeatInfoWidget extends StatefulWidget {
  Map<String, dynamic> info;
  int sectionLevel;
  int subtitleLevel;
  int descriptionLevel;
  FeatInfoWidget(
    this.info, {
    super.key,
    this.sectionLevel = 1,
    this.subtitleLevel = 2,
    this.descriptionLevel = 3,
  });

  @override
  State<StatefulWidget> createState() => FeatInfoWidgetState();
}

class FeatInfoWidgetState extends State<FeatInfoWidget> {
  @override
  Widget build(BuildContext context) {
    return DescriptionColumnWidget(widget.info);
  }
}

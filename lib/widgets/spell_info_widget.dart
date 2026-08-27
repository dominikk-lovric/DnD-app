import 'package:dnd_app/widgets/description_column_widget.dart';
import 'package:flutter/material.dart';

class SpellInfoWidget extends StatefulWidget {
  Map<String, dynamic> info;

  int sectionLevel;
  int subtitleLevel;
  int descriptionLevel;
  SpellInfoWidget(
    this.info, {
    super.key,
    this.sectionLevel = 1,
    this.subtitleLevel = 2,
    this.descriptionLevel = 3,
  });

  @override
  State<StatefulWidget> createState() => SpellInfoWidgetState();
}

class SpellInfoWidgetState extends State<SpellInfoWidget> {
  SpellInfoWidgetState();

  @override
  Widget build(BuildContext context) {
    return DescriptionColumnWidget(widget.info, showFalse: false);
  }
}

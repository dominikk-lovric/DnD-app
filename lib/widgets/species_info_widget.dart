import 'dart:math' as math;

import 'package:dnd_app/services/color_service.dart';
import 'package:dnd_app/services/text_style_service.dart';
import 'package:dnd_app/widgets/description_widget.dart';
import 'package:dnd_app/widgets/feature_description_widget.dart';
import 'package:dnd_app/widgets/list_widget.dart';
import 'package:dnd_app/widgets/table_widget.dart';
import 'package:flutter/material.dart';

class SpeciesInfoWidget extends StatefulWidget {
  Map<String, dynamic> info;
  int sectionLevel;
  int subtitleLevel;
  int descriptionLevel;

  SpeciesInfoWidget(
    this.info, {
    super.key,
    this.sectionLevel = 1,
    this.subtitleLevel = 2,
    this.descriptionLevel = 3,
  });

  @override
  State<StatefulWidget> createState() => SpeciesInfoWidgetStatie();
}

class SpeciesInfoWidgetStatie extends State<SpeciesInfoWidget> {
  SpeciesInfoWidgetStatie();

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 20,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.info.containsKey("creatureType"))
          Text(
            "Creatue Type: " + widget.info["creatureType"],
            style: TextStyleService.getTextStyle(widget.subtitleLevel, 4),
          ),
        if (widget.info.containsKey("size"))
          DescriptionWidget(
            "Size",
            ListWidget(widget.info["size"]),
            "sizeDescriptionStyle",
            titleLevel: widget.subtitleLevel,
          ),
        if (widget.info.containsKey("speed"))
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Transform.scale(
                scaleY: -1,
                child: Transform.rotate(
                  angle: math.pi,
                  child: Icon(
                    Icons.air,
                    size: widget.subtitleLevel * 20.0,
                    color: ColorService.getColor(4),
                  ),
                ),
              ),
              Text(
                "${widget.info["speed"]}ft",
                style: TextStyleService.getTextStyle(widget.subtitleLevel, 4),
              ),
            ],
          ),
        if (widget.info.containsKey("spells"))
          if (widget.info["spells"].containsKey("addedSpells"))
            TableWidget(widget.info["spells"]["addedSpells"], 4, "horizontal"),
        if (widget.info.containsKey("features"))
          DescriptionWidget(
            "Features",
            Padding(
              padding: EdgeInsetsGeometry.directional(start: 20),
              child: Column(
                spacing: 10,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...widget.info["features"].map((element) {
                    return FeatureDescriptionWidget(
                      element,
                      "featureDescriptionStyle",
                      clickLevel: widget.subtitleLevel,
                      levelTitle: true,
                    );
                  }),
                ],
              ),
            ),
            "sectionDescriptionStyle",
            titleLevel: widget.sectionLevel,
          ),
        if (widget.info.containsKey("subspecies"))
          DescriptionWidget(
            "Subspecies",
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                ...widget.info["subspecies"].map((el) {
                  return DescriptionWidget(
                    el["name"],
                    SpeciesInfoWidget(
                      el,
                      sectionLevel: widget.sectionLevel,
                      subtitleLevel: widget.subtitleLevel,
                      descriptionLevel: widget.descriptionLevel,
                    ),
                    "subspeciesDescriptionType",
                  );
                }),
              ],
            ),
            "sectionDescriptionType",
          ),
      ],
    );
  }
}

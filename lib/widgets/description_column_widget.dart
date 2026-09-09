import 'package:dnd_app/services/string_service.dart';
import 'package:dnd_app/services/settings_service.dart';
import 'package:dnd_app/services/text_style_service.dart';
import 'package:dnd_app/widgets/description_widget.dart';
import 'package:flutter/material.dart';

import 'package:dnd_app/services/schema_render_service.dart';

class DescriptionColumnWidget extends StatefulWidget {
  final Map<String, dynamic> info;
  final Map<String, dynamic> schemata;

  final int sectionLevel;
  final int subtitleLevel;
  final int descriptionLevel;
  final bool scrollable;
  final String category;

  const DescriptionColumnWidget(
    this.info,
    this.schemata, {
    super.key,
    this.sectionLevel = 1,
    this.subtitleLevel = 2,
    this.descriptionLevel = 3,
    this.scrollable = true,
    this.category = "",
  });

  @override
  State<DescriptionColumnWidget> createState() =>
      DescriptionColumnWidgetState();
}

class DescriptionColumnWidgetState extends State<DescriptionColumnWidget> {
  late String category;
  bool loaded = false;

  List<Widget> widgets = [];

  @override
  void initState() {
    super.initState();

    category = widget.category.isEmpty
        ? (widget.info["catId"] ?? "")
        : widget.category;

    getItems();
  }

  @override
  Widget build(BuildContext context) {
    if (!loaded) {
      return const Center(child: CircularProgressIndicator());
    }

    //    if (!widget.scrollable) {
    return Column(
      spacing: MediaQuery.sizeOf(context).width / 72,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: widgets,
    );
    //  }

    /*return ListView.builder(
      itemCount: widgets.length,
      itemBuilder: (context, index) {
        return widgets[index];
      },
    );*/
  }

  Future<void> getItems() async {
    final List<Widget> res = [];

    final categorySchema = widget.schemata[category];

    if (categorySchema == null) {
      setState(() {
        widgets = [];
        loaded = true;
      });
      return;
    }

    final Map<String, dynamic> schema = Map<String, dynamic>.from(
      categorySchema,
    );

    for (final key in widget.info.keys) {
      Map<String, dynamic>? schemaItem;

      if (schema.containsKey(key)) {
        schemaItem = Map<String, dynamic>.from(schema[key]);
      } else if (schema.containsKey("default")) {
        schemaItem = Map<String, dynamic>.from(schema["default"]);
      }

      if (schemaItem == null) {
        continue;
      }

      final title = StringService.titleFromKey(key);

      final setting =
          "${StringService.slugify(title)}${category}DescriptionStyle";

      final newTitle = SettingsService.getSetting(setting) == "static"
          ? ""
          : title;

      res.add(
        SchemaRenderService.render(
          context: context,
          category: category,
          data: widget.info[key],
          schema: schemaItem,
          schemata: widget.schemata,
          title: newTitle,
          setting: setting,
        ),
      );
    }

    setState(() {
      widgets = res;
      loaded = true;
    });
  }
}

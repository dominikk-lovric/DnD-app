import 'package:dnd_app/services/color_service.dart';
import 'package:dnd_app/services/json_service.dart';
import 'package:dnd_app/services/text_style_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CharacterCreatorWidget extends ConsumerStatefulWidget {
  @override
  ConsumerState<CharacterCreatorWidget> createState() {
    // TODO: implement createState
    return CharacterCreatorWidgetState();
  }
}

class CharacterCreatorWidgetState
    extends ConsumerState<CharacterCreatorWidget> {
  late final TextStyleController textStyleController;
  late final ColorController colorController;
  Map<String, dynamic> categoryData = {};
  Map<String, dynamic> classData = {};
  Map<String, dynamic> speciesData = {};
  Map<String, dynamic> backgroundData = {};
  int level = 0;
  bool loaded = false;
  @override
  initState() {
    loaded = false;
    super.initState();
    textStyleController = ref.read(textStyleControllerProvider.notifier);
    colorController = ref.read(colorControllerProvider.notifier);
    loadData();
  }

  Future<void> loadData() async {
    Map<String, dynamic> categories = await JsonService.loadFromPath(
      "assets/json/categories.json",
    );
    Map<String, dynamic> classes = await JsonService.loadFromPath(
      categories["classes"]["path"],
    );
    Map<String, dynamic> species = await JsonService.loadFromPath(
      categories["species"]["path"],
    );
    Map<String, dynamic> backgrounds = await JsonService.loadFromPath(
      categories["backgrounds"]["path"],
    );
    setState(() {
      categoryData = categories;
      classData = classes;
      speciesData = species;
      backgroundData = backgrounds;
      loaded = true;
    });
  }

  final _creatorKey = GlobalKey<CharacterCreatorWidgetState>();
  @override
  Widget build(BuildContext context) {
    if (!loaded) {
      return Center(child: CircularProgressIndicator());
    }
    return Form(
      key: _creatorKey,
      child: Column(
        spacing: MediaQuery.sizeOf(context).height / 72,
        children: [
          TextFormField(
            style: textStyleController.getTextStyle(6, 4),
            decoration: InputDecoration(
              label: Text(
                "Name",
                style: textStyleController.getTextStyle(6, 5),
              ),
              filled: true,
              fillColor: colorController.getColor(3),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(30)),
                borderSide: BorderSide(color: colorController.getColor(4)),
              ),
            ),
          ),

          TextFormField(
            style: textStyleController.getTextStyle(6, 4),
            maxLength: 2,
            decoration: InputDecoration(
              label: Text(
                "Level",
                style: textStyleController.getTextStyle(6, 5),
              ),
              hintText: "1-20",
              filled: true,
              fillColor: colorController.getColor(3),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: colorController.getColor(4)),
              ),
              hintStyle: textStyleController.getTextStyle(6, 5),
            ),
            keyboardType: TextInputType.numberWithOptions(),
            validator: (value) {
              return (int.parse(value ?? "0") <= 20 &&
                      int.parse(value ?? "0") > 0)
                  ? null
                  : "Level must be between 1 and 20";
            },
            onChanged: (value) {
              print(value);
              try {
                level = int.parse(value);
              } catch (e) {
                level = 0;
              }
              print(level);
            },
          ),
        ],
      ),
    );
  }

  Widget getChoiceSelector(Map<String, dynamic> options, {int initial = 0}) {
    List<String> keys = options.keys.toList();
    String _selected = options[keys[0]]["name"];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: DropdownButtonFormField(
            value: _selected,
            decoration: InputDecoration(
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items: keys
                .map(
                  (item) => DropdownMenuItem(
                    value: item,
                    child: Text(options[item]["name"]),
                  ),
                )
                .toList(),
            onChanged: (value) {
              setState(() => _selected = value ?? "");
            },
          ),
        ),
        const SizedBox(width: 8),
        IconButton.filled(onPressed: () {}, icon: Icon(Icons.circle)),
      ],
    );
  }
}

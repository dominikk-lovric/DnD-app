import 'package:dnd_app/services/color_service.dart';
import 'package:dnd_app/services/json_service.dart';
import 'package:dnd_app/services/settings_service.dart';
import 'package:dnd_app/services/text_style_service.dart';
import 'package:dnd_app/widgets/description_column_widget.dart';
import 'package:dnd_app/widgets/description_widget.dart';
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
  Map<String, dynamic> selectedMap = {};
  late final TextStyleController textStyleController;
  late final SettingsController settingsController;
  late final ColorController colorController;
  Map<String, dynamic> categoryData = {};
  Map<String, dynamic> classData = {};
  Map<String, dynamic> speciesData = {};
  Map<String, dynamic> backgroundData = {};
  Map<String, dynamic> schemata = {};
  int classesNum = 1;
  int level = 0;
  bool loaded = false;
  @override
  initState() {
    loaded = false;
    super.initState();
    settingsController = ref.read(settingsControllerProvider.notifier);
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
    Map<String, dynamic> schema = await JsonService.loadFromPath("schemata");
    setState(() {
      categoryData = categories;
      classData = classes;
      speciesData = species;
      backgroundData = backgrounds;
      schemata = schema;
      loaded = true;
      selectedMap["class1"] = selectedMap["class1"] ?? classData.keys.first;
      selectedMap["species"] = selectedMap["species"] ?? speciesData.keys.first;
      selectedMap["backgrounds"] =
          selectedMap["backgrounds"] ?? backgroundData.keys.first;
    });
  }

  final _creatorKey = GlobalKey<CharacterCreatorWidgetState>();
  @override
  Widget build(BuildContext context) {
    if (!loaded) {
      return Center(child: CircularProgressIndicator());
    }
    print(selectedMap);
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
              try {
                level = int.parse(value);
              } catch (e) {
                level = 0;
              }
              print(level);
            },
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.sizeOf(context).height / 144,
              vertical: MediaQuery.sizeOf(context).height / 72,
            ),
            decoration: BoxDecoration(
              color: colorController.getColor(3),
              borderRadius: BorderRadius.circular(
                MediaQuery.sizeOf(context).height / 72,
              ),
            ),
            child: Column(
              spacing: MediaQuery.sizeOf(context).height / 72,
              children: [
                Row(
                  children: [
                    Text(
                      "Class",
                      style: textStyleController.getTextStyle(5, 4),
                    ),
                    IconButton(
                      onPressed: () {
                        classesNum++;
                        selectedMap["class".toString() +
                                classesNum.toString()] =
                            selectedMap["class".toString() +
                                classesNum.toString()] ??
                            classData.keys.first;
                        setState(() {});
                      },
                      icon: Icon(Icons.add, color: colorController.getColor(4)),
                    ),
                  ],
                ),
                ...selectedMap.keys.toList().map((id) {
                  if (id.startsWith("class"))
                    return getChoiceSelector(
                      classData,
                      id,
                      "classes",
                      level: true,
                    );
                  return SizedBox.shrink();
                }),
              ],
            ),
          ),
          getChoiceSelector(speciesData, "species", "species"),
          getChoiceSelector(backgroundData, "backgrounds", "backgrounds"),
        ],
      ),
    );
  }

  Widget getChoiceSelector(
    Map<String, dynamic> options,
    String selectorId,
    String category, {
    bool level = false,
  }) {
    List<String> keys = options.keys.toList();
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.sizeOf(context).height / 144,
        vertical: 0,
      ),
      decoration: BoxDecoration(
        color: colorController.getColor(2),
        borderRadius: BorderRadius.circular(
          MediaQuery.sizeOf(context).height / 72,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () {
              selectedMap.remove(selectorId);
              setState(() {});
            },
            icon: Icon(Icons.cancel, color: colorController.getColor(4)),
          ),
          if (level)
            Flexible(
              flex: 1,
              child: TextFormField(
                maxLength: 2,
                validator: (value) {
                  return (int.parse(value ?? "0") <= 20 &&
                          int.parse(value ?? "0") > 0)
                      ? null
                      : "Level must be between 1 and 20";
                },
              ),
            ),

          Flexible(
            flex: 4,
            child: DropdownButtonFormField(
              icon: const SizedBox.shrink(),
              initialValue: selectedMap[selectorId],
              dropdownColor: colorController.getColor(3),
              decoration: InputDecoration(
                suffixIcon: null,
                filled: true,
                fillColor: Colors.transparent,
                border: InputBorder.none,
              ),
              items: keys.map((item) {
                String i = item;
                return DropdownMenuItem(
                  value: i,
                  child: Text(
                    options[item]["name"].toString(),
                    style: textStyleController.getTextStyle(6, 4),
                  ),
                );
              }).toList(),
              onChanged: (value) async {
                setState(() => selectedMap[selectorId] = value ?? "");
              },
            ),
          ),
          DescriptionWidget(
            options[selectedMap[selectorId]]["name"].toString(),
            buildInfoWidget(options[selectedMap[selectorId]]["json"]),
            category + "DescriptionStyle",
            clickWidget: Icon(
              Icons.open_in_new,
              color: colorController.getColor(4),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildInfoWidget(String item) {
    print(item);
    return FutureBuilder<dynamic>(
      future: JsonService.loadFromPath(item),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Text("Error loading data: ${snapshot.error}");
        }

        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final infoData = Map<String, dynamic>.from(snapshot.data as Map);
        return DescriptionColumnWidget(infoData, schemata);
      },
    );
  }
}

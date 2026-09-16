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
      selectedMap["classes"] = selectedMap["classes"] ?? [classData.keys.first];
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
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.all(
                  Radius.circular(MediaQuery.sizeOf(context).height / 72),
                ),
              ),
            ),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      "classes",
                      style: textStyleController.getTextStyle(5, 4),
                    ),
                    IconButton(
                      onPressed: () {
                        classesNum++;
                        selectedMap["classes"].add(classData.keys.first);
                        setState(() {});
                      },
                      icon: Icon(Icons.add, color: colorController.getColor(4)),
                    ),
                  ],
                ),
                SizedBox(height: MediaQuery.sizeOf(context).height / 72),
                ...selectedMap["classes"].map((id) {
                  int num = selectedMap["classes"].indexOf(id);
                  print(id + "=" + num.toString());
                  print(selectedMap["classes"][num]);
                  return Column(
                    children: [
                      getChoiceSelector(
                        classData,
                        (el) => el["classes"][num],
                        (el, val) => el["classes"][num] = val,
                        "classes",
                        additionalWidgets: [
                          IconButton(
                            onPressed: () {
                              selectedMap["classes"].remove(id);
                              setState(() {});
                            },
                            icon: Icon(
                              Icons.cancel,
                              color: colorController.getColor(4),
                            ),
                          ),
                          Flexible(
                            flex: 1,
                            child: TextFormField(
                              initialValue: "1",
                              maxLength: 2,
                              style: textStyleController.getTextStyle(6, 5),
                              textAlign: TextAlign.center,
                              textAlignVertical: TextAlignVertical.center,
                              validator: (value) {
                                return (int.parse(value ?? "0") <= 20 &&
                                        int.parse(value ?? "0") > 0)
                                    ? null
                                    : "Level must be between 1 and 20";
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: MediaQuery.sizeOf(context).height / 72),
                    ],
                  );
                }),
              ],
            ),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Species", style: textStyleController.getTextStyle(5, 4)),
                SizedBox(height: MediaQuery.sizeOf(context).height / 72),
                getChoiceSelector(
                  speciesData,
                  (el) => el["species"],
                  (el, val) => el["species"] = val,
                  "species",
                ),
              ],
            ),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Background",
                  style: textStyleController.getTextStyle(5, 4),
                ),
                SizedBox(height: MediaQuery.sizeOf(context).height / 72),
                getChoiceSelector(
                  backgroundData,
                  (el) => el["backgrounds"],
                  (el, val) => el["backgrounds"] = val,
                  "backgrounds",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget getChoiceSelector(
    Map<String, dynamic> options,
    dynamic Function(dynamic) selector,
    void Function(Map<String, dynamic>, dynamic) setter,
    String category, {
    List<Widget>? additionalWidgets = null,
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
          ...additionalWidgets ?? [],
          Flexible(
            flex: 4,
            child: DropdownButtonFormField(
              icon: const SizedBox.shrink(),
              initialValue: selector(selectedMap),
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
                setState(() => setter(selectedMap, value ?? ""));
              },
            ),
          ),
          DescriptionWidget(
            options[selector(selectedMap)]["name"].toString(),
            buildInfoWidget(options[selector(selectedMap)]["json"]),
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

  Widget getStartingEquipment(String path) {
    return FutureBuilder<dynamic>(
      future: JsonService.loadFromPath(path),
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
        List<List<dynamic>> equipment =
            infoData["startingEquipment"] ?? (infoData["equipment"] ?? []);

        return RadioGroup(onChanged: (value) {}, child: Column());
      },
    );
  }
}

import 'package:dnd_app/services/text_style_service.dart';
import 'package:flutter/material.dart';

import 'package:dnd_app/services/settings_service.dart';
import 'package:dnd_app/services/color_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CategorySelectorWdget extends ConsumerStatefulWidget {
  final List<dynamic> categories;
  final String currentState;
  final Function(String) onCategorySelected;
  final double height;
  final int categoryNumber;

  const CategorySelectorWdget({
    super.key,
    required this.height,
    required this.categoryNumber,
    required this.categories,
    required this.currentState,
    required this.onCategorySelected,
  });

  @override
  ConsumerState<CategorySelectorWdget> createState() =>
      CategorySelectorWidgetState();
}

class CategorySelectorWidgetState extends ConsumerState<CategorySelectorWdget> {
  late final SettingsController settingsController;
  late final ColorController colorController;
  late final TextStyleController textStyleController;
  late List<GlobalKey> _itemKeys;

  @override
  void initState() {
    super.initState();

    settingsController = ref.read(settingsControllerProvider.notifier);
    colorController = ref.read(colorControllerProvider.notifier);
    textStyleController = ref.read(textStyleControllerProvider.notifier);
    _itemKeys = List.generate(widget.categories.length, (_) => GlobalKey());
  }

  @override
  void didUpdateWidget(covariant CategorySelectorWdget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.categories.length != widget.categories.length) {
      _itemKeys = List.generate(widget.categories.length, (_) => GlobalKey());
    }
  }

  void focusCategory(String category) {
    final index = widget.categories.indexOf(category);

    if (index != -1) {
      Scrollable.ensureVisible(
        _itemKeys[index].currentContext!,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        alignment: 0.5,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemWidth = MediaQuery.of(context).size.width / widget.categoryNumber;
    if (widget.categories.isEmpty) {
      return SizedBox.shrink();
    }

    return Container(
      height: widget.height,
      child: Center(
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: widget.categories.length,
          itemBuilder: (BuildContext context, int index) {
            return Container(
              width: itemWidth,
              key: _itemKeys[index],
              child: Container(
                decoration: BoxDecoration(
                  border: widget.categories[index] == widget.currentState
                      ? Border(
                          bottom: BorderSide(
                            color: colorController.getColor(1),
                            width:
                                settingsController.getSetting("headerHeight") *
                                0.16 *
                                MediaQuery.sizeOf(context).height,
                          ),
                        )
                      : null,
                ),
                child: TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: colorController.getColor(4),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  onPressed: () => {
                    widget.onCategorySelected(widget.categories[index]),
                  },
                  child: Text(
                    widget.categories[index],
                    style: textStyleController.getTextStyle(4, 4),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

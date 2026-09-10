import 'package:dnd_app/services/color_service.dart';
import 'package:dnd_app/services/settings_service.dart';
import 'package:dnd_app/services/text_style_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SortingMenuWidget extends ConsumerStatefulWidget {
  final Future<void> Function(dynamic) function1;
  final Future<void> Function(dynamic) function2;
  final Future<void> Function(dynamic) function3;
  final int index;
  final List<String> sorts;
  final List<String>? subsort;

  const SortingMenuWidget(
    this.function1,
    this.function2,
    this.function3,
    this.index,
    this.sorts, {
    this.subsort,
    super.key,
  });

  @override
  ConsumerState<SortingMenuWidget> createState() => SortingMenuWidgetState();
}

class SortingMenuWidgetState extends ConsumerState<SortingMenuWidget> {
  late final SettingsController settingsController;
  late final ColorController colorController;
  late final TextStyleController textStyleController;

  final OverlayPortalController _controller = OverlayPortalController();
  final LayerLink _layerLink = LayerLink();

  final Object _groupId = Object();

  static const double _menuWidth = 240;

  @override
  void initState() {
    super.initState();

    settingsController = ref.read(settingsControllerProvider.notifier);
    colorController = ref.read(colorControllerProvider.notifier);
    textStyleController = ref.read(textStyleControllerProvider.notifier);
  }

  Future<void> _handleTap(String value) async {
    if (value == "group_yes") {
      await widget.function1(true);
    } else if (value == "group_no") {
      await widget.function1(false);
    } else if (value == "subsortAlphabetical") {
      await widget.function2(false);
    } else if (value == "subsortStandard") {
      await widget.function2(true);
    } else {
      await widget.function3(value);
    }
    setState(() {});
  }

  bool get isOpen => _controller.isShowing;

  void close() {
    _controller.hide();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: OverlayPortal(
        controller: _controller,
        overlayChildBuilder: (context) {
          return Stack(
            children: [
              CompositedTransformFollower(
                link: _layerLink,
                showWhenUnlinked: false,
                targetAnchor: Alignment.bottomRight,
                followerAnchor: Alignment.topRight,
                child: TapRegion(
                  groupId: _groupId,
                  onTapOutside: (_) => _controller.hide(),
                  child: Material(
                    elevation: 8,
                    color: colorController.getColor(2),
                    borderRadius: BorderRadius.circular(8),
                    clipBehavior: Clip.antiAlias,
                    child: SizedBox(
                      width: _menuWidth,
                      child: _buildMenuContent(),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
        child: TapRegion(
          groupId: _groupId,
          child: IconButton(
            icon: Icon(Icons.tune, color: colorController.getColor(4)),
            onPressed: _controller.toggle,
          ),
        ),
      ),
    );
  }

  Widget _buildMenuContent() {
    final currentSorting = settingsController.getSetting(
      "wikiSorting",
    )[widget.index];

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: double.infinity,
            color: colorController.getColor(1),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              "Sorting",
              style: textStyleController.getTextStyle(1, 4),
            ),
          ),
          Padding(
            padding: EdgeInsetsGeometry.directional(
              start: MediaQuery.sizeOf(context).height / 72,
            ),
            child: Text(
              style: textStyleController.getTextStyle(3, 4),
              "Grouping",
            ),
          ),
          _radioTile(
            label: "Yes",
            selected:
                settingsController.getSetting("wikiGrouping")[widget.index] ==
                "true",
            onTap: () => _handleTap("group_yes"),
          ),
          _radioTile(
            label: "No",
            selected:
                settingsController.getSetting("wikiGrouping")[widget.index] ==
                "false",
            onTap: () => _handleTap("group_no"),
          ),
          const Divider(height: 1),
          Padding(
            padding: EdgeInsetsGeometry.directional(
              start: MediaQuery.sizeOf(context).height / 72,
            ),
            child: Text(
              style: textStyleController.getTextStyle(3, 4),
              "Sort by",
            ),
          ),
          ...widget.sorts.map(
            (sort) => _radioTile(
              label: sort,
              selected: currentSorting == sort,
              onTap: () => _handleTap(sort),
            ),
          ),
          if (currentSorting == "primary" ||
              currentSorting == "featType" ||
              currentSorting == "source") ...[
            const Divider(height: 1),
            Padding(
              padding: EdgeInsetsGeometry.directional(
                start: MediaQuery.sizeOf(context).height / 72,
              ),
              child: Text(
                style: textStyleController.getTextStyle(3, 4),
                "Secondary sorting",
              ),
            ),
            _radioTile(
              label: "Alphabetical",
              selected:
                  settingsController.getSetting(currentSorting + "SubSort")
                      is! List,
              onTap: () => _handleTap("subsortAlphabetical"),
            ),
            _radioTile(
              label: "Standard",
              selected:
                  settingsController.getSetting(currentSorting + "SubSort")
                      is List,
              onTap: () => _handleTap("subsortStandard"),
            ),
          ],
          if (widget.subsort != null) ...[
            const Divider(height: 1),
            Padding(
              padding: EdgeInsetsGeometry.directional(
                start: MediaQuery.sizeOf(context).height / 72,
              ),
              child: Text(
                style: textStyleController.getTextStyle(3, 4),
                "Secondary sorting order",
              ),
            ),
            ...widget.subsort!.map(
              (value) => Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: (3 / 2) * MediaQuery.sizeOf(context).height / 72,
                  vertical: MediaQuery.sizeOf(context).height / 72,
                ),
                child: Text(
                  value,
                  style: textStyleController.getTextStyle(4, 4),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _radioTile({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: (3 / 2) * MediaQuery.sizeOf(context).height / 72,
          vertical: MediaQuery.sizeOf(context).height / 72,
        ),
        child: Row(
          children: [
            Icon(
              size: textStyleController.getFontSize(4),
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: colorController.getColor(4),
            ),
            SizedBox(width: MediaQuery.sizeOf(context).height / 72),
            Text(label, style: textStyleController.getTextStyle(4, 4)),
          ],
        ),
      ),
    );
  }
}

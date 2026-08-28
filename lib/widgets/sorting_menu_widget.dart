import 'package:dnd_app/services/color_service.dart';
import 'package:dnd_app/services/settings_service.dart';
import 'package:dnd_app/services/text_style_service.dart';
import 'package:flutter/material.dart';

class SortingMenuWidget extends StatefulWidget {
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
  State<SortingMenuWidget> createState() => _SortingMenuWidgetState();
}

class _SortingMenuWidgetState extends State<SortingMenuWidget> {
  final OverlayPortalController _controller = OverlayPortalController();
  final LayerLink _layerLink = LayerLink();

  final Object _groupId = Object();

  static const double _menuWidth = 240;

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
                    color: ColorService.getColor(2),
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
            icon: Icon(Icons.tune, color: ColorService.getColor(4)),
            onPressed: _controller.toggle,
          ),
        ),
      ),
    );
  }

  Widget _buildMenuContent() {
    final currentSorting = SettingsService.getSetting(
      "wikiSorting",
    )[widget.index];

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: double.infinity,
            color: ColorService.getColor(1),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text("Sorting", style: TextStyleService.getTextStyle(1, 4)),
          ),
          Text(style: TextStyleService.getTextStyle(3, 4), "Grouping"),
          _radioTile(
            label: "Yes",
            selected:
                SettingsService.getSetting("wikiGrouping")[widget.index] ==
                "true",
            onTap: () => _handleTap("group_yes"),
          ),
          _radioTile(
            label: "No",
            selected:
                SettingsService.getSetting("wikiGrouping")[widget.index] ==
                "false",
            onTap: () => _handleTap("group_no"),
          ),
          const Divider(height: 1),
          Text(style: TextStyleService.getTextStyle(3, 4), "Sort by"),
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
            Text(
              style: TextStyleService.getTextStyle(3, 4),
              "Secondary sorting",
            ),
            _radioTile(
              label: "Alphabetical",
              selected:
                  SettingsService.getSetting(currentSorting + "SubSort")
                      is! List,
              onTap: () => _handleTap("subsortAlphabetical"),
            ),
            _radioTile(
              label: "Standard",
              selected:
                  SettingsService.getSetting(currentSorting + "SubSort")
                      is List,
              onTap: () => _handleTap("subsortStandard"),
            ),
          ],
          if (widget.subsort != null) ...[
            const Divider(height: 1),
            Text(
              style: TextStyleService.getTextStyle(3, 4),
              "Secondary sorting order",
            ),
            ...widget.subsort!.map(
              (value) => Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Text(value, style: TextStyleService.getTextStyle(4, 4)),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: ColorService.getColor(4),
            ),
            const SizedBox(width: 8),
            Text(label, style: TextStyleService.getTextStyle(4, 4)),
          ],
        ),
      ),
    );
  }
}

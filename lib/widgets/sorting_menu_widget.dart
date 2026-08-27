import 'package:dnd_app/services/color_service.dart';
import 'package:dnd_app/services/settings_service.dart';
import 'package:dnd_app/services/text_style_service.dart';
import 'package:flutter/material.dart';

class SortingMenuWidget extends StatefulWidget {
  final Future<void> Function(dynamic) function1;
  final Future<void> Function(dynamic) function2;
  final Future<void> Function(dynamic) function3;
  final Future<void> Function(dynamic) function4;
  final Future<void> Function(dynamic) function5;

  final int index;
  final List<String> sorts;
  final List<String>? subsort;

  const SortingMenuWidget(
    this.function1,
    this.function2,
    this.function3,
    this.function4,
    this.function5,
    this.index,
    this.sorts, {
    this.subsort,
    super.key,
  });

  @override
  State<SortingMenuWidget> createState() => _SortingMenuWidgetState();
}

class _SortingMenuWidgetState extends State<SortingMenuWidget> {
  final GlobalKey _buttonKey = GlobalKey();

  OverlayEntry? _menuEntry;

  bool get isMenuOpen => _menuEntry != null;

  @override
  void dispose() {
    _closeMenu();
    super.dispose();
  }

  void _toggleMenu() {
    if (isMenuOpen) {
      _closeMenu();
    } else {
      _openMenu();
    }
  }

  void _openMenu() {
    final buttonContext = _buttonKey.currentContext;

    if (buttonContext == null) return;

    final RenderBox button = buttonContext.findRenderObject() as RenderBox;

    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    final Offset position = button.localToGlobal(
      Offset.zero,
      ancestor: overlay,
    );

    _menuEntry = OverlayEntry(
      builder: (overlayContext) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _closeMenu,
                child: const SizedBox.expand(),
              ),
            ),

            Positioned(
              top: position.dy + button.size.height,
              right: overlay.size.width - position.dx - button.size.width,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {},
                child: Material(
                  elevation: 8,
                  color: ColorService.getColor(3),
                  child: _buildMenu(),
                ),
              ),
            ),
          ],
        );
      },
    );

    Overlay.of(context).insert(_menuEntry!);
  }

  void _closeMenu() {
    _menuEntry?.remove();
    _menuEntry = null;
  }

  void _refreshMenu() {
    _menuEntry?.markNeedsBuild();
  }

  Widget _buildMenu() {
    final currentSorting = SettingsService.getSetting(
      "wikiSorting",
    )[widget.index];

    final grouping = SettingsService.getSetting("wikiGrouping")[widget.index];

    return SizedBox(
      width: 280,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 600),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 0, 0),
                child: Text(
                  "Sorting",
                  style: TextStyleService.getTextStyle(1, 4),
                ),
              ),
              const Divider(),
              _sectionTitle("Grouping"),
              _radioItem("Yes", grouping == "true", () async {
                await widget.function1(true);

                _refreshMenu();
              }),

              _radioItem("No", grouping == "false", () async {
                await widget.function2(false);

                _refreshMenu();
              }),

              const Divider(),

              _sectionTitle("Sort by"),

              ...widget.sorts.map(
                (sort) => _radioItem(sort, currentSorting == sort, () async {
                  await widget.function5(sort);

                  _refreshMenu();
                }),
              ),

              if (currentSorting == "primary" ||
                  currentSorting == "featType" ||
                  currentSorting == "source") ...[
                const Divider(),

                _sectionTitle("Secondary sorting"),

                _radioItem(
                  "Alphabetical",
                  SettingsService.getSetting(currentSorting + "SubSort")
                      is! List,
                  () async {
                    await widget.function3(false);

                    _refreshMenu();
                  },
                ),

                _radioItem(
                  "Standard",
                  SettingsService.getSetting(currentSorting + "SubSort")
                      is List,
                  () async {
                    await widget.function4(true);

                    _refreshMenu();
                  },
                ),
              ],

              if (widget.subsort != null) ...[
                const Divider(),

                _sectionTitle("Secondary sorting order"),

                ...widget.subsort!.map((value) {
                  return InkWell(
                    onTap: () {},
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      child: Text(
                        value,
                        style: TextStyleService.getTextStyle(4, 4),
                      ),
                    ),
                  );
                }),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Text(title, style: TextStyleService.getTextStyle(3, 4)),
    );
  }

  Widget _radioItem(
    String title,
    bool selected,
    Future<void> Function() onTap,
  ) {
    return InkWell(
      onTap: () async {
        await onTap();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: selected
                  ? ColorService.getColor(1)
                  : ColorService.getColor(4),
            ),

            const SizedBox(width: 8),

            Expanded(
              child: Text(title, style: TextStyleService.getTextStyle(4, 4)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      key: _buttonKey,
      icon: const Icon(Icons.tune),
      color: ColorService.getColor(4),
      onPressed: _toggleMenu,
    );
  }
}

import 'package:dnd_app/services/color_service.dart';
import 'package:dnd_app/services/string_service.dart';
import 'package:dnd_app/services/text_style_service.dart';
import 'package:flutter/material.dart';

class FilterMenuWidget extends StatefulWidget {
  final Map<String, dynamic> categoryData;
  final String currentCategory;
  final List<dynamic> filters;
  final Future<void> Function() function1;
  final Future<void> Function() load;

  const FilterMenuWidget(
    this.categoryData,
    this.currentCategory,
    this.filters,
    this.function1,
    this.load, {
    super.key,
  });

  @override
  State<FilterMenuWidget> createState() => FilterMenuWidgetState();
}

class FilterMenuWidgetState extends State<FilterMenuWidget> {
  final OverlayPortalController _mainController = OverlayPortalController();
  final LayerLink _mainLink = LayerLink();

  final Map<int, OverlayPortalController> _subControllers = {};
  final Map<int, LayerLink> _subLinks = {};

  final Object _groupId = Object();

  static const double _menuWidth = 280;

  bool get submenuOpen {
    bool flag = false;
    for (int i = 0; i < _subControllers.keys.toList().length; i++) {
      if (_subControllers[i]?.isShowing ?? false) {
        flag = true;
      }
    }
    return flag;
  }

  bool get menuOpen => _mainController.isShowing;

  void closeSubmenu() {
    for (int i = 0; i < _subControllers.keys.toList().length; i++) {
      _subControllers[i]?.hide();
    }
  }

  void closeMenu() {
    _mainController.hide();
  }

  OverlayPortalController _subControllerFor(int i) =>
      _subControllers.putIfAbsent(i, () => OverlayPortalController());
  LayerLink _subLinkFor(int i) => _subLinks.putIfAbsent(i, () => LayerLink());

  @override
  void didUpdateWidget(covariant FilterMenuWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentCategory != widget.currentCategory) {
      // filter identities per index are no longer valid for the new
      // category, so close everything rather than show stale options.
      for (final c in _subControllers.values) {
        if (c.isShowing) c.hide();
      }
      if (_mainController.isShowing) _mainController.hide();
    }
  }

  Future<void> _resetFilters() async {
    await widget.load();
    final refreshedFilters =
        widget.categoryData[widget.currentCategory]["filters"] as List<dynamic>;
    for (var i = 0; i < refreshedFilters.length; i++) {
      final availableOptions = refreshedFilters[i]["options"] as List<dynamic>;
      widget.filters[i]["options"] = List<dynamic>.from(availableOptions);
    }
    await widget.function1();
    setState(() {});
  }

  Future<void> _toggleOption(int i, dynamic option) async {
    setState(() {
      if (widget.filters[i]["options"].contains(option)) {
        widget.filters[i]["options"].remove(option);
      } else {
        widget.filters[i]["options"].add(option);
      }
    });
    await widget.function1();
  }

  void _closeSubmenusExcept(int? keep) {
    for (final entry in _subControllers.entries) {
      if (entry.key != keep && entry.value.isShowing) entry.value.hide();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _mainLink,
      child: OverlayPortal(
        controller: _mainController,
        overlayChildBuilder: (context) {
          return Stack(
            children: [
              CompositedTransformFollower(
                link: _mainLink,
                showWhenUnlinked: false,
                targetAnchor: Alignment.bottomRight,
                followerAnchor: Alignment.topRight,
                child: TapRegion(
                  groupId: _groupId,
                  onTapOutside: (_) {
                    _closeSubmenusExcept(null);
                    _mainController.hide();
                  },
                  child: Material(
                    elevation: 8,
                    color: ColorService.getColor(3),
                    borderRadius: BorderRadius.circular(8),
                    clipBehavior: Clip.antiAlias,
                    child: SizedBox(width: _menuWidth, child: _mainPanel()),
                  ),
                ),
              ),
            ],
          );
        },
        child: TapRegion(
          groupId: _groupId,
          child: IconButton(
            icon: const Icon(Icons.filter_alt),
            color: ColorService.getColor(4),
            onPressed: _mainController.toggle,
          ),
        ),
      ),
    );
  }

  Widget _mainPanel() {
    final filtersList =
        widget.categoryData[widget.currentCategory]["filters"] as List<dynamic>;

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
            child: Container(
              color: ColorService.getColor(1),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Filters", style: TextStyleService.getTextStyle(1, 4)),
                  IconButton(
                    icon: const Icon(Icons.rotate_left),
                    color: ColorService.getColor(4),
                    onPressed: _resetFilters,
                  ),
                ],
              ),
            ),
          ),
          ...List.generate(
            filtersList.length,
            (i) => _filterRow(i, filtersList),
          ),
        ],
      ),
    );
  }

  Widget _filterRow(int i, List<dynamic> filtersList) {
    return CompositedTransformTarget(
      key: ValueKey('filter_row_$i'),
      link: _subLinkFor(i),
      child: OverlayPortal(
        controller: _subControllerFor(i),
        overlayChildBuilder: (context) {
          final options = filtersList[i]["options"] as List<dynamic>;
          return Stack(
            children: [
              CompositedTransformFollower(
                link: _subLinkFor(i),
                showWhenUnlinked: false,
                // Anchored to open toward the left of the row, since the main
                // panel already hugs the right edge of the screen. Flip these
                // two Alignments if your layout needs it the other way.
                targetAnchor: Alignment.topLeft,
                followerAnchor: Alignment.topRight,
                child: TapRegion(
                  groupId: _groupId,
                  child: Material(
                    elevation: 8,
                    color: ColorService.getColor(3),
                    borderRadius: BorderRadius.circular(8),
                    clipBehavior: Clip.antiAlias,
                    // IntrinsicWidth sizes this panel to the widest row's
                    // natural width instead of a fixed width — the trade-off
                    // is that it can't sit inside a SingleChildScrollView
                    // (viewports can't report an intrinsic width), so a filter
                    // with a very large number of options will just make a
                    // very tall panel rather than a scrollable one.
                    child: IntrinsicWidth(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            width: double.infinity,
                            color: ColorService.getColor(1),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: Text(
                                StringService.titleFromKey(
                                  filtersList[i]["id"],
                                ),
                                style: TextStyleService.getTextStyle(3, 4),
                              ),
                            ),
                          ),
                          const Divider(height: 1),
                          ...options.map<Widget>((e) {
                            final bool isSelected = widget.filters[i]["options"]
                                .contains(e);
                            return InkWell(
                              onTap: () => _toggleOption(i, e),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Checkbox(
                                      value: isSelected,
                                      checkColor: ColorService.getColor(4),
                                      activeColor: ColorService.getColor(1),
                                      side: BorderSide(
                                        color: ColorService.getColor(4),
                                        width: 1.5,
                                      ),
                                      onChanged: (_) => _toggleOption(i, e),
                                    ),
                                    Text(
                                      e.toString(),
                                      style: TextStyleService.getTextStyle(
                                        4,
                                        4,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
        child: InkWell(
          onTap: () {
            _closeSubmenusExcept(i);
            _subControllerFor(i).toggle();
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (i != 0) const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      StringService.titleFromKey(filtersList[i]["id"]),
                      style: TextStyleService.getTextStyle(3, 4),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: ColorService.getColor(4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

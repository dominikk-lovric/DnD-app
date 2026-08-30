import 'package:dnd_app/services/color_service.dart';
import 'package:dnd_app/services/json_service.dart';
import 'package:dnd_app/services/settings_service.dart';
import 'package:dnd_app/services/string_service.dart';
import 'package:dnd_app/services/text_style_service.dart';
import 'package:flutter/material.dart';

class DescriptionStyleSelectorWidget extends StatefulWidget {
  String name;
  DescriptionStyleSelectorWidget(this.name, {super.key});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return DescriptionStyleSelectorWidgetState();
  }
}

class DescriptionStyleSelectorWidgetState
    extends State<DescriptionStyleSelectorWidget> {
  List<String> options = ["popUp", "expand", "page", "text", "sheet", "static"];

  final OverlayPortalController _controller = OverlayPortalController();
  final LayerLink _layerLink = LayerLink();

  final Object _groupId = Object();

  Future<void> handleTap(String name, setting) async {
    await SettingsService.setSetting(
      StringService.slugify(widget.name) + "descriptionStyle",
      setting,
    );
    print(SettingsService.getSetting(StringService.slugify(name)));
  }

  @override
  initState() {
    super.initState();
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
                targetAnchor: Alignment.bottomLeft,
                followerAnchor: Alignment.topRight,
                child: TapRegion(
                  groupId: _groupId,
                  onTapOutside: (_) => _controller.hide(),
                  child: Material(
                    elevation: 8,
                    color: ColorService.getColor(2),
                    borderRadius: BorderRadius.circular(8),
                    clipBehavior: Clip.antiAlias,
                    child: Container(child: _buildMenuContent()),
                  ),
                ),
              ),
            ],
          );
        },
        child: TapRegion(
          groupId: _groupId,
          child: GestureDetector(
            child: Text(StringService.titleFromKey(widget.name)),
            onTap: _controller.toggle,
          ),
        ),
      ),
    );
  }

  Widget _buildMenuContent() {
    if (SettingsService.getSetting(
          StringService.slugify(widget.name) + "descriptionStyle",
        ) ==
        null) {
      print("NULL");
    }
    String selected =
        SettingsService.getSetting(
          StringService.slugify(widget.name) + "descriptionStyle",
        ) ??
        SettingsService.getSetting("globalDescriptionStyle");
    print(
      StringService.slugify(widget.name) + "descriptionStyle" + " " + selected,
    );
    return IntrinsicWidth(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          ...options.map((el) {
            return GestureDetector(
              onTap: () async {
                print(
                  StringService.slugify(widget.name) +
                      "descriptionStyle" +
                      " " +
                      el.toString(),
                );
                await handleTap(
                  StringService.slugify(widget.name) + "descriptionStyle",
                  el.toString(),
                );
                _controller.hide();
              },
              child: Container(
                color: selected.toString() == el.toString()
                    ? ColorService.getColor(1)
                    : ColorService.getColor(3),
                child: Text(
                  el.toString(),
                  style: TextStyleService.getTextStyle(3, 4),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

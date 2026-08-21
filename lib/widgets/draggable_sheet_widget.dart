import 'package:dnd_app/services/color_service.dart';
import 'package:dnd_app/services/text_style_service.dart';
import 'package:flutter/material.dart';

class DraggableSheetWidget extends StatelessWidget {
  String title;
  Widget content;
  String? subtitle;
  int titleLevel;
  int subtitleLevel;
  int clickLevel;
  String clickTitle;
  Widget? clickWidget;
  Widget? titleWidget;
  DraggableSheetWidget(
    this.title,
    this.subtitle,
    this.content, {
    super.key,
    this.titleLevel = 3,
    this.subtitleLevel = 3,
    this.clickLevel = 1,
    this.clickTitle = "",
    this.clickWidget,
    this.titleWidget,
  });

  Widget getClickWidget() {
    return clickWidget ??
        Text(
          clickTitle == "" ? title : clickTitle,
          style: TextStyleService.getTextStyle(clickLevel, 4),
        );
  }

  Widget getTitleWidget() {
    return titleWidget ??
        Text(
          clickTitle == "" ? title : clickTitle,
          style: TextStyleService.getTextStyle(titleLevel, 4),
        );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final sheetController = DraggableScrollableController();

        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          enableDrag: false,
          useSafeArea: true,
          builder: (context) {
            return Stack(
              children: [
                DraggableScrollableSheet(
                  controller: sheetController,
                  maxChildSize: 1.0,
                  minChildSize: 0.25,
                  initialChildSize: 0.5,
                  snap: true,
                  snapSizes: const [0.25, 0.5, 1.0],
                  expand: true,
                  builder: (context, scrollController) {
                    return Container(
                      decoration: BoxDecoration(
                        color: ColorService.getColor(2),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(25),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onVerticalDragUpdate: (details) {
                              final screenHeight = MediaQuery.of(
                                context,
                              ).size.height;
                              final newSize =
                                  sheetController.size -
                                  details.delta.dy / screenHeight;
                              sheetController.jumpTo(newSize.clamp(0.25, 1.0));
                            },
                            onVerticalDragEnd: (details) {
                              const snapSizes = [0.25, 0.5, 1.0];
                              final current = sheetController.size;
                              final nearest = snapSizes.reduce(
                                (a, b) =>
                                    (a - current).abs() < (b - current).abs()
                                    ? a
                                    : b,
                              );
                              sheetController.animateTo(
                                nearest,
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeOut,
                              );
                            },
                            child: Column(
                              children: [
                                const SizedBox(height: 15),
                                Center(
                                  child: Container(
                                    width: 100,
                                    height: 3,
                                    decoration: BoxDecoration(
                                      color: ColorService.getColor(4),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 15),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [getTitleWidget()],
                                ),
                                const SizedBox(height: 10),
                                Divider(
                                  height: 1,
                                  color: ColorService.getColor(4),
                                  indent: 30,
                                  endIndent: 30,
                                ),
                              ],
                            ),
                          ),
                          if (subtitle != null)
                            Padding(
                              padding: EdgeInsetsGeometry.directional(
                                start: 30,
                                top: 15,
                              ),
                              child: Text(
                                subtitle.toString(),
                                style: TextStyleService.getTextStyle(
                                  subtitleLevel,
                                  4,
                                  Height: 0.8,
                                ),
                              ),
                            ),
                          Expanded(
                            child: SingleChildScrollView(
                              controller: scrollController,
                              child: Padding(
                                padding: EdgeInsetsGeometry.directional(
                                  start: 30,
                                  top: 10,
                                  end: 10,
                                ),
                                child: content,
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                        ],
                      ),
                    );
                  },
                ),

                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: sheetController,
                    builder: (context, _) {
                      double currentSize;
                      try {
                        currentSize = sheetController.size;
                      } catch (_) {
                        currentSize = 0.5;
                      }
                      final screenHeight = MediaQuery.of(context).size.height;
                      final emptyHeight = screenHeight * (1 - currentSize);
                      if (emptyHeight <= 0) return const SizedBox.shrink();
                      return Align(
                        alignment: Alignment.topCenter,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => Navigator.of(context).pop(),
                          child: SizedBox(
                            height: emptyHeight,
                            width: double.infinity,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
      child: getClickWidget(),
    );
  }
}

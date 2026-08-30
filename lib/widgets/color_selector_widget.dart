import 'package:dnd_app/services/color_service.dart';
import 'package:dnd_app/services/settings_service.dart';
import 'package:flutter/material.dart';

class ColorSelectorWidget extends StatefulWidget {
  int setting;
  final VoidCallback? onSaved;

  ColorSelectorWidget(this.setting, {super.key, this.onSaved});

  @override
  State<ColorSelectorWidget> createState() => _ColorSelectorWidget();
}

class _ColorSelectorWidget extends State<ColorSelectorWidget> {
  _ColorSelectorWidget();

  late final TextEditingController rController;
  late final TextEditingController gController;
  late final TextEditingController bController;

  late int INT32;
  late List<int> ARGB;

  @override
  void initState() {
    super.initState();
    INT32 = ColorService.getColor(widget.setting).toARGB32();
    ARGB = ColorService.fromARGB32(INT32);

    rController = TextEditingController(text: ARGB[1].toString());
    gController = TextEditingController(text: ARGB[2].toString());
    bController = TextEditingController(text: ARGB[3].toString());
  }

  @override
  void dispose() {
    rController.dispose();
    gController.dispose();
    bController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double height =
        (SettingsService.getSetting("listItemHeight") ?? 50.0) * 2;

    return AnimatedBuilder(
      animation: ColorService.themeNotifier,
      builder: (context, child) {
        return ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 350),
          child: Container(
            child: InputDecorator(
              decoration: InputDecoration(
                filled: true,
                fillColor: ColorService.getColor(3),
                labelText: ColorService.getColorNames()[widget.setting],
                labelStyle: TextStyle(color: ColorService.getColor(4)),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: ColorService.getColor(6),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Wrap(
                  spacing: 5,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: [
                    Container(
                      height: 60,
                      width: 60,
                      decoration: BoxDecoration(
                        color: Color.fromARGB(
                          ARGB[0],
                          ARGB[1],
                          ARGB[2],
                          ARGB[3],
                        ),
                        border: Border.all(color: Colors.white, width: 2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        colorInput(rController, "R", 1),
                        colorInput(gController, "G", 2),
                        colorInput(bController, "B", 3),
                      ],
                    ),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth < 350) {
                          return Wrap(
                            spacing: 5,
                            runSpacing: 10,
                            children: [ResetButtonWIdget(), SaveButtonWidget()],
                          );
                        }

                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          spacing: 10,
                          children: [ResetButtonWIdget(), SaveButtonWidget()],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget colorInput(TextEditingController controller, String label, int index) {
    return SizedBox(
      width: 60,
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        style: TextStyle(color: ColorService.getColor(4)),
        decoration: InputDecoration(
          filled: true,
          fillColor: ColorService.getColor(2),
          labelText: label,
          labelStyle: TextStyle(color: ColorService.getColor(4)),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: ColorService.getColor(6)),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: ColorService.getColor(4), width: 2),
          ),
        ),
        onChanged: (value) {
          final n = int.tryParse(value);
          if (n == null) {
            controller.text = "0";
            setState(() {
              ARGB[index] = 0;
            });
            return;
          }
          setState(() {
            ARGB[index] = n;
          });
        },
      ),
    );
  }

  Widget ResetButtonWIdget() {
    return TextButton(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.hovered)) {
            return ColorService.getColor(1);
          }
          return ColorService.getColor(0);
        }),
        foregroundColor: WidgetStateProperty.all(ColorService.getColor(4)),
      ),
      onPressed: () async {
        final color = ColorService.getBasicColor(widget.setting);
        ColorService.setColor(widget.setting, color);
        setState(() {
          ARGB = ColorService.fromARGB32(color.toARGB32());

          rController.text = ARGB[1].toString();
          gController.text = ARGB[2].toString();
          bController.text = ARGB[3].toString();
        });
      },
      child: Text("reset"),
    );
  }

  Widget SaveButtonWidget() {
    return TextButton(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.hovered)) {
            return ColorService.getColor(1);
          }
          return ColorService.getColor(0);
        }),
        foregroundColor: WidgetStateProperty.all(ColorService.getColor(4)),
      ),
      onPressed: () async {
        final color = Color.fromARGB(ARGB[0], ARGB[1], ARGB[2], ARGB[3]);

        ColorService.setColor(widget.setting, color);
      },
      child: const Text("Save"),
    );
  }
}
